//uart loop back 구조 설계
module uart_top (
    input  logic clk,
    input  logic rst,
    input  logic rx,
    output logic tx_done,
    output logic tx
);

    logic b_tick, w_rx_done;
    logic [7:0] w_rx_data;

    uart_rx U_UART_RX (
        .clk    (clk),
        .rst    (rst),
        .b_tick (b_tick),
        .rx     (rx),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    uart_tx U_UART_TX (
        .clk     (clk),
        .rst     (rst),
        .b_tick  (b_tick),
        .tx_start(w_rx_done),
        .tx_data (w_rx_data),
        .tx_done (tx_done),
        .tx      (tx)
    );

    baud_tick U_BAUD_TICK (
        .clk   (clk),
        .rst   (rst),
        .b_tick(b_tick)
    );

endmodule

//uart rx
module uart_rx (
    input  logic       clk,
    input  logic       rst,
    input  logic       b_tick,
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    typedef enum {
        IDLE,
        START,
        DATA,
        STOP
    } state_e;

    state_e c_state, n_state;

    //bit
    logic [2:0] bit_cnt_reg, bit_cnt_next;
    //baud tick
    logic [3:0] b_tick_cnt_reg, b_tick_cnt_next;
    //data
    logic [7:0] rx_data_buf_reg, rx_data_buf_next;

    assign rx_data = rx_data_buf_reg;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state         <= IDLE;
            b_tick_cnt_reg  <= 4'd0;
            bit_cnt_reg     <= 3'd0;
            rx_data_buf_reg <= 8'd0;
        end else begin
            c_state         <= n_state;
            b_tick_cnt_reg  <= b_tick_cnt_next;
            bit_cnt_reg     <= bit_cnt_next;
            rx_data_buf_reg <= rx_data_buf_next;
        end
    end

    always_comb begin
        n_state          = c_state;
        b_tick_cnt_next  = b_tick_cnt_reg;
        bit_cnt_next     = bit_cnt_reg;
        rx_data_buf_next = rx_data_buf_reg;
        rx_done          = 0;

        case (c_state)
            IDLE: begin
                if (b_tick & !rx) begin
                    b_tick_cnt_next  = 0;
                    bit_cnt_next     = 0;
                    rx_data_buf_next = 0;
                    n_state          = START;
                end
            end
            START: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 7) begin
                        b_tick_cnt_next = 0;
                        n_state = DATA;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next  = 0;
                        rx_data_buf_next = {rx, rx_data_buf_reg[7:1]};
                        if (bit_cnt_reg == 7) begin
                            n_state = STOP;
                        end else begin
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        n_state = IDLE;
                        rx_done = 1;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule

//uart tx
module uart_tx (
    input  logic       clk,
    input  logic       rst,
    input  logic       b_tick,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_done,
    output logic       tx
);

    typedef enum {
        IDLE,
        START,
        DATA,
        STOP
    } state_e;

    state_e c_state, n_state;

    //bit
    logic [2:0] bit_cnt_reg, bit_cnt_next;
    //baud tick
    logic [3:0] b_tick_cnt_reg, b_tick_cnt_next;
    //data
    logic [7:0] tx_data_buf_reg, tx_data_buf_next;


    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state         <= IDLE;
            b_tick_cnt_reg  <= 4'd0;
            bit_cnt_reg     <= 3'd0;
            tx_data_buf_reg <= 8'd0;
        end else begin
            c_state         <= n_state;
            b_tick_cnt_reg  <= b_tick_cnt_next;
            bit_cnt_reg     <= bit_cnt_next;
            tx_data_buf_reg <= tx_data_buf_next;
        end
    end

    always_comb begin
        n_state          = c_state;
        b_tick_cnt_next  = b_tick_cnt_reg;
        bit_cnt_next     = bit_cnt_reg;
        tx_data_buf_next = tx_data_buf_reg;
        tx               = 1;  //tx는 기본적으로 high 유지 
        tx_done          = 0;
        case (c_state)
            IDLE: begin
                if (tx_start) begin
                    n_state = START;
                    tx_data_buf_next = tx_data;
                    b_tick_cnt_next = 0;
                    bit_cnt_next = 0;
                end
            end
            START: begin
                tx = 0;
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        n_state = DATA;
                        b_tick_cnt_next = 0;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                tx = tx_data_buf_reg[0];
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        if (bit_cnt_reg == 7) begin
                            b_tick_cnt_next = 0;
                            bit_cnt_next = 0;  // 다시 생각해보기 
                            n_state = STOP;
                        end else begin
                            bit_cnt_next = bit_cnt_reg + 1;
                            tx_data_buf_next = {1'b0, tx_data_buf_reg[7:1]};
                            b_tick_cnt_next = 0;
                            n_state = DATA;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                tx = 1;
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        tx_done = 1;
                        b_tick_cnt_next = 0;
                        n_state = IDLE;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule

module baud_tick (
    input  logic clk,
    input  logic rst,
    output logic b_tick
);

    localparam BAUDRATE = 9600 * 16;
    localparam F_COUNT = 100_000_000 / BAUDRATE;

    logic [$clog2(F_COUNT) - 1 : 0] count_reg;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            b_tick    <= 0;
        end else begin
            if (count_reg == (F_COUNT - 1)) begin
                count_reg <= 0;
                b_tick    <= 1;
            end else begin
                count_reg <= count_reg + 1;
                b_tick    <= 0;
            end
        end
    end

endmodule
