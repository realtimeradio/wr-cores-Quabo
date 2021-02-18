-------------------------------------------------------------------------------
-- Title      : Transmission Streamer
-- Project    : WR Streamers
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/WR_Streamers
-------------------------------------------------------------------------------
-- File       : xrx_streamer.vhd
-- Author     : Tomasz Wlostowski
-- Company    : CERN BE-CO-HT
-- Created    : 2012-11-02
-- Platform   : FPGA-generic
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description: A simple core demonstrating how to encapsulate a continuous
-- stream of data words into Ethernet frames, in a format that is accepted by
-- the White Rabbit PTP core. This core decodes Ethernet frames encoded by
-- xtx_streamer. More info in the documentation.
-------------------------------------------------------------------------------
-- Copyright (c) 2012-2017 CERN/BE-CO-HT
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
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wishbone_pkg.all;
use work.wr_fabric_pkg.all;
use work.gencores_pkg.all;
use work.genram_pkg.all;
use work.streamers_priv_pkg.all;
use work.streamers_pkg.all;
use work.delay_pkg.all;

entity xrx_streamer_light is
  
  generic (
    -- Width of the data words, must be multiple of 16 bits. This value set to this generic
    -- on the receviving device must be the same as the value of g_tx_data_width set on the
    -- transmitting node. The g_rx_data_width and g_tx_data_width can be set to different
    -- values in the same device (i.e. instantiation of xwr_transmission entity). It is the
    -- responsibility of a network designer to make sure these parameters are properly set 
    -- in the network.
    g_data_width        : integer := 32;

    -- Size of RX buffer, in data words.
    g_buffer_size       : integer := 256;

    -- DO NOT USE unless you know what you are doing
    -- legacy: the streamers that were initially used in Btrain did not check/insert 
    -- the escape code. This is justified if only one block of a known number of words is 
    -- sent/expected.
    g_escape_code_disable : boolean := FALSE;

    -- DO NOT USE unless you know what you are doing
    -- legacy: the streamers that were initially used in Btrain accepted only a fixed
    -- number of words, regardless of the frame content. If this generic is set to number
    -- other than zero, only a fixed number of words is accepted. 
    -- In combination with the g_escape_code_disable generic set to TRUE, the behaviour of
    -- the "Btrain streamers" can be recreated.
    g_expected_words_number : integer := 0
    );

  port (
    clk_sys_i : in std_logic;
    rst_n_i   : in std_logic;

    -- Endpoint/WRC interface 
    snk_i : in  t_wrf_sink_in;
    snk_o : out t_wrf_sink_out;

    ---------------------------------------------------------------------------
    -- WRC Timing interface, used for latency measurement
    -- Caution: uses clk_ref_i clock domain!
    ---------------------------------------------------------------------------

    -- White Rabbit reference clock
    clk_ref_i : in std_logic := '0';

    -- Time valid flag
    tm_time_valid_i : in std_logic := '0';

    -- TAI seconds
    tm_tai_i : in std_logic_vector(39 downto 0) := x"0000000000";

    -- Fractional part of the second (in clk_ref_i cycles)
    tm_cycles_i : in std_logic_vector(27 downto 0) := x"0000000";

    ---------------------------------------------------------------------------
    -- User interface
    ---------------------------------------------------------------------------

    -- 1 indicates the 1st word of the data block on rx_data_o.
    rx_first_p1_o         : out std_logic;
    -- 1 indicates the last word of the data block on rx_data_o.
    rx_last_p1_o          : out std_logic;
    -- Received data.
    rx_data_o          : out std_logic_vector(g_data_width-1 downto 0);
    -- 1 indicted that rx_data_o is outputting a valid data word.
    rx_valid_o         : out std_logic;
    -- Synchronous data request input: when 1, the streamer may output another
    -- data word in the subsequent clock cycle.
    rx_dreq_i          : in  std_logic;
    -- Lost output: 1 indicates that one or more frames or blocks have been lost
    -- (left for backward compatibility).
    rx_lost_p1_o          : out std_logic := '0';
    -- indicates that one or more blocks within frame are missing
    rx_lost_blocks_p1_o    :  out std_logic := '0';
    -- indicates that one or more frames are missing, the number of frames is provied
    rx_lost_frames_p1_o    :  out std_logic := '0';
    --number of lost frames, the 0xF...F means that counter overflew
    rx_lost_frames_cnt_o : out std_logic_vector(14 downto 0);
    -- Latency measurement output: indicates the transport latency (between the
    -- TX streamer in remote device and this streamer), in clk_ref_i clock cycles.
    rx_latency_o       : out std_logic_vector(27 downto 0);
    -- 1 when the latency on rx_latency_o is valid.
    rx_latency_valid_o : out std_logic;
    -- received 	streamer frame (counts all frames, corrupted and not)
    rx_frame_p1_o         : out std_logic;
    -- configuration
    rx_streamer_cfg_i     : in t_rx_streamer_cfg := c_rx_streamer_cfg_default
    );

