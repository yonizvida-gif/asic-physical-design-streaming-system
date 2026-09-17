`timescale 1ns/1ps

module uart_tx_tb();

    localparam int CLK_FREQ = 10_000_000;
    localparam int BAUD     = 9600;
    localparam int BAUD_DIV = (CLK_FREQ + BAUD/2) / BAUD;

    logic        clk_slow;
    logic        rst_n;

    logic        fifo_empty;
    logic [15:0] fifo_data;

    logic        fifo_rinc;
    logic        tx_serial;
    logic        tx_busy;

    int errors;

    uart_tx dut (
        .clk_slow   (clk_slow),
        .rst_n      (rst_n),
        .fifo_empty (fifo_empty),
        .fifo_data  (fifo_data),
        .fifo_rinc  (fifo_rinc),
        .tx_serial  (tx_serial),
        .tx_busy    (tx_busy)
    );

    // 10 MHz clock -> 100 ns period
    initial begin
        clk_slow = 1'b0;
        forever #50 clk_slow = ~clk_slow;
    end

    // Simple FIFO-side model
    task automatic provide_fifo_word(input logic [15:0] word);
        begin
            @(negedge clk_slow);
            fifo_data  = word;
            fifo_empty = 1'b0;

            @(posedge fifo_rinc);

            @(negedge clk_slow);
            fifo_empty = 1'b1;

            @(negedge clk_slow);
            if (fifo_rinc !== 1'b0) begin
                $error("fifo_rinc stayed high for more than one clk_slow cycle");
                errors++;
            end
        end
    endtask

    // Check one UART frame: Start, 16 data bits LSB first, Stop
    task automatic check_uart_frame(input logic [15:0] expected_data);
        int i;
        begin
            @(negedge tx_serial);

            repeat(BAUD_DIV/2) @(posedge clk_slow);

            if (tx_serial !== 1'b0) begin
                $error("START bit error: expected 0");
                errors++;
            end

            if (tx_busy !== 1'b1) begin
                $error("tx_busy should be 1 during transmission");
                errors++;
            end

            for (i = 0; i < 16; i++) begin
                repeat(BAUD_DIV) @(posedge clk_slow);

                if (tx_serial !== expected_data[i]) begin
                    $error("DATA bit %0d error: expected %0b, got %0b",
                           i, expected_data[i], tx_serial);
                    errors++;
                end
            end

            repeat(BAUD_DIV) @(posedge clk_slow);

            if (tx_serial !== 1'b1) begin
                $error("STOP bit error: expected 1");
                errors++;
            end

            if (tx_busy !== 1'b1) begin
                $error("tx_busy went low before the Stop bit finished");
                errors++;
            end

            wait(tx_busy === 1'b0);

            if (tx_serial !== 1'b1) begin
                $error("tx_serial should be 1 in IDLE");
                errors++;
            end
        end
    endtask

    task automatic run_test_word(input logic [15:0] word);
        begin
            $display("[%0t] Testing UART word 0x%04h", $time, word);

            fork
                provide_fifo_word(word);
                check_uart_frame(word);
            join

            $display("[%0t] Finished UART word 0x%04h", $time, word);

            repeat(3) @(posedge clk_slow);
        end
    endtask

    initial begin
        errors     = 0;
        rst_n      = 1'b0;
        fifo_empty = 1'b1;
        fifo_data  = 16'h0000;

        repeat(5) @(posedge clk_slow);
        @(negedge clk_slow);
        rst_n = 1'b1;

        repeat(2) @(posedge clk_slow);

        if (tx_serial !== 1'b1) begin
            $error("After reset tx_serial should be 1");
            errors++;
        end

        if (tx_busy !== 1'b0) begin
            $error("After reset tx_busy should be 0");
            errors++;
        end

        if (fifo_rinc !== 1'b0) begin
            $error("After reset fifo_rinc should be 0");
            errors++;
        end

        run_test_word(16'h5555);
        run_test_word(16'hA5C3);
        run_test_word(16'hFFFF);

        if (errors == 0) begin
            $display("========================================");
            $display(" UART TX TEST PASSED");
            $display(" BAUD_DIV = %0d", BAUD_DIV);
            $display("========================================");
        end
        else begin
            $display("========================================");
            $display(" UART TX TEST FAILED - %0d errors", errors);
            $display("========================================");
        end

        $finish;
    end

    initial begin
        #20_000_000;
        $fatal(1, "UART TB TIMEOUT");
    end

endmodule
