`include "uvm_macros.svh"
import uvm_pkg::*;

interface adder_if;
    logic [7:0] a;
    logic [7:0] b;
    logic [8:0] y;
endinterface  //adder_if

class adder_seq_item extends uvm_sequence_item;
    rand logic [7:0] a;
    rand logic [7:0] b;
    logic      [8:0] y;

    function new(string name = "ADDER_SEQ_ITEM");
        super.new(name);
    endfunction  //new()

    `uvm_object_utils_begin(adder_seq_item)
        `uvm_field_int(a, UVM_DEFAULT)
        `uvm_field_int(b, UVM_DEFAULT)
        `uvm_field_int(y, UVM_DEFAULT)
    `uvm_object_utils_end
endclass  //adder_seq_item 

class adder_sequence extends uvm_sequence;
    //sequence는 object의 상속을 받고 있음 
    //factory에 adder_sequence 등록 macro
    `uvm_object_utils(adder_sequence)

    //sequence 안에 sequence item이 있는 것 
    adder_seq_item a_seq_item;

    //이름만 부모 클래스한테 알려주는 것 
    //그럼 component는 왜 c 까지 알려줘야 해?
    function new(string name = "ADDER_SEQUENCE");
        super.new(name);
    endfunction  //new()

    virtual task body();
        a_seq_item = adder_seq_item::type_id::create("SEQ_ITEM");

        repeat (100) begin
            start_item(a_seq_item);
            if (!a_seq_item.randomize()) begin
                `uvm_error("SEQ_ITEM", "Fail to generate random value!");
            end
            `uvm_info("SEQ", "Data send to Driver", UVM_NONE);
            finish_item(a_seq_item);
        end
    endtask  //body
endclass  //adder_sequence 

class adder_driver extends uvm_driver #(adder_seq_item);
    `uvm_component_utils(adder_driver)

    virtual adder_if a_if;
    adder_seq_item   a_seq_item;

    function new(string name = "ADDER_DRV", uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_seq_item = adder_seq_item::type_id::create("SEQ_ITEM", this);
        if (!uvm_config_db#(virtual adder_if)::get(
                this, "", "a_if", a_if
            )) begin
            `uvm_fatal(get_name(), "Unable to access adder interface");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        $display("Display run phase");
        forever begin
            seq_item_port.get_next_item(a_seq_item);
            a_if.a <= a_seq_item.a;
            a_if.b <= a_seq_item.b;
            #10;
            //#10;
            seq_item_port.item_done();
        end
    endtask  //run_phase
endclass  //adder_driver

//부모가 component 
class adder_monitor extends uvm_monitor;
    `uvm_component_utils(adder_monitor)

    //port는 다이아몬드 모양 만들어 준 것 
    uvm_analysis_port #(adder_seq_item) send;
    virtual adder_if a_if;
    //mon이 받은 것을 seq item에 넣기
    adder_seq_item a_seq_item;

    function new(string name = "ADDER_MON", uvm_component c);
        super.new(name, c);
        send = new("WRITE", this);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_seq_item = adder_seq_item::type_id::create("SEQ_ITEM", this);
        if (!uvm_config_db#(virtual adder_if)::get(
                this, "", "a_if", a_if
            )) begin
            `uvm_fatal(get_name(), "Unable to access adder interface");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            //mon을 읽어야 함
            //그리고 읽은 값을 넣어야 함
            #10;
            a_seq_item.a = a_if.a;
            a_seq_item.b = a_if.b;
            //#10;
            a_seq_item.y = a_if.y;
            `uvm_info("MON", "Send data to Scoreboard", UVM_LOW);
            send.write(a_seq_item);
        end
    endtask  //run_phase
endclass  //adder_monitor 

