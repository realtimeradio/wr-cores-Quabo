----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2019 03:13:54 PM
-- Design Name: 
-- Module Name: xrx_stream_l_fsm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.delay_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity xrx_stream_l_fsm is
  Port ( 
  clk_sys_i     :   in  std_logic;
  rst_n_i       :   in  std_logic;
  data_i        :   in  std_logic_vector(15 downto 0);
  sof_i         :   in  std_logic;
  eof_i         :   in  std_logic;
  dvalid_i      :   in  std_logic;
  data_o        :   out std_logic_vector(31 downto 0);
  accept_o      :   out std_logic;
  drop_o        :   out std_logic;
  dvalid_o      :   out std_logic;
  last_o        :   out std_logic;
  first_o       :   out std_logic;
  
  mac_local_cfg :           in std_logic_vector(47 downto 0);
  mac_remote_cfg:           in std_logic_vector(47 downto 0);
  accept_broadcasts_cfg:    in std_logic;
  filter_remote_cfg :       in std_logic    
  );
end xrx_stream_l_fsm;

architecture Behavioral of xrx_stream_l_fsm is

  type t_rx_state is (IDLE, HEADER, PAYLOAD, LAST, EOF);
  
  signal state  :   t_rx_state;
  
  signal fsm_in_data_d6     : std_logic_vector(15 downto 0);
  signal fsm_in_dvalid_d6   : std_logic;
  signal fsm_in_eof_d6      : std_logic;
  
  signal count              : unsigned(7 downto 0);
  signal pending_write      : std_logic;
  signal pack_data          : std_logic_vector(31 downto 0);
  signal ser_count          : unsigned(1 downto 0);
  signal dvalid_tmp         : std_logic;

begin

 U_delay_six_cyc : delay_six_cyc
    port map(
        clk_sys_i   =>  clk_sys_i,
        rst_n_i     =>  rst_n_i,
        data_i      =>  data_i,
        valid_i     =>  dvalid_i,
        eof_i       =>  eof_i,
        data_o      =>  fsm_in_data_d6,
        valid_o     =>  fsm_in_dvalid_d6,
        eof_o       =>  fsm_in_eof_d6);
        
  p_fsm : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if rst_n_i = '0' then
        state                  <= IDLE;
        count                  <= (others => '0');
        accept_o               <= '0';
        drop_o                 <= '0';
        dvalid_o               <= '0';
        pending_write          <= '0';
        last_o                 <= '0';
        ser_count              <= (others => '0');
        pack_data              <= (others=>'0');
      else
        case state is
          when IDLE =>
            count              <= (others => '0');
            accept_o           <= '0';
            drop_o             <= '0';
            dvalid_o           <= '0';
            pending_write      <= '0';
            ser_count          <= (others => '0');
            first_o            <= '0';
            last_o             <= '0';
            if(sof_i = '1') then
              state            <= HEADER;
            end if;

          when HEADER =>
            if(eof_i = '1') then
              state <= IDLE;
            elsif(dvalid_i = '1') then
              case count(7 downto 0) is
                when x"00" =>
                  if(data_i /= mac_local_cfg(47 downto 32) nor (accept_broadcasts_cfg = '1' and data_i /= x"ffff")) then
                    state <= IDLE;
                  end if;
                  count <= count + 1;
                when x"01" =>
                  if(data_i /= mac_local_cfg(31 downto 16) nor (accept_broadcasts_cfg = '1' and data_i /= x"ffff")) then
                    state <= IDLE;
                  end if;
                  count <= count + 1;
                when x"02" =>
                  if(data_i /= mac_local_cfg(15 downto 0) nor (accept_broadcasts_cfg = '1' and data_i /= x"ffff")) then
                    state <= IDLE;
                  end if;
                  count <= count + 1;
                when x"03" =>
                  if(data_i /= mac_remote_cfg(47 downto 32) and filter_remote_cfg ='1') then
                    state <= IDLE;
                  end if;
                  count <= count + 1;
                when x"04" =>
                  if(data_i /= mac_remote_cfg(31 downto 16) and filter_remote_cfg ='1') then
                    state <= IDLE;
                  end if;
                  count <= count + 1;
                when x"05" =>
                  if(data_i /= mac_remote_cfg(15 downto 0) and filter_remote_cfg ='1') then
                    state <= IDLE;
                  else
                    state                     <= PAYLOAD;
                    drop_o                    <= '0';
                    accept_o                  <= '0';
                    ser_count                 <= (others => '0');
                  end if;
                  count <= count + 1;
                when others => null;
              end case;
            end if;

          when PAYLOAD =>
--            if(eof_i = '1') then
--            if(fsm_in_eof_d6 = '1') then
--              state       <= IDLE;
--              drop_o   <= '1';
--              accept_o <= '0';     
--            elsif(dvalid_i = '1') then
--            elsif(fsm_in_dvalid_d6 = '1') then
            if(fsm_in_dvalid_d6 = '1') then
                last_o   <= '0';
                accept_o <= '0';
                drop_o   <= '0';

                pack_data(to_integer(ser_count) * 16 + 15 downto to_integer(ser_count) * 16) <= fsm_in_data_d6;
                                
                if(ser_count = 1) then
                  ser_count                                        <= (others => '0');
                  data_o(15 downto 0)                              <= pack_data(15 downto 0);
                  data_o(31 downto 16)                             <= fsm_in_data_d6;
                  dvalid_o                                         <= '0';
                  dvalid_tmp                                       <= '0';
                  pending_write                                    <= '1';
                elsif(ser_count = 0 and pending_write = '1') then
                  pending_write <= '0';
                  ser_count     <= ser_count + 1;
                  dvalid_o      <= '1';
                  dvalid_tmp    <= '1';
                else
                  ser_count     <= ser_count + 1;
                  dvalid_o      <= '0';
                  dvalid_tmp    <= '0';
                end if;         
            else --of:  elsif(dvalid_i = '1') then
              state <= LAST;
              last_o            <= '1';
              dvalid_o          <= '0';
              dvalid_tmp        <= '1';
              if(pending_write = '0') then
                    data_o(31 downto 16)           <= (others => '0');
                    data_o(15 downto 0)            <= pack_data(15 downto 0);
              end if; 
            end if;

--            if(dvalid_tmp = '1') then
--              accept_o <= '1';
--              drop_o   <= '0';
--            else
--              accept_o <= '0';
--              drop_o   <= '0';
--            end if;
          
          when LAST =>
            state       <= EOF;
            last_o   <= '1';
            dvalid_o <= '1';
            accept_o <= '0';
            drop_o   <= '0';
           
          when EOF =>
            last_o   <= '0';
            dvalid_o <= '0';
            drop_o   <= '0';
            accept_o <= '1';
            state       <= IDLE;
            
        end case;
      end if;
    end if;
  end process;

end Behavioral;
