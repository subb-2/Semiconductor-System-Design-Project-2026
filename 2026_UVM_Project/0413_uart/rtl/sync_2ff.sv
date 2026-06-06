module sync_2ff (
    input  logic clk,
    input  logic rst,
    input  logic async_in,
    output logic sync_out
);

    logic ff1, ff2;

    assign sync_out = ff2;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            ff1 <= 1'b1;
            ff2 <= 1'b1;
        end else begin
            //저속 비동기 신호가 들어와서 ff1에 저장되어 ff2로 전달
            ff1 <= async_in;
            ff2 <= ff1;
        end
    end
endmodule
