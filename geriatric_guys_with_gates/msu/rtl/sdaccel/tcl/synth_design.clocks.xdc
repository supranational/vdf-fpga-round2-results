# define clocks for synthesis step
# because synth_design is not run at top level, therefore kernel clock has not been defined

create_clock -name clk_extra_b0 -period 8 [get_ports ap_clk]
