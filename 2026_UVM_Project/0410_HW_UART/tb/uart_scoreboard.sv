`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"
`include "uart_env.sv"

`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)

class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)

    uvm_analysis_imp_exp #(uart_seq_item, uart_scoreboard) exp_imp;
    uvm_analysis_imp_act #(uart_seq_item, uart_scoreboard) act_imp;

    uart_seq_item exp_queue[$];
    //logic [7:0] uart_queue[$];
    uart_seq_item expected;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_imp = new("exp_imp", this);
        act_imp = new("act_imp", this);
    endfunction

    function void write_exp(uart_seq_item tx);
        exp_queue.push_back(tx);
        `uvm_info("SCB_EXP", $sformatf("원본 데이터 도착 및 저장: %0h", tx.data), UVM_HIGH)
    endfunction

    function void write_act(uart_seq_item tx);
        if (exp_queue.size() == 0) begin
            `uvm_error("SCB_FAIL", "정답지 없음!!!!")
            return;
        end

        expected = exp_queue.pop_front();

        if (expected.data !== tx.data) begin
            `uvm_error(get_type_name(), $sformatf("FAIL!! expected = %0h, tx_data = %0h", expected.data, tx.data))
        end else begin
            `uvm_info(get_type_name(), $sformatf("PASS!! expected = %0h, tx_data = %0h", expected.data, tx.data), UVM_MEDIUM)
        end
        
    endfunction

    virtual function void report_phase(uvm_phase phase);

    endfunction

endclass  //component 

`endif
