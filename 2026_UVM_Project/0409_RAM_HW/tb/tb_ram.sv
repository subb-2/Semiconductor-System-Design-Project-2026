`include "uvm_macros.svh"
import uvm_pkg::*;

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

class ram_one_write_seq extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_one_write_seq)

    function new(string name = "counter_master_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
        ram_seq_item item;
        item = ram_seq_item::type_id::create($sformatf("item"));

        start_item(item);
        if (!item.randomize() with {
                we == 1;
                addr == 10;
                wdata == 10;
                cycles inside {[1 : 5]};
            }) begin
            `uvm_fatal(get_type_name(), "Randomization failed!")
        end
        finish_item(item);

        `uvm_info(get_type_name(), $sformatf("One Write: %s",
                                             item.convert2string()), UVM_LOW)
    endtask  //body
endclass  //ram_one_write_seq

class ram_one_read_seq extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_one_read_seq)

    function new(string name = "counter_master_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
        ram_seq_item item;
        item = ram_seq_item::type_id::create($sformatf("item"));

        start_item(item);
        if (!item.randomize() with {
                we == 0;
                addr == 10;
                wdata == 10;
                cycles inside {[1 : 5]};
            }) begin
            `uvm_fatal(get_type_name(), "Randomization failed!")
        end
        finish_item(item);

        `uvm_info(get_type_name(), $sformatf("One Read: %s",
                                             item.convert2string()), UVM_LOW)
    endtask  //body
endclass  //ram_one_read_seq

class ram_write_seq extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_write_seq)

    int num_transactions;

    function new(string name = "counter_master_seq");
        super.new(name);
        num_transactions = 0;
    endfunction  //new()

    virtual task body();
        ram_seq_item item;
        for (int i = 0; i < num_transactions; i++) begin
            item = ram_seq_item::type_id::create($sformatf("item_%0d", i));

            start_item(item);
            if (!item.randomize() with {
                    we == 1;
                    //addr inside {[0 : 5]};
                    cycles inside {[1 : 5]};
                }) begin
                `uvm_fatal(get_type_name(), "Randomization failed!")
            end
            finish_item(item);

            `uvm_info(
                get_type_name(), $sformatf(
                "[%0d/%0d] %s", i + 1, num_transactions, item.convert2string()),
                UVM_HIGH)
        end
    endtask  //body
endclass  //ram_write_seq

class ram_read_seq extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_read_seq)

    int num_transactions;

    function new(string name = "counter_master_seq");
        super.new(name);
        num_transactions = 0;
    endfunction  //new()

    virtual task body();
        ram_seq_item item;
        for (int i = 0; i < num_transactions; i++) begin
            item = ram_seq_item::type_id::create($sformatf("item_%0d", i));

            start_item(item);
            if (!item.randomize() with {
                    we == 0;
                    //addr inside {[0 : 5]};
                    cycles inside {[1 : 5]};
                }) begin
                `uvm_fatal(get_type_name(), "Randomization failed!")
            end
            finish_item(item);

            `uvm_info(
                get_type_name(), $sformatf(
                "[%0d/%0d] %s", i + 1, num_transactions, item.convert2string()),
                UVM_HIGH)
        end
    endtask  //body
endclass  //ram_read_seq

class ram_both_seq extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_both_seq)

    int num_transactions;

    function new(string name = "counter_master_seq");
        super.new(name);
        num_transactions = 0;
    endfunction  //new()

    virtual task body();
        ram_seq_item item;
        for (int i = 0; i < num_transactions; i++) begin
            item = ram_seq_item::type_id::create($sformatf("item_%0d", i));

            start_item(item);
            if (!item.randomize() with {
                    //addr inside {[0 : 5]};
                    cycles inside {[1 : 5]};
                }) begin
                `uvm_fatal(get_type_name(), "Randomization failed!")
            end
            finish_item(item);

            `uvm_info(
                get_type_name(), $sformatf(
                "[%0d/%0d] %s", i + 1, num_transactions, item.convert2string()),
                UVM_HIGH)
        end
    endtask  //body
endclass  //ram_both_seq

class ram_master_seq extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_master_seq)

    function new(string name = "counter_master_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
        ram_one_write_seq one_write_seq;
        ram_one_read_seq one_read_seq;
        ram_write_seq write_seq;
        ram_read_seq read_seq;
        ram_both_seq both_seq;

        `uvm_info(get_type_name(), "===== Phase 1 : One Write =====",
                  UVM_MEDIUM)
        one_write_seq = ram_one_write_seq::type_id::create("one_write_seq");
        one_write_seq.start(m_sequencer);
        //#10;

        `uvm_info(get_type_name(), "===== Phase 2 : One Read =====", UVM_MEDIUM)
        one_read_seq = ram_one_read_seq::type_id::create("one_read_seq");
        one_read_seq.start(m_sequencer);
        //#10;

        `uvm_info(get_type_name(), "===== Phase 3 : Write =====", UVM_MEDIUM)
        write_seq = ram_write_seq::type_id::create("write_seq");
        write_seq.num_transactions = 256;
        write_seq.start(m_sequencer);
        //#10;

        `uvm_info(get_type_name(), "===== Phase 4 : Read =====", UVM_MEDIUM)
        read_seq = ram_read_seq::type_id::create("read_seq");
        read_seq.num_transactions = 256;
        read_seq.start(m_sequencer);
        //#10;

        `uvm_info(get_type_name(), "===== Phase 5 : Both =====", UVM_MEDIUM)
        both_seq = ram_both_seq::type_id::create("both_seq");
        both_seq.num_transactions = 70000;
        both_seq.start(m_sequencer);
        //#10;

        `uvm_info(get_type_name(), "===== Master Sequence done =====",
                  UVM_MEDIUM)

    endtask  //body
endclass  //ram_master_seq

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

class ram_coverage extends uvm_subscriber #(ram_seq_item);
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
    endfunction  //new()

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
endclass  //ram_coverage 

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
