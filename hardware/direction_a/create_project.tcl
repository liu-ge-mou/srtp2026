# Run with: vivado -mode batch -source create_project.tcl
set project_dir [file normalize [file dirname [info script]]]
create_project -force direction_a [file join $project_dir build] -part xc7a35tcpg236-1

foreach source {accumulator.v pe.v systolic_array_2x2.v} {
    add_files -fileset sources_1 [file join $project_dir rtl $source]
}
set_property top systolic_array_2x2 [get_filesets sources_1]

foreach source {test_accumulator.v test_pe.v test_systolic_array_2x2.v} {
    add_files -fileset sim_1 [file join $project_dir tb $source]
}
set_property top test_systolic_array_2x2 [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
close_project
