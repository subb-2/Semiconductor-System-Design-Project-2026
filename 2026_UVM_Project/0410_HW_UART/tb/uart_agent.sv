`ifndef AGENT_SV
`define AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"

typedef uvm_sequencer#(uart_seq_item) uart_sequencer;

class uart_agent extends uvm_agent;
    `uvm_component_utils(uart_agent)

    uart_driver drv;
    uart_monitor mon;
    uart_sequencer sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);    
        drv = uart_driver::type_id::create("drv", this);
        mon = uart_monitor::type_id::create("mon", this);
        sqr = uart_sequencer::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);    
        super.connect_phase(phase);    
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass //component 

`endif 