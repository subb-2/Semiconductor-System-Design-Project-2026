`timescale 1ns / 1ps

module tb_clk_div();

    reg clk, reset;
    wire clk_2, clk_10; // 왜 출력은 항상 wire? 로직이 drive 하고 있기 때문에 아니면 합성기가 오류 
    // reg는 출력을 내보내려고 하는 역할이므로 

clk_div dut(
    .clk(clk),
    .reset(reset),
    .clk_2(clk_2),
    .clk_10(clk_10)
);

always #5 clk = ~clk;

initial begin
    #0;
    clk = 0; 
    reset = 1;

    #20
    reset = 0;

    #1000;
    $stop;
end

endmodule
