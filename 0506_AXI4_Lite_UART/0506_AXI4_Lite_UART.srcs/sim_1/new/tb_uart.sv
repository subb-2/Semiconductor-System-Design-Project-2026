`timescale 1ns / 1ps

module tb_uart ();
    // Users to add parameters here
    parameter CLK_FREQ = 100_000_000;
    parameter BAUD_RATE = 115_200;
    parameter integer C_S00_AXI_DATA_WIDTH = 32;
    parameter integer C_S00_AXI_ADDR_WIDTH = 4;
    // Users to add ports here

    wire                                  loop_wire;
    wire                                  tx;
    wire                                  rx;
    wire                                  rx_intr;
    reg                                   s00_axi_aclk;
    reg                                   s00_axi_aresetn;
    reg  [    C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr;
    reg  [                         2 : 0] s00_axi_awprot;
    reg                                   s00_axi_awvalid;
    wire                                  s00_axi_awready;
    reg  [    C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata;
    reg  [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb;
    reg                                   s00_axi_wvalid;
    wire                                  s00_axi_wready;
    wire [                         1 : 0] s00_axi_bresp;
    wire                                  s00_axi_bvalid;
    reg                                   s00_axi_bready;
    reg  [    C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr;
    reg  [                         2 : 0] s00_axi_arprot;
    reg                                   s00_axi_arvalid;
    wire                                  s00_axi_arready;
    wire [    C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
    wire [                         1 : 0] s00_axi_rresp;
    wire                                  s00_axi_rvalid;
    reg                                   s00_axi_rready;


    uart_v1_0 #(
        // Users to add parameters here
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(115_200),
        .C_S00_AXI_DATA_WIDTH(32),
        .C_S00_AXI_ADDR_WIDTH(4)
    ) dut (
        .*,
        .tx(loop_wire),
        .rx(loop_wire)
    );

    always #5 s00_axi_aclk = ~s00_axi_aclk;

    task axi_write(input logic [31:0] addr, input logic [31:0] data);
        @(posedge s00_axi_aclk);
        s00_axi_awaddr  <= addr;
        s00_axi_awvalid <= 1'b1;
        s00_axi_wdata   <= data;
        s00_axi_wvalid  <= 1'b1;
        s00_axi_wstrb   <= 4'hf;
        s00_axi_bready  <= 1'b1;

        wait (s00_axi_awready && s00_axi_wready);
        @(posedge s00_axi_aclk);
        s00_axi_awvalid <= 1'b0;
        s00_axi_wvalid  <= 1'b0;

        wait (s00_axi_bvalid);
        @(posedge s00_axi_aclk);
        s00_axi_araddr  <= 1'b0;
        s00_axi_arvalid <= 1'b1;
        s00_axi_rready  <= 1'b1;

        wait (s00_axi_arready);
        @(posedge s00_axi_aclk);
        s00_axi_arvalid <= 1'b0;

        wait (s00_axi_rready);
        data = s00_axi_rdata;
        @(posedge s00_axi_aclk);
        s00_axi_rready <= 1'b0;
        @(posedge s00_axi_aclk);
    endtask

    task axi_read(input logic [31:0] addr, output logic [31:0] data);
        @(posedge s00_axi_aclk);
        s00_axi_araddr  <= addr;
        s00_axi_arvalid <= 1'b1;
        s00_axi_rready  <= 1'b1;

        wait (s00_axi_arready);
        @(posedge s00_axi_aclk);
        s00_axi_arvalid <= 1'b0;
        wait (s00_axi_rvalid);
        data = s00_axi_rdata;
        @(posedge s00_axi_aclk);
        s00_axi_rready <= 1'b0;
        @(posedge s00_axi_aclk);
    endtask

    initial begin
        logic [31:0] status_data;
        logic [31:0] tx_data;
        logic [31:0] rx_data;
        logic [31:0] control_data;

        s00_axi_aclk = 0;
        s00_axi_aresetn = 0;
        #100;
        s00_axi_aresetn = 1;
        #100;

        // tx_data 레지스터에 데이터 쓰기 0xAA, uart tx 시리얼 데이터 전송
        tx_data = 32'h0000_0055;
        axi_write(8'h04, tx_data);
        do begin
            axi_read(8'h00, status_data);
        end while (!status_data[1]);
        @(posedge s00_axi_aclk);
        axi_read(8'h08, rx_data);
        if (tx_data == rx_data) begin
            $display("[%t] [PASS!] tx_data: %0h, rx_data: %0h", $time, tx_data,
                     rx_data);
        end else begin
            $display("[%t] [FAIL!] tx_data: %0h, rx_data: %0h", $time, tx_data,
                     rx_data);
        end

        //3. 인터럽트 확인

        control_data = 32'h0000_0001;
        axi_write(8'h0c, control_data); //cr [0] = 1; 인터럽트 enable 

        status_data = 0;
        do begin
            axi_read(8'h00, status_data);
        end while (!status_data[0]);
        @(posedge s00_axi_aclk);

        tx_data = 32'h0000_0011;
        axi_write(8'h04, tx_data); // loop wire 가 되어 있으므로 전송하면 자동 수신, 수신 완료 후 인터럽트 발생 확인
        
        wait (rx_intr0);
        @(posedge s00_axi_aclk);

        @(posedge s00_axi_aclk);
        rx_data = 0;
        axi_read(8'h08, rx_data);


        //control_data = 32'h0000_0000;
        //axi_write(8'h0c, control_data); //cr [0] = 1; 인터럽트 enable 
        
        tx_data = 32'h0000_0011;
        axi_write(8'h04, tx_data); // loop wire 가 되어 있으므로 전송하면 자동 수신, 수신 완료 후 인터럽트 발생 안옴 확인 



        #100;
        //$finish;

    end

endmodule
