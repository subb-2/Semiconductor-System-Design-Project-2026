class weapon;
    string name;

    function new(string name);
        this.name = name;        
    endfunction //new()

    virtual function void shot();
        $display(" [%s] ... (소리 없음)", name);
    endfunction

endclass //base_packet

class M16 extends weapon;
    function new(string name);
        super.new(name);        
    endfunction //new()

    virtual function void shot();
        $display(" [%s] 탕탕!", name);
    endfunction
endclass //ext_packet 

class K2 extends weapon;
    function new(string name);
        super.new(name);        
    endfunction //new()

    virtual function void shot();
        $display(" [%s] 빵빵!", name);
    endfunction
endclass //ext_packet 


class AUG extends weapon;
    function new(string name);
        super.new(name);        
    endfunction //new()

    virtual function void shot();
        $display(" [%s] 삐~~~익~~~텅텅", name);
    endfunction
endclass //ext_packet 


module tb_oop();
    initial begin
        //handler를 배열로 3개 제작 
        weapon BlackPink = new("없음");
        weapon hand = new("주먹");
        M16 m16 = new("M16");
        AUG aug = new("AUG");
        K2 k2 = new("K2");

        $display("==== 다형성 데모 ====");
        BlackPink.shot();
        $display("==== 무기 M16으로 변경 ====");
        BlackPink = m16;
        BlackPink.shot();
        $display("==== 무기 AUG으로 변경 ====");
        BlackPink = aug;
        BlackPink.shot();
        $display("==== 무기 K2으로 변경 ====");
        BlackPink = k2;
        BlackPink.shot();    
    end
    
endmodule