module async_fifo (
   input  logic        wclk,
   input  logic        wrst_n,
   input  logic        rclk,
   input  logic        rrst_n,
	
   input  logic [15:0] wdata,
   input  logic        winc,

   output logic [15:0] rdata,
   input  logic        rinc,

   output logic        wfull,
   output logic        rempty
);

	logic [4:0] wptr, rptr;
	logic [4:0] wgray, rgray;
	
	(* ramstyle = "logic" *)
	logic [15:0] mem [0:15];
	
	logic [4:0] wgray_sync1, wgray_sync2;
	logic [4:0] rgray_sync1, rgray_sync2;
	
	always @(posedge wclk or negedge wrst_n) begin
		if(!wrst_n) begin
			wptr  <= 5'h00;
			wgray <= 5'h00;
		end
		else begin
			if(winc && !wfull) begin
				mem[wptr[3:0]] <= wdata;
				wptr  <= wptr + 5'd1;
				wgray <= (wptr + 5'd1) ^ ((wptr + 5'd1) >> 1);
			end
		end
		
	end

	always @(posedge rclk or negedge rrst_n) begin
		if(!rrst_n) begin
			wgray_sync1 <= 5'h00;
         wgray_sync2 <= 5'h00;
		end
		else begin
         wgray_sync1 <= wgray;
         wgray_sync2 <= wgray_sync1;
      end
	end
	
	always @(posedge wclk or negedge wrst_n) begin
		if(!wrst_n) begin
			rgray_sync1 <= 5'h00;
         rgray_sync2 <= 5'h00;
		end
		else begin
         rgray_sync1 <= rgray;
         rgray_sync2 <= rgray_sync1;
      end
	end

	always @(posedge rclk or negedge rrst_n) begin
		if(!rrst_n) begin
			rptr   <= 5'h00;
			rgray  <= 5'h00;
			rdata  <= 16'h0000;
		end
		else begin
			if(rinc && !rempty) begin
				rdata <= mem[rptr[3:0]]; 
				rptr  <= rptr + 5'd1;
				rgray <= (rptr + 5'd1) ^ ((rptr + 5'd1) >> 1);
			end
		end
		
	end

	
	assign rempty = (rgray == wgray_sync2);
	
	assign wfull = (wgray == {~rgray_sync2[4:3], rgray_sync2[2:0]});


endmodule 