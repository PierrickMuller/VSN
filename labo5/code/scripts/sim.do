#!/usr/bin/tclsh

# Main proc at the end #

#------------------------------------------------------------------------------
proc vhdl_compile { } {
  global Path_VHDL
  global Path_TB
  puts "\nVHDL compilation :"

  vlib morse
  vcom -mixedsvvh -2008 -work morse $Path_VHDL/morse_pkg.vhd

  vlib work
  vcom -mixedsvvh -2008 $Path_VHDL/morse_pkg.vhd
  vcom -mixedsvvh -2008 $Path_VHDL/morse_char_receiver.vhdp
  vlog -mixedsvvh -sv $Path_TB/morse_char_receiver_tb.sv
}

#------------------------------------------------------------------------------
proc sim_start { LOG_RELATIVE_MARGIN testcase errno} {

  vsim -t 1ns -GLOG_RELATIVE_MARGIN=$LOG_RELATIVE_MARGIN -GTESTCASE=$testcase -GERRNO=$errno work.morse_char_receiver_tb
  add wave -r *
  wave refresh
  set StdArithNoWarnings 1
  set NumericStdNoWarnings 1
  run 10ns
  set StdArithNoWarnings 0
  set NumericStdNoWarnings 0
  run -all
}

#------------------------------------------------------------------------------
proc do_all {LOG_RELATIVE_MARGIN testcase errno } {
  vhdl_compile
  sim_start $LOG_RELATIVE_MARGIN $testcase $errno
}

## MAIN #######################################################################

# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  vlib work
}

puts -nonewline "  Path_VHDL => "
set Path_VHDL     "../src"
set Path_TB       "../src_tb"

global Path_VHDL
global Path_TB

# start of sequence -------------------------------------------------

if {$argc>0} {
  if {[string compare $1 "all"] == 0} {
    do_all $2 $3 $4
  } elseif {[string compare $1 "comp_vhdl"] == 0} {
    vhdl_compile
  } elseif {[string compare $1 "sim"] == 0} {
    sim_start $2 $3 $4
  }

} else {
  do_all 0 0 0
}
