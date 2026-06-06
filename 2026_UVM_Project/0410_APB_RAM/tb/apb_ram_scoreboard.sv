`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "apb_ram_seq_item.sv"

class apb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(apb_scoreboard)

    //통신 통로
    uvm_analysis_imp #(apb_seq_item, apb_scoreboard) ap_imp;

    //reference 값 만들기
    logic [31:0] ref_mem[0:(2**6-1)];
    logic [31:0] expected;

    int num_writes = 0;
    int num_reads = 0;
    int num_errors = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    //scb, cov 경우에는 report 까지 하는 경우도 있음
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(apb_seq_item tx);
        if (tx.pwrite) begin
            //write일 때 저장
            //>>2 해줘야지 맞춰서 들어간다고? %4 했던거 때문인가? 
            ref_mem[tx.paddr>>2] = tx.pwdata;
            num_writes++;
        end else begin
            //read일 때 빼기
            num_reads++;
            expected = ref_mem[tx.paddr>>2];
            if (expected !== tx.prdata) begin
                num_errors++;
                `uvm_error(
                    get_type_name(),
                    $sformatf(
                        "FAIL! paddr = 0x%02h, expected = 0x%08h, prdata = 0x%08h",
                        tx.paddr, expected, tx.prdata))
            end else begin
                `uvm_info(get_type_name(), $sformatf(
                          "PASS! paddr = 0x%02h, expected = 0x%08h, prdata = 0x%08h",
                          tx.paddr,
                          expected,
                          tx.prdata
                          ), UVM_MEDIUM)
            end
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        string result = (num_errors == 0) ? "** PASS **" : "** FAIL **";
        `uvm_info(get_type_name(), "************* summary report ***************", UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Result : %s", result), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Write num : %0d", num_writes), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Read num : %0d", num_reads), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Error num : %0d", num_errors), UVM_MEDIUM)
        `uvm_info(get_type_name(), "*******************************************", UVM_MEDIUM)
    endfunction

endclass  //component 

`endif
