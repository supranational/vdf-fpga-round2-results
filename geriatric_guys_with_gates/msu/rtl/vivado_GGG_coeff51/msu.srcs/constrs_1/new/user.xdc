
create_clock -period 28.549 -name modsqr_clk_phase00 [get_ports clk_phase[0]]
create_clock -period 28.549 -name modsqr_clk_phase08 -waveform {14.275 28.549} [get_ports clk_phase[8]]

create_pblock sl_exclusion
resize_pblock [get_pblocks sl_exclusion] -add {CLOCKREGION_X4Y0:CLOCKREGION_X5Y9}
set_property EXCLUDE_PLACEMENT 1 [get_pblocks sl_exclusion]
create_pblock SLR2
add_cells_to_pblock [get_pblocks SLR2] [get_cells -quiet [list inst_wrapper/inst_kernel/msu/modsqr/modsqr]]
resize_pblock [get_pblocks SLR2] -add {CLOCKREGION_X0Y10:CLOCKREGION_X5Y14}
