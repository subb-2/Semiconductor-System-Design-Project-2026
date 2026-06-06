module tb_adder();
	logic [7:0] a;
	logic [7:0] b;
	logic [8:0] y;

	adder dut(,*);

	initial begin
		$fsdbDumpfile("wave.fsdb");
		$fsdbDumpvars(0);
	end

	initial begin
		$fsdbDumpfile("wave.fsdb");
		$fsdbDumpvars(0);
	end

	initial begin
		a = 0;
		b = 0;
		#10;
	end
endmodule
