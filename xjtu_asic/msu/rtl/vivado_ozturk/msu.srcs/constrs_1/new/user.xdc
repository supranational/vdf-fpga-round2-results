
create_clock -period 8.000 -name ap_clk -waveform {0.000 4.000} [get_ports ap_clk]
#set_property USER_SLR_ASSIGNMENT SLR0 [get_cells inst_wrapper/inst_kernel/msu/modsqr/modsqr]
#create_pblock SLR0
#add_cells_to_pblock [get_pblocks SLR0] [get_cells -quiet [list inst_wrapper/inst_kernel/msu]]
#resize_pblock [get_pblocks SLR0] -add {CLOCKREGION_X0Y5:CLOCKREGION_X5Y9}

