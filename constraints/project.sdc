# ============================================================
# Clock Constraints
# ============================================================

# Fast clock: 100 MHz
create_clock -name clk_fast -period 10.000 [get_ports {clk_fast}]

# Slow clock: 10 MHz
create_clock -name clk_slow -period 100.000 [get_ports {clk_slow}]

# Clock uncertainty
#derive_clock_uncertainty


# ============================================================
# Asynchronous Clock Domains
# ============================================================

set_clock_groups -asynchronous \
    -group [get_clocks {clk_fast}] \
    -group [get_clocks {clk_slow}]


# ============================================================
# Input Delays
# ============================================================

set_input_delay -max 2.0 -clock clk_fast [get_ports {valid_in}]
set_input_delay -min 0.5 -clock clk_fast [get_ports {valid_in}]

set_input_delay -max 2.0 -clock clk_fast [get_ports {data_in[*]}]
set_input_delay -min 0.5 -clock clk_fast [get_ports {data_in[*]}]


# ============================================================
# UART Output
# ============================================================

set_false_path -to [get_ports {tx_serial}]


# ============================================================
# Clock Uncertainty
# ============================================================

set_clock_uncertainty 0.2 [get_clocks {clk_fast}]
set_clock_uncertainty 0.2 [get_clocks {clk_slow}]


#set_false_path -from [get_ports {rst_n}]