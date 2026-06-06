`ifndef COVERAGE_SV
`define COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class ram_coverage extends uvm_subscriber#(ram_seq_item);
    `uvm_component_utils(ram_coverage)

    ram_seq_item item;

    covergroup ram_cg;
        cp_we: coverpoint item.we {bins write = {1}; bins read = {1};}
        cp_addr: coverpoint item.addr {
            bins zero = {8'h00};
            bins low = {[8'h01 : 8'h3F]};
            bins mid1 = {[8'h40 : 8'h7F]};
            bins mid2 = {[8'h80 : 8'hBF]};
            bins high = {[8'hC0 : 8'hFE]};
            bins last = {8'hFF};
        }
        cp_wdata: coverpoint item.wdata {
            bins zero = {0};
            bins low = {[1 : 16384]};
            bins mid1 = {[16385 : 32768]};
            bins mid2 = {[32769 : 49152]};
            bins high = {[49153 : 65535]};
            bins last = {65536};
        }
        cp_rdata: coverpoint item.rdata {
            bins zero = {0};
            bins low = {[1 : 16384]};
            bins mid1 = {[16385 : 32768]};
            bins mid2 = {[32769 : 49152]};
            bins high = {[49153 : 65535]};
            bins last = {65536};
        }

        cx_we_addr: cross cp_we, cp_addr;

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ram_cg = new();
    endfunction //new()

    virtual function void write(ram_seq_item t);
        item = t;

        ram_cg.sample();
        `uvm_info(get_type_name(), $sformatf(
                  "ram_cg sampled : %s", item.convert2string()), UVM_MEDIUM)

    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "\n\n===== Coverage Summary =====", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "     Overall : %.1f%%", ram_cg.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "     we : %.1f%%", ram_cg.cp_we.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "     addr : %.1f%%", ram_cg.cp_addr.get_coverage()),
                  UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "     wdata : %.1f%%", ram_cg.cp_wdata.get_coverage()),
                  UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "     rdata : %.1f%%", ram_cg.cp_rdata.get_coverage()),
                  UVM_LOW);
        `uvm_info(
            get_type_name(), $sformatf(
            "     cross(we, addr) : %.1f%%", ram_cg.cx_we_addr.get_coverage()),
            UVM_LOW);
        `uvm_info(get_type_name(), "===== Coverage Summary =====\n\n", UVM_LOW);
    endfunction

endclass //component 

`endif 