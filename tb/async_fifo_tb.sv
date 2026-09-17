`timescale 1ns/1ps

module async_fifo_tb();

    logic        wclk;
    logic        wrst_n;
    logic        rclk;
    logic        rrst_n;

    logic [15:0] wdata;
    logic        winc;

    logic [15:0] rdata;
    logic        rinc;

    logic        wfull;
    logic        rempty;

	 int num_loops;
	 
	 logic w_done;
	 logic r_done;
	 
    async_fifo dut (
        .wclk   (wclk),
        .wrst_n (wrst_n),
        .rclk   (rclk),
        .rrst_n (rrst_n),

        .wdata  (wdata),
        .winc   (winc),

        .rdata  (rdata),
        .rinc   (rinc),

        .wfull  (wfull),
        .rempty (rempty)
    );
	 
	 
    // Write clock
    initial begin
        wclk = 1'b0;
        forever #5 wclk = ~wclk;
    end


    // Read clock
    initial begin
        rclk = 1'b0;
        forever #8.5 rclk = ~rclk;
    end

	 initial begin
			num_loops = $urandom_range(50,20);	
	 end

	 
	 initial begin
			w_done = 1'b0;
			wrst_n = 1'b1;
			@(posedge wclk);
			wrst_n = 1'b0;
			wdata = 16'h0000;
			winc = 1'b0;
			repeat(2) @(negedge wclk);
			wrst_n = 1'b1;
			
			repeat(num_loops) begin
						wdata = $urandom_range(16'hFFFF,0);
						winc = $urandom_range(1,0);
						@(negedge wclk);
			end
			winc   = 1'b0;
			w_done = 1'b1;
	 end
	 
	 initial begin
			r_done = 1'b0;
			rrst_n = 1'b1;
			@(posedge rclk);
			rrst_n = 1'b0;
			rinc = 1'b0;
			repeat(2) @(negedge rclk);
			rrst_n = 1'b1;
			
			repeat(num_loops) begin
					rinc = $urandom_range(1,0);
					@(negedge rclk);
			end
			rinc   = 1'b0;
			r_done = 1'b1;
			
	 end
	 
	 
	 initial begin
			wait(r_done && w_done);
			$finish;	
	 end
endmodule