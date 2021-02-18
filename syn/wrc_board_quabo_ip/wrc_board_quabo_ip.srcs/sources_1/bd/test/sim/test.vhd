--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
--Date        : Tue Apr 16 10:41:10 2019
--Host        : Wei-Berkeley running 64-bit Ubuntu 18.04.2 LTS
--Command     : generate_target test.bd
--Design      : test
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity test is
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of test : entity is "test,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=test,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=1,numReposBlks=1,numNonXlnxBlks=1,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of test : entity is "test.hwdef";
end test;

architecture STRUCTURE of test is
  component test_wrc_board_quabo_Light_0_0 is
  port (
    clk_20m_vcxo_i : in STD_LOGIC;
    clk_125m_gtx_n_i : in STD_LOGIC;
    clk_125m_gtx_p_i : in STD_LOGIC;
    plldac_sclk_o : out STD_LOGIC;
    plldac_din_o : out STD_LOGIC;
    pll25dac_cs_n_o : out STD_LOGIC;
    pll20dac_cs_n_o : out STD_LOGIC;
    sfp_txp_o : out STD_LOGIC;
    sfp_txn_o : out STD_LOGIC;
    sfp_rxp_i : in STD_LOGIC;
    sfp_rxn_i : in STD_LOGIC;
    sfp_mod_def0_i : in STD_LOGIC;
    sfp_mod_def1_b : inout STD_LOGIC;
    sfp_mod_def2_b : inout STD_LOGIC;
    sfp_rate_select_o : out STD_LOGIC;
    sfp_tx_fault_i : in STD_LOGIC;
    sfp_tx_disable_o : out STD_LOGIC;
    sfp_los_i : in STD_LOGIC;
    onewire_b : inout STD_LOGIC;
    uart_rxd_i : in STD_LOGIC;
    uart_txd_o : out STD_LOGIC;
    spi_ncs_o : out STD_LOGIC;
    spi_mosi_o : out STD_LOGIC;
    spi_miso_i : in STD_LOGIC;
    wrs_tx_data_i : in STD_LOGIC_VECTOR ( 31 downto 0 );
    wrs_tx_valid_i : in STD_LOGIC;
    wrs_tx_dreq_o : out STD_LOGIC;
    wrs_tx_last_i : in STD_LOGIC;
    wrs_tx_flush_i : in STD_LOGIC;
    mac_local_tx : in STD_LOGIC_VECTOR ( 47 downto 0 );
    mac_target_tx : in STD_LOGIC_VECTOR ( 47 downto 0 );
    ethertype_tx : in STD_LOGIC_VECTOR ( 15 downto 0 );
    qtag_ena_tx : in STD_LOGIC;
    qtag_vid_tx : in STD_LOGIC_VECTOR ( 11 downto 0 );
    qtag_prio_tx : in STD_LOGIC_VECTOR ( 2 downto 0 );
    wrs_rx_first_o : out STD_LOGIC;
    wrs_rx_last_o : out STD_LOGIC;
    wrs_rx_data_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
    wrs_rx_valid_o : out STD_LOGIC;
    wrs_rx_dreq_i : in STD_LOGIC;
    mac_local_rx : in STD_LOGIC_VECTOR ( 47 downto 0 );
    mac_remote_rx : in STD_LOGIC_VECTOR ( 47 downto 0 );
    ethertype_rx : in STD_LOGIC_VECTOR ( 15 downto 0 );
    accept_broadcasts_rx : in STD_LOGIC;
    filter_remote_rx : in STD_LOGIC;
    fixed_latency_rx : in STD_LOGIC_VECTOR ( 27 downto 0 );
    reset_i : in STD_LOGIC;
    clk_ext_10m_p_i : in STD_LOGIC;
    clk_ext_10m_n_i : in STD_LOGIC;
    pps_i : in STD_LOGIC;
    pps_o : out STD_LOGIC;
    clk_sys_o : out STD_LOGIC
  );
  end component test_wrc_board_quabo_Light_0_0;
  signal NLW_wrc_board_quabo_Light_0_clk_sys_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_onewire_b_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_pll20dac_cs_n_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_pll25dac_cs_n_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_plldac_din_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_plldac_sclk_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_pps_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_sfp_mod_def1_b_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_sfp_mod_def2_b_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_sfp_rate_select_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_sfp_tx_disable_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_sfp_txn_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_sfp_txp_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_spi_mosi_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_spi_ncs_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_uart_txd_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_wrs_rx_first_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_wrs_rx_last_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_wrs_rx_valid_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_wrs_tx_dreq_o_UNCONNECTED : STD_LOGIC;
  signal NLW_wrc_board_quabo_Light_0_wrs_rx_data_o_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
