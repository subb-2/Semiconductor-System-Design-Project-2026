`ifndef UART_SEQ_ITEM_SV
`define UART_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_seq_item extends uvm_sequence_item;

    rand bit [7:0] data;
    rand int delay;
    rand int pc_baudrate;

    logic rx;
    logic tx_done;
    logic tx;

    //이게 꼭 필요한가?
    constraint delay_c {delay inside {[1 : 10]};}
    constraint pc_baudrate_c {pc_baudrate inside {[9300 : 9900]};}

    `uvm_object_utils_begin(uart_seq_item)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(delay, UVM_ALL_ON)
        `uvm_field_int(pc_baudrate, UVM_ALL_ON)
        `uvm_field_int(rx, UVM_ALL_ON)
        `uvm_field_int(tx_done, UVM_ALL_ON)
        `uvm_field_int(tx, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "counter_seq_item");
        super.new(name);
    endfunction  //new()

    function string convert2string;
        return $sformatf(
            "data = %h, delay = %0d, pc_baudrate = %0d, rx = %0b, tx_done = %0b, tx = %0b",
            data,
            delay,
            pc_baudrate,
            rx,
            tx_done,
            tx
        );

    endfunction

endclass  //component 

`endif
