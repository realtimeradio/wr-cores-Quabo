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
  signal seq_no, seq_new,count  : unsigned(14 downto 0);


  signal is_escape : std_logic;
  signal rx_pending                : std_logic;

  signal pack_data, fifo_data : std_logic_vector(g_data_width-1 downto 0);

  signal fifo_drop, fifo_accept, fifo_accept_d0, fifo_dvalid : std_logic;
  signal fifo_sync, fifo_last, frames_lost, blocks_lost      : std_logic;
  signal fifo_dout, fifo_din                                 : std_logic_vector(g_data_width + 1 downto 0);

  signal pending_write, fab_dvalid_pre : std_logic;



  signal got_next_subframe : std_logic;
  signal is_frame_seq_id : std_logic;
  signal sync_seq_no : std_logic;
  
  signal fab_dvalid_d0 : std_logic;
  
  -- fixed latency signals
  type   t_rx_delay_state is (DISABLED, DELAY, ALLOW);
  signal timestamped        : std_logic;
  signal delay_cnt          : unsigned(27 downto 0);
  signal rx_dreq_allow      : std_logic;
  signal rx_latency         : unsigned(27 downto 0);
  signal rx_latency_stored  : unsigned(27 downto 0);
  signal rx_latency_valid   : std_logic;
  signal delay_state        : t_rx_delay_state;
  signal rx_dreq            : std_logic;
  signal is_vlan            : std_logic;
  
  signal fsm_in_data_d6     : std_logic_vector (15 downto 0);
  signal fsm_in_valid_d6    : std_logic;
  signal fsm_in_eof_d6      : std_logic;
  
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
  is_escape     <= '0';
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
  


  U_delay_six_cyc : delay_six_cyc
    port map(
        clk_sys_i   =>  clk_sys_i,
        rst_n_i     =>  rst_n_i,
        data_i      =>  fsm_in.data,
        valid_i     =>  fsm_in.dvalid,
        eof_i       =>  fsm_in.eof,
        data_o      =>  fsm_in_data_d6,
        valid_o     =>  fsm_in_valid_d6,
        eof_o       =>  fsm_in_eof_d6);
        
    
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
      d_accept_i => fifo_accept_d0,
      d_valid_i  => fifo_dvalid,
      d_o        => fifo_dout,
      d_valid_o  => rx_valid_o,
      d_req_i    => rx_dreq);

  fifo_din(g_data_width+1)          <= fifo_sync;
  fifo_din(g_data_width)            <= fifo_last or 
                                        ((not pending_write) and is_escape); -- when word is 16 bits
  fifo_din(g_data_width-1 downto 0) <= fifo_data;

  rx_data_o  <= fifo_dout(g_data_width-1 downto 0);
  rx_first_p1_o <= fifo_dout(g_data_width+1);
  rx_last_p1_o  <= fifo_dout(g_data_width);

  -------------------------------------------------------------------------------------------
  -- end of fixed latency implementation
  -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  p_fsm : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if rst_n_i = '0' then
        state                  <= IDLE;
        count                  <= (others => '0');
        seq_no                 <= (others => '1');
        fifo_accept            <= '0';
        fifo_drop              <= '0';
        fifo_dvalid            <= '0';
        pending_write          <= '0';
        got_next_subframe      <= '0';
        fifo_sync              <= '0';
        fifo_last              <= '0';
        ser_count              <= (others => '0');
        sync_seq_no            <= '1';
        rx_frame_p1_o          <= '0';
        rx_lost_frames_cnt_o   <= (others => '0');
        frames_lost            <= '0';
        rx_latency             <= (others=>'0');
        rx_latency_valid       <= '0';
        blocks_lost            <= '0';
        pack_data              <= (others=>'0');
        is_vlan                <= '0';
      else
        case state is
          when IDLE =>
            count              <= (others => '0');
            fifo_accept        <= '0';
            fifo_drop          <= '0';
            fifo_dvalid        <= '0';
            pending_write      <= '0';
            got_next_subframe  <='0';
            ser_count          <= (others => '0');
            fifo_sync          <='0';
            fifo_last          <= '0';
            rx_frame_p1_o      <= '0';
            rx_lost_frames_cnt_o <= (others => '0');
            frames_lost          <= '0';
            blocks_lost          <= '0';
            rx_latency           <= (others=>'0');
            rx_latency_valid     <= '0';
            is_vlan              <= '0';

            if(fsm_in.sof = '1') then
              state            <= HEADER;
            end if;

          when HEADER =>
            if(fsm_in.eof = '1') then
              state <= IDLE;
            elsif(fsm_in.dvalid = '1') then
              case count(7 downto 0) is
                when x"00" =>
                  if(fsm_in.data /= rx_streamer_cfg_i.mac_local(47 downto 32) nor (rx_streamer_cfg_i.accept_broadcasts = '1' and fsm_in.data /= x"ffff")) then
                    state <= IDLE;
                  end if;
                  count <= count + 1;
                when x"01" =>
                  if(fsm_in.data /= rx_streamer_cfg_i.mac_local(31 downto 16) nor (rx_streamer_cfg_i.accept_broadcasts = '1' and fsm_in.data /= x"ffff")) then
                    state <= IDLE;
                  end if;
                  count <= count + 1;
                when x"02" =>
                  if(fsm_in.data /= rx_streamer_cfg_i.mac_local(15 downto 0) nor (rx_streamer_cfg_i.accept_broadcasts = '1' and fsm_in.data /= x"ffff")) then
                    state <= IDLE;
                  end if;
                  count <= count + 1;
                when x"03" =>
                  if(fsm_in.data /= rx_streamer_cfg_i.mac_remote(47 downto 32) and rx_streamer_cfg_i.filter_remote ='1') then
                    state <= IDLE;
                  end if;
                  count <= count + 1;
                when x"04" =>
                  if(fsm_in.data /= rx_streamer_cfg_i.mac_remote(31 downto 16) and rx_streamer_cfg_i.filter_remote ='1') then
                    state <= IDLE;
                  end if;
                  count <= count + 1;
                when x"05" =>
                  if(fsm_in.data /= rx_streamer_cfg_i.mac_remote(15 downto 0) and rx_streamer_cfg_i.filter_remote ='1') then
                    state <= IDLE;
                  end if;
                  count <= count + 1;
                when x"06" =>
                  state                      <= PAYLOAD;
                  rx_frame_p1_o              <= '1';
                  fifo_drop                  <= '0';
                  fifo_accept                <= '0';
                  ser_count                  <= (others => '0');
                  
                  count <= count + 1;
                when others => null;
              end case;
            end if;

          when PAYLOAD =>
            if(fsm_in.eof = '1') then
              state       <= IDLE;
              fifo_drop   <= '1';
              fifo_accept <= '0';     
            elsif(fsm_in.dvalid = '1') then
                fifo_last   <= '0';
                fifo_accept <= '0';
                fifo_drop   <= '0';

                pack_data(to_integer(ser_count) * 16 + 15 downto to_integer(ser_count) * 16) <= fsm_in.data;
                
                if(ser_count = g_data_width/16 - 1) then
                  ser_count                                        <= (others => '0');

                  if (ser_count = x"00") then -- ML: the case when g_data_width == 16
                     fifo_data(g_data_width-1 downto 0)            <= pack_data(g_data_width-1 downto 0);
                     fifo_dvalid <= not is_escape;
                     pending_write <= '0';
                  else
                    ser_count                                        <= (others => '0');
                    fifo_data(g_data_width-16-1 downto 0)            <= pack_data(g_data_width-16-1 downto 0);
                    fifo_data(g_data_width-1 downto g_data_width-16) <= fsm_in.data;
                    fifo_dvalid                                      <= '0';
                    pending_write                                    <= '1';
                  end if;
                elsif(ser_count = g_data_width/16-2 and pending_write = '1') then
                  pending_write <= '0';
                  ser_count     <= ser_count + 1;
                  fifo_dvalid   <= '1';
                else
                  ser_count   <= ser_count + 1;
                  fifo_dvalid <= '0';
                end if;         
            else --of:  elsif(fsm_in.dvalid = '1') then
              state <= LAST;
              fifo_last <= '1';
              fifo_dvalid <= '1';
              if(pending_write = '0') then
                    fifo_data(g_data_width-1 downto g_data_width-16) <= (others => '0');
                    fifo_data(g_data_width-16-1 downto 0)            <= pack_data(g_data_width-16-1 downto 0);
              end if;
              
            end if;

            if(fifo_dvalid = '1') then
              fifo_accept <= '1';
              fifo_drop   <= '0';
            else
              fifo_accept <= '1';
              fifo_drop   <= '0';
            end if;
          
          when LAST =>
            state       <= EOF;
            fifo_last   <= '0';
            fifo_dvalid <= '0';
            fifo_accept <= '1';
            fifo_drop   <= '0';
           
          when EOF =>
            fifo_dvalid <= '0';
            fifo_drop   <= '0';
            fifo_accept <= '0';
            state       <= IDLE;
            
        end case;
      end if;
    end if;
  end process;

  p_delay_fifo_accept : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      fifo_accept_d0 <= fifo_accept;
    end if;
  end process;

  rx_lost_p1_o        <= frames_lost or blocks_lost;
  rx_lost_blocks_p1_o <= blocks_lost;
  rx_lost_frames_p1_o <= frames_lost;
  rx_latency_o        <= std_logic_vector(rx_latency);
  rx_latency_valid_o  <= rx_latency_valid;

end rtl;
