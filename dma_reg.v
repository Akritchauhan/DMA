`timescale 1ns / 1ps

module dma_reg(clk,rst,addr,din,write_en,src_addr,dst_addr,transfer_size,start);

input wire clk,rst;
input wire [1:0] addr;
input wire[31:0] din;
input wire write_en;
output reg [31:0] src_addr , dst_addr ,transfer_size;
output reg start;

always @(posedge clk or posedge rst)begin
if(rst)begin
src_addr<=0;
dst_addr<=0;
transfer_size<=0;
start <=0;
end
else begin
start<=1'b0;
if(write_en)begin
case(addr)
2'b00:src_addr <=din;
2'b01:dst_addr <=din;
2'b10:transfer_size <=din;
2'b11: start <=din;
endcase
end
end
end
endmodule
