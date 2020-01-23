# report critical path through each chunk
#
# there are 22 chunks
#
# get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/*

set all_the_chunks [list \
 0 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/modulus_GGG_chunk*_inst0 \
 1 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks1[0].modulus_GGG_chunk*_inst  \
 2 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks1[1].modulus_GGG_chunk*_inst  \
 3 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks1[2].modulus_GGG_chunk*_inst  \
 4 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks1[3].modulus_GGG_chunk*_inst  \
 5 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks1[4].modulus_GGG_chunk*_inst  \
 6 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks1[5].modulus_GGG_chunk*_inst  \
 7 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks1[6].modulus_GGG_chunk*_inst  \
 8 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks1[7].modulus_GGG_chunk*_inst  \
 9 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks2[0].modulus_GGG_chunk*_inst  \
10 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks2[1].modulus_GGG_chunk*_inst  \
11 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks2[2].modulus_GGG_chunk*_inst  \
12 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks2[3].modulus_GGG_chunk*_inst  \
13 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks2[4].modulus_GGG_chunk*_inst  \
14 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks2[5].modulus_GGG_chunk*_inst  \
15 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks2[6].modulus_GGG_chunk*_inst  \
16 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks2[7].modulus_GGG_chunk*_inst  \
17 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks2[8].modulus_GGG_chunk*_inst  \
18 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks2[9].modulus_GGG_chunk*_inst  \
19 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks2[10].modulus_GGG_chunk*_inst  \
20 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/chunks2[11].modulus_GGG_chunk*_inst  \
21 WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/modsqr/modsqr/modsqr_topdie/modulus_GGG_inst/modulus_GGG_chunk*_inst_21  \
]

foreach {chunk_num chunk_name} $all_the_chunks {
    set report_file chunk_timing.${STEP}.[format "%02d" ${chunk_num}].rpt
    set all_chunk_cells [get_cells -hier -filter "NAME =~ ${chunk_name}/*"]

    set to_path      [get_timing_paths -to      $all_chunk_cells]
    set from_path    [get_timing_paths -from    $all_chunk_cells]
    set through_path [get_timing_paths -through $all_chunk_cells]

    puts "# writing file ${report_file}"

    if {[string equal "(none)" [get_property GROUP $from_path]]} {

	# no "from" path was found, so only report "through"
	report_timing -file ${report_file} -of_objects $through_path

    } else {

	# report "from", "to", and clock latency correction
	report_timing         -file ${report_file} -of_objects $to_path
	report_timing -append -file ${report_file} -of_objects $from_path

	set to_slack   [get_property SLACK $to_path]
	set from_slack [get_property SLACK $from_path]

	# calculate the clock latency correction, to equalize slack for from/to paths
	set correction [expr ( $from_slack - $to_slack ) / 2.0 ]
	# round to 3 decimal places
	set correction [expr [::tcl::mathfunc::round [expr $correction * 1000]] / 1000.0]

	set fid [open $report_file a]
	puts $fid ""
	puts $fid "chunk [format {%02d} ${chunk_num}] correction for clock [get_property ENDPOINT_CLOCK ${to_path}] is ${correction}"
	close $fid
    }
}

unset report_file chunk_num chunk_name all_chunk_cells to_path from_path through_path to_slack from_slack correction fid
