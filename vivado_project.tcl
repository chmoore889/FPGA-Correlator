#*****************************************************************************************
# Vivado (TM) v2020.2 (64-bit)
#
# vivado_project.tcl: Tcl script for re-creating project 'vivado_project'
#
# IP Build 3064653 on Wed Nov 18 14:17:31 MST 2020
#
# This file contains the Vivado Tcl commands for re-creating the project to the state*
# when this script was generated. In order to re-create the project, please source this
# file in the Vivado Tcl Shell.
#
# * Note that the runs in the created project will be configured the same way as the
#   original project, however they will not be launched automatically. To regenerate the
#   run results please launch the synthesis/implementation runs as needed.
#
#*****************************************************************************************
# Check file required for this script exists
proc checkRequiredFiles { origin_dir} {
  set status true
  set files [list \
   "${origin_dir}/src/design/ip/data_storage_fifo/data_storage_fifo.xci" \
   "${origin_dir}/src/design/UART_interface.vhd" \
   "${origin_dir}/src/design/combiner.vhd" \
   "${origin_dir}/src/design/correlator.vhd" \
   "${origin_dir}/src/design/counter.vhd" \
   "${origin_dir}/src/design/dsp_multiply_and_accumulate.vhd" \
   "${origin_dir}/src/design/multi_tau_correlator.vhd" \
   "${origin_dir}/src/design/multiplication_accumulator.vhd" \
   "${origin_dir}/src/design/scaler.vhd" \
   "${origin_dir}/uart-for-fpga/rtl/comp/uart_clk_div.vhd" \
   "${origin_dir}/uart-for-fpga/rtl/comp/uart_debouncer.vhd" \
   "${origin_dir}/uart-for-fpga/rtl/comp/uart_parity.vhd" \
   "${origin_dir}/uart-for-fpga/rtl/comp/uart_rx.vhd" \
   "${origin_dir}/uart-for-fpga/rtl/comp/uart_tx.vhd" \
   "${origin_dir}/uart-for-fpga/rtl/uart.vhd" \
   "${origin_dir}/src/design/top.vhd" \
   "${origin_dir}/src/design/ip/corr_out_fifo/corr_out_fifo.xci" \
   "${origin_dir}/src/design/ip/single_divider/single_divider.xci" \
   "${origin_dir}/src/design/ip/uint32_to_single/uint32_to_single.xci" \
   "${origin_dir}/src/constraints/Arty-A7-100-Master.xdc" \
   "${origin_dir}/src/testbench/multiplication_accumulator_testbench.vhd" \
   "${origin_dir}/src/testbench/multiplication_accumulator_testbench_behav.wcfg" \
   "${origin_dir}/src/testbench/correlator_testbench.vhd" \
   "${origin_dir}/src/testbench/correlator_testbench_behav.wcfg" \
   "${origin_dir}/src/testbench/combiner_testbench.vhd" \
   "${origin_dir}/src/testbench/combiner_testbench_behav.wcfg" \
   "${origin_dir}/src/testbench/correlator_combiner_testbench.vhd" \
   "${origin_dir}/src/testbench/correlator_combiner_testbench_behav.wcfg" \
   "${origin_dir}/src/testbench/divided_correlator.vhd" \
   "${origin_dir}/src/testbench/divided_correlator_behav.wcfg" \
   "${origin_dir}/src/testbench/multi_tau_correlator_testbench.vhd" \
   "${origin_dir}/src/testbench/multi_tau_correlator_testbench_behav.wcfg" \
   "${origin_dir}/src/testbench/uart_interface_testbench.vhd" \
   "${origin_dir}/src/testbench/uart_interface_testbench_behav.wcfg" \
   "${origin_dir}/utils/top_routed.dcp" \
  ]
  foreach ifile $files {
    if { ![file isfile $ifile] } {
      puts " Could not find remote file $ifile "
      set status false
    }
  }

  return $status
}
# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir [file dirname [info script]]

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Set the project name
set _xil_proj_name_ "vivado_project"

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
  set _xil_proj_name_ $::user_project_name
}

variable script_file
set script_file "vivado_project.tcl"

