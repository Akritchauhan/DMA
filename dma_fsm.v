`timescale 1ns / 1ps

module dma_fsm(clk,rst,start,size,fifo_wr_en,fifo_rd_en,busy);
input wire clk,rst;
input wire start;
input wire [31:0] size;
output reg fifo_wr_en,fifo_rd_en;
output reg busy;


parameter idle = 2'b00,
          fetch = 2'b01,
          deposit = 2'b10;

reg [1:0] state;


reg[31:0] count;

always @(posedge clk or posedge rst)begin
if(rst)begin
state<=idle;
fifo_wr_en<=0;
fifo_rd_en<=0;
count<=0;
busy<=0;
end
else begin
fifo_wr_en<=0;
fifo_rd_en<=0;
case(state)
idle:begin
busy<=0;
if(start)begin
 state<=fetch;
 busy<=1;count<=0;
 end
 end
 
fetch:
begin
fifo_wr_en<=1;
state<=deposit;
end

deposit: begin
    if (count + 4 >= size) begin
        state <= idle;
        busy  <= 0;
    end else begin
        fifo_rd_en <= 1;
        count <= count + 4;
        state <= fetch;
    end
end
endcase
end
end


endmodule
