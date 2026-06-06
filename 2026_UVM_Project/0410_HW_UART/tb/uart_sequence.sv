`ifndef UART_SEQUENCE_SV
`define UART_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"

class uart_seq extends uvm_sequence#(uart_seq_item);
    `uvm_object_utils(uart_seq)

    function new(string name = "uart_seq");
        super.new(name);
    endfunction //new()

    virtual task body ();
        
    endtask //body

endclass //component 

class uart_rand_data_seq extends uart_seq;
    `uvm_object_utils(uart_rand_data_seq)

    int num_loop = 0;

    function new(string name = "uart_rand_data_seq");
        super.new(name);
    endfunction  //new()

    virtual task body ();
        repeat(num_loop) begin
            uart_seq_item item = uart_seq_item::type_id::create("item");
            start_item(item);
                if(!item.randomize()) 
                `uvm_fatal(get_type_name(), "Randomize() Fail!")
            finish_item(item);
        end     
    endtask //body


endclass //uart_rand_data_seq

`endif 