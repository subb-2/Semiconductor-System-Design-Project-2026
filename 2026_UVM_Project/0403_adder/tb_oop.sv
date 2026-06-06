//UVM 아니고, 그냥 상속 이해를 위한 것 
//부모 클래스 
class base_packet;
    //멤버 변수 
    bit [7:0] addr;
    bit [31:0] data;

    function new(bit [7:0] addr, bit [31:0] data);
        //this. 은 멤버 변수고 = 뒤에 있는 것은 매개 변수 
        //멤버 변수에 매개변수를 넣겠다. 
        this.addr = addr;
        this.data = data;        
    endfunction //new()

    virtual function void print();
        $display(" [Base] addr = 0x%02h, data = 0x%08h", addr, data);
    endfunction

    virtual function int get_size();
        return 5;
    endfunction
endclass //base_packet

//자식 클래스 
//상속 -> 확장  (상속보다 확장이라는 말이 더 잘 맞음)
//상속을 받아서 checksum 을 추가 
class ext_packet extends base_packet;
    //멤버 변수 
    //부모가 가진 멤버 변수 + checksum 변수 
    bit [15:0] checksum;

    //생성자 new 
    //instance 생성할 때 처음으로 호출 
    function new(bit [7:0] addr, bit [31:0] data, bit [15:0] checksum);
        //부모 멤버 변수에 대입
        super.new(addr, data);
        //현재 class의 멤버 변수에 대입 
        this.checksum = checksum;
    endfunction //new()

    virtual function void print();
        $display("  [Extended] addr = 0x%02h, data = 0x%08h, checksum = 0x%04h", addr, data, checksum);
        
    endfunction

    virtual function int get_size();
        return super.get_size() + 2;
    endfunction
endclass //ext_packet 

module tb_oop();
    initial begin
        //handler 생성 
        base_packet bp;
        ext_packet ep;
        //handler에 instance의 주소를 대입  
        bp = new(8'haa, 32'h1111_2222);
        ep = new(8'hbb, 32'h33333_4444, 16'hff00);

        $display("==== 기본 패킷 ====");
        bp.print();
        $display("  크기 : %0d byte", bp.get_size());

        $display("==== 확장 패킷 ====");
        ep.print();
        $display("  크기 : %0d byte", ep.get_size());
    end
    
endmodule