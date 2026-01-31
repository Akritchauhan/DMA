`timescale 1ns / 1ps
module axi_master_write(clk,rst,m_write_start,m_write_addr,
m_write_done,m_axi_addr,m_axi_valid,m_axi_ready,
m_axi_wdata,m_axi_wvalid,m_axi_wready,m_axi_bvalid,
m_axi_bready,fifo_rdata,fifo_ren);

input wire clk,rst;
input wire m_write_start;
input wire [31:0] m_write_addr;
output reg m_write_done;

output reg [31:0] m_axi_addr;
output reg m_axi_valid;
input wire m_axi_ready;

output reg [31:0] m_axi_wdata;
output reg m_axi_wvalid;
input wire m_axi_wready;

input wire m_axi_bvalid;
output reg m_axi_bready;

input wire [31:0] fifo_rdata;
output reg fifo_ren;

parameter idle=2'b00,
aw_phase=2'b01,
w_phase=2'b10,
b_phase =2'b11;

reg [1:0] state;

always @(posedge clk or posedge rst)begin
if(rst)begin
state<=idle;
m_axi_valid<=1'b0;
m_axi_wvalid<=1'b0;
m_axi_bready<=1'b0;
fifo_ren<=1'b0;
m_write_done<=1'b0;
end
else begin
case(state)
idle:begin
m_write_done<=1'b0;
if(m_write_start)begin
m_axi_addr<=m_write_addr;
m_axi_valid<=1'b1;
state<=aw_phase;
end
end

aw_phase:begin
if(m_axi_ready)begin
m_axi_valid<=1'b0;
m_axi_wvalid<=1'b1;
m_axi_wdata<=fifo_rdata;
fifo_ren <=1'b1;
state <=w_phase;
end
end

w_phase:begin
fifo_ren<=1'b0;
if(m_axi_wready)begin
m_axi_wvalid<=1'b0;
m_axi_bready<=1'b1;
state <=b_phase;
end
end

b_phase:begin
if(m_axi_bvalid)begin
m_axi_bready<=1'b0;
m_write_done<=1'b1;
state <=idle;
end
end
endcase
end
end
endmodule
