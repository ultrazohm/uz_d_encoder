#	cd [get_property DIRECTORY [current_project]]
#	source {./vivado_export_xsa.tcl}

set work_directory [get_property DIRECTORY [current_project]] ; 
cd $work_directory ; 
write_hw_platform -fixed -force -include_bit -file {zusys_wrapper.xsa}
open_run impl_1
write_debug_probes -force ../DebugProbes
