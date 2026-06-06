module baud_rate_gen #(
    parameter int BAUD_RATE = 9600
) (
    input  logic clk,
    input  logic rst,
    output logic tick
);

    localparam int CLK_DIV = 100_000_000 / (BAUD_RATE * 16) - 1;
    //위에서 -1 해줬으므로, +1 해준 것 
    localparam int CNT_W = $clog2(CLK_DIV + 1);  //여유 bit 설정
    logic [CNT_W-1 : 0] cnt;  // 분주 counter

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt  <= 0;
            tick <= 0;
        end else begin
            if (cnt == CLK_DIV) begin
                cnt  <= 0;
                tick <= 1'b1;
            end else begin
                cnt  <= cnt + 1;
                tick <= 1'b0;
            end
        end
    end

endmodule
