`timescale 1ns / 1ps

module top_i2c (
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] sw,
    input  logic       scl,
    inout  wire        sda,
    output logic [7:0] fnd_data,
    output logic [3:0] fnd_digit
);

    logic [7:0] s_rx_data;
    logic       s_done;

    fnd_controller U_FND (
        .clk(clk),
        .reset(rst),
        .fnd_in_data({6'b0, s_rx_data}),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data)
    );

    i2c_slave U_I2C_SlAVE (
        .clk(clk),
        .rst(rst),
        .tx_data(sw),
        .rx_data(s_rx_data),
        .done(s_done),
        .scl(scl),
        .sda(sda)
    );


endmodule
