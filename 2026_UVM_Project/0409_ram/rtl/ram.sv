
module ram (
    input  logic        clk,
    input  logic        we,
    input  logic [ 7:0] addr,
    input  logic [15:0] wdata,
    output logic [15:0] rdata
);

    logic [15:0] mem[0:(2**8-1)];

    //ram 특징 : rst 없음
    always_ff @(posedge clk) begin
        if (we) mem[addr] <= wdata;
        else rdata <= mem[addr];
    end

endmodule
