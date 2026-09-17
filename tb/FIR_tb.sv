`timescale 1ns/1ps

module FIR_tb();
	logic clk_fast;
   logic rst_n;
   logic valid_in;
   logic [7:0] data_in;

	logic valid_out;
   logic [15:0] data_out;
	 
	FIR d1(.clk_fast(clk_fast), .rst_n(rst_n), .valid_in(valid_in), .data_in(data_in), .valid_out(valid_out), .data_out(data_out));
	 
	initial begin
		clk_fast = 1'b0;
		forever begin
			#5 clk_fast = ~clk_fast;
		end
	end
	
	initial begin
		data_in = 8'd0;
		valid_in = 1'b0;
		rst_n = 1'b1;
		@(negedge clk_fast);
		rst_n = 1'b0;
		
		repeat(3) @(negedge clk_fast);
		
		rst_n = 1'b1;
		@(negedge clk_fast);
		valid_in = 1'b1;
		data_in = 8'd2;
		
		@(negedge clk_fast);
		data_in = 8'd4;
		
		@(negedge clk_fast);
		data_in = 8'd6;
		
		@(negedge clk_fast);
		valid_in = 1'b0;
		data_in = 8'd8;
		
		@(negedge clk_fast);
		valid_in = 1'b1;
		data_in = 8'd10;
		
		@(negedge clk_fast);
		data_in = 8'd12;
		
		@(negedge clk_fast);
      valid_in = 1'b0;

		repeat(3) @(negedge clk_fast);
		$finish;
	end


endmodule 