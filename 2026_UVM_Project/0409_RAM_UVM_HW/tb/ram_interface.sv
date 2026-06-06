interface ram_if (
    input logic clk
);
    logic        we;
    logic [ 7:0] addr;
    logic [15:0] wdata;
    logic [15:0] rdata;

    clocking drv_cb @(posedge clk);
        //#1step = #1 
        //input#1은 input에만 영향을 주기 때문에 여기서는 의미 없음 
        //output #0; 는 clk 발생 후 값을 바로 출력한다. 
        default output #0;
        output we;
        output addr;
        output wdata;
    endclocking

    clocking mon_cb @(posedge clk);
        //#1step = #1 
        //input #1은 clk 발생 시점 기준으로, 한 step 전 값을 읽는다.
        default input #1step;
        input we;
        input addr;
        input wdata;
        input rdata;
    endclocking


endinterface  //ram_if(input logic clk)