# Help information for this script
proc print_help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--project_name <name>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--project_name <name>\] Create project with the specified name. Default"
  puts "                       name is the name of the project from where this"
  puts "                       script was generated.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name" { incr i; set _xil_proj_name_ [lindex $::argv $i] }
      "--help"         { print_help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/vivado_project"]"

# Check for paths and files needed for project creation
set validate_required 0
if { $validate_required } {
  if { [checkRequiredFiles $origin_dir] } {
    puts "Tcl file $script_file is valid. All files required for project creation is accesable. "
  } else {
    puts "Tcl file $script_file is not valid. Not all files required for project creation is accesable. "
    return
  }
}

# Create project
create_project ${_xil_proj_name_} $origin_dir/vivado_project -part xc7a100tcsg324-1 -quiet -force

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "board_part" -value "digilentinc.com:arty-a7-100:part0:1.0" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${_xil_proj_name_}.cache/ip" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "platform.board_id" -value "nexys-a7-100t" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj
set_property -name "webtalk.activehdl_export_sim" -value "72" -objects $obj
set_property -name "webtalk.ies_export_sim" -value "72" -objects $obj
set_property -name "webtalk.modelsim_export_sim" -value "73" -objects $obj
set_property -name "webtalk.questa_export_sim" -value "73" -objects $obj
set_property -name "webtalk.riviera_export_sim" -value "72" -objects $obj
set_property -name "webtalk.riviera_launch_sim" -value "7" -objects $obj
set_property -name "webtalk.vcs_export_sim" -value "72" -objects $obj
set_property -name "webtalk.xsim_export_sim" -value "73" -objects $obj
set_property -name "webtalk.xsim_launch_sim" -value "678" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_MEMORY" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
set files [list \
 [file normalize "${origin_dir}/src/design/ip/data_storage_fifo/data_storage_fifo.xci"] \
 [file normalize "${origin_dir}/src/design/UART_interface.vhd"] \
 [file normalize "${origin_dir}/src/design/combiner.vhd"] \
 [file normalize "${origin_dir}/src/design/correlator.vhd"] \
 [file normalize "${origin_dir}/src/design/counter.vhd"] \
 [file normalize "${origin_dir}/src/design/dsp_multiply_and_accumulate.vhd"] \
 [file normalize "${origin_dir}/src/design/multi_tau_correlator.vhd"] \
 [file normalize "${origin_dir}/src/design/multiplication_accumulator.vhd"] \
 [file normalize "${origin_dir}/src/design/scaler.vhd"] \
 [file normalize "${origin_dir}/uart-for-fpga/rtl/comp/uart_clk_div.vhd"] \
 [file normalize "${origin_dir}/uart-for-fpga/rtl/comp/uart_debouncer.vhd"] \
 [file normalize "${origin_dir}/uart-for-fpga/rtl/comp/uart_parity.vhd"] \
 [file normalize "${origin_dir}/uart-for-fpga/rtl/comp/uart_rx.vhd"] \
 [file normalize "${origin_dir}/uart-for-fpga/rtl/comp/uart_tx.vhd"] \
 [file normalize "${origin_dir}/uart-for-fpga/rtl/uart.vhd"] \
 [file normalize "${origin_dir}/src/design/top.vhd"] \
]
add_files -norecurse -fileset $obj $files

# Set 'sources_1' fileset file properties for remote files
set file "$origin_dir/src/design/ip/data_storage_fifo/data_storage_fifo.xci"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "generate_files_for_reference" -value "0" -objects $file_obj
set_property -name "registered_with_manager" -value "1" -objects $file_obj
if { ![get_property "is_locked" $file_obj] } {
  set_property -name "synth_checkpoint_mode" -value "Singular" -objects $file_obj
}

set file "$origin_dir/src/design/UART_interface.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/src/design/combiner.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/src/design/correlator.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/src/design/counter.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/src/design/dsp_multiply_and_accumulate.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/src/design/multi_tau_correlator.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/src/design/multiplication_accumulator.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/src/design/scaler.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/uart-for-fpga/rtl/comp/uart_clk_div.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/uart-for-fpga/rtl/comp/uart_debouncer.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/uart-for-fpga/rtl/comp/uart_parity.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/uart-for-fpga/rtl/comp/uart_rx.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/uart-for-fpga/rtl/comp/uart_tx.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/uart-for-fpga/rtl/uart.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file "$origin_dir/src/design/top.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj


# Set 'sources_1' fileset file properties for local files
# None

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property -name "top" -value "top" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
set files [list \
 [file normalize "${origin_dir}/src/design/ip/corr_out_fifo/corr_out_fifo.xci"] \
]
add_files -norecurse -fileset $obj $files

# Set 'sources_1' fileset file properties for remote files
set file "$origin_dir/src/design/ip/corr_out_fifo/corr_out_fifo.xci"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "generate_files_for_reference" -value "0" -objects $file_obj
set_property -name "registered_with_manager" -value "1" -objects $file_obj
if { ![get_property "is_locked" $file_obj] } {
  set_property -name "synth_checkpoint_mode" -value "Singular" -objects $file_obj
}


# Set 'sources_1' fileset file properties for local files
# None

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
set files [list \
 [file normalize "${origin_dir}/src/design/ip/single_divider/single_divider.xci"] \
]
add_files -norecurse -fileset $obj $files

# Set 'sources_1' fileset file properties for remote files
set file "$origin_dir/src/design/ip/single_divider/single_divider.xci"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "generate_files_for_reference" -value "0" -objects $file_obj
set_property -name "registered_with_manager" -value "1" -objects $file_obj
if { ![get_property "is_locked" $file_obj] } {
  set_property -name "synth_checkpoint_mode" -value "Singular" -objects $file_obj
}


# Set 'sources_1' fileset file properties for local files
# None

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
set files [list \
 [file normalize "${origin_dir}/src/design/ip/uint32_to_single/uint32_to_single.xci"] \
]
add_files -norecurse -fileset $obj $files

# Set 'sources_1' fileset file properties for remote files
set file "$origin_dir/src/design/ip/uint32_to_single/uint32_to_single.xci"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "generate_files_for_reference" -value "0" -objects $file_obj
set_property -name "registered_with_manager" -value "1" -objects $file_obj
if { ![get_property "is_locked" $file_obj] } {
  set_property -name "synth_checkpoint_mode" -value "Singular" -objects $file_obj
}


# Set 'sources_1' fileset file properties for local files
# None

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/src/constraints/Arty-A7-100-Master.xdc"]"
set file_added [add_files -norecurse -fileset $obj [list $file]]
set file "$origin_dir/src/constraints/Arty-A7-100-Master.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]
set_property -name "target_constrs_file" -value "[file normalize "$origin_dir/src/constraints/Arty-A7-100-Master.xdc"]" -objects $obj
set_property -name "target_ucf" -value "[file normalize "$origin_dir/src/constraints/Arty-A7-100-Master.xdc"]" -objects $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
set files [list \
 [file normalize "${origin_dir}/src/testbench/multiplication_accumulator_testbench.vhd"] \
 [file normalize "${origin_dir}/src/testbench/multiplication_accumulator_testbench_behav.wcfg"] \
]
add_files -norecurse -fileset $obj $files

# Set 'sim_1' fileset file properties for remote files
set file "$origin_dir/src/testbench/multiplication_accumulator_testbench.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj


# Set 'sim_1' fileset file properties for local files
# None

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property -name "hbs.configure_design_for_hier_access" -value "1" -objects $obj
set_property -name "top" -value "multiplication_accumulator_testbench" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj
set_property -name "xsim.simulate.runtime" -value "INF" -objects $obj

# Create 'correlator' fileset (if not found)
if {[string equal [get_filesets -quiet correlator] ""]} {
  create_fileset -simset correlator
}

# Set 'correlator' fileset object
set obj [get_filesets correlator]
set files [list \
 [file normalize "${origin_dir}/src/testbench/correlator_testbench.vhd"] \
 [file normalize "${origin_dir}/src/testbench/correlator_testbench_behav.wcfg"] \
]
add_files -norecurse -fileset $obj $files

# Set 'correlator' fileset file properties for remote files
set file "$origin_dir/src/testbench/correlator_testbench.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets correlator] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj


# Set 'correlator' fileset file properties for local files
# None

# Set 'correlator' fileset properties
set obj [get_filesets correlator]
set_property -name "hbs.configure_design_for_hier_access" -value "1" -objects $obj
set_property -name "nl.mode" -value "funcsim" -objects $obj
set_property -name "top" -value "correlator_testbench" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj
set_property -name "xsim.simulate.runtime" -value "INF" -objects $obj

# Create 'combiner' fileset (if not found)
if {[string equal [get_filesets -quiet combiner] ""]} {
  create_fileset -simset combiner
}

# Set 'combiner' fileset object
set obj [get_filesets combiner]
set files [list \
 [file normalize "${origin_dir}/src/testbench/combiner_testbench.vhd"] \
 [file normalize "${origin_dir}/src/testbench/combiner_testbench_behav.wcfg"] \
]
add_files -norecurse -fileset $obj $files

# Set 'combiner' fileset file properties for remote files
set file "$origin_dir/src/testbench/combiner_testbench.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets combiner] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj


# Set 'combiner' fileset file properties for local files
# None

# Set 'combiner' fileset properties
set obj [get_filesets combiner]
set_property -name "hbs.configure_design_for_hier_access" -value "1" -objects $obj
set_property -name "top" -value "combiner_testbench" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj
set_property -name "xsim.simulate.runtime" -value "INF" -objects $obj

# Create 'correlator_combiner' fileset (if not found)
if {[string equal [get_filesets -quiet correlator_combiner] ""]} {
  create_fileset -simset correlator_combiner
}

# Set 'correlator_combiner' fileset object
set obj [get_filesets correlator_combiner]
set files [list \
 [file normalize "${origin_dir}/src/testbench/correlator_combiner_testbench.vhd"] \
 [file normalize "${origin_dir}/src/testbench/correlator_combiner_testbench_behav.wcfg"] \
]
add_files -norecurse -fileset $obj $files

# Set 'correlator_combiner' fileset file properties for remote files
set file "$origin_dir/src/testbench/correlator_combiner_testbench.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets correlator_combiner] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj


# Set 'correlator_combiner' fileset file properties for local files
# None

# Set 'correlator_combiner' fileset properties
set obj [get_filesets correlator_combiner]
set_property -name "hbs.configure_design_for_hier_access" -value "1" -objects $obj
set_property -name "top" -value "correlator_combiner_testbench" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj
set_property -name "xsim.simulate.runtime" -value "INF" -objects $obj

# Create 'divided_correlator' fileset (if not found)
if {[string equal [get_filesets -quiet divided_correlator] ""]} {
  create_fileset -simset divided_correlator
}

# Set 'divided_correlator' fileset object
set obj [get_filesets divided_correlator]
set files [list \
 [file normalize "${origin_dir}/src/testbench/divided_correlator.vhd"] \
 [file normalize "${origin_dir}/src/testbench/divided_correlator_behav.wcfg"] \
]
add_files -norecurse -fileset $obj $files

# Set 'divided_correlator' fileset file properties for remote files
set file "$origin_dir/src/testbench/divided_correlator.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets divided_correlator] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj


# Set 'divided_correlator' fileset file properties for local files
# None

# Set 'divided_correlator' fileset properties
set obj [get_filesets divided_correlator]
set_property -name "hbs.configure_design_for_hier_access" -value "1" -objects $obj
set_property -name "top" -value "divided_correlator" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "xsim.simulate.runtime" -value "INF" -objects $obj

# Create 'multi_tau_correlator' fileset (if not found)
if {[string equal [get_filesets -quiet multi_tau_correlator] ""]} {
  create_fileset -simset multi_tau_correlator
}

# Set 'multi_tau_correlator' fileset object
set obj [get_filesets multi_tau_correlator]
set files [list \
 [file normalize "${origin_dir}/src/testbench/multi_tau_correlator_testbench.vhd"] \
 [file normalize "${origin_dir}/src/testbench/multi_tau_correlator_testbench_behav.wcfg"] \
]
add_files -norecurse -fileset $obj $files

# Set 'multi_tau_correlator' fileset file properties for remote files
set file "$origin_dir/src/testbench/multi_tau_correlator_testbench.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets multi_tau_correlator] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj


# Set 'multi_tau_correlator' fileset file properties for local files
# None

# Set 'multi_tau_correlator' fileset properties
set obj [get_filesets multi_tau_correlator]
set_property -name "hbs.configure_design_for_hier_access" -value "1" -objects $obj
set_property -name "nl.mode" -value "funcsim" -objects $obj
set_property -name "top" -value "multi_tau_correlator_testbench" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "xsim.simulate.runtime" -value "INF" -objects $obj

# Create 'uart' fileset (if not found)
if {[string equal [get_filesets -quiet uart] ""]} {
  create_fileset -simset uart
}

# Set 'uart' fileset object
set obj [get_filesets uart]
set files [list \
 [file normalize "${origin_dir}/src/testbench/uart_interface_testbench.vhd"] \
 [file normalize "${origin_dir}/src/testbench/uart_interface_testbench_behav.wcfg"] \
]
add_files -norecurse -fileset $obj $files

# Set 'uart' fileset file properties for remote files
set file "$origin_dir/src/testbench/uart_interface_testbench.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets uart] [list "*$file"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj


# Set 'uart' fileset file properties for local files
# None

# Set 'uart' fileset properties
set obj [get_filesets uart]
set_property -name "hbs.configure_design_for_hier_access" -value "1" -objects $obj
set_property -name "incremental" -value "0" -objects $obj
set_property -name "nl.mode" -value "funcsim" -objects $obj
set_property -name "top" -value "uart_interface_testbench" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj
set_property -name "xsim.simulate.runtime" -value "INF" -objects $obj

# Set 'utils_1' fileset object
set obj [get_filesets utils_1]
set files [list \
 [file normalize "${origin_dir}/utils/top_routed.dcp"] \
]
add_files -norecurse -fileset $obj $files

# Set 'utils_1' fileset file properties for remote files
set file "$origin_dir/utils/top_routed.dcp"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets utils_1] [list "*$file"]]
set_property -name "netlist_only" -value "0" -objects $file_obj


