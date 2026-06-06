// 템플릿을 따로 만들어서 사용하기 위한 작업
//정의되어있지 않으면, 정의하라는 의미 
`ifndef RAM_SEQ_ITEM_SV
`define RAM_SEQ_ITEM_SV
//include 했을 때, 반복해서 부르지 않기 위함
//이름이 정의되어있지 않으면 내부를 정의해라라는 의미
//또 다시 부르면, 이미 정의되어있으므로, 안에 있는 내용을 실행하지 않고 그냥 빠져 나옴
//`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

//템플릿 
class ram_seq_item extends uvm_sequence_item;
    rand logic        we;
    rand logic [ 7:0] addr;
    rand logic [15:0] wdata;
    logic      [15:0] rdata;

    constraint c_addr {addr inside {[8'h00 : 8'h0f]};}

    //factory에 등록하는 절차 
    `uvm_object_utils_begin(ram_seq_item)
        `uvm_field_int(we, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "ram_seq_item");
        super.new(name);
    endfunction  //new()

    function string convert2string();
        return $sformatf(
            "we = %0b addr = 0x%02h wdata = 0x%04h, rdata = 0x%04h",
            we,
            addr,
            wdata,
            rdata
        );

    endfunction
endclass  //component 

`endif
