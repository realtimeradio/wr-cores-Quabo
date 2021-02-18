----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2019 06:29:39 PM
-- Design Name: 
-- Module Name: delay_6_cyc - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity delay_six_cyc is
port(
    clk_sys_i   : in    std_logic;
    rst_n_i     : in    std_logic;
    data_i      : in    std_logic_vector( 15 downto 0);
    valid_i     : in    std_logic;
    eof_i       : in    std_logic;
    data_o      : out   std_logic_vector( 15 downto 0);
    valid_o     : out   std_logic;
    eof_o       : out   std_logic
);
end delay_six_cyc;

architecture Behavioral of delay_six_cyc is

signal  data_i_d0, data_i_d1, data_i_d2, data_i_d3, data_i_d4: std_logic_vector( 15 downto 0);
signal  valid_i_d0, valid_i_d1, valid_i_d2, valid_i_d3, valid_i_d4: std_logic;
signal  eof_i_d0, eof_i_d1, eof_i_d2, eof_i_d3, eof_i_d4 : std_logic;
 

begin

delay : process (clk_sys_i)
begin
    if rising_edge(clk_sys_i) then
        if(rst_n_i = '0') then
            data_i_d0 <= (others => '0');
            data_i_d1 <= (others => '0');
            data_i_d2 <= (others => '0');
            data_i_d3 <= (others => '0');
            data_i_d4 <= (others => '0');
--            data_i_d5 <= (others => '0');
            data_o    <= (others => '0');
            
            valid_i_d0 <= '0';
            valid_i_d1 <= '0';
            valid_i_d2 <= '0';
            valid_i_d3 <= '0';
            valid_i_d4 <= '0';
--            valid_i_d5 <= '0';
            valid_o    <= '0';
            
            eof_i_d0   <= '0';
            eof_i_d1   <= '0';
            eof_i_d2   <= '0';
            eof_i_d3   <= '0';
            eof_i_d4   <= '0';
--            eof_i_d5   <= '0';
            eof_o      <= '0';
         else
            data_i_d0  <= data_i;
            data_i_d1  <= data_i_d0;
            data_i_d2  <= data_i_d1;
            data_i_d3  <= data_i_d2;
            data_i_d4  <= data_i_d3;
--            data_i_d5  <= data_i_d4;
            data_o     <= data_i_d4;
            
            valid_i_d0 <= valid_i;
            valid_i_d1 <= valid_i_d0;
            valid_i_d2 <= valid_i_d1;
            valid_i_d3 <= valid_i_d2;
            valid_i_d4 <= valid_i_d3;
--            valid_i_d5 <= valid_i_d4;
            valid_o    <= valid_i_d4;
            
            eof_i_d0   <= eof_i;
            eof_i_d1   <= eof_i_d0;
            eof_i_d2   <= eof_i_d1;
            eof_i_d3   <= eof_i_d2;
            eof_i_d4   <= eof_i_d3;
--            eof_i_d5   <= eof_i_d4;
            eof_o      <= eof_i_d4;
        end if;
    end if;
end process;

end Behavioral;
