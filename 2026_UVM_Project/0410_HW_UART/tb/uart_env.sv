`ifndef ENVIRONMENT_SV
`define ENVIRONMENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_scoreboard.sv"

class uart_env extends uvm_env;
    `uvm_component_utils(uart_env)

    uart_agent agt;
    uart_scoreboard scb;
    uart_coverage_sim cov_sim;
    uart_coverage_data cov_data;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);    
        agt = uart_agent::type_id::create("agt", this);
        scb = uart_scoreboard::type_id::create("scb", this);
        cov_sim = uart_coverage_sim::type_id::create("cov_sim", this);
        cov_data = uart_coverage_data::type_id::create("cov_data", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);    
        super.connect_phase(phase);    
        agt.drv.ap.connect(scb.exp_imp);
        agt.mon.ap.connect(scb.act_imp);
        agt.drv.ap.connect(cov_sim.analysis_export);
        agt.mon.ap.connect(cov_data.analysis_export);
    endfunction

endclass //component 

`endif 