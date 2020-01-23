# Tcl script run before route_design

puts "### Running script [file tail [info script]]"

set STEP {route_design.pre}

# checkpoint
write_checkpoint ${STEP}.dcp

# reports
report_clocks                           > report_clocks.${STEP}.rpt
report_timing_summary -max_paths 10 	> report_timing_summary.${STEP}.rpt
report_utilization -hierarchical 	> report_utilization_hierarchical.${STEP}.rpt
report_utilization -slr 		> report_utilization_slr.${STEP}.rpt
report_utilization -hierarchical -hierarchical_depth 3 -cells [get_cells -hier -regexp .*/msu/modsqr] > report_utilization_hierarchical.modsqr.${STEP}.rpt
set FH [open "report_nets.${STEP}.rpt" w]
puts $FH "Total nets is [llength [get_nets -hier -top]]"
close $FH
