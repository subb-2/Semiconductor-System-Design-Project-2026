`timescale 1ns / 1ps

module tb_TimerCounter ();

    logic        clk;
    logic        rst_n;
    logic        cnt_en;
    logic        cnt_clear;
    logic        intr_en;
    logic [31:0] PSC;
    logic [31:0] ARR;
    logic        intr;
    logic [31:0] count;

    TimerCounter dut (.*);

    always #5 clk = ~clk;

    task TMR_SetPSC(logic [31:0] psc);
        PSC = psc; 
    endtask

    task TMR_SetARR(logic [31:0] arr);
        ARR = arr;
    endtask

    task TMR_SetIntrEn(bit en);
        intr_en = en;
    endtask
    
    task TMRSetCounterEn(bit en);
        cnt_en = en;
    endtask

    task TMRSetCounterClear(bit clear);
        cnt_clear = clear;
    endtask

    initial begin
        clk   = 0;
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        //10kHz 마다 인터럽트 
        TMR_SetPSC(100 - 1);
        TMR_SetARR(100 - 1);
        TMRSetCounterClear(0);
        TMR_SetIntrEn(1);
        TMRSetCounterEn(1);

        wait (intr);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        wait (intr);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        wait (intr);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        repeat (400) @(posedge clk);
        TMRSetCounterClear(1);
        @(posedge clk);
        TMRSetCounterClear(0);
        @(posedge clk);
        wait (intr);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $stop;
    end
endmodule
