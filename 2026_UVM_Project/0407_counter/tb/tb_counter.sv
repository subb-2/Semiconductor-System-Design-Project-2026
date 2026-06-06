`include "uvm_macros.svh"
import uvm_pkg::*;

interface counter_if (
    input logic clk
);
    logic       rst_n;
    logic       enable;
    logic [3:0] count;
endinterface  //counter_if

//transaction
class counter_seq_item extends uvm_sequence_item;
    //object 부류
    rand bit       rst_n;
    rand bit       enable;
    rand bit       cycles;
    logic    [3:0] count;

    //{} 안의 값을 랜덤 값으로 대입하겠다.
    //시간제어 변수 
    constraint cycles {cycles inside {[1 : 20]};}

    //필드 변수값을 factory에 등록
    `uvm_object_utils_begin(counter_seq_item)
        `uvm_field_int(rst_n, UVM_ALL_ON)
        `uvm_field_int(enable, UVM_ALL_ON)
        `uvm_field_int(cycles, UVM_ALL_ON)
        `uvm_field_int(count, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "counter_seq_item");
        super.new(name);
    endfunction  //new()

    //한 번에 읽는 방법
    //factory 묶음을 주고 받고?
    //convert2string : 현재 객체 값을 사람이 읽기 쉬운 문자열로 바꿔주는 함수
    function string convert2string;
        return $sformatf(
            "rst_n=%0b enable=%0b cycles=%0d count=%0h",
            rst_n,
            enable,
            cycles,
            count
        );
    endfunction

endclass  //counter_seq_item

class counter_reset_seq extends uvm_sequence #(counter_seq_item);
    `uvm_object_utils(counter_reset_seq)

    //구조에 등록시키기 위함
    function new(string name = "counter_reset_seq");
        super.new(name);
    endfunction  //new()

    //실제 동작하는 위치 
    virtual task body();
        //class handler
        counter_seq_item item;
        item = counter_seq_item::type_id::create("item");

        //driver와 통신하는 부분 
        start_item(item);
        //item 준비된 상태에서 item 값 대임
        item.rst_n  = 0;
        item.enable = 0;
        item.cycles = 2;
        finish_item(item);
        `uvm_info(get_type_name(), "Reset Done!", UVM_MEDIUM)
    endtask  //body
endclass  //counter_reset_seq

