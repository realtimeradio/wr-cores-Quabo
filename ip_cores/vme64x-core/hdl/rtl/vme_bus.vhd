--------------------------------------------------------------------------------
-- CERN (BE-CO-HT)
-- VME64x Core
-- http://www.ohwr.org/projects/vme64x-core
--------------------------------------------------------------------------------
--
-- unit name:     VME_bus
--
-- description:
--
--   This block acts as interface between the VMEbus and the CR/CSR space or
--   WB bus.
--
--------------------------------------------------------------------------------
-- GNU LESSER GENERAL PUBLIC LICENSE
--------------------------------------------------------------------------------
-- This source file is free software; you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by the
-- Free Software Foundation; either version 2.1 of the License, or (at your
-- option) any later version. This source is distributed in the hope that it
-- will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
-- of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU Lesser General Public License for more details. You should have
-- received a copy of the GNU Lesser General Public License along with this
-- source; if not, download it from http://www.gnu.org/licenses/lgpl-2.1.html
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vme64x_pkg.all;
use work.wishbone_pkg.all;

entity vme_bus is
  generic (
    g_CLOCK_PERIOD  : integer;
    g_WB_GRANULARITY  : t_wishbone_address_granularity
  );
  port (
    clk_i           : in  std_logic;
    rst_n_i         : in  std_logic;

    -- VME signals
    VME_AS_n_i      : in  std_logic;
    VME_LWORD_n_o   : out std_logic := '0';
    VME_LWORD_n_i   : in  std_logic;
    VME_RETRY_n_o   : out std_logic;
    VME_RETRY_OE_o  : out std_logic;
    VME_WRITE_n_i   : in  std_logic;
    VME_DS_n_i      : in  std_logic_vector(1 downto 0);
    VME_DTACK_n_o   : out std_logic;
    VME_DTACK_OE_o  : out std_logic;
    VME_BERR_n_o    : out std_logic;
    VME_ADDR_i      : in  std_logic_vector(31 downto 1);
    VME_ADDR_o      : out std_logic_vector(31 downto 1) := (others => '0');
    VME_ADDR_DIR_o  : out std_logic;
    VME_ADDR_OE_N_o : out std_logic;
    VME_DATA_i      : in  std_logic_vector(31 downto 0);
    VME_DATA_o      : out std_logic_vector(31 downto 0) := (others => '0');
    VME_DATA_DIR_o  : out std_logic;
    VME_DATA_OE_N_o : out std_logic;
    VME_AM_i        : in  std_logic_vector(5 downto 0);
    VME_IACKIN_n_i  : in  std_logic;
    VME_IACK_n_i    : in  std_logic;
    VME_IACKOUT_n_o : out std_logic;

    -- WB signals
    wb_stb_o        : out std_logic;
    wb_ack_i        : in  std_logic;
    wb_dat_o        : out std_logic_vector(31 downto 0);
    wb_dat_i        : in  std_logic_vector(31 downto 0);
    wb_adr_o        : out std_logic_vector(31 downto 0);
    wb_sel_o        : out std_logic_vector(3 downto 0);
    wb_we_o         : out std_logic;
    wb_cyc_o        : out std_logic;
    wb_err_i        : in  std_logic;
    wb_stall_i      : in  std_logic;

    -- Function decoder
    addr_decoder_i  : in  std_logic_vector(31 downto 1);
    addr_decoder_o  : out std_logic_vector(31 downto 1);
    decode_start_o  : out std_logic;
    decode_done_i   : in std_logic;
    am_o            : out std_logic_vector( 5 downto 0);
    decode_sel_i    : in  std_logic;

    -- CR/CSR space signals:
    cr_csr_addr_o   : out std_logic_vector(18 downto 2);
    cr_csr_data_i   : in  std_logic_vector( 7 downto 0);
    cr_csr_data_o   : out std_logic_vector( 7 downto 0);
    cr_csr_we_o     : out std_logic;
    module_enable_i : in  std_logic;
    bar_i           : in  std_logic_vector( 4 downto 0);

    -- Interrupts
    INT_Level_i     : in  std_logic_vector( 2 downto 0);
    INT_Vector_i    : in  std_logic_vector( 7 downto 0);
    irq_pending_i   : in  std_logic;
    irq_ack_o       : out std_logic
  );
