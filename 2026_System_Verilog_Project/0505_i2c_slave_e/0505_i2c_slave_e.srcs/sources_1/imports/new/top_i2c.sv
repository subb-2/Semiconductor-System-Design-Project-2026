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
    logic s_done, s_busy;

    logic [7:0] sw_sync1, sw_sync2;

    always_ff @(posedge clk) begin
        sw_sync1 <= sw;
        sw_sync2 <= sw_sync1;
    end

    fnd_controller U_FND (
        .clk(clk),
        .reset(rst),
        .fnd_in_data({6'b0, s_rx_data}),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data)
    );

    I2C_SLAVE U_I2C_SlAVE (
        .clk(clk),
        .reset(rst),
        .tx_data(sw_sync2),
        .rx_data(s_rx_data),
        .done(s_done),
        .busy(s_busy),
        .scl(scl),
        .sda(sda)
    );


endmodule
