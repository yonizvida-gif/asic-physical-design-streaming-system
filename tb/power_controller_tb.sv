`timescale 1ns/1ps

module power_controller_tb();
    logic clk_fast;
    logic rst_n;
    logic valid_in;
    logic clk_en;

    power_controller d1 (
        .clk_fast(clk_fast),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .clk_en(clk_en)
    );

    initial begin
        clk_fast = 1'b0;
        forever begin
            #5 clk_fast = ~clk_fast;
        end
    end

	 initial begin

		rst_n    = 1'b0;
      valid_in = 1'b0;

      repeat(2) @(negedge clk_fast);
      rst_n = 1'b1;

      @(negedge clk_fast);
      valid_in = 1'b1;

      @(negedge clk_fast);
      valid_in = 1'b0;

      repeat(9) @(negedge clk_fast);

      @(negedge clk_fast);

      @(negedge clk_fast);

      valid_in = 1'b1;

      @(negedge clk_fast);

      valid_in = 1'b0;

      repeat(2) @(negedge clk_fast);

      $finish;
    end

endmodule 