end xrx_streamer_light;

architecture rtl of xrx_streamer_light is

  type t_rx_state is (IDLE, HEADER, PAYLOAD, LAST, EOF);

  signal fab, fsm_in : t_pipe;

  signal state : t_rx_state;
  
  signal ser_count : unsigned(7 downto 0);
  signal count  : unsigned(14 downto 0);


  signal pack_data, fifo_data : std_logic_vector(g_data_width-1 downto 0);

  signal fifo_drop, fifo_accept, fifo_dvalid : std_logic;
  signal fifo_sync, fifo_last, frames_lost                   : std_logic;
  signal fifo_dout, fifo_din                                 : std_logic_vector(g_data_width + 1 downto 0);

  signal pending_write, fab_dvalid_pre : std_logic;


  
  signal fab_dvalid_d0 : std_logic;
  
  -- fixed latency signals
  signal rx_dreq            : std_logic;
  
  
  constant c_fixed_latency_zero : unsigned(27 downto 0) := (others => '0');
  constant c_timestamper_delay  : unsigned(27 downto 0) := to_unsigned(12, 28); -- cycles
  
begin  -- rtl


  U_Fabric_Sink : xwb_fabric_sink
    port map (
      clk_i     => clk_sys_i,
      rst_n_i   => rst_n_i,
      snk_i     => snk_i,
      snk_o     => snk_o,
      addr_o    => fab.addr,
      data_o    => fab.data,
      dvalid_o  => fab_dvalid_pre,
      sof_o     => fab.sof,
      eof_o     => fab.eof,
      error_o   => fab.error,
      bytesel_o => fab.bytesel,
      dreq_i    => fab.dreq);

  fab.dvalid <= '1' when fab_dvalid_pre = '1' and fab.addr = c_WRF_DATA and fab.bytesel = '0' else '0';

  fsm_in.dvalid <= fab.dvalid;
  fsm_in.data   <= fab.data;
  fab.dreq      <= fsm_in.dreq;
--  fsm_in.eof <= fab.eof or fab.error;
  fsm_in.eof <= (not fsm_in.dvalid) and fab_dvalid_d0;
  fsm_in.sof <= fab.sof;

  gen_fab_addr_d0 : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
        if rst_n_i = '0' then
            fab_dvalid_d0 <= '0';
        else
            fab_dvalid_d0 <= fab.dvalid;
        end if;
   end if;
  end process;
  
        
    
  U_Output_FIFO : dropping_buffer
    generic map (
      g_size       => g_buffer_size,
      g_data_width => g_data_width + 2)
    port map (
      clk_i      => clk_sys_i,
      rst_n_i    => rst_n_i,
      d_i        => fifo_din,
      d_req_o    => fsm_in.dreq,
      d_drop_i   => fifo_drop,
      d_accept_i => fifo_accept,
      d_valid_i  => fifo_dvalid,
      d_o        => fifo_dout,
      d_valid_o  => rx_valid_o,
      d_req_i    => '1');

  fifo_din(g_data_width+1)          <= fifo_sync;
  fifo_din(g_data_width)            <= fifo_last; -- when word is 16 bits
  fifo_din(g_data_width-1 downto 0) <= fifo_data;

  rx_data_o  <= fifo_dout(g_data_width-1 downto 0);
  rx_first_p1_o <= fifo_dout(g_data_width+1);
  rx_last_p1_o  <= fifo_dout(g_data_width);

  -------------------------------------------------------------------------------------------
  -- end of fixed latency implementation
  -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  p_fsm : xrx_stream_l_fsm
  port map (
    clk_sys_i   =>  clk_sys_i,
    rst_n_i     =>  rst_n_i,
    data_i      =>  fsm_in.data,
    sof_i       =>  fsm_in.sof,
    eof_i       =>  fsm_in.eof,
    dvalid_i    =>  fsm_in.dvalid,
    data_o      =>  fifo_data,
    accept_o    =>  fifo_accept,
    drop_o      =>  fifo_drop,
    dvalid_o    =>  fifo_dvalid,
    last_o      =>  fifo_last,
    first_o     =>  fifo_sync,
    mac_local_cfg   =>  rx_streamer_cfg_i.mac_local,
    mac_remote_cfg  =>  rx_streamer_cfg_i.mac_remote,
    accept_broadcasts_cfg   =>  rx_streamer_cfg_i.accept_broadcasts,
    filter_remote_cfg   =>  rx_streamer_cfg_i.filter_remote
  );

  
  rx_lost_p1_o        <= '0';
  rx_lost_blocks_p1_o <= '0';
  rx_lost_frames_p1_o <= '0';
  rx_latency_o        <= (others => '0');
  rx_latency_valid_o  <= '0';

end rtl;
