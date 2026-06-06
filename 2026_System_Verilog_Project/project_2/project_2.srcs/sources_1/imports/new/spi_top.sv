`timescale 1ns / 1ps

module spi_top (
    input logic clk,
    input logic rst,

    input logic sclk,
    input logic mosi,
    input logic cs_n,
    output logic miso,
    input  logic [7:0] sw,
    output logic [3:0] fnd_digit,
    output logic [7:0] fnd_data
);

    logic [7:0] s_tx_data;
    logic [7:0] s_rx_data;
    //logic       s_busy;
    logic       s_rx_done;

    logic [7:0] clk_div;
    assign clk_div = 8'd4;

    fnd_controller U_FND (
        .clk(clk),
        .reset(rst),
        .fnd_in_data({6'b0, s_rx_data}),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data)
    );


    spi_slave U_SPI_SLAVE (
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        //.busy(s_busy),
        .cs_n(cs_n),
        .tx_data(sw),
        .rx_data(s_rx_data),
        .rx_done(s_rx_done)
    );
endmodule

