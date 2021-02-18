-------------------------------------------------------------------------------
-- Title      : WRPC reference design for KM3NeT Central Logic Board (QUABO)
--            : based on kintex-7
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : wrc_board_quabo.vhd
-- Author(s)  : Peter Jansweijer <peterj@nikhef.nl>
-- Modified by: Wei Liu
-- Company    : Nikhef
-- Created    : 2017-11-08
-- Last update: 2019-03-14
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level file for the WRPC reference design on the QUABO.
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
use work.wr_quabo_pkg.all;
use work.wr_fabric_pkg.all;
use work.streamers_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity wrc_board_quabo is
  generic (
--     g_dpram_initf : string := "../../bin/wrpc/wrc_phy16.bram";
    g_dpram_initf : string := "/home/wei/Desktop/wrc_phy16_no_arp_sdb.bram";
--	 g_dpram_initf : string := "../../bin/wrpc/wrc_no_vlan.bram";
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
    spi_sclk_o : out std_logic;
    spi_ncs_o  : out std_logic;
    spi_mosi_o : out std_logic;
    spi_miso_i : in  std_logic;
    ---------------------------------------------------------------------------
    -- WR streamers (when g_fabric_iface = "streamers")
    ---------------------------------------------------------------------------
   -- wrs_tx_data_i  : in  std_logic_vector(31 downto 0) ;
   -- wrs_tx_valid_i : in  std_logic;
   --wrs_tx_dreq_o  : out std_logic;
   --wrs_tx_last_i  : in  std_logic;
   --wrs_tx_flush_i : in  std_logic ;
   --mac_local_tx   : in  std_logic_vector(47 downto 0);
   --mac_target_tx  : in  std_logic_vector(47 downto 0);
   --ethertype_tx   : in  std_logic_vector(15 downto 0);
   --qtag_ena_tx    : in  std_logic;
   --qtag_vid_tx    : in  std_logic_vector(11 downto 0);
   --qtag_prio_tx   : in  std_logic_vector(2  downto 0);
   --wrs_rx_first_o : out std_logic;
   --wrs_rx_last_o  : out std_logic;
   --wrs_rx_data_o  : out std_logic_vector(31 downto 0);
   --wrs_rx_valid_o : out std_logic;
   --wrs_rx_dreq_i  : in  std_logic;
   --mac_local_rx   : in  std_logic_vector(47 downto 0);
   --mac_remote_rx  : in  std_logic_vector(47 downto 0);
   --ethertype_rx   : in  std_logic_vector(15 downto 0);
   --accept_broadcasts_rx: in std_logic;
   --filter_remote_rx: in  std_logic;
   --fixed_latency_rx: in  std_logic_vector(27 downto 0);
    ---------------------------------------------------------------------------
    -- Red LED next to the SFP: blinking indicates that packets are being
    -- transferred.
--    led_act_o   : out std_logic;
    -- Green LED next to the SFP: indicates if the link is up.
--    led_link_o  : out std_logic;

    reset_i     : in  std_logic;

    ---------------------------------------------------------------------------
    -- Digital I/O FMC Pins
    -- used in this design to output WR-aligned 1-PPS (in Slave mode) and input
    -- 10MHz & 1-PPS from external reference (in GrandMaster mode).
    ---------------------------------------------------------------------------

    -- Clock input from LEMO 5 on the mezzanine front panel. Used as 10MHz
    -- external reference input.
    --clk_ext_10m_p_i : in std_logic;
    --clk_ext_10m_n_i : in std_logic;
    clk_ext_10m : in std_logic;
--pps_i	  : in	 std_logic;
	pps_o	  : out   std_logic;
--	abscal_tx_o : out std_logic;
--	abscal_rx_o : out std_logic;
--	eeprom_scl_b : inout std_logic;
--	eeprom_sda_b : inout std_logic;
--	led_o :out std_logic;
--	clk_10m_sys_o : out std_logic;
	clk_sys_o : out std_logic

  );
end entity wrc_board_quabo;

architecture top of wrc_board_quabo is

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
  --signal clk_ext_10m    : std_logic;

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
--  signal spi_sclk_o :std_logic;
  -- DIO Mezzanine
