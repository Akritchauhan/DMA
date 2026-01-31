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



`timescale 1ns / 1ps

module dma_top (
    input  wire        clk,
    input  wire        rst,

    // ---------------- AXI-Lite Slave (CPU) ----------------
    input  wire [31:0] s_axi_addr,
    input  wire        s_axi_valid,
    output wire        s_axi_ready,
    input  wire [31:0] s_axi_wdata,
    input  wire        s_axi_wvalid,
    output wire        s_axi_wready,
    output wire        s_axi_bvalid,
    input  wire        s_axi_bready,

    // ---------------- AXI Master Read ----------------
    output wire [31:0] m_axi_araddr,
    output wire        m_axi_arvalid,
    input  wire        m_axi_arready,
    input  wire [31:0] m_axi_rdata,
    input  wire        m_axi_rvalid,
    output wire        m_axi_rready,

    // ---------------- AXI Master Write ----------------
    output wire [31:0] m_axi_awaddr,
    output wire        m_axi_awvalid,
    input  wire        m_axi_awready,
    output wire [31:0] m_axi_wdata,
    output wire        m_axi_wvalid,
    input  wire        m_axi_wready,
    input  wire        m_axi_bvalid,
    output wire        m_axi_bready
);

    // ---------------- Internal Wires ----------------
    wire [31:0] src_addr, dst_addr, transfer_size;
    wire        dma_start;

    wire [31:0] fifo_wdata, fifo_rdata;
    wire        fifo_wen, fifo_ren;
    wire        fifo_full, fifo_empty;

    wire        read_done;
    wire        write_done;

    // ---------------- AXI-Lite Slave ----------------
    axi_lite_slave i_slave (
        .clk(clk),
        .rst(rst),
        .s_addr(s_axi_addr),
        .s_valid(s_axi_valid),
        .s_ready(s_axi_ready),
        .s_wdata(s_axi_wdata),
        .s_wvalid(s_axi_wvalid),
        .s_wready(s_axi_wready),
        .s_bvalid(s_axi_bvalid),
        .s_bready(s_axi_bready),
        .src_addr(src_addr),
        .dst_addr(dst_addr),
        .transfer_size(transfer_size),
        .ctrl_start(dma_start)
    );

    // ---------------- FIFO ----------------
    fifo #(
        .datawidth(32),
        .depth(16)
    ) i_fifo (
        .clk(clk),
        .rst(rst),
        .din(fifo_wdata),
        .write_en(fifo_wen),
        .read_en(fifo_ren),
        .dout(fifo_rdata),
        .full(fifo_full),
        .empty(fifo_empty)
    );

    // ---------------- AXI Master Read ----------------
    axi_master_read i_mread (
        .clk(clk),
        .rst(rst),
        .m_read_start(dma_start),
        .m_read_addr(src_addr),
        .m_read_done(read_done),
        .m_axi_addr(m_axi_araddr),
        .m_axi_valid(m_axi_arvalid),
        .m_axi_ready(m_axi_arready),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),
        .fifo_wdata(fifo_wdata),
        .fifo_wen(fifo_wen)
    );

    // ---------------- AXI Master Write ----------------
    axi_master_write i_mwrite (
        .clk(clk),
        .rst(rst),
        .m_write_start(read_done),
        .m_write_addr(dst_addr),
        .m_write_done(write_done),
        .m_axi_addr(m_axi_awaddr),
        .m_axi_valid(m_axi_awvalid),
        .m_axi_ready(m_axi_awready),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready),
        .fifo_rdata(fifo_rdata),
        .fifo_ren(fifo_ren)
    );

endmodule

