`ifndef RAM_SEQUENCE_SV
`define RAM_SEQUENCE_SV

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
            if (!item.randomize() with {we == 1; cycles == 1;})
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

        start_item(
            item); //wait driver signal 드라이버가 보내달라고 할 때까지 대기 
        for (int i = 0; i < 2 ** 8; i++) begin
            if (!item.randomize() with {
                    we == 1;
                    addr == i;
                    cycles == 1;
                })
                `uvm_fatal(get_type_name(), "Randomization Fail!");
        end
        finish_item(item);  //send item driver

        start_item(
            item); //wait driver signal 드라이버가 보내달라고 할 때까지 대기 
        for (int i = 0; i < 2 ** 8; i++) begin
            item.we   = 0;
            item.addr = i;
            cycles == 1;
        end
        finish_item(item);  //send item driver
    endtask  //body

endclass  //component 

`endif