end vme_bus;

architecture rtl of vme_bus is
  -- Local data
  signal s_locDataIn                : std_logic_vector(63 downto 0);
  signal s_locDataOut               : std_logic_vector(63 downto 0);

  -- VME latched signals
  signal s_ADDRlatched              : std_logic_vector(31 downto 1);
  signal s_LWORDlatched_n           : std_logic;
  signal s_DSlatched_n              : std_logic_vector(1 downto 0);
  signal s_AMlatched                : std_logic_vector(5 downto 0);
  signal s_WRITElatched_n           : std_logic;

  -- Address and data from the VME bus.  There are two registers so that the
  -- first one can be placed in the IOBs.
  signal s_vme_addr_reg             : std_logic_vector(31 downto 1);
  signal s_vme_data_reg             : std_logic_vector(31 downto 0);
  signal s_vme_lword_n_reg          : std_logic;
  signal s_vme_addr_dir             : std_logic;

  type t_addressingType is (
    A24,
    A24_BLT,
    A24_MBLT,
    CR_CSR,
    A16,
    A32,
    A32_BLT,
    A32_MBLT,
    AM_ERROR
  );

  type t_transferType is (
    SINGLE,
    BLT,
    MBLT,
    TFR_ERROR
  );

  -- Addressing type (depending on VME_AM_i)
  signal s_addressingType           : t_addressingType;
  signal s_transferType             : t_transferType;

  type t_mainFSMstates is (
    -- Wait until AS is asserted.
    IDLE,

    -- Reformat address according to AM.
    REFORMAT_ADDRESS,

    -- Decoding ADDR and AM (selecting card or conf).
    DECODE_ACCESS,

    -- Wait until DS is asserted.
    WAIT_FOR_DS,

    -- Wait until DS is stable (and asserted).
    LATCH_DS,

    -- Decode DS, generate WB request
    CHECK_TRANSFER_TYPE,

    -- Wait for WB reply
    MEMORY_REQ,

    -- For read cycle, put data on the bus
    DATA_TO_BUS,

    -- Assert DTACK
    DTACK_LOW,

    -- Increment address for block transfers
    INCREMENT_ADDR,

    -- Check if IACK is for this slave
    IRQ_CHECK,

    -- Pass IACKIN to IACKOUT
    IRQ_PASS,

    --  Wait until AS is deasserted
    WAIT_END
  );

  -- Main FSM signals
  signal s_mainFSMstate             : t_mainFSMstates;
  signal s_conf_req                 : std_logic;   -- Global memory request
  signal s_dataPhase                : std_logic;   -- for MBLT
  signal s_MBLT_Data                : std_logic;   -- for MBLT: '1' in Addr

  -- Access decode signals
  signal s_conf_sel                 : std_logic;   -- CR or CSR is addressed
  signal s_card_sel                 : std_logic;   -- WB memory is addressed
  signal s_irq_sel                  : std_logic;   -- IACK transaction

  signal s_err                      : std_logic;

  -- Calculate the number of LATCH DS states necessary to match the timing
  -- rule 2.39 page 113 VMEbus specification ANSI/IEEE STD1014-1987.
  -- (max skew for the slave is 20 ns)
  constant c_num_latchDS            : natural range 1 to 8 :=
    (20 + g_CLOCK_PERIOD - 1) / g_CLOCK_PERIOD;

  signal s_DS_latch_count           : unsigned (2 downto 0);
