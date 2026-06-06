`ifndef DRIVER_SV
`define DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uart_seq_item.sv"

class uart_driver extends uvm_driver #(uart_seq_item);
    `uvm_component_utils(uart_driver)

    uvm_analysis_port #(uart_seq_item) ap;
    virtual uart_if u_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "u_if", u_if)) begin
            `uvm_fatal(get_type_name(),
                       "Driver에서 uvm_config_db 에러 발생.")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        uart_init();
        wait (u_if.rst == 0);
        `uvm_info(get_type_name(),
                  "리셋 해제 확인, 트랜젝션 대기 중...",
                  UVM_MEDIUM)

        forever begin
            uart_seq_item tx;
            seq_item_port.get_next_item(tx);
            drive_uart(tx);
            ap.write(tx);
            seq_item_port.item_done();
            wait (u_if.drv_cb.tx_done == 1);
            `uvm_info("D_CHECK", $sformatf("%s / tx_done = 1", tx.convert2string()), UVM_DEBUG)
        end
    endtask  //run_phase

    task uart_init();
        u_if.drv_cb.rx <= 1;
    endtask  //uart_init

    task drive_uart(uart_seq_item tx);
        int clk_per_bit;
        clk_per_bit = 100_000_000 / tx.pc_baudrate;

        repeat (tx.delay) @(u_if.drv_cb);

        @(u_if.drv_cb);

        u_if.drv_cb.rx <= 0;
        repeat (clk_per_bit) @(u_if.drv_cb);

        for (int i = 0; i < 8; i++) begin
            u_if.drv_cb.rx <= tx.data[i];
            repeat (clk_per_bit) @(u_if.drv_cb);
        end

        u_if.drv_cb.rx <= 1;
        repeat (clk_per_bit) @(u_if.drv_cb);

        `uvm_info(get_type_name(), $sformatf("drv uart 구동 완료 : %s", tx.convert2string()), UVM_MEDIUM)

    endtask  //drive_uart

endclass  //component 

`endif
