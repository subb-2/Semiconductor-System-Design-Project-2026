//UVM에서 제공하는 매크로 파일 가져오는 것
//UVM 전용 문법들을 사용하기 위해  
`include "uvm_macros.svh" 
//UVM 패키지 안에 있는 클래스와 기능들 가져오는 것 
//UVM 안에 있는 이름들을 코드에서 바로 쓸 수 있게 
import uvm_pkg::*;

//class 선언 
//uvm_test를 상속받아서 만들겠다는 것 
//uvm_test는 UVM에서 제공하는 기본 테스트 클래스 
//hello_test는 그 기능을 물려받아서 만든 사용자 테스트 
//uvm_test = 기본 뼈대
//hello_test = 내가 만든 테스트 
class hello_test extends uvm_test;
    //factory 등록 매크로
    //UVM에서는 테스트나 컴포넌트를 그냥 막 생성하는 게 아니라,
    //factory라는 등록 시스템을 통해 관리
    //hello_test라는 클래스를 UVM이 인식하고 생성할 수 있게 등록 
    //세미콜론 없어도 됨
    //extends -> 상속 받는 것 
    //다형성 기능을 하기위해 등록시켜주는 것 
    `uvm_component_utils(hello_test)

    //class의 멤버 변수
    int loop_count;
    
    //생성자 함수 
    //제일 먼저 부르는 함수 
    //클래스 객체가 만들어질 때 자동으로 호출됨 
    //name = 객체 이름
    //parent = 상위 컴포넌트 -> test는 보통 최상위라 parent가 null인 경우 많음 
    function new(string name = "hello_test", uvm_component parent = null);
        //super = 부모 클래스 의미 
        //부모 클래스 안에 있는 new를 불러서 등록 
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        loop_count = 0;       
        `uvm_info("PHASE", "[1] build_phase - loop_count = 0 초기화 ", UVM_LOW);        
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("PHASE", "[2] connect_phase - 컴포넌트를 서로 연결하는 단계", UVM_LOW);        
    endfunction

    //run_phase = 실행 단계 
    virtual task run_phase (uvm_phase phase);
        phase.raise_objection(this); //uvm 내부 동작을 끝내지 마라 
        `uvm_info("PHASE", "[3] run_phase - 시뮬레이션 실행 시작!", UVM_LOW);        
        
        //반복 테스트 
        //run phase 안에 반복문 넣을 수 있음 
        for(int i = 0; i < 5; i++) begin
            loop_count = (i + 1);
            `uvm_info("LOOP", $sformatf("테스트 반복 %0d/5 실행 중...", loop_count), UVM_LOW)
            #10;
        end

        `uvm_info("PHASE", "[3] run_phase - 시뮬레이션 실행 완료!", UVM_LOW);        
        #100;
        phase.drop_objection(this); //uvm 내부 동작을 끝내도 좋다 
    endtask //run_phase

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("PHASE", $sformatf("[4] report_phase - loop_count %0d 동작", loop_count), UVM_LOW);        
    endfunction

endclass //hello_test extends uvm_test

//top module
module test_uvm ();
    initial begin
        //class 호출해서 run_phase 실행
        run_test("hello_test");
    end
endmodule