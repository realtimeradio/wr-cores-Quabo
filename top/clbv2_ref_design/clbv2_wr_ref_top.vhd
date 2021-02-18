-------------------------------------------------------------------------------
-- Title      : WRPC reference design for KM3NeT Central Logic Board (CLBv2)
--            : based on kintex-7
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : clbv2_wr_ref_top.vhd
-- Author(s)  : Peter Jansweijer <peterj@nikhef.nl>
-- Company    : Nikhef
-- Created    : 2017-11-08
-- Last update: 2017-11-08
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level file for the WRPC reference design on the CLBv2.
--
-- This is a reference top HDL that instanciates the WR PTP Core together with
-- its peripherals to be run on a CLB card.
--
-- There are two main usecases for this HDL file:
-- * let new users easily synthesize a WR PTP Core bitstream that can be run on
--   reference hardware
-- * provide a reference top HDL file showing how the WRPC can be instantiated
--   in HDL projects.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2017 Nikhef
-------------------------------------------------------------------------------
-- GNU LESSER GENERAL PUBLIC LICENSE
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;
use work.wr_board_pkg.all;
use work.wr_clbv2_pkg.all;
use work.wr_fabric_pkg.all;
--use work.gn4124_core_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity clbv2_wr_ref_top is
  generic (
--    g_dpram_initf : string := "../../bin/wrpc/wrc_phy16.bram";
	 g_dpram_initf : string := "../../bin/wrpc/wrc_no_vlan.bram";
    -- Simulation-mode enable parameter. Set by default (synthesis) to 0, and
    -- changed to non-zero in the instantiation of the top level DUT in the testbench.
    -- Its purpose is to reduce some internal counters/timeouts to speed up simulations.
    g_simulation : integer := 0
  );
  port (
    ---------------------------------------------------------------------------`
    -- Clocks/resets
    ---------------------------------------------------------------------------

    -- Local oscillators
    clk_20m_vcxo_i : in std_logic;                -- 20MHz VCXO clock

    clk_125m_gtx_n_i : in std_logic;              -- 125 MHz GTX reference
    clk_125m_gtx_p_i : in std_logic;

    ---------------------------------------------------------------------------
    -- SPI interface to DACs
    ---------------------------------------------------------------------------

    plldac_sclk_o     : out std_logic;
    plldac_din_o      : out std_logic;
    pll25dac_cs_n_o : out std_logic; --cs1
    pll20dac_cs_n_o : out std_logic; --cs2

    ---------------------------------------------------------------------------
    -- SFP I/O for transceiver
    ---------------------------------------------------------------------------

    sfp_txp_o         : out   std_logic;
    sfp_txn_o         : out   std_logic;
    sfp_rxp_i         : in    std_logic;
    sfp_rxn_i         : in    std_logic;
    sfp_mod_def0_i    : in    std_logic;          -- sfp detect
    sfp_mod_def1_b    : inout std_logic;          -- scl
    sfp_mod_def2_b    : inout std_logic;          -- sda
    sfp_rate_select_o : out   std_logic;
    sfp_tx_fault_i    : in    std_logic;
    sfp_tx_disable_o  : out   std_logic;
    sfp_los_i         : in    std_logic;

    ---------------------------------------------------------------------------
    -- Onewire interface
    ---------------------------------------------------------------------------

    onewire_b : inout std_logic;

    ---------------------------------------------------------------------------
    -- UART
    ---------------------------------------------------------------------------

    uart_rxd_i : in  std_logic;
    uart_txd_o : out std_logic;

    ---------------------------------------------------------------------------
    -- Flash memory SPI interface
    ---------------------------------------------------------------------------
--	 spi_sclk_o : out std_logic;
    spi_ncs_o  : out std_logic;
    spi_mosi_o : out std_logic;
    spi_miso_i : in  std_logic;
    ---------------------------------------------------------------------------
    -- Miscellanous CLBv2 pins
    ---------------------------------------------------------------------------
    -- Red LED next to the SFP: blinking indicates that packets are being
    -- transferred.
    led_act_o   : out std_logic;
    -- Green LED next to the SFP: indicates if the link is up.
    led_link_o  : out std_logic;

    reset_i     : in  std_logic;

    ---------------------------------------------------------------------------
    -- Digital I/O FMC Pins
    -- used in this design to output WR-aligned 1-PPS (in Slave mode) and input
    -- 10MHz & 1-PPS from external reference (in GrandMaster mode).
    ---------------------------------------------------------------------------

    -- Clock input from LEMO 5 on the mezzanine front panel. Used as 10MHz
    -- external reference input.
    dio_clk_p_i : in std_logic;
    dio_clk_n_i : in std_logic;

    -- Differential inputs, dio_p_i(N) inputs the current state of I/O (N+1) on
    -- the mezzanine front panel.
--    dio_n_i : in std_logic_vector(4 downto 0);
--    dio_p_i : in std_logic_vector(4 downto 0);

    -- Differential outputs. When the I/O (N+1) is configured as output (i.e. when
    -- dio_oe_n_o(N) = 0), the value of dio_p_o(N) determines the logic state
    -- of I/O (N+1) on the front panel of the mezzanine
--    dio_n_o : out std_logic_vector(4 downto 0);
--    dio_p_o : out std_logic_vector(4 downto 0);

    -- Output enable. When dio_oe_n_o(N) is 0, connector (N+1) on the front
    -- panel is configured as an output.
--    dio_oe_n_o    : out std_logic_vector(4 downto 0);

    -- Termination enable. When dio_term_en_o(N) is 1, connector (N+1) on the front
    -- panel is 50-ohm terminated
--    dio_term_en_o : out std_logic_vector(4 downto 0);

    -- Two LEDs on the mezzanine panel. Only Top one is currently used - to
    -- blink 1-PPS.
--    dio_led_top_o : out std_logic;
--    dio_led_bot_o : out std_logic;

    -- I2C interface for accessing FMC EEPROM. Deprecated, was used in
    -- pre-v3.0 releases to store WRPC configuration. Now we use Flash for this.
--    dio_scl_b : inout std_logic;
--    dio_sda_b : inout std_logic;
	 
	 pps_i	  : in	 std_logic;
	 pps_o	  : out   std_logic;
	 abscal_tx_o : out std_logic;
	 abscal_rx_o : out std_logic;
	 eeprom_scl_b : inout std_logic;
	 eeprom_sda_b : inout std_logic;
	 led_o :out std_logic;
	 clk_10m_sys_o : out std_logic

  );
end entity clbv2_wr_ref_top;

architecture top of clbv2_wr_ref_top is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------

  -- Number of masters on the wishbone crossbar
  constant c_NUM_WB_MASTERS : integer := 2;

  -- Number of slaves on the primary wishbone crossbar
  constant c_NUM_WB_SLAVES : integer := 1;

  -- Primary Wishbone master(s) offsets
  constant c_WB_MASTER_PCIE    : integer := 0;
  constant c_WB_MASTER_ETHBONE : integer := 1;

  -- Primary Wishbone slave(s) offsets
  constant c_WB_SLAVE_WRC : integer := 0;

  -- sdb header address on primary crossbar
  constant c_SDB_ADDRESS : t_wishbone_address := x"00040000";

  -- f_xwb_bridge_manual_sdb(size, sdb_addr)
  -- Note: sdb_addr is the sdb records address relative to the bridge base address
  constant c_wrc_bridge_sdb : t_sdb_bridge :=
    f_xwb_bridge_manual_sdb(x"0003ffff", x"00030000");

  -- Primary wishbone crossbar layout
  constant c_WB_LAYOUT : t_sdb_record_array(c_NUM_WB_SLAVES - 1 downto 0) := (
    c_WB_SLAVE_WRC => f_sdb_embed_bridge(c_wrc_bridge_sdb, x"00000000"));

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  -- clock and reset
  signal reset_n        : std_logic;
  signal clk_sys_62m5   : std_logic;
  signal rst_sys_62m5_n : std_logic;
  signal rst_ref_62m5_n : std_logic;
  signal clk_ref_62m5   : std_logic;
  signal clk_ref_div2   : std_logic;
  signal clk_ext_10m    : std_logic;

  -- I2C EEPROM
  signal eeprom_sda_in  : std_logic;
  signal eeprom_sda_out : std_logic;
  signal eeprom_scl_in  : std_logic;
  signal eeprom_scl_out : std_logic;

  -- SFP
  signal sfp_sda_in  : std_logic;
  signal sfp_sda_out : std_logic;
  signal sfp_scl_in  : std_logic;
  signal sfp_scl_out : std_logic;

  -- OneWire
  signal onewire_data : std_logic;
  signal onewire_oe   : std_logic;

  -- LEDs and GPIO
  signal wrc_abscal_txts_out : std_logic;
  signal wrc_abscal_rxts_out : std_logic;
  signal wrc_pps_out : std_logic;
  signal wrc_pps_led : std_logic;
  signal wrc_pps_in  : std_logic;
  signal svec_led    : std_logic_vector(15 downto 0);
  -- SPI PINs connected to STARTUP_VIRTEX6
--  signal spi_miso_i :std_logic;
  signal spi_sclk_o :std_logic;
  -- DIO Mezzanine
--  signal dio_in  : std_logic_vector(4 downto 0);
--  signal dio_out : std_logic_vector(4 downto 0);

begin  -- architecture top

  -----------------------------------------------------------------------------
  -- STARTUPE2 for using configuration flash
  -----------------------------------------------------------------------------
	STARTUPE2_FOR_QB : STARTUPE2
   generic map (
      PROG_USR => "FALSE",  -- Activate program event security feature. Requires encrypted bitstreams.
      SIM_CCLK_FREQ => 0.0  -- Set the Configuration Clock Frequency(ns) for simulation.
   )
   port map (
      CFGCLK => open,       -- 1-bit output: Configuration main clock output
      CFGMCLK => open,     -- 1-bit output: Configuration internal oscillator clock output
      EOS => open,             -- 1-bit output: Active high output signal indicating the End Of Startup.
      PREQ => open,           -- 1-bit output: PROGRAM request to fabric output
      CLK => '0',             -- 1-bit input: User start-up clock input
      GSR => '0',             -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
      GTS => '0',             -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
      KEYCLEARB => '0', -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
      PACK => '0',           -- 1-bit input: PROGRAM acknowledge input
      USRCCLKO => spi_sclk_o,   -- 1-bit input: User CCLK input
      USRCCLKTS => '0', -- 1-bit input: User CCLK 3-state enable input
      USRDONEO => '1',   -- 1-bit input: User DONE pin output control
      USRDONETS => '1'  -- 1-bit input: User DONE 3-state enable output
   );
  -----------------------------------------------------------------------------
  -- The WR PTP core board package (WB Slave + WB Master)
  -----------------------------------------------------------------------------
  
--  wrc_frabic_src_i <= wrc_frabic_snk_o;
--  wrc_frabic_snk_i <= wrc_frabic_src_o;
  reset_n <= not reset_i; -- Reset = high active on CLB
  
  cmp_xwrc_board_clbv2 : xwrc_board_clbv2
    generic map (
      g_simulation                => g_simulation,
      g_with_external_clock_input => TRUE,
      g_dpram_initf               => g_dpram_initf,
      g_fabric_iface              => PLAIN)
    port map (
      areset_n_i          => reset_n,
      clk_20m_vcxo_i      => clk_20m_vcxo_i,
      clk_125m_gtp_n_i    => clk_125m_gtx_n_i,
      clk_125m_gtp_p_i    => clk_125m_gtx_p_i,
      clk_10m_ext_i       => clk_ext_10m,
      clk_sys_62m5_o      => clk_sys_62m5,
      clk_ref_62m5_o      => clk_ref_62m5,
      rst_sys_62m5_n_o    => rst_sys_62m5_n,
      rst_ref_62m5_n_o    => rst_ref_62m5_n,

      plldac_sclk_o       => plldac_sclk_o,
      plldac_din_o        => plldac_din_o,
      pll25dac_cs_n_o     => pll25dac_cs_n_o,
      pll20dac_cs_n_o     => pll20dac_cs_n_o,

      sfp_txp_o           => sfp_txp_o,
      sfp_txn_o           => sfp_txn_o,
      sfp_rxp_i           => sfp_rxp_i,
      sfp_rxn_i           => sfp_rxn_i,
      sfp_det_i           => sfp_mod_def0_i,
      sfp_sda_i           => sfp_sda_in,
      sfp_sda_o           => sfp_sda_out,
      sfp_scl_i           => sfp_scl_in,
      sfp_scl_o           => sfp_scl_out,
      sfp_rate_select_o   => sfp_rate_select_o,
      sfp_tx_fault_i      => sfp_tx_fault_i,
      sfp_tx_disable_o    => sfp_tx_disable_o,
      sfp_los_i           => sfp_los_i,

      eeprom_sda_i        => eeprom_sda_in,
      eeprom_sda_o        => eeprom_sda_out,
      eeprom_scl_i        => eeprom_scl_in,
      eeprom_scl_o        => eeprom_scl_out,

      onewire_i           => onewire_data,
      onewire_oen_o       => onewire_oe,
      -- Uart
      uart_rxd_i          => uart_rxd_i,
      uart_txd_o          => uart_txd_o,
      -- flash
		spi_sclk_o			  => spi_sclk_o,
		spi_ncs_o  			  => spi_ncs_o,
		spi_mosi_o	 		  => spi_mosi_o,
		spi_miso_i			  => spi_miso_i,
		
      abscal_txts_o       => wrc_abscal_txts_out,
      abscal_rxts_o       => wrc_abscal_rxts_out,

      pps_ext_i           => wrc_pps_in,
      pps_p_o             => wrc_pps_out,
      pps_led_o           => wrc_pps_led,
      led_link_o          => led_link_o,
      led_act_o           => led_act_o,
		clk_10m_sys_o		  => clk_10m_sys_o);

  -- Tristates for SFP EEPROM
  sfp_mod_def1_b <= '0' when sfp_scl_out = '0' else 'Z';
  sfp_mod_def2_b <= '0' when sfp_sda_out = '0' else 'Z';
  sfp_scl_in     <= sfp_mod_def1_b;
  sfp_sda_in     <= sfp_mod_def2_b;

  -- tri-state onewire access
  onewire_b    <= '0' when (onewire_oe = '1') else 'Z';
  onewire_data <= onewire_b;

  ------------------------------------------------------------------------------
  -- Digital I/O FMC Mezzanine connections
  ------------------------------------------------------------------------------
--  gen_dio_iobufs: for I in 0 to 4 generate
--    U_ibuf: IBUFDS
--      generic map (
--        DIFF_TERM => true)
--      port map (
--        O  => dio_in(i),
--        I  => dio_p_i(i),
--        IB => dio_n_i(i));
--
--    U_obuf : OBUFDS
--      port map (
--        I  => dio_out(i),
--        O  => dio_p_o(i),
--        OB => dio_n_o(i));
--  end generate;
  -- Configure Digital I/Os 0 to 3 as outputs
--  dio_oe_n_o(2 downto 0) <= (others => '0');
  -- Configure Digital I/Os 3 and 4 as inputs for external reference
--  dio_oe_n_o(3)          <= '1';  -- for external 1-PPS
--  dio_oe_n_o(4)          <= '1';  -- for external 10MHz clock
  -- All DIO connectors are not terminated
--  dio_term_en_o          <= (others => '0');

  -- EEPROM I2C tri-states
--  dio_sda_b <= '0' when (eeprom_sda_out = '0') else 'Z';
--  eeprom_sda_in <= dio_sda_b;
  eeprom_sda_b <= '0' when (eeprom_sda_out = '0') else 'Z';
  eeprom_sda_in <= eeprom_sda_b;
--  dio_scl_b <= '0' when (eeprom_scl_out = '0') else 'Z';
--  eeprom_scl_in <= dio_scl_b;
  eeprom_scl_b <= '0' when (eeprom_scl_out = '0') else 'Z';
  eeprom_scl_in <= eeprom_scl_b;

  -- Div by 2 reference clock to LEMO connector
  process(clk_ref_62m5)
  begin
    if rising_edge(clk_ref_62m5) then
      clk_ref_div2 <= not clk_ref_div2;
    end if;
  end process;

  cmp_ibugds_extref: IBUFGDS
    generic map (
      DIFF_TERM => true)
    port map (
      O  => clk_ext_10m,
      I  => dio_clk_p_i,
      IB => dio_clk_n_i);


  wrc_pps_in    <= pps_i;
  pps_o    <= wrc_pps_out;
  abscal_rx_o    <= wrc_abscal_rxts_out;
  abscal_tx_o    <= wrc_abscal_txts_out;

  -- LEDs
  U_Extend_PPS : gc_extend_pulse
  generic map (
    g_width => 10000000)
  port map (
    clk_i      => clk_ref_62m5,
    rst_n_i    => rst_ref_62m5_n,
    pulse_i    => wrc_pps_led,
--    extended_o => dio_led_top_o);
	 extended_o => led_o);

--  dio_led_bot_o <= '0';

end architecture top;
