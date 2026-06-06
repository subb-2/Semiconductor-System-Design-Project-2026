module apb_ram (
    input  logic        PCLK,
    input  logic        PRESET,
    //APB Interface signanls
    input  logic [ 7:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY
);

    //주소 들어올 때, 4byte로 끊어서 들어오게 함
    logic [31:0] mem[0:(2**6-1)];

    assign PREADY = 1;

    always_ff @(posedge PCLK) begin
        //PREADY <= 0;
        //ram은 rst 없음
        if (PSEL & PENABLE & PWRITE) begin
            //PREADY <= 1;
            mem[PADDR[7:2]] <= PWDATA;
            //else PRDATA <= mem[PADDR[7:2]];
        end
    end

    assign PRDATA = mem[PADDR[7:2]];

endmodule
