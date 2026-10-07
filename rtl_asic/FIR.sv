
module FIR (input logic clk_fast, rst_n, valid_in, input logic [7:0] data_in, output logic valid_out, output logic [15:0] data_out);

logic [7:0] x0,x1,x2,x3;


	always @(posedge clk_fast or negedge rst_n) begin
		
		if(!rst_n) begin
			x0 <= 8'h00;
			x1 <= 8'h00;
			x2 <= 8'h00;
			x3 <= 8'h00;
			valid_out <= 1'b0;
			data_out  <= 16'h0000;
		end
		else begin
		
			valid_out <= 1'b0;
			
			if(valid_in) begin
				x0 <= data_in;
				x1 <= x0;
				x2 <= x1;
				x3 <= x2;
				
				data_out <= (x0 * 1) + (x1 * 2) + (x2 * 3) + (x3 * 4);
				valid_out <= 1'b1;
			end
		
		end
			

	end



endmodule 