begin
wrc_board_quabo_Light_0: component test_wrc_board_quabo_Light_0_0
     port map (
      accept_broadcasts_rx => '0',
      clk_125m_gtx_n_i => '0',
      clk_125m_gtx_p_i => '0',
      clk_20m_vcxo_i => '0',
      clk_ext_10m_n_i => '0',
      clk_ext_10m_p_i => '0',
      clk_sys_o => NLW_wrc_board_quabo_Light_0_clk_sys_o_UNCONNECTED,
      ethertype_rx(15 downto 0) => B"0000000000000000",
      ethertype_tx(15 downto 0) => B"0000000000000000",
      filter_remote_rx => '0',
      fixed_latency_rx(27 downto 0) => B"0000000000000000000000000000",
      mac_local_rx(47 downto 0) => B"000000000000000000000000000000000000000000000000",
      mac_local_tx(47 downto 0) => B"000000000000000000000000000000000000000000000000",
      mac_remote_rx(47 downto 0) => B"000000000000000000000000000000000000000000000000",
      mac_target_tx(47 downto 0) => B"000000000000000000000000000000000000000000000000",
      onewire_b => NLW_wrc_board_quabo_Light_0_onewire_b_UNCONNECTED,
      pll20dac_cs_n_o => NLW_wrc_board_quabo_Light_0_pll20dac_cs_n_o_UNCONNECTED,
      pll25dac_cs_n_o => NLW_wrc_board_quabo_Light_0_pll25dac_cs_n_o_UNCONNECTED,
      plldac_din_o => NLW_wrc_board_quabo_Light_0_plldac_din_o_UNCONNECTED,
      plldac_sclk_o => NLW_wrc_board_quabo_Light_0_plldac_sclk_o_UNCONNECTED,
      pps_i => '0',
      pps_o => NLW_wrc_board_quabo_Light_0_pps_o_UNCONNECTED,
      qtag_ena_tx => '0',
      qtag_prio_tx(2 downto 0) => B"000",
      qtag_vid_tx(11 downto 0) => B"000000000000",
      reset_i => '0',
      sfp_los_i => '0',
      sfp_mod_def0_i => '0',
      sfp_mod_def1_b => NLW_wrc_board_quabo_Light_0_sfp_mod_def1_b_UNCONNECTED,
      sfp_mod_def2_b => NLW_wrc_board_quabo_Light_0_sfp_mod_def2_b_UNCONNECTED,
      sfp_rate_select_o => NLW_wrc_board_quabo_Light_0_sfp_rate_select_o_UNCONNECTED,
      sfp_rxn_i => '0',
      sfp_rxp_i => '0',
      sfp_tx_disable_o => NLW_wrc_board_quabo_Light_0_sfp_tx_disable_o_UNCONNECTED,
      sfp_tx_fault_i => '0',
      sfp_txn_o => NLW_wrc_board_quabo_Light_0_sfp_txn_o_UNCONNECTED,
      sfp_txp_o => NLW_wrc_board_quabo_Light_0_sfp_txp_o_UNCONNECTED,
      spi_miso_i => '0',
      spi_mosi_o => NLW_wrc_board_quabo_Light_0_spi_mosi_o_UNCONNECTED,
      spi_ncs_o => NLW_wrc_board_quabo_Light_0_spi_ncs_o_UNCONNECTED,
      uart_rxd_i => '0',
      uart_txd_o => NLW_wrc_board_quabo_Light_0_uart_txd_o_UNCONNECTED,
      wrs_rx_data_o(31 downto 0) => NLW_wrc_board_quabo_Light_0_wrs_rx_data_o_UNCONNECTED(31 downto 0),
      wrs_rx_dreq_i => '0',
      wrs_rx_first_o => NLW_wrc_board_quabo_Light_0_wrs_rx_first_o_UNCONNECTED,
      wrs_rx_last_o => NLW_wrc_board_quabo_Light_0_wrs_rx_last_o_UNCONNECTED,
      wrs_rx_valid_o => NLW_wrc_board_quabo_Light_0_wrs_rx_valid_o_UNCONNECTED,
      wrs_tx_data_i(31 downto 0) => B"00000000000000000000000000000000",
      wrs_tx_dreq_o => NLW_wrc_board_quabo_Light_0_wrs_tx_dreq_o_UNCONNECTED,
      wrs_tx_flush_i => '0',
      wrs_tx_last_i => '0',
      wrs_tx_valid_i => '0'
    );
end STRUCTURE;
