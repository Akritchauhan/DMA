`timescale 1ns / 1ps
module axi_lite_slave(clk,rst,s_addr,s_valid,s_ready,s_wdata,s_wvalid,s_wready,s_bvalid,s_bready,src_addr,dst_addr,transfer_size,ctrl_start);
input wire clk;
input wire rst;
input wire [31:0] s_addr;
input wire s_valid;
output reg s_ready;

input wire[31:0] s_wdata;
input wire s_wvalid;
output reg s_wready;

output reg s_bvalid;
input wire s_bready;

output wire [31:0] src_addr;
output wire [31:0] dst_addr;
output wire [31:0] transfer_size;
output wire ctrl_start;

reg [31:0] reg_src , reg_dst ,reg_size;
reg reg_start;
wire reg_wen;

always @(posedge clk)begin
if(!rst)begin
s_ready <= 1'b0;
s_wready <=1'b0;
s_bvalid <=1'b0;
end
else begin
if(!s_ready && s_valid)
s_ready<=1'b1;
else
s_ready<=1'b0;

if(!s_wready && s_wvalid)
s_wready<=1'b1;
else
s_wready<=1'b0;

if(s_wready && s_wvalid && !s_bvalid)
s_bvalid<=1'b1;
else if(s_bready && s_bvalid)
s_bvalid<=1'b0;
end
end

assign reg_wen=s_wready && s_wvalid;

always @(posedge clk)begin
if(!rst)begin
reg_src <=1'b0;
reg_dst <=1'b0;
reg_size <=1'b0;
reg_start <=1'b0;
end
else if(reg_wen)begin
case(s_addr[3:2])
2'b00:reg_src <=s_wdata;
2'b01:reg_dst<= s_wdata;
2'b10:reg_size<=s_wdata;
2'b11:reg_start<=s_wdata[0];
endcase
end else begin
reg_start <=1'b0;
end
end

assign src_addr =reg_src;
assign dst_addr =reg_dst;
assign transfer_size=reg_size;
assign ctrl_start =reg_start;

endmodule
