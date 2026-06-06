module tb_uart ();

    logic       clk;
    logic       rst;
    logic [7:0] tx_data;
    logic [7:0] tx_data_temp;
    logic       tx_start;
    logic       tx;
    logic       tx_busy;
    logic       rx;
    logic [7:0] rx_data;
    logic [7:0] rx_data_temp;
    logic       rx_valid;


    uart #(
        .BAUD_RATE(9600)
    ) dut (
        .clk     (clk),
        .rst     (rst),
        .tx_data (tx_data),
        .tx_start(tx_start),
        .tx      (tx),
        .tx_busy (tx_busy),
        .rx      (tx),
        .rx_data (rx_data),
        .rx_valid(rx_valid)
    );

    always #5 clk = ~clk;

    logic [7:0] uart_que[$];

    //task send_data(logic [7:0] data);
    task send_data(int loop);
        repeat (loop) begin
            //tx_data  = data;
            tx_data_temp = $urandom();
            tx_data = tx_data_temp;
            uart_que.push_back(tx_data_temp);
            $display("SEND: tx_data_temp = %02h", tx_data_temp);
            tx_start = 1'b1;
            wait (tx_busy == 1'b1);
            tx_start = 1'b0;

            @(posedge clk);
            //wait (tx_busy == 1'b1);
            //wait (rx_valid == 1'b1);
            wait (tx_busy == 1'b0);
            @(posedge clk);
        end
    endtask  //send_data
    
    task receive_data();
        logic [7:0] expected_data;
        forever begin
            //tx_data  = data;
            wait (rx_valid == 1'b1);
            //@(posedge clk);
            rx_data_temp = rx_data;
            expected_data = uart_que.pop_front();
            if (rx_data_temp == expected_data) begin
                $display("PASS! rx_data_temp = %02h and tx_data = %02h is same.", rx_data_temp, expected_data);
            end else begin
                $display("FAIL! rx_data_temp = %02h and tx_data = %02h is different.", rx_data_temp, expected_data);    
            end
            wait (rx_valid == 1'b0);
        end
    endtask  //send_data

    initial begin
        clk = 0;
        rst = 1;
        repeat (3) @(posedge clk);
        rst = 0;
        repeat (3) @(posedge clk);
        fork
            send_data(5);
            receive_data();
        join_any
        wait(tx_busy == 1'b0);
        //send_data(8'h55);
        //send_data(8'h11);
        //send_data(8'hff);
        #30;
        $finish;
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_uart, "+all");
    end

endmodule
