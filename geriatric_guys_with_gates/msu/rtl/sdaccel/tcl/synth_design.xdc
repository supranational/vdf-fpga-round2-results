# timing constraints for synthesis step

#---------------------------------------------------------------------------------------------------
# find the MMCM cell name

set MMCM_cell [get_cells -hier -regexp {.*/MMCME4_inst_}]

#---------------------------------------------------------------------------------------------------
# fix names for auto-derived clocks generated by MMCM
# only specify clocks that have loads

create_generated_clock -name  modsqr_clk_phase_00 [get_pins -of_object $MMCM_cell -filter {REF_PIN_NAME==CLKOUT0}]
create_generated_clock -name  modsqr_clk_phase_08 [get_pins -of_object $MMCM_cell -filter {REF_PIN_NAME==CLKOUT0B}]
create_generated_clock -name  modsqr_clk_phase_01 [get_pins -of_object $MMCM_cell -filter {REF_PIN_NAME==CLKOUT1B}]
create_generated_clock -name  modsqr_clk_phase_02 [get_pins -of_object $MMCM_cell -filter {REF_PIN_NAME==CLKOUT2B}]
create_generated_clock -name  modsqr_clk_phase_03 [get_pins -of_object $MMCM_cell -filter {REF_PIN_NAME==CLKOUT3B}]

#---------------------------------------------------------------------------------------------------
# modify clock settingss for synth/impl flow

# 125 MHz input to phase detector
set_property DIVCLK_DIVIDE     1    ${MMCM_cell}

# 1593.75 MHz VCO
set_property CLKFBOUT_MULT_F  12.75 ${MMCM_cell}

# modsqr 37.946 MHz = 26.353 ns
set_property CLKOUT0_DIVIDE_F 42    ${MMCM_cell}
set_property CLKOUT1_DIVIDE   42    ${MMCM_cell}
set_property CLKOUT2_DIVIDE   42    ${MMCM_cell}
set_property CLKOUT3_DIVIDE   42    ${MMCM_cell}

# clk_phase[1] @ 9.065 ns
set_property CLKOUT1_DUTY_CYCLE 0.344 ${MMCM_cell}

# clk_phase[2] @ 10.304 ns
set_property CLKOUT2_DUTY_CYCLE 0.391 ${MMCM_cell}

# clk_phase[3] @ 10.488 ns
set_property CLKOUT3_DUTY_CYCLE 0.398 ${MMCM_cell}

#---------------------------------------------------------------------------------------------------
# fix clock phase relationships
# rest of paths are correct with default 1 cycle

#---------------------------------------------------------------------------------------------------
# set_max_delay on clock domain crossing (CDC) paths

# because modsqr clocks are asynchronous to the kernel (mostly, sorta, let's pretend they are)
# the right thing to do is this:
#   set_clock_groups -name modsqr_clk -asynchronous -group [get_clocks modsqr_clk_phase*]
# but that incorrectly overrides these set_max_delay we use for CDC constraints

# first, get the periods

set KERNEL_CLOCK_PERIOD [get_property PERIOD [get_clocks clk_extra_b0]]
set MODSQR_CLOCK_PERIOD [get_property PERIOD [get_clocks modsqr_clk_phase_00]]

# max delay for control signals that get synchronized is a bit less than one clock period of capture clock

set MAX_DELAY_CONTROL_TO_KERNEL [expr 0.9 * ${KERNEL_CLOCK_PERIOD}]
set MAX_DELAY_CONTROL_TO_MODSQR [expr 0.9 * ${MODSQR_CLOCK_PERIOD}]

# round off values to nearest picosecond

set MAX_DELAY_CONTROL_TO_KERNEL [expr round(1000 * ${MAX_DELAY_CONTROL_TO_KERNEL}) / 1000.0]
set MAX_DELAY_CONTROL_TO_MODSQR [expr round(1000 * ${MAX_DELAY_CONTROL_TO_MODSQR}) / 1000.0]

# max delay for datapath is twice as long (because there are no sync flops)

