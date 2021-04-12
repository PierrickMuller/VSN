
# !/usr/bin/tclsh

# Main proc at the end #

#------------------------------------------------------------------------------
proc compile_duv { } {
  global Path_DUV
  puts "\nVHDL DUV compilation :"

  #vcom -2008 $Path_DUV/com_store_velux.vhdp
  vcom -work project_lib -2008 $Path_DUV/com_store_velux.vhdp

}

#------------------------------------------------------------------------------
proc compile_tb { } {
  global Path_TB
  global Path_DUV
  puts "\nVHDL TB compilation :"

  vcom -work common_lib  -2008 $Path_TB/common_lib/logger_pkg.vhd
  vcom -work common_lib  -2008 $Path_TB/common_lib/comparator_pkg.vhd
  vcom -work common_lib  -2008 $Path_TB/common_lib/complex_comparator_pkg.vhd
  vcom -work common_lib  -2008 $Path_TB/common_lib/common_ctx.vhd

  vcom -work project_lib -2008 $Path_TB/project_logger_pkg.vhd
  vcom -work project_lib -2008 $Path_TB/projet_ctx.vhd
  vcom -work project_lib -2008 $Path_TB/com_store_velux_tb.vhd
}

#------------------------------------------------------------------------------
proc sim_start {TESTCASE N ERRNO} {

  #vsim -t 1ns -GN=$N -GERRNO=$ERRNO -GTESTCASE=$TESTCASE work.com_store_velux_tb
  vsim -t 1ns -GN=$N -GERRNO=$ERRNO -GTESTCASE=$TESTCASE project_lib.com_store_velux_tb
#  do wave.do
  add wave -r *
  wave refresh
  set StdArithNoWarnings 1
  set NumericStdNoWarnings 1
  run 1ns
  set StdArithNoWarnings 0
  set NumericStdNoWarnings 0
  run -all
}

#------------------------------------------------------------------------------
proc do_all {TESTCASE N ERRNO} {
  compile_duv
  compile_tb
  sim_start $TESTCASE $N $ERRNO
}

## MAIN #######################################################################

# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  vlib work
}

puts -nonewline "  Path_VHDL => "
set Path_DUV     "../../src"
set Path_TB       "../src_tb"

global Path_DUV
global Path_TB

# start of sequence -------------------------------------------------

if {$argc>0} {
  if {[string compare $1 "all"] == 0} {
    do_all $2 $3 $4 
    #do_all 0 $2 $3 $4 
  } elseif {[string compare $1 "comp_duv"] == 0} {
    compile_duv
  } elseif {[string compare $1 "comp_tb"] == 0} {
    compile_tb
  } elseif {[string compare $1 "sim"] == 0} {
    sim_start 0 $2
  }

} else {
  do_all 0 3 0
}
