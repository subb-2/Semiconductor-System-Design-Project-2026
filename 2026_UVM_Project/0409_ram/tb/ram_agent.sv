// 템플릿을 따로 만들어서 사용하기 위한 작업
//정의되어있지 않으면, 정의하라는 의미 
`ifndef RAM_AGENT_SV
`define RAM_AGENT_SV
//include 했을 때, 반복해서 부르지 않기 위함
//이름이 정의되어있지 않으면 내부를 정의해라라는 의미
//또 다시 부르면, 이미 정의되어있으므로, 안에 있는 내용을 실행하지 않고 그냥 빠져 나옴
//`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ram_seq_item.sv"
`include "ram_driver.sv"
`include "ram_monitor.sv"

//템플릿 
class ram_agent extends uvm_agent;
    `uvm_component_utils(ram_agent)

    ram_driver drv;
    ram_monitor mon;

    uvm_sequencer #(ram_seq_item) sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    //scb, cov 경우에는 report 까지 하는 경우도 있음
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = ram_driver::type_id::create("drv", this);
        mon = ram_monitor::type_id::create("mon", this);
        sqr = uvm_sequencer#(ram_seq_item)::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass  //component 

`endif