class adder_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(adder_scoreboard)
    uvm_analysis_imp #(adder_seq_item, adder_scoreboard) recv;

    function new(string name = "ADDER_SCB", uvm_component c);
        super.new(name, c);
        recv = new("READ", this);
    endfunction  //new()

    virtual function void write(adder_seq_item data);
        `uvm_info("SCB", "Data received from Monitor", UVM_LOW);
        if (data.a + data.b == data.y) begin
            `uvm_info("SCB", $sformatf("PASS!, a:%0d + b:%0d = y:%0d", data.a,
                                       data.b, data.y), UVM_LOW);
        end else begin
            `uvm_error("SCB", $sformatf(
                       "FAIL!, a:%0d + b:%0d != y:%0d", data.a, data.b, data.y
                       ));
        end
    endfunction
endclass  //adder_scoreboard 

//component 아래 agent 존재 
class adder_agent extends uvm_agent;
    `uvm_component_utils(adder_agent)

    adder_monitor a_mon;
    adder_driver a_drv;
    //괄호 안에는 클래스 이름 넣어주기 
    //uvm 라이브러리에 있는 것을 가져다 사용 
    //코드 구현은 안해줘도 됨, mon, drv 두 가지만 코드 구현 하면 됨 
    uvm_sequencer#(adder_seq_item) a_sqr;

    function new(string name = "ADDER_AGENT", uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_mon = adder_monitor::type_id::create("MON", this);
        a_drv = adder_driver::type_id::create("DRV", this);
        a_sqr = uvm_sequencer#(adder_seq_item)::type_id::create("SQR", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //drv와 sqr 간의 연결 
        a_drv.seq_item_port.connect(a_sqr.seq_item_export);
    endfunction
endclass  //adder_agent

class adder_environment extends uvm_env;
    //uvm 상속받아서 새롭게 정의하는 것 
    //factory에 adder_environment를 등록하는 `macro 
    `uvm_component_utils(adder_environment)  //add factory
    //env는 agent와 scb를 만든다.

    adder_agent a_agt;
    adder_scoreboard a_scb;

    function new(string name = "ADDER_ENV", uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_agt = adder_agent::type_id::create("AGT", this);
        a_scb = adder_scoreboard::type_id::create("SCB", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //mon과 scb 연결 
        a_agt.a_mon.send.connect(a_scb.recv);
    endfunction

endclass  //adder_environment

//test 블록 구현
//uvm_test를 상속받는 adder_test
//트리거로 불려지면서 인스턴스 만들어짐 
//uvm_test를 상속받음 
class adder_test extends uvm_test;
    //uvm_test의 부모 class는 component 
    //factory에 adder_test class를 등록시키는 것 
    //등록시키는 매크로 
    //기본 틀에 내가 생성한 클래스를 알려줘야함 
    //괄호 안에는 클래스 이름 들어감
    //factory에 등록하는 매크로 
    `uvm_component_utils(adder_test)  //add factory

    //sequence와 env를 만든다.
    //핸들러 2개 필요
    //test가 sequence와 env를 생성시킨다.
    adder_sequence a_seq;
    adder_environment a_env;

    //부모 클래스에 이름 알려주는 것 
    //c = component로 이런 식으로 많이 적음 
    function new(string name = "ADDER_TEST", uvm_component c);
        super.new(name, c);
    endfunction  //new()

    //build_phase가 동작하면서 해당 phase를 동작시킨다. 
    //핸들러에 인스턴스한 값의 주소를 리턴해준다.
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //factory가 인스턴스 생성 
        a_seq = adder_sequence::type_id::create("SEQ", this);
        a_env = adder_environment::type_id::create("ENV", this);
    endfunction


    virtual task run_phase(uvm_phase phase);
        //objection을 안하면, 동작을 아에 안하게 되어버림
        //실행이 되기 전에 그냥 끝나버림
        //fork-join 생각하면 됨

        phase.raise_objection(this);
        //a_seq의 멤버인 start에 env의 멤버인 agt의 멤버인 sqr
        //sequencer와 sequence를 연결하겠다는 의미 
        //연결하면서 start 해준다.
        a_seq.start(a_env.a_agt.a_sqr);
        //#1000;
        //`uvm_info(get_type_name(), "Objection Test Message!", UVM_LOW);
        phase.drop_objection(this);
    endtask  //

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

endclass  //adder_test 

module tb_adder ();

    // interface 블록 생성 
    adder_if a_if ();

    //dut 블록 생성 
    adder dut (
        //interface와 dut 연결 
        .a(a_if.a),
        .b(a_if.b),
        .y(a_if.y)
    );

    initial begin
        //verdi에서 자세하게 보려면, fsdb가 필요함
        //dump 해서 build 디렉토리 밑에 wave.fsdb를 만들어라.
        //0의 의미는 -> 
        //디버깅용 
        $fsdbDumpvars(0);
        $fsdbDumpfile("build/wave.fsdb");
    end

    initial begin
        //config 설정하는 db인데, a_if가 들어가 있음
        //db 안에 a_if를 넣어놓고, drv와 mon이 생성되면서, a_if를 가져다가 사용하는 것 
        //db라는 외부 저장소에 interface 정보를 임시 저장시키는 것 
        //가상 인터페이스를 저장하는 것 
        //저장되는 데이터 type을 #괄호 안에 적기
        //::는 하나의 멤버 의미 -> .의 의미와 비슷하면서 다름
        //.은 driver.reset(); -> 드라이버가 이미 인스턴스로 만들어져있어서, 인스턴스의 멤버 의미
        //::는 클래스의 멤버를 의미
        //set이라는 함수를 통해서 가상의 인터페이스를 저장하겠다는 의미
        //tb_adder가 uvm_config_db를 부른 것

        //null은 호출 주체 (context) tb_adder가 주체인데,
        //tb_adder는 component가 아니기 때문에 null을 넣음

        //component이면, this를 넣어줌 
        //"*"는 받을 수 있는 대상의 경로 (위치가 그렇다는 것)
        //"*"는 모든 컴포넌트가 받을 수 있다는 의미 
        //"a_if" 는 key 이름 (문자열) , get 할 때 이 이름으로 찾는다.
        //키 값의 이름을 기준으로 저장되어있는 값을 읽어오는 것
        //a_if : 실제 저장할 값 (instance)
        uvm_config_db#(virtual adder_if)::set(null, "*", "a_if", a_if);
        //test bench를 실행시키라는 트리거 
        //uvm test로 상속받은 클래스 이름 
        //트리거 역할 uvm factory 동작 트리거 
        //adder_test 는 uvm_test를 상속 받은 class 이름 
        //adder test를 instance 시키고 동작시킨다. 
        //run_test라는 트리고 안에 인스턴스 시키고 실체화 시키고 동작시키는 것이 들어 있음 
        run_test("adder_test");
    end

endmodule