set MAX_DELAY_DATAPATH_TO_KERNEL [expr 2 * ${MAX_DELAY_CONTROL_TO_KERNEL}]
set MAX_DELAY_DATAPATH_TO_MODSQR [expr 2 * ${MAX_DELAY_CONTROL_TO_MODSQR}]

# default max delay covers the datapath : sq_in, sq_out

set_max_delay \
    -datapath_only \
    -from [get_clocks clk_extra_b0] \
    -to   [get_clocks modsqr_clk_phase_00] \
    ${MAX_DELAY_DATAPATH_TO_MODSQR}

set_max_delay \
    -datapath_only \
    -from [get_clocks modsqr_clk_phase_00] \
    -to   [get_clocks clk_extra_b0] \
    ${MAX_DELAY_DATAPATH_TO_KERNEL}

# override these defaults for specific control signals

# modsqr_reset sync flop
set_max_delay \
    -datapath_only \
    -from [get_clocks clk_extra_b0] \
    -to [get_pins \
	     -of_object [get_cells -hier -filter {IS_SEQUENTIAL == true && NAME =~ *modsqr*/modsqr_reset_sync1_reg* }] \
	     -filter {DIRECTION == IN && IS_CLOCK == false}] \
    ${MAX_DELAY_CONTROL_TO_MODSQR}

# modsqr_start sync flop
set_max_delay \
    -datapath_only \
    -from [get_clocks clk_extra_b0] \
    -to [get_pins \
	     -of_object [get_cells -hier -filter {IS_SEQUENTIAL == true && NAME =~ *modsqr*/modsqr_start_sync1_reg* }] \
	     -filter {DIRECTION == IN && IS_CLOCK == false}] \
    ${MAX_DELAY_CONTROL_TO_MODSQR}

# valid sync flop
set_max_delay \
    -datapath_only \
    -from [get_clocks modsqr_clk_phase_00] \
    -to [get_pins \
	     -of_object [get_cells -hier -filter {IS_SEQUENTIAL == true && NAME =~ *modsqr*/valid_sync1_reg* }] \
	     -filter {DIRECTION == IN && IS_CLOCK == false}] \
    ${MAX_DELAY_CONTROL_TO_KERNEL}

#---------------------------------------------------------------------------------------------------
# force bypass signal to *not* bypass
# this greatly reduces the number of timing paths

set_case_analysis 0 \
    [get_pins \
	 -of_object [get_cells -hier -filter {IS_SEQUENTIAL == true && NAME =~ *modsqr*/bypass_reg* }] \
	 -filter {DIRECTION == OUT}]

#---------------------------------------------------------------------------------------------------
# overconstrain paths

set_clock_uncertainty -setup 4 -from [get_clocks modsqr_clk_phase_00] -to [get_clocks modsqr_clk_phase_00]

set_clock_uncertainty -setup 2 -from [get_clocks modsqr_clk_phase_08] -to [get_clocks modsqr_clk_phase_00]
set_clock_uncertainty -setup 2 -from [get_clocks modsqr_clk_phase_00] -to [get_clocks modsqr_clk_phase_08]

set_clock_uncertainty -setup 2 -from [get_clocks modsqr_clk_phase_01] -to [get_clocks modsqr_clk_phase_00]
set_clock_uncertainty -setup 2 -from [get_clocks modsqr_clk_phase_00] -to [get_clocks modsqr_clk_phase_01]

set_clock_uncertainty -setup 2 -from [get_clocks modsqr_clk_phase_02] -to [get_clocks modsqr_clk_phase_00]
set_clock_uncertainty -setup 2 -from [get_clocks modsqr_clk_phase_00] -to [get_clocks modsqr_clk_phase_02]

set_clock_uncertainty -setup 2 -from [get_clocks modsqr_clk_phase_03] -to [get_clocks modsqr_clk_phase_00]
set_clock_uncertainty -setup 2 -from [get_clocks modsqr_clk_phase_00] -to [get_clocks modsqr_clk_phase_03]