begin
  -- These output signals are connected to the buffers on the board
  -- SN74VMEH22501A Function table:  (A is fpga, B is VME connector)
  --   OEn | DIR | OUTPUT                 OEAB   |   OEBYn   |   OUTPUT
  --    H  |  X  |   Z                      L    |     H     |     Z
  --    L  |  H  | A to B                   H    |     H     |   A to B
  --    L  |  L  | B to A                   L    |     L     |   B to Y
  --                                        H    |     L     |A to B, B to Y |

  VME_DATA_OE_N_o <= '0'; -- Driven IFF DIR = 1
  VME_ADDR_OE_N_o <= '0'; -- Driven IFF DIR = 1

  ------------------------------------------------------------------------------
  -- Access Mode Decoders
  ------------------------------------------------------------------------------
  -- Type of data transfer decoder
  -- VME64 ANSI/VITA 1-1994...Table 2-2 "Signal levels during data transfers"

  -- Bytes position on VMEbus:
  --
  -- A24-31 | A16-23 | A08-15 | A00-07 | D24-31 | D16-23 | D08-15 | D00-07
  --        |        |        |        |        |        | BYTE 0 |
  --        |        |        |        |        |        |        | BYTE 1
  --        |        |        |        |        |        | BYTE 2 |
  --        |        |        |        |        |        |        | BYTE 3
  --        |        |        |        |        |        | BYTE 0 | BYTE 1
  --        |        |        |        |        |        | BYTE 2 | BYTE 3
  --        |        |        |        | BYTE 0 | BYTE 1 | BYTE 2 | BYTE 3
  -- BYTE 0 | BYTE 1 | BYTE 2 | BYTE 3 | BYTE 4 | BYTE 5 | BYTE 6 | BYTE 7

  -- Address modifier decoder
  -- Both the supervisor and the user access modes are supported
  with s_AMlatched select s_addressingType <=
    A24      when c_AM_A24_S_SUP | c_AM_A24_S,
    A24_BLT  when c_AM_A24_BLT | c_AM_A24_BLT_SUP,
    A24_MBLT when c_AM_A24_MBLT | c_AM_A24_MBLT_SUP,
    CR_CSR   when c_AM_CR_CSR,
    A16      when c_AM_A16 | c_AM_A16_SUP,
    A32      when c_AM_A32 | c_AM_A32_SUP,
    A32_BLT  when c_AM_A32_BLT | c_AM_A32_BLT_SUP,
    A32_MBLT when c_AM_A32_MBLT | c_AM_A32_MBLT_SUP,
    AM_ERROR when others;

  -- Transfer type decoder
  with s_addressingType select s_transferType <=
    SINGLE    when A24 | CR_CSR | A16 | A32,
    BLT       when A24_BLT | A32_BLT,
    MBLT      when A24_MBLT | A32_MBLT,
    TFR_ERROR when others;

  ------------------------------------------------------------------------------
  -- MAIN FSM
  ------------------------------------------------------------------------------
  p_VMEmainFSM : process (clk_i) is
    variable addr_word_incr : natural range 0 to 7;
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' or VME_AS_n_i = '1' then
        -- FSM reset after power up,
        -- software reset, manually reset,
        -- on rising edge of AS.
        s_conf_req       <= '0';
        decode_start_o   <= '0';

        -- VME
        VME_DTACK_OE_o   <= '0';
        VME_DTACK_n_o    <= '1';
        VME_DATA_DIR_o   <= '0';
        VME_ADDR_DIR_o   <= '0';
        VME_BERR_n_o     <= '1';
        VME_ADDR_o       <= (others => '0');
        VME_LWORD_n_o    <= '1';
        VME_DATA_o       <= (others => '0');
        VME_IACKOUT_n_o  <= '1';
        s_dataPhase      <= '0';
        s_MBLT_Data      <= '0';
        s_mainFSMstate   <= IDLE;

        -- WB
        wb_sel_o         <= "0000";
        wb_cyc_o         <= '0';
        wb_stb_o         <= '0';
        s_err            <= '0';

        s_ADDRlatched    <= (others => '0');
        s_AMlatched      <= (others => '0');

        s_vme_addr_reg   <= (others => '0');
        s_vme_addr_dir   <= '0';

        s_card_sel <= '0';
        s_conf_sel <= '0';
        s_irq_sel  <= '0';
        irq_ack_o  <= '0';
      else
        s_conf_req       <= '0';
        decode_start_o   <= '0';
        VME_DTACK_OE_o   <= '0';
        VME_DTACK_n_o    <= '1';
        VME_DATA_DIR_o   <= '0';
        VME_ADDR_DIR_o   <= '0';
        VME_BERR_n_o     <= '1';
        VME_IACKOUT_n_o  <= '1';
        irq_ack_o        <= '0';

        case s_mainFSMstate is

          when IDLE =>
            -- Can only be here if VME_AS_n_i has fallen to 0, which starts a
            -- cycle.
            assert VME_AS_n_i = '0';

            -- Store ADDR, AM and LWORD
            s_ADDRlatched    <= VME_ADDR_i;
            s_LWORDlatched_n <= VME_LWORD_n_i;
            s_AMlatched      <= VME_AM_i;

            if VME_IACK_n_i = '1' then
              -- VITA-1 Rule 2.11
              -- Slaves MUST NOT respond to DTB cycles when IACK* is low.
              s_mainFSMstate <= REFORMAT_ADDRESS;
            else
              -- IACK cycle.
              s_mainFSMstate <= IRQ_CHECK;
            end if;

          when REFORMAT_ADDRESS =>
            -- Reformat address according to the mode (A16, A24, A32)
            -- FIXME: not needed if ADEM are correctly reduced to not compare
            -- MSBs of A16 or A24 addresses.
            s_vme_addr_reg <= s_ADDRlatched;
            case s_addressingType is
              when A16 =>
                s_vme_addr_reg (31 downto 16) <= (others => '0');  -- A16
              when A24 | A24_BLT | A24_MBLT =>
                s_vme_addr_reg (31 downto 24) <= (others => '0');  -- A24
              when others =>
                null;  -- A32
            end case;

            s_vme_lword_n_reg <= s_LWORDlatched_n;

            -- Address is not yet decoded.
            s_card_sel <= '0';
            s_conf_sel <= '0';
            s_irq_sel <= '0';

            --  DS latch counter
            s_DS_latch_count <= to_unsigned (c_num_latchDS, 3);

            --  VITA-1 Rule 2.6
            --  A Slave MUST NOT respond with a falling edge on DTACK* during
            --  an unaligned transfer cycle, if it does not have UAT
            --  capability.
            if s_LWORDlatched_n = '0' and s_ADDRlatched(1) = '1' then
              -- unaligned.
              s_mainFSMstate <= WAIT_END;
            else
              if s_ADDRlatched(23 downto 19) = bar_i
                and s_AMlatched = c_AM_CR_CSR
              then
                -- conf_sel = '1' it means CR/CSR space addressed
                s_conf_sel <= '1';
                s_mainFSMstate <= WAIT_FOR_DS;
              else
                s_mainFSMstate <= DECODE_ACCESS;
                decode_start_o  <= '1';
              end if;
            end if;

          when DECODE_ACCESS =>
            -- Check if this slave board is addressed.

            -- Wait for DS in parallel.
            if VME_DS_n_i /= "11" then
              s_WRITElatched_n <= VME_WRITE_n_i;
              if s_DS_latch_count /= 0 then
                s_DS_latch_count <= s_DS_latch_count - 1;
              end if;
            end if;

            if decode_done_i = '1' then
              if decode_sel_i = '1' and module_enable_i = '1' then
                -- card_sel = '1' it means WB application addressed
                s_card_sel <= '1';
                -- Keep only the local part of the address.
                s_vme_addr_reg <= addr_decoder_i;

                if VME_DS_n_i = "11" then
                  s_mainFSMstate <= WAIT_FOR_DS;
                else
                  s_mainFSMstate <= LATCH_DS;
                end if;
              else
                -- Another board will answer; wait here the rising edge on
                -- VME_AS_i (done by top if).
                s_mainFSMstate <= WAIT_END;
              end if;
            else
              -- Not yet decoded.
              s_mainFSMstate <= DECODE_ACCESS;
            end if;

          when WAIT_FOR_DS =>
            -- wait until DS /= "11"
            -- Note: before entering this state, s_DS_latch_count must be set.

            if VME_DS_n_i /= "11" then
              -- VITAL-1 Table 4-1
              -- For interrupts ack, the handler MUST NOT drive WRITE* low
              s_WRITElatched_n <= VME_WRITE_n_i;
              if s_DS_latch_count /= 0 then
                s_DS_latch_count <= s_DS_latch_count - 1;
              end if;
              s_mainFSMstate <= LATCH_DS;
            else
              s_mainFSMstate <= WAIT_FOR_DS;
            end if;

          when LATCH_DS =>
            -- This state is necessary indeed the VME master can assert the
            -- DS lines not at the same time.

            -- VITA-1 Rule 2.53a
            -- During all read cycles [...], the responding slave MUST NOT
            -- drive the D[] lines until DSA* goes low.
            VME_DATA_DIR_o   <= s_WRITElatched_n;
            VME_ADDR_DIR_o   <= '0';

            if s_transferType = MBLT then
              s_dataPhase <= '1';

              -- Start with D[31..0] when writing, but D[63..32] when reading.
              s_vme_addr_reg(2) <= not s_WRITElatched_n;
            else
              s_dataPhase <= '0';
            end if;

            if s_DS_latch_count = 0 or s_transferType = MBLT then
              if s_irq_sel = '1' then
                s_mainFSMstate <= DATA_TO_BUS;
              elsif s_transferType = MBLT and s_MBLT_Data = '0' then
                -- MBLT: ack address.
                -- (Data are also read but discarded).
                s_mainFSMstate <= DTACK_LOW;
              else
                s_mainFSMstate <= CHECK_TRANSFER_TYPE;
              end if;

              -- Read DS (which is delayed to avoid metastability).
              s_DSlatched_n  <= VME_DS_n_i;

              -- Read DATA (which are stable)
              s_locDataIn(63 downto 33) <= VME_ADDR_i;
              s_LWORDlatched_n          <= VME_LWORD_n_i;
              s_vme_data_reg            <= VME_DATA_i;
            else
              s_mainFSMstate   <= LATCH_DS;
              s_DS_latch_count <= s_DS_latch_count - 1;
            end if;

          when CHECK_TRANSFER_TYPE =>
            VME_DATA_DIR_o   <= s_WRITElatched_n;
            VME_ADDR_DIR_o   <= '0';
            s_dataPhase      <= s_dataPhase;

            --  VME_ADDR is an output during MBLT *read* data transfer.
            if s_transferType = MBLT and s_WRITElatched_n = '1' then
              s_vme_addr_dir  <= '1';
            else
              s_vme_addr_dir  <= '0';
            end if;

            s_locDataIn(32)          <= s_LWORDlatched_n;
            s_locDataIn(31 downto 0) <= s_vme_data_reg;
            if s_vme_lword_n_reg = '1' and s_vme_addr_reg(1) = '0' then
              -- Word/byte access with A1=0
              s_locDataIn(31 downto 16)  <= s_vme_data_reg(15 downto 0);
            end if;

            --  Translate DS+LWORD+ADDR to WB byte selects
            if s_vme_lword_n_reg = '0' then
              wb_sel_o <= "1111";
            else
              wb_sel_o <= "0000";
              case s_vme_addr_reg(1) is
                when '0' =>
                  wb_sel_o (3 downto 2) <= not s_DSlatched_n;
                when '1' =>
                  wb_sel_o (1 downto 0) <= not s_DSlatched_n;
                when others =>
                  null;
              end case;
            end if;

            --  VITA-1 Rule 2.6
            --  A Slave MUST NOT respond with a falling edge on DTACK* during
            --  an unaligned transfer cycle, if it does not have UAT
            --  capability.
            if s_vme_lword_n_reg = '0' and s_DSlatched_n /= "00" then
              -- unaligned.
              s_mainFSMstate <= WAIT_END;
            else
              s_mainFSMstate <= MEMORY_REQ;
              s_conf_req <= s_conf_sel;

              -- Start WB cycle.
              wb_cyc_o <= s_card_sel;
              wb_stb_o <= s_card_sel;
              s_err <= '0';
            end if;

          when MEMORY_REQ =>
            -- To request the memory CR/CSR or WB memory it is sufficient to
            -- generate a pulse on s_conf_req signal
            VME_DTACK_OE_o   <= '1';
            VME_DATA_DIR_o   <= s_WRITElatched_n;
            VME_ADDR_DIR_o   <= s_vme_addr_dir;

            -- Assert STB if stall was asserted.
            wb_stb_o <= s_card_sel and wb_stall_i;

            if s_conf_sel = '1'
              or (s_card_sel = '1' and (wb_ack_i = '1' or wb_err_i = '1'))
            then
              -- WB ack
              wb_stb_o <= '0';
              s_err <= s_card_sel and wb_err_i;
              if (s_card_sel and wb_err_i) = '1' then
                -- Error
                s_mainFSMstate <= DTACK_LOW;
              elsif s_WRITElatched_n = '0' then
                -- Write cycle.
                if s_dataPhase = '1' then
                  -- MBLT
                  s_dataPhase <= '0';
                  s_vme_addr_reg(2) <= '0';

                  s_locDataIn(31 downto 0) <= s_locDataIn(63 downto 32);

                  wb_stb_o <= s_card_sel;

                  s_mainFSMstate <= MEMORY_REQ;
                else
                  s_mainFSMstate <= DTACK_LOW;
                end if;
              else
                -- Read cycle

                -- Mux (CS-CSR or WB)
                s_locDataOut(63 downto 32) <= s_locDataOut(31 downto 0);
                s_locDataOut(31 downto 0) <= (others => '0');
                if s_card_sel = '1' then
                  if s_vme_lword_n_reg = '1' and s_vme_addr_reg(1) = '0' then
                    -- Word/byte access with A1 = 0
                    s_locDataOut(15 downto 0) <= wb_dat_i(31 downto 16);
                  else
                    s_locDataOut(31 downto 0) <= wb_dat_i;
                  end if;
                else
                  s_locDataOut(7 downto 0) <= cr_csr_data_i;
                end if;

                if s_dataPhase = '1' then
                  -- MBLT
                  s_dataPhase <= '0';
                  s_vme_addr_reg(2) <= '1';

                  wb_stb_o <= s_card_sel;

                  s_mainFSMstate <= MEMORY_REQ;
                else
                  s_mainFSMstate <= DATA_TO_BUS;
                end if;
              end if;
            else
              s_mainFSMstate <= MEMORY_REQ;
            end if;

          when DATA_TO_BUS =>
            VME_DTACK_OE_o   <= '1';
            VME_DATA_DIR_o   <= s_WRITElatched_n;
            VME_ADDR_DIR_o   <= s_vme_addr_dir;

            VME_ADDR_o    <= s_locDataOut(63 downto 33);
            VME_LWORD_n_o <= s_locDataOut(32);
            VME_DATA_o    <= s_locDataOut(31 downto 0);

            -- VITA-1 Rule 2.54a
            -- During all read cycles, the responding Slave MUST NOT drive
            -- DTACK* low before it drives D[].
            s_mainFSMstate   <= DTACK_LOW;

          when DTACK_LOW =>
            VME_DTACK_OE_o   <= '1';
            VME_DATA_DIR_o   <= s_WRITElatched_n;
            VME_ADDR_DIR_o   <= s_vme_addr_dir;

            --  Set DTACK (or retry or berr)
            if s_card_sel = '1' and s_err = '1' then
              VME_BERR_n_o  <= '0';
            else
              VME_DTACK_n_o <= '0';
            end if;

            -- VITA-1 Rule 2.57
            -- Once the responding Slave has driven DTACK* or BERR* low, it
            -- MUST NOT release them or drive DTACK* high until it detects
            -- both DS0* and DS1* high.
            if VME_DS_n_i = "11" then
              VME_DATA_DIR_o  <= '0';
              VME_BERR_n_o    <= '1';

              -- Rescind DTACK.
              VME_DTACK_n_o <= '1';

              --  DS latch counter
              s_DS_latch_count <= to_unsigned (c_num_latchDS, 3);

              if s_irq_sel = '1' then
                s_mainFSMstate <= WAIT_END;
              elsif s_transferType = SINGLE then
                --  Cycle should be finished, but allow another access at
                --  the same address (RMW).
                s_mainFSMstate <= WAIT_FOR_DS;
              else
                if s_transferType = MBLT and s_MBLT_Data = '0' then
                  -- MBLT: end of address phase.
                  s_mainFSMstate <= WAIT_FOR_DS;
                  s_MBLT_Data <= '1';
                else
                  -- Block
                  s_mainFSMstate <= INCREMENT_ADDR;
                end if;
              end if;
            else
              s_mainFSMstate <= DTACK_LOW;
            end if;

          when INCREMENT_ADDR =>
            VME_DTACK_OE_o   <= '1';
            VME_ADDR_DIR_o   <= s_vme_addr_dir;

            if s_vme_lword_n_reg = '0' then
              if s_transferType = MBLT then
                -- 64 bit
                addr_word_incr := 4;
              else
                -- 32 bit
                addr_word_incr := 2;
              end if;
            else
              if s_DSlatched_n (0) = '0' then
                -- Next word for D16 or D08(O)
                addr_word_incr := 1;
              else
                addr_word_incr := 0;
              end if;
            end if;
            -- Only increment within the window, don't check the limit.
            -- BLT  --> limit = 256 bytes  (rule 2.12a ANSI/VITA 1-1994)
            -- MBLT --> limit = 2048 bytes (rule 2.78  ANSI/VITA 1-1994)
            s_vme_addr_reg (11 downto 1) <= std_logic_vector
              (unsigned(s_vme_addr_reg (11 downto 1)) + addr_word_incr);
            s_mainFSMstate   <= WAIT_FOR_DS;

          when IRQ_CHECK =>
            if VME_IACKIN_n_i = '0' then
              if s_ADDRlatched(3 downto 1) = INT_Level_i
                and irq_pending_i = '1'
              then
                -- That's for us
                s_locDataOut <= (others => '0');
                s_locDataOut (7 downto 0) <= INT_Vector_i;
                s_irq_sel <= '1';
                irq_ack_o <= '1';

                s_mainFSMstate <= WAIT_FOR_DS;
              else
                -- Pass
                VME_IACKOUT_n_o <= '0';
                s_mainFSMstate <= IRQ_PASS;
              end if;
            else
              s_mainFSMstate <= IRQ_CHECK;
            end if;

          when IRQ_PASS =>
            -- Will stay here until AS is released.
            VME_IACKOUT_n_o <= '0';
            s_mainFSMstate <= IRQ_PASS;

          when WAIT_END =>
            -- Will stay here until AS is released.
            s_mainFSMstate <= WAIT_END;

          when others =>
            -- No-op, wait until AS is released.
            s_mainFSMstate <= WAIT_END;

        end case;
      end if;
    end if;
  end process;

  -- Retry is not supported
  VME_RETRY_n_o  <= '1';
  VME_RETRY_OE_o <= '0';

  -- WB Master
  with g_WB_GRANULARITY select
    wb_adr_o <= "00" & s_vme_addr_reg(31 downto 2) when WORD,
                 s_vme_addr_reg(31 downto 2) & "00" when BYTE;
  wb_we_o <= not s_WRITElatched_n;
  wb_dat_o <= s_locDataIn(31 downto 0);

  -- Function Decoder
  addr_decoder_o <= s_vme_addr_reg;
  am_o           <= s_AMlatched;

  -- CR/CSR In/Out
  cr_csr_data_o  <= s_locDataIn(7 downto 0);
  cr_csr_addr_o  <= s_vme_addr_reg(18 downto 2);
  cr_csr_we_o    <= '1' when s_conf_req = '1' and
                             s_WRITElatched_n = '0'
                             else '0';
end rtl;
