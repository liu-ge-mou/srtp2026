# Run with: vivado -mode batch -source create_project.tcl
set project_dir [file normalize [file dirname [info script]]]
create_project -force direction_b [file join $project_dir build] -part xc7a35tcpg236-1

foreach source {mul7_4.v mul.v multi.v add.v} {
    add_files -fileset sources_1 [file join $project_dir deps $source]
}
foreach source {systolic_array_conv.v systolic_conv_network.v} {
    add_files -fileset sources_1 [file join $project_dir rtl $source]
}
set_property top systolic_conv_network [get_filesets sources_1]

add_files -fileset sim_1 [file join $project_dir tb test_systolic_conv_network.v]
set_property top test_systolic_conv_network [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
close_project
