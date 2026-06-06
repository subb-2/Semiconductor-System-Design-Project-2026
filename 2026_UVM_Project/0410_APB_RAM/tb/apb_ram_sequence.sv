`ifndef APB_RAM_SEQUENCE_SV
`define APB_RAM_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "apb_ram_seq_item.sv"

class apb_base_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(apb_base_seq)

    int num_loop = 0;

    function new(string name = "apb_base_seq");
        super.new(name);
    endfunction  //new()

    //매개변수로 주소와 데이터를 받고 싶음
    //괄호 안에 입력을 넣는 것 
    //randomize는 의미 없게 되긴 했음 -> 랜덤이 아닌 값을 집어 넣음 
    task do_write(bit [7:0] addr, bit [31:0] data);
        apb_seq_item item;
        item = apb_seq_item::type_id::create("item");
        start_item(item);
        if (!item.randomize() with {
                pwrite == 1'b1;
                paddr == addr;
                pwdata == data;
            })
            `uvm_fatal(get_type_name(), "do_write() Randomize() fail!")
            finish_item(item);
            `uvm_info(get_type_name(), $sformatf("do_write() write 전송 완료: addr = 0x%02h data = 0x%08h", addr, data), UVM_MEDIUM)
    endtask  //do_write

     task do_read(bit [7:0] addr, output bit [31:0] rdata);
        apb_seq_item item;
        item = apb_seq_item::type_id::create("item");
        start_item(item);
        if (!item.randomize() with {
                pwrite == 1'b0;
                paddr == addr;
            })
            `uvm_fatal(get_type_name(), "do_read() Randomize() fail!")
            finish_item(item);
            rdata = item.prdata;
            `uvm_info(get_type_name(), $sformatf("do_read() read 전송 완료: addr = 0x%02h data = 0x%08h", addr, rdata), UVM_MEDIUM)
    endtask  //do_read

    virtual task body();

    endtask  //body

endclass  //component 

class apb_write_read_seq extends apb_base_seq;
    `uvm_object_utils(apb_write_read_seq)

    int num_loop = 0;
    bit [7:0]  addr;
    bit [31:0] wdata;
    bit [31:0] rdata;

    function new(string name = "apb_write_read_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();

        for (int i = 0; i < num_loop; i++) begin
            apb_seq_item item = apb_seq_item::type_id::create("item");

            //지금 뭐가 문제야?
            //addr = (i * 4) % 64;
            addr = (i % 64) * 4;

            wdata = $urandom;

            if (!item.randomize() with {})
                `uvm_fatal(get_type_name(), "Randomization Fail!");
            do_write(addr, wdata);
            do_read(addr, rdata);
        end
    endtask  //body

endclass  //component 

class apb_rand_seq extends apb_base_seq;
    `uvm_object_utils(apb_rand_seq)

    int num_loop = 0;
    bit [7:0] addr;
    bit [7:0] wdata, rdat;

    function new(string name = "apb_rand_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
        repeat(num_loop) begin
            apb_seq_item item = apb_seq_item::type_id::create("item");
            start_item(item);
            if(!item.randomize()) 
                `uvm_fatal(get_type_name(), "Randomize() Fail!")
            finish_item(item);
        end
        
    endtask  //body

endclass  //component 

`endif
