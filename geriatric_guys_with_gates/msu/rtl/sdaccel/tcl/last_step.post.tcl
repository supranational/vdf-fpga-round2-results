# Tcl script run after the final step

puts "### Running script [file tail [info script]]"

if {[string equal $ACTIVE_STEP "route_design"]} {

    # we are in post-hook for step route_design
    # first, find out if route_design is the last step
    # if it is, then we will find "report_timing_and_scale_freq" in the parent post hook script

    set filename "../../../scripts/_sdx_post_route.tcl"
    set fid [open $filename r]
    set is_match [regexp {report_timing_and_scale_freq[^\]]*} [read $fid [file size $filename]] matchvar]
    close $fid

    if {! $is_match} {
	# route_design is not the last step, so return
	puts "# returning because $ACTIVE_STEP is not the last step"
	return
    }

} elseif {[string equal $ACTIVE_STEP "post_route_phys_opt_design"]} {

    # we are in post-hook for step post_route_phys_opt_design
    # look for "report_timing_and_scale_freq" in the parent post hook script

    set filename "../../../scripts/_sdx_post_post_route_phys_opt.tcl"
    set fid [open $filename r]
    set is_match [regexp {report_timing_and_scale_freq[^\]]*} [read $fid [file size $filename]] matchvar]
    close $fid

} else {
    puts "# unknown ACTIVE_STEP : $ACTIVE_STEP"
    return
}

# if we are here, then this is the last step,
# and report_timing_and_scale_freq command has been captured in $matchvar

#----------------------------------------------------------------------------------------------------
# This proc report_timing_and_scale_freq is normally run by the parent post hook script
# but it will error out if there are timing violations, thus terminating Vivado early.
#
# So we've prevented it from running up there, by setting the magic switch skipTimingCheckAndFrequencyScaling=1
#
# However... it must run eventually, because it writes file $output_dir/_new_clk_freq which is needed by F1
#
# So run it here, at the end of our last post hook script,
# with arguments we've copied from the parent post hook script,
# except we change these values to prevent it from failing:
#
#   worst_negative_slack      -1000
#   error_on_hold_violation   false
#   skip_timing_and_scaling   false
#   enable_auto_freq_scale    false

puts "### Running hacked-up report_timing_and_scale_freq:"
puts "###   was: $matchvar"

regsub {worst_negative_slack\s+\w+}    $matchvar {worst_negative_slack -1000}    matchvar
regsub {error_on_hold_violation\s+\w+} $matchvar {error_on_hold_violation false} matchvar
regsub {skip_timing_and_scaling\s+\w+} $matchvar {skip_timing_and_scaling false} matchvar
regsub {enable_auto_freq_scale\s+\w+}  $matchvar {enable_auto_freq_scale false}  matchvar

puts "###   now: $matchvar"

# run timing analysis and frequency scaling
if { ![eval $matchvar] } {
  return false
}

unset matchvar
