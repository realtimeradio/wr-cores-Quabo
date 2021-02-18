To create Vivado project for wrc_board_fasec IPcore generation, open Vivado and
run build.tcl script _before_ launching hdlmake; some files need copying in.
For instance:
 vivado -mode batch -source build.tcl
