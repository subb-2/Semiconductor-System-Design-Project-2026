`include "uvm_macros.svh"
import uvm_pkg::*;

`include "ram_sequence.sv"
`include "ram_coverage.sv"
`include "ram_test.sv"

interface ram_if (
    input logic clk
);
    logic        we;
    logic [ 7:0] addr;
    logic [15:0] wdata;
    logic [15:0] rdata;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output we;
        output addr;
        output wdata;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input we;
        input addr;
        input wdata;
        input rdata;
    endclocking

endinterface  //ram_if

class ram_seq_item extends uvm_sequence_item;
    rand bit        we;
    rand bit [ 7:0] addr;
    rand bit [15:0] wdata;
    logic    [15:0] rdata;
    rand int        cycles;

    constraint cycles_c {cycles inside {[1 : 20]};}

    `uvm_object_utils_begin(ram_seq_item)
        `uvm_field_int(we, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(cycles, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "ram_seq_item");
        super.new(name);
    endfunction  //new()

    function string convert2string;
        return $sformatf(
            "we = %0b, addr = %0d, wdata = %0d, cycles = %0d",
            we,
            addr,
            wdata,
            cycles
        );
    endfunction
endclass  //ram_seq_item


class ram_driver extends uvm_driver #(ram_seq_item);
    `uvm_component_utils(ram_driver)
    virtual ram_if ram_if;

    event drv_ev;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ram_if)::get(
                this, "", "ram_if", ram_if
            )) begin
            `uvm_fatal(get_type_name(), "build_phase Run completed");
        end
    endfunction

    virtual task drive_item(ram_seq_item item);
        //@(negedge ram_if.clk);
        ram_if.drv_cb.we <= item.we;
        ram_if.drv_cb.addr <= item.addr;
        ram_if.drv_cb.wdata <= item.wdata;
        `uvm_info(get_type_name(), $sformatf("driver_cycles: %0d", item.cycles),
                  UVM_HIGH);
        `uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM);
        repeat (item.cycles) @(ram_if.drv_cb);
        @(ram_if.drv_cb);
        ->drv_ev;

        //@(ram_if.drv_cb);
    endtask  //drive_item


    virtual task run_phase(uvm_phase phase);
        ram_seq_item item;
        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
            seq_item_port.item_done();
        end
    endtask
endclass  //ram_driver

class ram_monitor extends uvm_monitor;
    `uvm_component_utils(ram_monitor)
    virtual ram_if ram_if;

    event drv_ev;

    uvm_analysis_port #(ram_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual ram_if)::get(
                this, "", "ram_if", ram_if
            )) begin
            `uvm_fatal(get_type_name(), "ram_if not found")
        end
        `uvm_info(get_type_name(), "build_phase execution complete", UVM_HIGH);
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "run phase execution", UVM_DEBUG);
        forever begin
            ram_seq_item item = ram_seq_item::type_id::create("item");
            @(drv_ev);
            //@(posedge ram_if.clk);
            //#1;
            // @(ram_if.mon_cb);
            item.we = ram_if.mon_cb.we;
            item.addr = ram_if.mon_cb.addr;
            item.wdata = ram_if.mon_cb.wdata;
            item.rdata = ram_if.mon_cb.rdata;
            ap.write(item);
            `uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM);
        end

    endtask
endclass  //ram_monitor



class ram_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ram_scoreboard)

    uvm_analysis_imp #(ram_seq_item, ram_scoreboard) ap_imp;

    logic [15:0] expected_ram[0:255];
    int error_data;
    int match_data;
    int write_data;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
        error_data = 0;
        match_data = 0;
        write_data = 0;
    endfunction  //new()

    virtual function void write(ram_seq_item item);
        `uvm_info(get_type_name(), $sformatf(
                  "Received : %s", item.convert2string()), UVM_MEDIUM);

        if (item.we === 1'b1) begin
            expected_ram[item.addr] = item.wdata;
            `uvm_info(
                get_type_name(), $sformatf(
                "WRITE MONITOR addr = %0d, wdata = %0d", item.addr, item.wdata),
                UVM_DEBUG);
            write_data++;
        end else if (item.we === 1'b0) begin
            if (expected_ram[item.addr] === item.rdata) begin
                `uvm_info(get_type_name(), $sformatf(
                          "PASS! addr = %0d, expected_data = %0d, rdata = %0d",
                          item.addr,
                          expected_ram[item.addr],
                          item.rdata
                          ), UVM_LOW);
                match_data++;
            end else begin
                `uvm_error(get_type_name(), $sformatf(
                           "FAIL!! expected_data = %0d, rdata = %0d, check_addr = %0d",
                           expected_ram[item.addr],
                           item.rdata,
                           item.addr
                           ));
                error_data++;
            end
        end

    endfunction

endclass  //ram_scoreboard

class ram_agent extends uvm_agent;
    `uvm_component_utils(ram_agent)

    uvm_sequencer #(ram_seq_item) sqr;
    ram_driver drv;
    ram_monitor mon;

    event drv_ev;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "new generation", UVM_DEBUG);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = uvm_sequencer#(ram_seq_item)::type_id::create("sqr", this);
        `uvm_info(get_type_name(), "sqr generation", UVM_DEBUG);
        drv = ram_driver::type_id::create("drv", this);
        `uvm_info(get_type_name(), "drv generation", UVM_DEBUG);
        mon = ram_monitor::type_id::create("mon", this);
        `uvm_info(get_type_name(), "mon generation", UVM_DEBUG);

        drv.drv_ev = drv_ev;
        mon.drv_ev = drv_ev;
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass  //ram_agent

class ram_environment extends uvm_env;
    `uvm_component_utils(ram_environment)

    ram_agent agt;
    ram_scoreboard scb;
    ram_coverage cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "new generation", UVM_DEBUG);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = ram_agent::type_id::create("agt", this);
        scb = ram_scoreboard::type_id::create("scb", this);
        cov = ram_coverage::type_id::create("cov", this);
        `uvm_info(get_type_name(), "agt generation", UVM_DEBUG);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.ap.connect(scb.ap_imp);
        agt.mon.ap.connect(cov.analysis_export);
    endfunction
endclass  //ram_environment

class ram_test extends uvm_test;
    //seq, env 생성
    `uvm_component_utils(ram_test)

    ram_environment env;
    ram_master_seq  seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "new generation", UVM_DEBUG);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ram_environment::type_id::create("env", this);
        `uvm_info(get_type_name(), "env generation", UVM_DEBUG);
        seq = ram_master_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "seq generation", UVM_DEBUG);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq.start(env.agt.sqr);
        #100;
        phase.drop_objection(this);
    endtask

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) == 0) begin
            `uvm_info(get_type_name(), "===== TEST PASS ! =====", UVM_LOW)
        end else begin
            `uvm_info(get_type_name(), "===== TEST FAIL ! =====", UVM_LOW)
        end
    endfunction
endclass  //ram_test

module tb_ram ();

    logic clk;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    ram_if ram_if (clk);

    ram dut (
        .clk  (clk),
        .we   (ram_if.we),
        .addr (ram_if.addr),
        .wdata(ram_if.wdata),
        .rdata(ram_if.rdata)
    );

    initial begin
        //
        uvm_config_db#(virtual ram_if)::set(null, "*", "ram_if", ram_if);
        run_test("ram_test");
    end
endmodule
