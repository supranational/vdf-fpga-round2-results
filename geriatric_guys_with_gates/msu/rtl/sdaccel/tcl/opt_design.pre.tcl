# Tcl script run before opt_design

puts "### Running script [file tail [info script]]"

set STEP {opt_design.pre}

# save checkpoint
write_checkpoint ${STEP}.dcp

# early reports
report_clocks                           > report_clocks.${STEP}_constraints.rpt
report_timing_summary -max_paths 10 	> report_timing_summary.${STEP}_constraints.rpt

# reapply timing constraints from synth step
set scriptDir [file dirname [file normalize [info script]]]
read_xdc [file join $scriptDir "synth_design.xdc"]

# reports at start of implementation flow
report_clocks                           > report_clocks.${STEP}.rpt
report_timing_summary -max_paths 10 	> report_timing_summary.${STEP}.rpt
report_utilization -hierarchical 	> report_utilization_hierarchical.${STEP}.rpt
report_utilization -hierarchical -hierarchical_depth 3 -cells [get_cells -hier -regexp .*/msu/modsqr] > report_utilization_hierarchical.modsqr.${STEP}.rpt
set FH [open "report_nets.${STEP}.rpt" w]
puts $FH "Total nets is [llength [get_nets -hier -top]]"
close $FH
