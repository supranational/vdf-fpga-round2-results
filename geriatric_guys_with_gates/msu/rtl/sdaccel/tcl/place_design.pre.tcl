# Tcl script run before place_design

puts "### Running script [file tail [info script]]"

set STEP {place_design.pre}

# save checkpoint
write_checkpoint ${STEP}.dcp

# Required for SDAccel to prevent this:
# ERROR: [Place 30-718] Sub-optimal placement for an MMCM/PLL-BUFGCE-MMCM/PLL cascade pair.If this sub optimal condition is acceptable for this design, you may use the CLOCK_DEDICATED_ROUTE constraint in the .xdc file to demote this message to a WARNING. However, the use of this override is highly discouraged. These examples can be used directly in the .xdc file to override this clock rule.
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets WRAPPER_INST/SH/kernel_clks_i/clkwiz_kernel_clk0/inst/CLK_CORE_DRP_I/clk_inst/clk_out1]

# placement constraints

add_cells_to_pblock [get_pblocks pblock_dynamic_SLR2] [get_cells [list {WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie}]]
add_cells_to_pblock [get_pblocks pblock_dynamic_SLR1] [get_cells [list {WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_middie}]]

# reports

report_drc -ruledecks {default} > report_drc.${STEP}.rpt
