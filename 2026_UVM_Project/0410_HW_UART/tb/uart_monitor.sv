`ifndef MONITOR_SV
`define MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"

class uart_monitor extends uvm_monitor;
    `uvm_component_utils(uart_monitor)

    uvm_analysis_port #(uart_seq_item) ap;
    virtual uart_if u_if;


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "u_if", u_if)) begin
            `uvm_fatal(get_type_name(), "monitor에서 uvm_config_db 에러 발생.")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "UART 모니터링 시작 ...",
                  UVM_MEDIUM)

        forever begin
            collect_transaction();
        end
    endtask  //run_phase

    task collect_transaction ();

        uart_seq_item tx;

        int clk_per_bit;
        clk_per_bit = 100_000_000 / 9600;
        
        tx = uart_seq_item::type_id::create("mon_tx");

        wait(u_if.mon_cb.tx == 0); 
        
        repeat (clk_per_bit + (clk_per_bit/2)) @(u_if.mon_cb);


        for (int i = 0; i < 8; i++) begin
            //sw 변수이므로, = 사용 
            tx.data[i] = u_if.mon_cb.tx;
            repeat (clk_per_bit) @(u_if.mon_cb);
        end

        `uvm_info(get_type_name(),
                      $sformatf("mon tx: %s", tx.convert2string()), UVM_MEDIUM)

        ap.write(tx);

        `uvm_info(get_type_name(), $sformatf("drv uart 구동 완료 : %s", tx.convert2string()), UVM_MEDIUM)

    endtask //collect_transaction

endclass  //component 

`endif
