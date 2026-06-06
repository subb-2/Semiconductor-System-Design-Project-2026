// 템플릿을 따로 만들어서 사용하기 위한 작업
//정의되어있지 않으면, 정의하라는 의미 
`ifndef RAM_BASE_TEST_SV
`define RAM_BASE_TEST_SV
//include 했을 때, 반복해서 부르지 않기 위함
//이름이 정의되어있지 않으면 내부를 정의해라라는 의미
//또 다시 부르면, 이미 정의되어있으므로, 안에 있는 내용을 실행하지 않고 그냥 빠져 나옴
//`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

//템플릿 
class ram_base_test extends uvm_test;
    `uvm_component_utils(ram_base_test)

    //시퀀스는 뼈대가 아님 -> component 아님
    ram_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    //scb, cov 경우에는 report 까지 하는 경우도 있음
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ram_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        //agt에 있는 sqr 연결시킴 
        //ram_sequence seq = ram_sequence::type_id::create("seq");

        phase.raise_objection(this);
        //seq.num_transactions = 10;
        //seq.start(env.agt.sqr);
        run_test_seq();
        phase.drop_objection(this);

        `uvm_info("TEST", "ram test 완료", UVM_NONE)
    endtask  //run_phase

    //내가 class를 만들고, 이것을 상속받아서 사용하고 싶음 
    virtual task run_test_seq();
        // 자식 클래스에서 해당 기능 구현 
    endtask  //run_test_seq

endclass  //component 

class ram_write_read_test extends ram_base_test;
    `uvm_component_utils(ram_write_read_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual task run_test_seq();
        //test에서는 시퀀스 부르는 일이 가장 핵심 
        ram_write_read_sequence seq = ram_write_read_sequence::type_id::create(
            "seq"
        );
        seq.num_transactions = 10;
        seq.start(env.agt.sqr);
    endtask  //run_phase

endclass

class ram_full_sweep_test extends ram_base_test;
    `uvm_component_utils(ram_full_sweep_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual task run_test_seq();
        //test에서는 시퀀스 부르는 일이 가장 핵심 
        ram_full_sweep_sequence seq = ram_full_sweep_sequence::type_id::create(
            "seq"
        );
        seq.start(env.agt.sqr);
    endtask  //run_phase

endclass

class ram_random_test extends ram_base_test;
    `uvm_component_utils(ram_random_test)

    int num_transactions = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual task run_test_seq();
        //test에서는 시퀀스 부르는 일이 가장 핵심 
        ram_random_sequence seq = ram_random_sequence::type_id::create("seq");
        seq.num_transactions = 100;
        seq.start(env.agt.sqr);
    endtask  //run_phase

endclass

`endif
