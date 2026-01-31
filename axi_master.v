`timescale 1ns / 1ps
module axi_master_read(clk,rst,m_read_start,m_read_addr,m_read_done,m_axi_addr,m_axi_valid,m_axi_ready,m_axi_rdata,m_axi_rvalid,m_axi_rready,fifo_wdata,fifo_wen);
input wire clk,rst;
input wire m_read_start;
input wire [31:0] m_read_addr;
output reg m_read_done;

output reg [31:0]m_axi_addr;
output reg m_axi_valid;
input wire m_axi_ready;

input wire [31:0] m_axi_rdata;
input wire m_axi_rvalid;
output reg m_axi_rready;

output reg [31:0] fifo_wdata;
output reg fifo_wen;

parameter idle=2'b00,
addr_phase =2'b01,
data_phase=2'b10;

reg [1:0] state;

always @(posedge clk or posedge rst)begin
if(rst)begin
state<=idle;
m_axi_valid<=1'b0;
m_axi_rready<=1'b0;
m_read_done <=1'b0;
fifo_wen<=0;
end
else begin
case(state)
idle:begin
m_read_done<=1'b0;
if(m_read_start)begin
m_axi_addr<=m_read_addr;
m_axi_valid<=1'b1;
state <=addr_phase;
end
end

addr_phase:begin
if(m_axi_ready)begin
m_axi_valid <=1'b0;
m_axi_rready<=1'b1;
state <=data_phase;
end
end

data_phase:begin
if(m_axi_rvalid)begin
fifo_wdata <=m_axi_rdata;
fifo_wen <=1'b1;
m_axi_rready<=1'b0;
m_read_done <=1'b1;
state <=idle;
end
end
endcase

if(state !=data_phase) fifo_wen <=0;
end
end
endmodule
