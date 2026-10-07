module uart_tx (
    input  logic        clk_slow,
    input  logic        rst_n,

    input  logic        fifo_empty,
    input  logic [15:0] fifo_data,

    output logic        fifo_rinc,
    output logic        tx_serial,
    output logic        tx_busy
);

	localparam int CLK_FREQ = 10_000_000;
	
	parameter  int BAUD     = 9600; 
	
	localparam int BAUD_DIV       = (CLK_FREQ + BAUD/2) / BAUD;
	localparam int BAUD_CNT_WIDTH = $clog2(BAUD_DIV);
	localparam logic [BAUD_CNT_WIDTH-1:0] BAUD_COUNT_MAX = BAUD_CNT_WIDTH'(BAUD_DIV - 1);

	logic [BAUD_CNT_WIDTH-1:0] baud_counter;
	
	logic [3:0] bit_counter;
	
	typedef enum logic [2:0] {IDLE, READ_FIFO, LOAD_DATA, START_BIT, SEND_DATA, STOP_BIT} state_e;

	state_e state;
	
	logic [15:0] data;
	
	
	always @(posedge clk_slow or negedge rst_n) begin
		if(!rst_n) begin
			state        <= IDLE;
			bit_counter  <= 4'd0; 
			baud_counter <= 11'd0;
			fifo_rinc    <= 1'b0;
			tx_serial    <= 1'b1;
			tx_busy      <= 1'b0;
			data         <= 16'h0000;
		end
		else begin
			case(state)
				
				IDLE: 	  begin
									tx_busy <= 1'b0;
									if(!fifo_empty) begin
										state   <= READ_FIFO;
										tx_busy <= 1'b1;
										fifo_rinc <= 1'b1;
									end
							  end
							
			
				READ_FIFO: begin
									fifo_rinc <= 1'b0;		
									state     <= LOAD_DATA;
							  end
			
				LOAD_DATA: begin
									data      <= fifo_data;
									state     <= START_BIT;
									tx_serial <= 1'b0;
							  end
							  
				START_BIT: begin
									
									if(baud_counter == BAUD_COUNT_MAX) begin
										baud_counter <= 11'd0;
										bit_counter  <= 4'd0;
										tx_serial    <= data[0];
										state        <= SEND_DATA;
									end
									else begin
										baud_counter <= baud_counter + 11'd1;
									end
							  end
				
			
				SEND_DATA: begin
									if(baud_counter == BAUD_COUNT_MAX) begin
										baud_counter <= 11'd0;
										
										if(bit_counter != 4'hF) begin
											bit_counter   <= bit_counter + 4'd1;
											tx_serial     <= data[bit_counter + 4'd1];
										end
									
										else begin
											bit_counter <= 4'd0;
											tx_serial   <= 1'b1;
											state       <= STOP_BIT;
										end
									end
									else begin
										baud_counter <= baud_counter + 11'd1;
									end
							  end
			
				STOP_BIT:  begin
									
									if(baud_counter == BAUD_COUNT_MAX) begin
										baud_counter <= 11'd0;
										tx_busy <= 1'b0;
										state        <= IDLE;
									end
									else begin
										baud_counter <= baud_counter + 11'd1;
									end
									
							end

				default:    begin
   							 		state        <= IDLE;
    								baud_counter <= '0;
   									bit_counter  <= '0;
    								fifo_rinc    <= 1'b0;
   									tx_serial    <= 1'b1;
    								tx_busy      <= 1'b0;
							end
			endcase
								
		end
	
	end
	
endmodule 