class counter_count_seq extends uvm_sequence #(counter_seq_item);
    `uvm_object_utils(counter_count_seq)

    int num_transactions;

    //구조에 등록시키기 위함
    function new(string name = "counter_count_seq");
        super.new(name);
        num_transactions = 0;
    endfunction  //new()

    //실제 동작하는 위치 
    virtual task body();
        counter_seq_item item;
        for (int i = 0; i < num_transactions; i++) begin
            //get_type_name()이 $sformatf 이름이라고?
            item = counter_seq_item::type_id::create($sformatf("item_%0d", i));

            start_item(item);
            //실제 동작하는 값 
            //with는 조건 하에 랜덤을 만들라는 의미 
            if (!item.randomize() with {
                    rst_n == 1;
                    enable == 1;
                    cycles inside {[1 : 5]};
                })
                `uvm_fatal(get_type_name(), "Randomization failed!")
            finish_item(item);

            `uvm_info(
                get_type_name(), $sformatf(
                "[%0d/%0d] %s", i + 1, num_transactions, item.convert2string()),
                UVM_HIGH)
        end
    endtask  //body
endclass  //counter_count_seq

//묶는 역할 
class counter_master_seq extends uvm_sequence #(counter_seq_item);
    `uvm_object_utils(counter_master_seq)

    //구조에 등록시키기 위함
    function new(string name = "counter_master_seq");
        super.new(name);
    endfunction  //new()

    //실제 동작하는 위치 
    virtual task body();
        counter_reset_seq reset_seq;
        counter_count_seq count_seq;

        `uvm_info(get_type_name(), "===== Phase 1 : Reset =====", UVM_MEDIUM)
        reset_seq = counter_reset_seq::type_id::create("reset_seq");
        reset_seq.start(m_sequencer);

        `uvm_info(get_type_name(), "===== Phase 2 : Count =====", UVM_MEDIUM)
        count_seq = counter_count_seq::type_id::create("count_seq");
        count_seq.num_transactions = 5;
        count_seq.start(m_sequencer);

        `uvm_info(get_type_name(), "===== Master Sequence done =====",
                  UVM_MEDIUM)
    endtask  //body
endclass  //counter_master_seq

//uvm component를 상속받겠다.
//이 클래스를 factory에 등록해줘야지
//uvm 동작할 때 동작이 가능함 
class counter_driver extends uvm_driver #(counter_seq_item);
    `uvm_component_utils(counter_driver)
    virtual counter_if c_if;

    function new(string name, uvm_component parent);
        //하이라키 출력이 나올 수 있는 이유 
        super.new(name, parent);
    endfunction  //new()

    //모든 component class는 phase를 가지고 있음 
    //build는 interface 만들고, 설정하는 역할 
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //위의 virtual counter_if c_if; (17)를 읽어서 c_if에 값을 넣겠다.
        //config_db에 저장된 값을 get으로 가져와서 c_if에 저장하는 것 
        //통신이 아니기에 connect가 아니라 build에서 함 
        if (!uvm_config_db#(virtual counter_if)::get(
                this, "", "c_if", c_if
            )) begin
            `uvm_fatal(get_type_name(), "c_if를 찾을 수 없습니다!")
        end
        `uvm_info(get_type_name(), "build_phase 실행 완료.", UVM_HIGH);
    endfunction

    virtual task drive_item(counter_seq_item item);
        c_if.rst_n  <= item.rst_n;
        c_if.enable <= item.enable;
        repeat (item.cycles) @(posedge c_if.clk);
        `uvm_info(get_type_name(), $sformatf("driver_cycles: %0d", item.cycles),
                  UVM_HIGH);
    endtask  //drive_count

    //driver에서 stimulus를 생성해서 넣어주는 형식으로 제작할 것
    virtual task run_phase(uvm_phase phase);
        counter_seq_item item;
        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
            seq_item_port.item_done();
        end
    endtask

endclass  //counter_driver

//받은 값 확인 & 판단 
class counter_monitor extends uvm_monitor;
    `uvm_component_utils(counter_monitor)
    virtual counter_if c_if;
    //판단을 위한 비교 변수 
    int expected_count;

    function new(string name, uvm_component parent);
        //하이라키 출력이 나올 수 있는 이유 
        super.new(name, parent);
        expected_count = 0;
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual counter_if)::get(
                this, "", "c_if", c_if
            )) begin
            `uvm_fatal(get_type_name(), "c_if를 찾을 수 없습니다!")
        end
        `uvm_info(get_type_name(), "build_phase 실행 완료.", UVM_HIGH);
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "run phase 실행", UVM_DEBUG);
        //mon도 rst가 아닐 때 count
        @(posedge c_if.rst_n);

        forever begin
            //mon은 계속 확인하고 있는 것
            @(posedge c_if.clk);
            `uvm_info(get_type_name(), "@(posedge c_if.clk) 대기 실행",
                      UVM_DEBUG);
            #1;
            if (!c_if.rst_n) begin
                expected_count = 0;
            end else if (c_if.enable) begin
                //4bit니까 15까지 count 가능 
                expected_count = (expected_count + 1) % 16;
                if (c_if.count != expected_count) begin
                    `uvm_error(get_type_name(),
                               $sformatf(
                                   "불일치! 예상 = %0d, 실제 = %0d",
                                   expected_count, c_if.count))
                end else begin
                    `uvm_info(get_type_name(), $sformatf(
                              "일치! count = %0d", c_if.count), UVM_LOW)
                end
            end
        end
    endtask

endclass  //counter_monitor

//agent가 할 일이 뭐였지..
//그냥 drv, mon build 하는 것 뿐인거 아닌가? 
class counter_agent extends uvm_agent;
    `uvm_component_utils(counter_agent)

    uvm_sequencer #(counter_seq_item) sqr;

    counter_driver drv;
    counter_monitor mon;

    function new(string name, uvm_component parent);
        //하이라키 출력이 나올 수 있는 이유 
        super.new(name, parent);
    endfunction  //new()

    //모든 component class는 phase를 가지고 있음 
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = uvm_sequencer#(counter_seq_item)::type_id::create("sqr", this);
        `uvm_info(get_type_name(), "sqr 생성", UVM_DEBUG);
        drv = counter_driver::type_id::create("drv", this);
        `uvm_info(get_type_name(), "drv 생성", UVM_DEBUG);
        mon = counter_monitor::type_id::create("mon", this);
        `uvm_info(get_type_name(), "mon 생성", UVM_DEBUG);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass  //counter_agent

class counter_environment extends uvm_env;
    `uvm_component_utils(counter_environment)

    counter_agent agt;

    function new(string name, uvm_component parent);
        //하이라키 출력이 나올 수 있는 이유 
        super.new(name, parent);
        `uvm_info(get_type_name(), "new 실행", UVM_DEBUG);
    endfunction  //new()

    //모든 component class는 phase를 가지고 있음 
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = counter_agent::type_id::create("agt", this);
        `uvm_info(get_type_name(), "agt 생성", UVM_DEBUG);
    endfunction

