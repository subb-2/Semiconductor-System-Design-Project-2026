// 템플릿을 따로 만들어서 사용하기 위한 작업
//정의되어있지 않으면, 정의하라는 의미 
`ifndef RAM_SCOREBOARD_SV
`define RAM_SCOREBOARD_SV
//include 했을 때, 반복해서 부르지 않기 위함
//이름이 정의되어있지 않으면 내부를 정의해라라는 의미
//또 다시 부르면, 이미 정의되어있으므로, 안에 있는 내용을 실행하지 않고 그냥 빠져 나옴
//`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ram_seq_item.sv"

//sw의 dut 제작
//받은 값을 레퍼런스에 넣고
//실제 값과 레퍼런스 값 비교 판단 
//sw로 레퍼런스를 잘 만들어야 함

//템플릿 
class ram_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ram_scoreboard)

    //일종의 class 
    uvm_analysis_imp #(ram_seq_item, ram_scoreboard) ap_imp;

    //이 ram에 read 하거나 write 하거나
    logic [15:0] ref_mem[0:(2**8-1)];
    int pass_cnt = 0;
    int fail_cnt = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    //scb, cov 경우에는 report 까지 하는 경우도 있음
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //instance 를 만들고 handler에 대입 
        ap_imp = new("ap_imp", this);
    endfunction

    virtual function void write(ram_seq_item item);
        logic [15:0] expected;
        if (item.we) begin
            ref_mem[item.addr] = item.wdata;
            `uvm_info(get_type_name(),
                      $sformatf("쓰기 기록 : addr = 0x%02h, data = 0x%04h",
                                item.addr, item.wdata), UVM_MEDIUM)
        end else begin
            expected = ref_mem[item.addr];
            if (item.rdata === expected) begin
                pass_cnt++;
                `uvm_info(
                    get_type_name(),
                    $sformatf(
                        "PASS: addr = 0x%02h, expected = 0x%04h, real = 0x%04h",
                        item.addr, expected, item.rdata), UVM_MEDIUM)
            end else begin
                fail_cnt++;
                `uvm_error(get_type_name(), $sformatf(
                           "FAIL: addr = 0x%02h, expected = 0x%04h, real = 0x%04h",
                           item.addr,
                           expected,
                           item.rdata
                           ))
            end
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "\n\n===== Scoreboard Summary =====",
                  UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "Total transaction: %0d", pass_cnt + fail_cnt), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("Pass: %0d", pass_cnt), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("Fail: %0d", fail_cnt), UVM_LOW);
        if (fail_cnt > 0) begin
            `uvm_error(get_type_name(),
                       $sformatf("TEST FAILED: %0d mismatches detected!",
                                 fail_cnt))
        end else begin
            `uvm_info(get_type_name(), $sformatf(
                      "TEST PASSED: %0d matches detected!", pass_cnt), UVM_LOW)
        end
    endfunction

endclass  //component 

`endif
