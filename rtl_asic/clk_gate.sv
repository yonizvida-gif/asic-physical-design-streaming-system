module clk_gate (
    input  logic inclk,
    input  logic ena,
    output logic outclk
);

    sky130_fd_sc_hd__dlclkp_1 u_icg (
        .CLK  (inclk),
        .GATE (ena),
        .GCLK (outclk)
    );

endmodule