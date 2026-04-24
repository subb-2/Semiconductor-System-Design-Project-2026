`timescale 1ns / 1ps

module ram (
    input        clk,
    input        we,
    input  [9:0] addr,
    input  [7:0] wdata,
    output reg [7:0] rdata
);

//timing 보기
//write에서 상승엣지일 때 주소와 데이터를 ram에 저장

    //ram space , 배열은 낮은 주소부터 
    reg [7:0] ram [0:1023]; 

    //to write to RAM
    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= wdata;
        end
        //output SL 
        else begin
            rdata <= ram[addr];
        end
    end

    //조합 출력
    //assign rdata = ram[addr];

endmodule
