`ifndef COVERAGE_SV
`define COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"

class uart_coverage_sim extends uvm_subscriber #(uart_seq_item);
    `uvm_component_utils(uart_coverage_sim)

    uart_seq_item tx;

    covergroup uart_cg_sim;

        cp_delay: coverpoint tx.delay {
            bins delay_low = {[1 : 5]}; bins delay_high = {[6 : 10]};
        }

        cp_pc_baudrate: coverpoint tx.pc_baudrate {
            bins pc_baudrate_low = {[9300 : 9600]};
            bins pc_baudrate_high = {[9600 : 9900]};
        }

    endgroup


    function new(string name, uvm_component parent);
        super.new(name, parent);
        uart_cg_sim = new();
    endfunction  //new()

    function void write(uart_seq_item t);
        tx = t;
        uart_cg_sim.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== Coverage Summary =====", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "    Overall : %.1f%%", uart_cg_sim.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "    delay : %.1f%%", uart_cg_sim.cp_delay.get_coverage()),
                  UVM_LOW);
        `uvm_info(
            get_type_name(), $sformatf(
            "    pc_baudrate : %.1f%%", uart_cg_sim.cp_pc_baudrate.get_coverage()),
            UVM_LOW);
        `uvm_info(get_type_name(), "===== Coverage Summary =====\n\n", UVM_LOW);

    endfunction

endclass  //component 

class uart_coverage_data extends uvm_subscriber #(uart_seq_item);
    `uvm_component_utils(uart_coverage_data)

    uart_seq_item tx;

    covergroup uart_cg_data;

        cp_data: coverpoint tx.data {
            bins data_low = {[8'h00 : 8'h3F]};
            bins data_mid_low = {[8'h40 : 8'h7F]};
            bins data_mid_high = {[8'h80 : 8'hBF]};
            bins data_high = {[8'hC0 : 8'hFF]};
            bins data_all_zero = {8'h00};
            bins data_all_ones = {8'hFF};
            bins data_a = {8'hAA};
            bins data_5 = {8'h55};
        }

    endgroup


    function new(string name, uvm_component parent);
        super.new(name, parent);
        uart_cg_data = new();
    endfunction  //new()

    function void write(uart_seq_item t);
        tx = t;
        uart_cg_data.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== Coverage Summary =====", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "    Overall : %.1f%%", uart_cg_data.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "    data : %.1f%%", uart_cg_data.cp_data.get_coverage()),
                  UVM_LOW);
        `uvm_info(get_type_name(), "===== Coverage Summary =====\n\n", UVM_LOW);

    endfunction

endclass  //component

`endif
