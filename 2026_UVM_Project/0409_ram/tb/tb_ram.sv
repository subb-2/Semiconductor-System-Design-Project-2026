//`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

//파일 이름과 동일하게 
`include "ram_interface.sv"
`include "ram_seq_item.sv"
`include "ram_sequence.sv"
`include "ram_driver.sv"
`include "ram_monitor.sv"
`include "ram_agent.sv"
`include "ram_scoreboard.sv"
`include "ram_coverage.sv"
`include "ram_env.sv"
`include "ram_test.sv"

module tb_ram ();
    logic clk;
    initial clk = 0;
    always #5 clk = ~clk;

    ram_if r_if (clk);

    ram dut (
        .clk(clk),
        .we(r_if.we),
        .addr(r_if.addr),
        .wdata(r_if.wdata),
        .rdata(r_if.rdata)
    );
    //인터페이스 config_db에 저장
    initial begin
        //data type은 virtual 형태로 해야 함
        uvm_config_db#(virtual ram_if)::set(null, "*", "r_if", r_if);
        run_test();
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_ram, "+all"); 
    end

endmodule