--  signal dio_in  : std_logic_vector(4 downto 0);
--  signal dio_out : std_logic_vector(4 downto 0);
  signal wrs_tx_cfg_i: t_tx_streamer_cfg;
  signal wrs_rx_cfg_i: t_rx_streamer_cfg;
  --
  signal led_act_o : std_logic;
  signal led_link_o : std_logic;
  signal abscal_tx_o : std_logic;
  signal abscal_rx_o : std_logic;
  signal eeprom_scl_b : std_logic;
  signal eeprom_sda_b : std_logic;
  
  signal wrs_tx_data_i  :  std_logic_vector(31 downto 0) ;
  signal wrs_tx_valid_i :  std_logic;
  signal wrs_tx_dreq_o  :  std_logic;
  signal wrs_tx_last_i  :  std_logic;
  signal wrs_tx_flush_i :  std_logic ;
  signal mac_local_tx   :  std_logic_vector(47 downto 0);
  signal mac_target_tx  :  std_logic_vector(47 downto 0);
  signal ethertype_tx   :  std_logic_vector(15 downto 0);
  signal qtag_ena_tx    :  std_logic;
  signal qtag_vid_tx    :  std_logic_vector(11 downto 0);
  signal qtag_prio_tx   :  std_logic_vector(2  downto 0);
  signal wrs_rx_first_o :  std_logic;
  signal wrs_rx_last_o  :  std_logic;
  signal wrs_rx_data_o  :  std_logic_vector(31 downto 0);
  signal wrs_rx_valid_o :  std_logic;
  signal wrs_rx_dreq_i  :  std_logic;
  signal mac_local_rx   :  std_logic_vector(47 downto 0);
  signal mac_remote_rx  :  std_logic_vector(47 downto 0);
  signal ethertype_rx   :  std_logic_vector(15 downto 0);
  signal accept_broadcasts_rx: std_logic;
  signal filter_remote_rx:  std_logic;
  signal fixed_latency_rx:  std_logic_vector(27 downto 0);
  
  --signal clk_ext_10m_p_i :  std_logic;
  --signal clk_ext_10m_n_i :  std_logic;
  signal pps_i           :  std_logic;
begin  -- architecture top

  -----------------------------------------------------------------------------
  -- STARTUPE2 for using configuration flash
  -----------------------------------------------------------------------------
