# Tcl script run before synth_design

puts "### Running script [file tail [info script]]"

# get directory this script is in
set scriptDir [file dirname [file normalize [info script]]]

# create the constraint fileset for synthesis
create_fileset -constrset synth_constrs
set obj [get_filesets synth_constrs]

# add the XDC clocks definition file to the fileset
set file [file join $scriptDir "synth_design.clocks.xdc"]
add_files -norecurse -fileset $obj [list $file]

# set properties on this file
set file_obj [get_files -of_objects $obj [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj
set_property -name "used_in" -value "synthesis" -objects $file_obj
set_property -name "used_in_synthesis" -value "1" -objects $file_obj
set_property -name "processing_order" -value "EARLY" -objects $file_obj

# add the XDC constraint file to the fileset
set file [file join $scriptDir "synth_design.xdc"]
add_files -norecurse -fileset $obj [list $file]

# set properties on this file
set file_obj [get_files -of_objects $obj [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj
set_property -name "used_in" -value "synthesis" -objects $file_obj
set_property -name "used_in_synthesis" -value "1" -objects $file_obj
set_property -name "processing_order" -value "LATE" -objects $file_obj
