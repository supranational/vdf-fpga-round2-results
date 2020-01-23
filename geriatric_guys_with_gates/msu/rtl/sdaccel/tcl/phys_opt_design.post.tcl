# Tcl script run after phys_opt_design

puts "### Running script [file tail [info script]]"

set STEP {phys_opt_design.post}

# checkpoint
write_checkpoint ${STEP}.dcp

# reports
report_clocks                           > report_clocks.${STEP}.rpt
report_timing_summary -max_paths 10 	> report_timing_summary.${STEP}.rpt
report_power                            > report_power.${STEP}.rpt
report_utilization -hierarchical 	> report_utilization_hierarchical.${STEP}.rpt
report_utilization -slr 		> report_utilization_slr.${STEP}.rpt
report_utilization -hierarchical -hierarchical_depth 3 -cells [get_cells -hier -regexp .*/msu/modsqr] > report_utilization_hierarchical.modsqr.${STEP}.rpt
set FH [open "report_nets.${STEP}.rpt" w]
puts $FH "Total nets is [llength [get_nets -hier -top]]"
close $FH
