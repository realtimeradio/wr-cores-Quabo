`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2019 04:49:01 PM
// Design Name: 
// Module Name: xrx_stream_l_fsm_sim
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


module xrx_stream_l_fsm_sim(

    );
reg clk,rst;
initial
begin
    rst = 0;
    #5;
    clk = 0;
    #5;
    clk = 1;
    #10
    rst = 1;
    forever #5 clk = ~clk;
end

reg [15:0]data_i;
reg sof_i, dvalid_i, eof_i;
wire [31:0]data_o;
wire accept_o,drop_o,dvalid_o,last_o,first_o;
wire [47:0]mac_local_cfg, mac_remote_cfg;
wire accept_broadcasts_cfg, filter_remote_cfg;
assign mac_local_cfg = 48'hffffffffffff;
assign mac_remote_cfg = 48'h 000000000000;
assign accept_broadcasts_cfg = 1;
assign filter_remote_cfg = 0;
reg rst_test;

always @(posedge clk)
begin
    if(rst == 0)
        begin
        rst_test <= 0;
        data_i  <=  16'h0000;
        end
    else if(data_i < 60 )
        begin
        data_i <= data_i + 1;
        rst_test<=1;
        end
    else 
        begin
        data_i <= data_i;   
        rst_test<=0;
        end     
end

always @(posedge clk)
begin
    if(rst == 0)
        sof_i <= 0;
    else if(data_i == 2)
        sof_i <= 1;
    else
        sof_i <= 0;
end

always @(posedge clk)
begin
    if(rst == 0)
        dvalid_i <= 0;
    else if(data_i == 4)
        dvalid_i <= 1;
    else if(data_i == 59)
        dvalid_i <= 0;
    else
        dvalid_i <= dvalid_i;      
end

always @(posedge clk)
begin
    if(rst == 0)
        eof_i <= 0;
    else if(data_i == 59)
        eof_i <= 1;
    else
        eof_i <= 0;
        
end

xrx_stream_l_fsm test0(
    .clk_sys_i(clk),
    .rst_n_i(rst),
    .data_i(data_i),
    .sof_i(sof_i),
    .eof_i(eof_i),
    .dvalid_i(dvalid_i),
    .data_o(data_o),
    .accept_o(accept_o),
    .drop_o(drop_o),
    .dvalid_o(dvalid_o),
    .last_o(last_o),
    .first_o(first_o),
    .mac_local_cfg(mac_local_cfg),
    .mac_remote_cfg(mac_remote_cfg),
    .accept_broadcasts_cfg(accept_broadcasts_cfg),
    .filter_remote_cfg(filter_remote_cfg)
);

wire [33:0] buf_data_i;
wire buf_valid_o;
wire [33:0] buf_data_o;
wire buf_last_o;
wire buf_first_o;
wire [31:0] buf_valid_data_o;
dropping_buffer #
(
  .g_size(256),
  .g_data_width(34)
)test1(
      .clk_i(clk),
      .rst_n_i(rst),
      .d_i(buf_data_i),
      .d_req_o(),
      .d_drop_i(drop_o),
      .d_accept_i(accept_o),
      .d_valid_i(dvalid_o),
      .d_o(buf_data_o),
      .d_valid_o(buf_valid_o),
      .d_req_i(1));

assign buf_data_i = {first_o, last_o, data_o};
assign buf_first_o = buf_data_o[33];
assign buf_last_o  = buf_data_o[32];
assign buf_valid_data_o = buf_data_o[31:0];

endmodule


    
