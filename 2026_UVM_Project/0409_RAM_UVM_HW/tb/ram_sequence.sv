// 템플릿을 따로 만들어서 사용하기 위한 작업
//정의되어있지 않으면, 정의하라는 의미 
`ifndef RAM_SEQUENCE_SV
`define RAM_SEQUENCE_SV
//include 했을 때, 반복해서 부르지 않기 위함
//이름이 정의되어있지 않으면 내부를 정의해라라는 의미
//또 다시 부르면, 이미 정의되어있으므로, 안에 있는 내용을 실행하지 않고 그냥 빠져 나옴
//`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ram_seq_item.sv"

//템플릿 
class ram_random_sequence extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_random_sequence)

    int num_transactions = 0;

    function new(string name = "ram_random_sequence");
        super.new(name);
    endfunction  //new()

    virtual task body();
        repeat (num_transactions) begin
            ram_seq_item item = ram_seq_item::type_id::create("item");

            start_item(item);
            if (!item.randomize())
                `uvm_fatal(get_type_name(), "Randomization Fail!");
            finish_item(item);
        end
    endtask  //body

endclass  //component 

class ram_write_read_sequence extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_write_read_sequence)

    int num_transactions = 0;

    function new(string name = "ram_write_read_sequence");
        super.new(name);
    endfunction  //new()

    virtual task body();

        repeat (num_transactions) begin
            ram_seq_item item = ram_seq_item::type_id::create("item");

            start_item(
                item); //wait driver signal 드라이버가 보내달라고 할 때까지 대기 
            if (!item.randomize() with {we == 1;})
                `uvm_fatal(get_type_name(), "Randomization Fail!");
            finish_item(item);  //send item driver

            start_item(
                item); // wait driver signal 드라이버가 다 처리할 때까지 대기 
            //주소는 그대로 유지 
            item.we = 0;
            finish_item(item);  //send item driver
        end
    endtask  //body

endclass  //component 

class ram_full_sweep_sequence extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_full_sweep_sequence)

    function new(string name = "ram_full_sweep_sequence");
        super.new(name);
    endfunction  //new()

    virtual task body();
        ram_seq_item item = ram_seq_item::type_id::create("item");

        for (int i = 0; i < 2 ** 8; i++) begin
        start_item(item); 
            //wait driver signal 드라이버가 보내달라고 할 때까지 대기 
            if (!item.randomize() with {
                    we == 1;
                    addr == i;
                })
                `uvm_fatal(get_type_name(), "Randomization Fail!");
        finish_item(item);  //send item driver
        end

        for (int i = 0; i < 2 ** 8; i++) begin
        start_item(item); 
            //wait driver signal 드라이버가 보내달라고 할 때까지 대기 
            item.we   = 0;
            item.addr = i;
        finish_item(item);  //send item driver
        end
    endtask  //body

endclass  //component 

`endif