# Set 'utils_1' fileset file properties for local files
# None

# Set 'utils_1' fileset properties
set obj [get_filesets utils_1]

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part xc7a100tcsg324-1 -flow {Vivado Synthesis 2020} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2020" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'synth_1_synth_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0] "" ] } {
  create_report_config -report_name synth_1_synth_report_utilization_0 -report_type report_utilization:1.0 -steps synth_design -runs synth_1
}
set obj [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0]
if { $obj != "" } {

}
set obj [get_runs synth_1]
set_property -name "auto_incremental_checkpoint.directory" -value "C:/Users/Christopher/Desktop/DCS/fpga/vivado_project/vivado_project.srcs/utils_1/imports/synth_1" -objects $obj
set_property -name "strategy" -value "Vivado Synthesis Defaults" -objects $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part xc7a100tcsg324-1 -flow {Vivado Implementation 2020} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2020" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'impl_1_init_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_init_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_init_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps init_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_init_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_opt_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_drc_0] "" ] } {
  create_report_config -report_name impl_1_opt_report_drc_0 -report_type report_drc:1.0 -steps opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_drc_0]
if { $obj != "" } {

}
# Create 'impl_1_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps power_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_place_report_io_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_io_0] "" ] } {
  create_report_config -report_name impl_1_place_report_io_0 -report_type report_io:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_io_0]
