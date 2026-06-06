`include "uvm_macros.svh"
import uvm_pkg::*;

interface ram_if (
    input logic clk
);
    logic        we;
    logic [ 7:0] addr;
    logic [15:0] wdata;
    logic [15:0] rdata;
endinterface  //ram_if

class ram_seq_item extends uvm_sequence_item;
    rand bit        we;
    rand bit [ 7:0] addr;
    rand bit [15:0] wdata;
    logic    [15:0] rdata;

    `uvm_object_utils_begin(ram_seq_item)
        `uvm_field_int(we, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "ram_seq_item");
        super.new(name);
    endfunction  //new()

    function string convert2string;
        return $sformatf("we = %0b, addr = %0d, wdata = %0d", we, addr, wdata);
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
            }) begin
            `uvm_fatal(get_type_name(), "Randomization failed!")
        end
        finish_item(item);

        `uvm_info(get_type_name(), $sformatf("One Write: %s", item.convert2string()), UVM_LOW)
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
            }) begin
            `uvm_fatal(get_type_name(), "Randomization failed!")
        end
        finish_item(item);

        `uvm_info(get_type_name(), $sformatf("One Read: %s", item.convert2string()), UVM_LOW)
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
                    addr inside {[0 : 5]};
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
                    addr inside {[0 : 5]};
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
            if (!item.randomize() with {addr inside {[0 : 5]};}) begin
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
        #20;

        `uvm_info(get_type_name(), "===== Phase 2 : One Read =====", UVM_MEDIUM)
        one_read_seq = ram_one_read_seq::type_id::create("one_read_seq");
        one_read_seq.start(m_sequencer);
        #20;

        `uvm_info(get_type_name(), "===== Phase 3 : Write =====", UVM_MEDIUM)
        write_seq = ram_write_seq::type_id::create("write_seq");
        write_seq.num_transactions = 10;
        write_seq.start(m_sequencer);
        #20;

        `uvm_info(get_type_name(), "===== Phase 4 : Read =====", UVM_MEDIUM)
        read_seq = ram_read_seq::type_id::create("read_seq");
        read_seq.num_transactions = 10;
        read_seq.start(m_sequencer);
        #20;

        `uvm_info(get_type_name(), "===== Phase 5 : Both =====", UVM_MEDIUM)
        both_seq = ram_both_seq::type_id::create("both_seq");
        both_seq.num_transactions = 10;
        both_seq.start(m_sequencer);
        #20;

        `uvm_info(get_type_name(), "===== Master Sequence done =====",
                  UVM_MEDIUM)

    endtask  //body
endclass  //ram_master_seq

class ram_driver extends uvm_driver #(ram_seq_item);
    `uvm_component_utils(ram_driver)
    virtual ram_if ram_if;

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
        @(negedge ram_if.clk);
        ram_if.we <= item.we;
        ram_if.addr <= item.addr;
        ram_if.wdata <= item.wdata;
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

    logic [15:0] expected_ram[0:255];
    //logic [7:0] pre_addr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        //for (int i = 0; i < 256; i++) begin
        //    expected_ram[i] = 0;
        //end
        //pre_addr = 0;
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
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
        @(posedge ram_if.clk);
        #1;

        if (ram_if.we === 1'b1) begin
            expected_ram[ram_if.addr] = ram_if.wdata;

            `uvm_info(
                get_type_name(),
                $sformatf(
                    "WRITE MONITOR addr = %0d, wdata = %0d",
                    ram_if.addr, ram_if.wdata
                ),
                UVM_DEBUG
            );
        end
        else if (ram_if.we === 1'b0) begin
            if (expected_ram[ram_if.addr] === ram_if.rdata) begin
                `uvm_info(
                    get_type_name(),
                    $sformatf(
                        "PASS! addr = %0d, expected_data = %0d, rdata = %0d",
                        ram_if.addr,
                        expected_ram[ram_if.addr],
                        ram_if.rdata
                    ),
                    UVM_LOW
                );
            end
            else begin
                `uvm_error(
                    get_type_name(),
                    $sformatf(
                        "FAIL!! expected_data = %0d, rdata = %0d, check_addr = %0d",
                        expected_ram[ram_if.addr],
                        ram_if.rdata,
                        ram_if.addr
                    )
                );
            end
        end
    end
endtask
endclass  //ram_monitor

class ram_agent extends uvm_agent;
    `uvm_component_utils(ram_agent)

    uvm_sequencer #(ram_seq_item) sqr;
    ram_driver drv;
    ram_monitor mon;

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
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass  //ram_agent

class ram_environment extends uvm_env;
    `uvm_component_utils(ram_environment)

    ram_agent agt;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "new generation", UVM_DEBUG);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = ram_agent::type_id::create("agt", this);
        `uvm_info(get_type_name(), "agt generation", UVM_DEBUG);
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
