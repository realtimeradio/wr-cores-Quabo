library IEEE;
use ieee.std_logic_1164.all;

package axi4_stream_pkg is 
	
	type t_axi_stream_txd_o is record
		tdata : std_logic_vector (31 downto 0);
		tkeep : std_logci_vector (3  downto 0);
		tlast : std_logic;
		tvalid: std_logic;
	end record;
	
	type t_axi_stream_txd_i is record
		tready :std_logic;
	end record;
	
	subtype t_axi_stream_rxd_i is t_axi_stream_txd_o;
	subtype t_axi_stream_rxd_o is t_axi_strean_txd_i;

end package;