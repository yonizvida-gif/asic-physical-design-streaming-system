# ============================================================
# Clock Constraints
# ============================================================

# Fast clock: 100 MHz
create_clock -name clk_fast -period 10.000 [get_ports {clk_fast}]

# Slow clock: 10 MHz
create_clock -name clk_slow -period 100.000 [get_ports {clk_slow}]

# Clock uncertainty
derive_clock_uncertainty


# ============================================================
# Asynchronous Clock Domains
# ============================================================

set_clock_groups -asynchronous \
    -group [get_clocks {clk_fast}] \
    -group [get_clocks {clk_slow}]
 

#get_false_path \
    -from [get_clocks {clk_fast}] \
	 -to   [get_clocks {clk_slow}]
	 

#get_false_path \
    -from [get_clocks {clk_slow}] \
	 -to   [get_clocks {clk_fast}]