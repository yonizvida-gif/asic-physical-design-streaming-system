module top(
input logic clk_fast, clk_slow, rst_n, valid_in,
input logic [7:0] data_in,

output logic tx_serial
);

	logic valid_write, valid_read;
	logic full, empty;
	logic tx_busy;
	
	logic clk_en;
	logic gated_clk;
	
	logic [15:0] data_out;
	logic [15:0] fifo_out;
	
	logic       fir_valid_in;
	logic [7:0] fir_data_in;

	clk_gate d1 (
		.inclk  (clk_fast),  //  altclkctrl_input.inclk
		.ena    (clk_en),    //                  .ena
		.outclk (gated_clk)  // altclkctrl_output.outclk
	);

	power_controller d2(
		.clk_fast(clk_fast), 
		.rst_n(rst_n), 
		.valid_in(valid_in), 
		.clk_en(clk_en)
	);
	
	
	FIR d3(
		.clk_fast(gated_clk), 
		.rst_n(rst_n), 
		.valid_in(fir_valid_in), 
		.data_in(fir_data_in), 
		.valid_out(valid_write), 
		.data_out(data_out)
	);

	
	async_fifo d4(
		.wclk(clk_fast),
      .wrst_n(rst_n),
      .rclk(clk_slow),
      .rrst_n(rst_n),
      .wdata(data_out),
      .winc(valid_write),
		.rdata(fifo_out),
		.rinc(valid_read),
      .wfull(full),
		.rempty(empty)
	);
	
	uart_tx d5(
		.clk_slow(clk_slow),
		.rst_n(rst_n),
		.fifo_empty(empty),
		.fifo_data(fifo_out),
		.fifo_rinc(valid_read),
		.tx_serial(tx_serial),
		.tx_busy(tx_busy)
	);
	
	
	
	
	
	always_ff @(posedge clk_fast or negedge rst_n) begin
		if (!rst_n) begin
			fir_valid_in <= 1'b0;
         fir_data_in  <= 8'h00;
		end
      else begin
			fir_valid_in <= valid_in;

			if (valid_in)
				fir_data_in <= data_in;
		end
	end

endmodule