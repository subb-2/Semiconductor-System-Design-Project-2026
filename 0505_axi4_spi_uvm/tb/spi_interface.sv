interface spi_if (
    input logic clk,
    input logic rst_n
);
    // SPI Slave Control / Snoop signals
    logic [   7:0] tx_data;
    logic [   7:0] rx_data;
    logic          rx_done;
    // AXI-Lite Write Address Channel
    logic [ 3 : 0] awaddr;
    logic [ 2 : 0] awprot;
    logic          awvalid;
    logic          awready;
    // AXI-Lite Write Data Channel
    logic [31 : 0] wdata;
    logic [   3:0] wstrb;
    logic          wvalid;
    logic          wready;
    // AXI-Lite Write Response Channel
    logic [ 1 : 0] bresp;
    logic          bvalid;
    logic          bready;
    // AXI-Lite Read Address Channel
    logic [ 3 : 0] araddr;
    logic [ 2 : 0] arprot;
    logic          arvalid;
    logic          arready;
    // AXI-Lite Read Data Channel
    logic [  31:0] rdata;
    logic [ 1 : 0] rresp;
    logic          rvalid;
    logic          rready;


    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        //tb -> DUT
        output tx_data;
        output awaddr;
        output awprot;
        output awvalid;
        output wdata;
        output wstrb;
        output wvalid;
        output bready;
        output araddr;
        output arprot;
        output arvalid;
        output rready;
        //DUT -> tb
        input rx_data;
        input rx_done;
        input awready;
        input wready;
        input bresp;
        input bvalid;
        input arready;
        input rresp;
        input rvalid;
        input rdata;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input tx_data;
        input awaddr;
        input awprot;
        input awvalid;
        input wdata;
        input wstrb;
        input wvalid;
        input bready;
        input araddr;
        input arprot;
        input arvalid;
        input rready;
        input rx_data;
        input rx_done;
        input awready;
        input wready;
        input bresp;
        input bvalid;
        input arready;
        input rresp;
        input rvalid;
        input rdata;

    endclocking

    modport mp_drv(clocking drv_cb, input clk, input rst_n);
    modport mp_mon(clocking mon_cb, input clk, input rst_n);

endinterface  //spi_if
