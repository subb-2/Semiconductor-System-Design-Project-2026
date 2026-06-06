module uart #(
    parameter int BAUD_RATE = 9600
) (
    input  logic       clk,
    input  logic       rst,
    //tx port
    input  logic [7:0] tx_data,
    input  logic       tx_start,
    output logic       tx,
    output logic       tx_busy,
    //rx port
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_valid
);

    logic tick;
    logic rx_sync;

    //외부에서 들어오는 baudrate가 괄호 안에 들어감 
    baud_rate_gen #(
        .BAUD_RATE(BAUD_RATE)
    ) U_BRG (
        .clk (clk),
        .rst (rst),
        .tick(tick)
    );

    uart_tx U_UART_TX (
        .clk     (clk),
        .rst     (rst),
        .tick    (tick),
        .tx_data (tx_data),
        .tx_start(tx_start),
        .tx      (tx),
        .tx_busy (tx_busy)
    );

    sync_2ff U_SYNC_RX (
        .clk     (clk),
        .rst     (rst),
        .async_in(rx),
        .sync_out(rx_sync)
    );

    uart_rx U_UART_RX (
        .clk     (clk),
        .rst     (rst),
        .tick    (tick),
        .rx      (rx_sync),
        .rx_data (rx_data),
        .rx_valid(rx_valid)
    );

endmodule
