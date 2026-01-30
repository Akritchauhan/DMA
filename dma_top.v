`timescale 1ns / 1ps
module dma_top (
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  cpu_addr,
    input  wire [31:0] cpu_wdata,
    input  wire        cpu_we,
    output wire [31:0] mem_data_out
);

wire [31:0] src_addr;
wire [31:0] dst_addr;
wire [31:0] size;
wire start;

wire fifo_wr_en;
wire fifo_rd_en;
wire fifo_full;
wire fifo_empty;

/* DMA Registers */
dma_reg u_regs (
    .clk(clk),
    .rst(rst),
    .addr(cpu_addr),
    .din(cpu_wdata),
    .write_en(cpu_we),
    .src_addr(src_addr),
    .dst_addr(dst_addr),
    .transfer_size(size),
    .start(start)
);

/* DMA FSM */
dma_fsm u_fsm (
    .clk(clk),
    .rst(rst),
    .start(start),
    .size(size),
    .fifo_wr_en(fifo_wr_en),
    .fifo_rd_en(fifo_rd_en),
    .busy()
);

/* FIFO */
fifo #(
    .datawidth(32),
    .depth(16)
) u_fifo (
    .clk(clk),
    .rst(rst),
    .din(32'hABCD1234),
    .write_en(fifo_wr_en),
    .read_en(fifo_rd_en),
    .dout(mem_data_out),
    .full(fifo_full),
    .empty(fifo_empty)
);

endmodule
