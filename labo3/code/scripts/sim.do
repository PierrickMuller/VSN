
# !/usr/bin/tclsh

# Main proc at the end #

#------------------------------------------------------------------------------
proc compile_duv { } {
  global Path_DUV
  puts "\nVHDL DUV compilation :"

  vlib morse
  vcom -2008 -work morse $Path_DUV/morse_pkg.vhd
  vcom -2008 -work morse $Path_DUV/morse_burst_emitter_pkg.vhd

  vlib work
#  vcom -2008 -work work $Path_DUV/morse_ctx.vhd
  vcom -2008 -work work $Path_DUV/fifo.vhd
  vcom -2008 -work work $Path_DUV/morse_char_emitter.vhd
  vcom -2008 -work work $Path_DUV/morse_burst_emitter.vhd
}

#------------------------------------------------------------------------------
proc compile_tb { } {
  global Path_TB
  global Path_DUV
  puts "\nVHDL TB compilation :"

  do compile_tlmvm.do

  vlib common_lib
  vcom -work common_lib  -2008 $Path_TB/common_lib/logger_pkg.vhd
  vcom -work common_lib  -2008 $Path_TB/common_lib/comparator_pkg.vhd
  vcom -work common_lib  -2008 $Path_TB/common_lib/complex_comparator_pkg.vhd
  vcom -work common_lib  -2008 $Path_TB/common_lib/common_ctx.vhd

  vcom -work project_lib -2008 $Path_TB/project_logger_pkg.vhd
  vcom -work project_lib -2008 $Path_TB/project_ctx.vhd

  vlib work

    vcom -2008 $Path_TB/transactions_pkg.vhd

  # Input Agent
  vcom -2008 $Path_TB/input_agent/input_agent_driver.vhd
  vcom -2008 $Path_TB/input_agent/input_agent_monitor.vhd
  vcom -2008 $Path_TB/input_agent/input_agent_sequencer.vhd
  vcom -2008 $Path_TB/input_agent/input_agent.vhd

  # Output Agent
  vcom -2008 $Path_TB/output_agent/output_agent_monitor.vhd
  vcom -2008 $Path_TB/output_agent/output_agent.vhd


#  vcom -2008 $Path_TB/min_max_top_tb.vhd

  # Scoreboard
  vcom -2008 $Path_TB/scoreboard.vhd

  # Test Bench
  vcom -2008 $Path_TB/morse_burst_emitter_tb.vhd
}

#------------------------------------------------------------------------------
proc sim_start {TESTCASE FIFOSIZE ERRNO} {

  global StdArithNoWarnings
  global NumericStdNoWarnings

#  vsim -t 1ns -GFIFOSIZE=$FIFOSIZE -GERRNO=$ERRNO -GTESTCASE=$TESTCASE work.morse_tb

  vsim -warning error -t 1ns -GFIFOSIZE=$FIFOSIZE -GERRNO=$ERRNO -GTESTCASE=$TESTCASE work.morse_burst_emitter_tb
#  do wave.do
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
proc do_all {TESTCASE FIFOSIZE ERRNO} {
  compile_duv
  compile_tb
  sim_start $TESTCASE $FIFOSIZE $ERRNO
}

## MAIN #######################################################################

# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  vlib work
}

puts -nonewline "  Path_VHDL => "
set Path_DUV     "../src"
set Path_TB       "../src_tb"

global Path_DUV
global Path_TB

# start of sequence -------------------------------------------------

if {$argc>0} {
  if {[string compare $1 "all"] == 0} {
    do_all $2 $3 $4
  } elseif {[string compare $1 "comp_duv"] == 0} {
    compile_duv
  } elseif {[string compare $1 "comp_tb"] == 0} {
    compile_tb
  } elseif {[string compare $1 "sim"] == 0} {
    sim_start $2 $3 $4
  }

} else {
  do_all 0 8 0
}
