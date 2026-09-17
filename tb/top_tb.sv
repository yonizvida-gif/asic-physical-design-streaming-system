`timescale 1ns/1ps

module top_tb();

    localparam int CLK_FAST_HALF = 5;    // 100 MHz -> 10 ns period
    localparam int CLK_SLOW_HALF = 50;   // 10 MHz  -> 100 ns period

    localparam int CLK_SLOW_FREQ = 10_000_000;
    localparam int BAUD          = 9600;
    localparam int BAUD_DIV      = (CLK_SLOW_FREQ + BAUD/2) / BAUD;

    logic       clk_fast;
    logic       clk_slow;
    logic       rst_n;
    logic       valid_in;
    logic [7:0] data_in;

    logic       tx_serial;

    int errors;

    logic [7:0] fir_x0, fir_x1, fir_x2, fir_x3;
    logic [15:0] exp_queue[$];

    logic [15:0] rx_word;
    logic [15:0] exp_word;

    top dut (
        .clk_fast  (clk_fast),
        .clk_slow  (clk_slow),
        .rst_n     (rst_n),
        .valid_in  (valid_in),
        .data_in   (data_in),
        .tx_serial (tx_serial)
    );

    // clk_fast = 100 MHz
    initial begin
        clk_fast = 1'b0;
        forever #CLK_FAST_HALF clk_fast = ~clk_fast;
    end

    // clk_slow = 10 MHz
    initial begin
        clk_slow = 1'b0;
        forever #CLK_SLOW_HALF clk_slow = ~clk_slow;
    end

    // מחשב את תוצאת ה-FIR הצפויה ודוחף לתור
    task automatic push_expected(input logic [7:0] sample);
        logic [15:0] expected;
        begin
            expected = (fir_x0 * 16'd1) +
                       (fir_x1 * 16'd2) +
                       (fir_x2 * 16'd3) +
                       (fir_x3 * 16'd4);

            exp_queue.push_back(expected);

            fir_x3 = fir_x2;
            fir_x2 = fir_x1;
            fir_x1 = fir_x0;
            fir_x0 = sample;
        end
    endtask

    // שולח דגימה אחת למערכת
    task automatic send_sample(input logic [7:0] sample);
        begin
            push_expected(sample);

            @(negedge clk_fast);
            data_in   = sample;
            valid_in  = 1'b1;

            @(negedge clk_fast);
            valid_in  = 1'b0;
            data_in   = 8'h00;
        end
    endtask

    // דיקוד Frame אחד של UART
    task automatic read_uart_word(output logic [15:0] word);
        int i;
        begin
            word = 16'h0000;

            // חכה ל-Start bit
            @(negedge tx_serial);

            // עבור לאמצע ה-Start bit
            repeat (BAUD_DIV/2) @(posedge clk_slow);

            if (tx_serial !== 1'b0) begin
                $error("START bit error");
                errors++;
            end

            // דגימה של 16 ביטים, LSB first
            for (i = 0; i < 16; i++) begin
                repeat (BAUD_DIV) @(posedge clk_slow);
                word[i] = tx_serial;
            end

            // דגימת Stop bit
            repeat (BAUD_DIV) @(posedge clk_slow);

            if (tx_serial !== 1'b1) begin
                $error("STOP bit error");
                errors++;
            end
        end
    endtask

    // קורא מילה אחת מה-UART ומשווה לצפוי
    task automatic compare_one_word();
        begin
            read_uart_word(rx_word);
            exp_word = exp_queue.pop_front();

            if (rx_word !== exp_word) begin
                $error("UART mismatch: expected = 0x%04h, got = 0x%04h", exp_word, rx_word);
                errors++;
            end
            else begin
                $display("[%0t] PASS: expected = 0x%04h, got = 0x%04h", $time, exp_word, rx_word);
            end
        end
    endtask

    initial begin
    errors   = 0;
    rst_n    = 1'b0;
    valid_in = 1'b0;
    data_in  = 8'h00;

    fir_x0 = 8'h00;
    fir_x1 = 8'h00;
    fir_x2 = 8'h00;
    fir_x3 = 8'h00;

    // Reset
    repeat (5) @(posedge clk_fast);
    @(negedge clk_fast);
    rst_n = 1'b1;

    repeat (5) @(posedge clk_fast);

    // Basic checks after reset
    if (tx_serial !== 1'b1) begin
        $error("tx_serial should be 1 after reset");
        errors++;
    end

    if (dut.clk_en !== 1'b1) begin
        $error("clk_en should be 1 after reset");
        errors++;
    end

    fork

        // UART checker starts before transmission begins
        begin : uart_checker
            repeat (10) begin
                compare_one_word();
            end
        end

        // Input stimulus
        begin : stimulus

            // ============================
            // Block 1
            // ============================
            $display("[%0t] Sending BLOCK 1", $time);

            send_sample(8'd2);
            send_sample(8'd4);
            send_sample(8'd6);
            send_sample(8'd8);
            send_sample(8'd10);

            // ============================
            // Idle
            // ============================
            $display("[%0t] Entering IDLE", $time);

            repeat (12) @(posedge clk_fast);

            if (dut.clk_en !== 1'b0) begin
                $error("clk_en should go low after inactivity");
                errors++;
            end
            else begin
                $display("[%0t] PASS: clk_en went low after inactivity", $time);
            end

            // ============================
            // Block 2 - Wake-up test
            // ============================
            $display("[%0t] Sending BLOCK 2 - wake-up test", $time);

            send_sample(8'd12);

            // Check that power controller woke up
            if (dut.clk_en !== 1'b1) begin
                $error("clk_en should return high after new valid data");
                errors++;
            end
            else begin
                $display("[%0t] PASS: clk_en returned high", $time);
            end

            send_sample(8'd14);
            send_sample(8'd16);
            send_sample(8'd18);
            send_sample(8'd20);

        end

    join

    // Expected queue must now be empty
    if (exp_queue.size() != 0) begin
        $error("Expected queue is not empty at end of test");
        errors++;
    end

    if (errors == 0) begin
        $display("========================================");
        $display(" TOP SYSTEM TEST PASSED");
        $display(" BLOCK1 -> IDLE -> WAKEUP -> BLOCK2 PASS");
        $display("========================================");
    end
    else begin
        $display("========================================");
        $display(" TOP SYSTEM TEST FAILED - %0d errors", errors);
        $display("========================================");
    end

    $finish;
end

    // Timeout
    initial begin
        #30_000_000; // 30 ms
        $fatal(1, "TOP TB TIMEOUT");
    end

endmodule