//4bit counter
//basys 보드의 버튼이 active high 이기 때문에 
//누르면 high가 됨
//그래서 그동안 high로 한 것 
module counter (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       enable,
    output logic [3:0] count
);

    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            count <= 0;
        end else begin
            if (enable) count <= count + 1;
        end
    end

endmodule
