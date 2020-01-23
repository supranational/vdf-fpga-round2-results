# Tcl script run before post_route_phys_opt_design

puts "### Running script [file tail [info script]]"

set STEP {post_route_phys_opt_design.pre}

#----------------------------------------------------------------------------------------------------
# relax overconstrained paths

set_clock_uncertainty -setup 0 -from [get_clocks modsqr_clk_phase_00] -to [get_clocks modsqr_clk_phase_00]

set_clock_uncertainty -setup 0 -from [get_clocks modsqr_clk_phase_08] -to [get_clocks modsqr_clk_phase_00]
set_clock_uncertainty -setup 0 -from [get_clocks modsqr_clk_phase_00] -to [get_clocks modsqr_clk_phase_08]

set_clock_uncertainty -setup 0 -from [get_clocks modsqr_clk_phase_01] -to [get_clocks modsqr_clk_phase_00]
set_clock_uncertainty -setup 0 -from [get_clocks modsqr_clk_phase_00] -to [get_clocks modsqr_clk_phase_01]

set_clock_uncertainty -setup 0 -from [get_clocks modsqr_clk_phase_02] -to [get_clocks modsqr_clk_phase_00]
set_clock_uncertainty -setup 0 -from [get_clocks modsqr_clk_phase_00] -to [get_clocks modsqr_clk_phase_02]

set_clock_uncertainty -setup 0 -from [get_clocks modsqr_clk_phase_03] -to [get_clocks modsqr_clk_phase_00]
set_clock_uncertainty -setup 0 -from [get_clocks modsqr_clk_phase_00] -to [get_clocks modsqr_clk_phase_03]

#----------------------------------------------------------------------------------------------------
# enable bypass

# turn on bypass path
set_case_analysis 1 \
    [get_pins \
	 -of_object [get_cells -hier -filter {IS_SEQUENTIAL == true && NAME =~ *modsqr*/bypass_reg* }] \
	 -filter {DIRECTION == OUT}]

# these flops are now bypassed, so prevent bogus timing reports ending at them
set_disable_timing -from C [get_cells -hier -filter {IS_SEQUENTIAL == true && NAME =~ */modulus_GGG_inst/*/lut_addr_reg_reg*}]
set_disable_timing -from C [get_cells -hier -filter {IS_SEQUENTIAL == true && NAME =~ */modsqr_middie/reduced_grid_sum_reg_reg*}]

#---------------------------------------------------------------------------------------------------
# modify clock settings to signoff values
# this agrees with RTL, and thus the bitstream values

# find the MMCM cell name
set MMCM_cell [get_cells -hier -regexp {.*/MMCME4_inst_}]

# 41.667 MHz input to phase detector
set_property DIVCLK_DIVIDE     3    ${MMCM_cell}

# 1291.667 MHz VCO
set_property CLKFBOUT_MULT_F  31    ${MMCM_cell}

# modsqr 39.141 MHz = 25.548 ns
set_property CLKOUT0_DIVIDE_F 33    ${MMCM_cell}
set_property CLKOUT1_DIVIDE   33    ${MMCM_cell}
set_property CLKOUT2_DIVIDE   33    ${MMCM_cell}
set_property CLKOUT3_DIVIDE   33    ${MMCM_cell}

# clk_phase[1] @ 10.398 ns
set_property CLKOUT1_DUTY_CYCLE 0.407 ${MMCM_cell}

# clk_phase[2] @ 10.986 ns
set_property CLKOUT2_DUTY_CYCLE 0.430 ${MMCM_cell}

# clk_phase[3] @ 10.168 ns
set_property CLKOUT3_DUTY_CYCLE 0.398 ${MMCM_cell}

#---------------------------------------------------------------------------------------------------
# update and report

update_timing

report_timing_summary -max_paths 10 -input_pins > report_timing_summary.${STEP}.rpt

source [file join [file dirname [info script]] "chunk_timing.tcl"]

#---------------------------------------------------------------------------------------------------
