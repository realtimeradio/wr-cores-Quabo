`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2019 02:52:14 PM
// Design Name: 
// Module Name: xrx_streamers_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module xrx_streamers_sim(

    );
reg clk,rst;

initial
begin
    rst = 0;
    #10;
    rst = 1;
    clk = 0;
    forever #5 clk = ~clk;
end

xrx_streamer_light xrx_streamer_light_sim(
    clk_sys_i(clk),
    rst_n_i()
); 
    
endmodule

