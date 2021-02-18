library ieee;
use ieee.std_logic_1164.all;

package delay_pkg is

component delay_six_cyc
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
end component;

end package;