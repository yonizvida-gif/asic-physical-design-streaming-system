module power_controller (
    input  logic clk_fast,
    input  logic rst_n,
    input  logic valid_in,
    output logic clk_en
);

    logic [3:0] count;
    logic       clk_en_reg;

    assign clk_en = clk_en_reg | valid_in;

    always @(posedge clk_fast or negedge rst_n) begin
        if (!rst_n) begin
            clk_en_reg <= 1'b1;
            count      <= 4'd0;
        end
        else begin
            if (valid_in) begin
                count      <= 4'd0;
                clk_en_reg <= 1'b1;
            end
            else begin
                if (count == 4'd9) begin
                    count      <= 4'd10;
                    clk_en_reg <= 1'b0;
                end
                else if (count < 4'd9) begin
                    count      <= count + 4'd1;
                    clk_en_reg <= 1'b1;
                end
                else begin
                    count      <= 4'd10;
                    clk_en_reg <= 1'b0;
                end
            end
        end
    end

endmodule