if { $obj != "" } {

}
# Create 'impl_1_place_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_utilization_0] "" ] } {
  create_report_config -report_name impl_1_place_report_utilization_0 -report_type report_utilization:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_utilization_0]
if { $obj != "" } {

}
# Create 'impl_1_place_report_control_sets_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_control_sets_0] "" ] } {
  create_report_config -report_name impl_1_place_report_control_sets_0 -report_type report_control_sets:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_control_sets_0]
if { $obj != "" } {
set_property -name "options.verbose" -value "1" -objects $obj

}
# Create 'impl_1_place_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name impl_1_place_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj

}
# Create 'impl_1_place_report_incremental_reuse_1' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_1] "" ] } {
  create_report_config -report_name impl_1_place_report_incremental_reuse_1 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_1]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj

}
# Create 'impl_1_place_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_place_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_place_report_incremental_reuse_2' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_2] "" ] } {
  create_report_config -report_name impl_1_place_report_incremental_reuse_2 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_2]
if { $obj != "" } {
set_property -name "display_name" -value "Incremental Reuse 1 - Place Design" -objects $obj

}
# Create 'impl_1_post_place_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_post_place_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_post_place_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_place_power_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_post_place_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_route_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_drc_0] "" ] } {
  create_report_config -report_name impl_1_route_report_drc_0 -report_type report_drc:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_drc_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_methodology_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_methodology_0] "" ] } {
  create_report_config -report_name impl_1_route_report_methodology_0 -report_type report_methodology:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_methodology_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_power_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_power_0] "" ] } {
  create_report_config -report_name impl_1_route_report_power_0 -report_type report_power:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_power_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_route_status_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_route_status_0] "" ] } {
  create_report_config -report_name impl_1_route_report_route_status_0 -report_type report_route_status:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_route_status_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_route_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_route_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name impl_1_route_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_incremental_reuse_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_clock_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_clock_utilization_0] "" ] } {
  create_report_config -report_name impl_1_route_report_clock_utilization_0 -report_type report_clock_utilization:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_clock_utilization_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_bus_skew_0] "" ] } {
  create_report_config -report_name impl_1_route_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'impl_1_post_route_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_post_route_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_route_phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'impl_1_post_route_phys_opt_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_bus_skew_0] "" ] } {
  create_report_config -report_name impl_1_post_route_phys_opt_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps post_route_phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
set obj [get_runs impl_1]
set_property -name "incremental_checkpoint" -value "C:/Users/Christopher/Desktop/Research/fpga/utils/top_routed.dcp" -objects $obj
set_property -name "auto_incremental_checkpoint" -value "1" -objects $obj
set_property -name "auto_incremental_checkpoint.directory" -value "C:/Users/Christopher/Desktop/Research/fpga/utils" -objects $obj
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

# Change current directory to project folder
cd [file dirname [info script]]

puts "INFO: Project created:${_xil_proj_name_}"
# Create 'drc_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "drc_1" ] ] ""]} {
create_dashboard_gadget -name {drc_1} -type drc
}
set obj [get_dashboard_gadgets [ list "drc_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_drc_0" -objects $obj

# Create 'methodology_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "methodology_1" ] ] ""]} {
create_dashboard_gadget -name {methodology_1} -type methodology
}
set obj [get_dashboard_gadgets [ list "methodology_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_methodology_0" -objects $obj

# Create 'power_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "power_1" ] ] ""]} {
create_dashboard_gadget -name {power_1} -type power
}
set obj [get_dashboard_gadgets [ list "power_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_power_0" -objects $obj

# Create 'timing_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "timing_1" ] ] ""]} {
create_dashboard_gadget -name {timing_1} -type timing
}
set obj [get_dashboard_gadgets [ list "timing_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_timing_summary_0" -objects $obj

# Create 'utilization_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "utilization_1" ] ] ""]} {
create_dashboard_gadget -name {utilization_1} -type utilization
}
set obj [get_dashboard_gadgets [ list "utilization_1" ] ]
set_property -name "reports" -value "synth_1#synth_1_synth_report_utilization_0" -objects $obj
set_property -name "run.step" -value "synth_design" -objects $obj
set_property -name "run.type" -value "synthesis" -objects $obj

# Create 'utilization_2' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "utilization_2" ] ] ""]} {
create_dashboard_gadget -name {utilization_2} -type utilization
}
set obj [get_dashboard_gadgets [ list "utilization_2" ] ]
set_property -name "reports" -value "impl_1#impl_1_place_report_utilization_0" -objects $obj

move_dashboard_gadget -name {utilization_1} -row 0 -col 0
move_dashboard_gadget -name {power_1} -row 1 -col 0
move_dashboard_gadget -name {drc_1} -row 2 -col 0
move_dashboard_gadget -name {timing_1} -row 0 -col 1
move_dashboard_gadget -name {utilization_2} -row 1 -col 1
move_dashboard_gadget -name {methodology_1} -row 2 -col 1
