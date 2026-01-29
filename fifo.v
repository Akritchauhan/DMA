`timescale 1ns / 1ps
module fifo(clk,rst,din,write_en,read_en,dout,full,empty);
parameter datawidth=32;
parameter depth=16;
input wire clk, rst;
input wire [datawidth-1:0] din;
input wire write_en,read_en;
output reg [datawidth -1 :0] dout;
output wire full,empty;

reg [datawidth -1 : 0] mem [0:depth -1];
reg [3:0] write_ptr,read_ptr;
reg [4:0] count;  // one extra handle full/empty

assign full=(count == depth);
assign empty =(count == 0);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        write_ptr   <= 0;
        read_ptr   <= 0;
        count   <= 0;
        dout<= 0;
    end else begin
    if(write_en && !full)begin
    mem[write_ptr]<= din;
    write_ptr <= write_ptr + 1;
    count<=count +1;
    end
    if (read_en && !empty )begin
    dout<= mem[read_ptr];
    read_ptr<=read_ptr+1;
    count<=count+1;
    end
   end
  end
endmodule