--	STARTUPE2_FOR_QB : STARTUPE2
--   generic map (
--      PROG_USR => "FALSE",  -- Activate program event security feature. Requires encrypted bitstreams.
--      SIM_CCLK_FREQ => 0.0  -- Set the Configuration Clock Frequency(ns) for simulation.
--   )
--   port map (
--      CFGCLK => open,       -- 1-bit output: Configuration main clock output
--      CFGMCLK => open,     -- 1-bit output: Configuration internal oscillator clock output
--      EOS => open,             -- 1-bit output: Active high output signal indicating the End Of Startup.
--      PREQ => open,           -- 1-bit output: PROGRAM request to fabric output
--      CLK => '0',             -- 1-bit input: User start-up clock input
--      GSR => '0',             -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
--      GTS => '0',             -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
--      KEYCLEARB => '0', -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
--      PACK => '0',           -- 1-bit input: PROGRAM acknowledge input
--      USRCCLKO => spi_sclk_o,   -- 1-bit input: User CCLK input
--     USRCCLKTS => '0', -- 1-bit input: User CCLK 3-state enable input
--      USRDONEO => '1',   -- 1-bit input: User DONE pin output control
--      USRDONETS => '1'  -- 1-bit input: User DONE 3-state enable output
--   );
  -----------------------------------------------------------------------------
  -- The WR PTP core board package (WB Slave + WB Master)
  -----------------------------------------------------------------------------
  pps_i          <= '0';
  wrs_tx_data_i  <= (31 downto 0 => '0');
  wrs_tx_valid_i <= '0';
  wrs_tx_last_i  <= '0';
  wrs_tx_flush_i <= '0';
  mac_local_tx   <= (47 downto 0 => '0');
  mac_target_tx  <= (47 downto 0 => '0');
  ethertype_tx   <= (15 downto 0 => '0');
  qtag_ena_tx    <= '0';
  qtag_vid_tx    <= (11 downto 0 => '0');
  qtag_prio_tx   <= (2 downto 0 => '0');
  wrs_rx_dreq_i  <= '0';
  mac_local_rx   <= (47 downto 0 => '0');
  mac_remote_rx  <= (47 downto 0 => '0');
  ethertype_rx   <= (15 downto 0 => '0');
  accept_broadcasts_rx<= '0';
  filter_remote_rx<= '0';
  fixed_latency_rx<= (27 downto 0 => '0');
  
  reset_n <= reset_i; -- Reset = low active on quabo
  wrs_tx_cfg_i.mac_local <= mac_local_tx;
  wrs_tx_cfg_i.mac_target<= mac_target_tx;
  wrs_tx_cfg_i.ethertype <= ethertype_tx;
  wrs_tx_cfg_i.qtag_ena <= qtag_ena_tx;
  wrs_tx_cfg_i.qtag_vid <= qtag_vid_tx;
  wrs_tx_cfg_i.qtag_prio <= qtag_prio_tx;
  
  wrs_rx_cfg_i.mac_local <= mac_local_rx;
  wrs_rx_cfg_i.mac_remote <= mac_remote_rx;
  wrs_rx_cfg_i.ethertype <= ethertype_rx;
  wrs_rx_cfg_i.accept_broadcasts <= accept_broadcasts_rx;
  wrs_rx_cfg_i.filter_remote <= filter_remote_rx;
  wrs_rx_cfg_i.fixed_latency <= fixed_latency_rx;
  cmp_xwrc_board_quabo : xwrc_board_quabo
    generic map (
      g_simulation                => g_simulation,
      g_with_external_clock_input => FALSE,   -- RR changed
      g_dpram_initf               => g_dpram_initf,
      g_fabric_iface              => STREAMERS)--PLAIN)
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
	  spi_sclk_o		  => spi_sclk_o,
	  spi_ncs_o  		  => spi_ncs_o,
	  spi_mosi_o	 	  => spi_mosi_o,
	  spi_miso_i		  => spi_miso_i,
	  --Streamers
	  wrs_tx_data_i        => wrs_tx_data_i,
      wrs_tx_valid_i       => wrs_tx_valid_i,
      wrs_tx_dreq_o        => wrs_tx_dreq_o,
      wrs_tx_last_i        => wrs_tx_last_i,
      wrs_tx_flush_i       => wrs_tx_flush_i,
      wrs_tx_cfg_i         => wrs_tx_cfg_i,
      wrs_rx_first_o       => wrs_rx_first_o,
      wrs_rx_last_o        => wrs_rx_last_o,
      wrs_rx_data_o        => wrs_rx_data_o,
      wrs_rx_valid_o       => wrs_rx_valid_o,
      wrs_rx_dreq_i        => wrs_rx_dreq_i,
      wrs_rx_cfg_i         => wrs_rx_cfg_i,
      
      abscal_txts_o       => wrc_abscal_txts_out,
      abscal_rxts_o       => wrc_abscal_rxts_out,

      pps_ext_i           => wrc_pps_in,
      pps_p_o             => wrc_pps_out,
      pps_led_o           => wrc_pps_led,
      led_link_o          => led_link_o,
      led_act_o           => led_act_o);
--	  clk_10m_sys_o		  => clk_10m_sys_o);
	  
 --  clk_sys_o <= clk_sys_62m5; RR changed
  clk_sys_o <= clk_ref_62m5; -- RR changed
  -- Tristates for SFP EEPROM
  sfp_mod_def1_b <= '0' when sfp_scl_out = '0' else 'Z';
  sfp_mod_def2_b <= '0' when sfp_sda_out = '0' else 'Z';
  sfp_scl_in     <= sfp_mod_def1_b;
  sfp_sda_in     <= sfp_mod_def2_b;

  -- tri-state onewire access
  onewire_b    <= '0' when (onewire_oe = '1') else 'Z';
  onewire_data <= onewire_b;


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

--  clk_ext_10m_p_i <= '1';
--  clk_ext_10m_n_i <= '0';
--  cmp_ibugds_extref: IBUFGDS
--    generic map (
--      DIFF_TERM => true)
--    port map (
--      O  => clk_ext_10m,
--      I  => clk_ext_10m_p_i,
--      IB => clk_ext_10m_n_i);


  wrc_pps_in    <= pps_i;
  pps_o    <= wrc_pps_out;
  abscal_rx_o    <= wrc_abscal_rxts_out;
  abscal_tx_o    <= wrc_abscal_txts_out;

--  -- LEDs
--  U_Extend_PPS : gc_extend_pulse
--  generic map (
--    g_width => 10000000)
--  port map (
--    clk_i      => clk_ref_62m5,
--    rst_n_i    => rst_ref_62m5_n,
--    pulse_i    => wrc_pps_led,
----    extended_o => dio_led_top_o);
--	 extended_o => led_o);

end architecture top;
