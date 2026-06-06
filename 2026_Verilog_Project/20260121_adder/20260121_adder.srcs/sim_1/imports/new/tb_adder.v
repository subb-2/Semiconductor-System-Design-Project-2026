`timescale 1ns / 1ps

module tb_adder();


    //tb_adder local variable 
    
    
    //Instanciate_half_adder
//   half_adder dut ( // dut : instanciate name : design under test 
//       .a(a),
//       .b(b),
//       .sum(sum), 
//      .carry(carry)
//  );

    //instanciate full adder
// full_adder dut (
//     .a(a),
//     .b(b),
//     .cin(cin),
//     .sum(sum),
//     .c(carry)
// );


//instanciate full adder 
   // full_adder_bit dut (
   //     .a0(a0),
   //     .b0(b0),
   //     .a1(a1),
   //     .b1(b1),
   //     .a2(a2),
   //     .b2(b2),
   //     .a3(a3),
   //     .b3(b3),
   //     .fa_cin(fa_cin),
   //     .sum0(sum0),
   //     .sum1(sum1),
   //     .sum2(sum2),
   //     .sum3(sum3),
   //     .fa_c(fa_c)
   // );

   reg [7:0] a, b;
   wire [7:0] sum;
   wire c; 


    integer i = 0, j = 0; // data type : 2 type : x,z는 없다. 숫자만 들어갈 수 있음 32bit가 기본 (자료형)
    //initial 문 밖에서 선언해야 함 

    adder dut(
        .a(a), // bit 결합 
        .b(b),
        .sum(sum),
        .c(c)
        );

    //init
    initial begin
        #0;
        a = 8'b0000_0000; //보기 좋으라고 언더바 
        b = 8'b0000_0000;
        #10;

        for ( i = 0; i < 256; i = i + 1 ) begin
            for ( j = 0 ; j < 256 ; j = j + 1 ) begin
                a = i;
                b = j;
                #10;
            end
            
        end

        
        $stop; // 시뮬 멈추는 것, 뒤에 더 볼 수 있음 

        #100;
        $finish; // 더 이상 시뮬 안하겠다는 선언
    end


endmodule