endclass  //counter_environment

class counter_test extends uvm_test;
    `uvm_component_utils(counter_test)

    counter_environment env;

    function new(string name, uvm_component parent);
        //하이라키 출력이 나올 수 있는 이유 
        super.new(name, parent);
        `uvm_info(get_type_name(), "new 생성", UVM_DEBUG);
    endfunction  //new()

    //모든 component class는 phase를 가지고 있음 
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = counter_environment::type_id::create("env", this);
        `uvm_info(get_type_name(), "env 생성", UVM_DEBUG);
    endfunction

    virtual task run_phase(uvm_phase phase);

        //counter_master_seq seq;

        counter_reset_seq reset_seq;
        counter_count_seq count_seq;

        phase.raise_objection(this);
        //seq = counter_master_seq::type_id::create("seq");
        //seq.start(env.agt.sqr);
        reset_seq = counter_reset_seq::type_id::create("reset_seq");
        reset_seq.start(env.agt.sqr);
        count_seq = counter_count_seq::type_id::create("count_seq");
        count_seq.num_transactions = 10;
        count_seq.start(env.agt.sqr);
        
        #100;
        phase.drop_objection(this);

    endtask  //run_phase

    //왜 여기서 report 하는게 맞아?
    //error가 있으면 fail
    virtual function void report_phase(uvm_phase phase);
        //super.report_phase(phase);
        //sim 중에 출력되는 메시지 모두 수집 역할 
        uvm_report_server svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) == 0) begin
            `uvm_info(get_type_name(), "===== TEST PASS ! =====", UVM_LOW)
        end else begin
            `uvm_info(get_type_name(), "===== TEST FAIL ! =====", UVM_LOW)
        end
    endfunction

endclass  //counter_test

module tb_counter ();
    logic clk;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    counter_if c_if (clk);

    //counter dut가 인스턴스 이름 
    counter dut (
        .clk(clk),
        .rst_n(c_if.rst_n),
        .enable(c_if.enable),
        .count(c_if.count)
    );

    initial begin
        //interface를 config_db 저장소에 넣기
        //(type), "c_if" : key 값, c_if : 실제 저장되는 값 
        uvm_config_db#(virtual counter_if)::set(null, "*", "c_if", c_if);
        run_test("counter_test");
    end

endmodule
