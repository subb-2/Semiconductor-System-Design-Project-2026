interface uart_if (
    input logic clk,
    input logic rst
);

    logic rx;
    logic tx_done;
    logic tx;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output rx;
        input tx_done;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input rx;
        input tx;
        input tx_done;
    endclocking

    modport mp_drv (clocking drv_cb, input clk, input rst);
    modport mp_mon (clocking mon_cb, input clk, input rst);

endinterface  //uart_if
