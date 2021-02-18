--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
--Date        : Tue Apr 16 10:41:10 2019
--Host        : Wei-Berkeley running 64-bit Ubuntu 18.04.2 LTS
--Command     : generate_target test_wrapper.bd
--Design      : test_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity test_wrapper is
end test_wrapper;

architecture STRUCTURE of test_wrapper is
  component test is
  end component test;
begin
test_i: component test
 ;
end STRUCTURE;
