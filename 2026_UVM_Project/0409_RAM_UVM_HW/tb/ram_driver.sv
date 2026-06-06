// 템플릿을 따로 만들어서 사용하기 위한 작업
//정의되어있지 않으면, 정의하라는 의미 
`ifndef RAM_DRIVER_SV
`define RAM_DRIVER_SV
//include 했을 때, 반복해서 부르지 않기 위함
//이름이 정의되어있지 않으면 내부를 정의해라라는 의미
//또 다시 부르면, 이미 정의되어있으므로, 안에 있는 내용을 실행하지 않고 그냥 빠져 나옴
//`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ram_seq_item.sv"

//템플릿 
class ram_driver extends uvm_driver #(ram_seq_item);
    `uvm_component_utils(ram_driver)

    virtual ram_if r_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    //scb, cov 경우에는 report 까지 하는 경우도 있음
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ram_if)::get(this, "", "r_if", r_if))
            //fatal이 동작하면 tb가 멈춤
            `uvm_fatal(
            get_type_name(),
            "ram interface를 config_db에서 가져올 수 없음")
    endfunction

    virtual task run_phase(uvm_phase phase);
        ram_seq_item item;
        forever begin
            //sqr가 준 값을 가지고 보내는 역할이 drv
            //sqr한테 item 요청
            seq_item_port.get_next_item(item);
            r_if.drv_cb.we <= item.we; 
            r_if.drv_cb.addr <= item.addr;
            r_if.drv_cb.wdata <= item.wdata;
            @(r_if.drv_cb);
            //read일 때는 두 클럭 기다려야 함
            //그래야지 받을 수 있음 
            //꼭 기다려야할까? 
            if (!item.we) begin
                @(r_if.drv_cb);
            end
            //mon도 동일하게 조건문 사용
            `uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM);
            //sqr한테 알리면, sqr가 seq한테 알려주고 seq가 다음을 실행함 
            seq_item_port.item_done();
        end
    endtask  //run_phase

endclass  //component 

`endif
