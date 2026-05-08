`include "uvm_macros.svh"
import uvm_pkg::*;

`include "spi_agent.sv"
`include "spi_coverage.sv"
`include "spi_driver.sv"
`include "spi_env.sv"
`include "spi_interface.sv"
`include "spi_monitor.sv"
`include "spi_scoreboard.sv"
`include "spi_seq_item.sv"
`include "spi_sequence.sv"
`include "spi_test.sv"

module tb_spi ();

    logic clk;
    logic rst_n;

    always #5 clk = ~clk;

    spi_if spi_if (
        clk,
        rst_n
    );

    axi_spi_top #(
        .C_S00_AXI_DATA_WIDTH(32),
        .C_S00_AXI_ADDR_WIDTH(4)
    ) dut (
        .tx_data        (spi_if.tx_data),
        .rx_data        (spi_if.rx_data),
        .rx_done        (spi_if.rx_done),
        .s00_axi_aclk   (clk),
        .s00_axi_aresetn(rst_n),
        .s00_axi_awaddr (spi_if.awaddr),
        .s00_axi_awprot (3'b000),
        .s00_axi_awvalid(spi_if.awvalid),
        .s00_axi_awready(spi_if.awready),
        .s00_axi_wdata  (spi_if.wdata),
        .s00_axi_wstrb  (spi_if.wstrb),
        .s00_axi_wvalid (spi_if.wvalid),
        .s00_axi_wready (spi_if.wready),
        .s00_axi_bresp  (spi_if.bresp),
        .s00_axi_bvalid (spi_if.bvalid),
        .s00_axi_bready (spi_if.bready),
        .s00_axi_araddr (spi_if.araddr),
        .s00_axi_arprot (3'b000),
        .s00_axi_arvalid(spi_if.arvalid),
        .s00_axi_arready(spi_if.arready),
        .s00_axi_rdata  (spi_if.rdata),
        .s00_axi_rresp  (spi_if.rresp),
        .s00_axi_rvalid (spi_if.rvalid),
        .s00_axi_rready (spi_if.rready)
    );


    initial begin
        clk = 0;
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
    end

    initial begin
        uvm_config_db#(virtual spi_if)::set(null, "*", "spi_if", spi_if);
        run_test();
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_spi, "+all");
    end
endmodule
