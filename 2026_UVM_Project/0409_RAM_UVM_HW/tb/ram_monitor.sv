// 템플릿을 따로 만들어서 사용하기 위한 작업
//정의되어있지 않으면, 정의하라는 의미 
`ifndef RAM_MONITOR_SV
`define RAM_MONITOR_SV
//include 했을 때, 반복해서 부르지 않기 위함
//이름이 정의되어있지 않으면 내부를 정의해라라는 의미
//또 다시 부르면, 이미 정의되어있으므로, 안에 있는 내용을 실행하지 않고 그냥 빠져 나옴
//`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ram_seq_item.sv" 

//템플릿 
class ram_monitor extends uvm_monitor;
    `uvm_component_utils(ram_monitor)

    virtual ram_if r_if;

    uvm_analysis_port #(ram_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    //scb, cov 경우에는 report 까지 하는 경우도 있음
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual ram_if)::get(this, "", "r_if", r_if))
            `uvm_fatal(get_type_name(),
                       "ram interface를 config_db에서 가져올 수 없음")
    endfunction

    virtual task run_phase(uvm_phase phase);
        //엣지 발생 직전, 값 읽기
        forever begin
            //읽어온 것을 item에 넣기
            ram_seq_item item = ram_seq_item::type_id::create("item");
            @(r_if.mon_cb);
            item.we    = r_if.mon_cb.we;
            item.addr  = r_if.mon_cb.addr;
            item.wdata = r_if.mon_cb.wdata;
            //read 값을 제대로 읽어오기 위함 
            if (!item.we) begin
                @(r_if.mon_cb) item.rdata = r_if.mon_cb.rdata;
            end
            `uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM);
            ap.write(item);
        end
    endtask  //run_phase

endclass  //component 

`endif
