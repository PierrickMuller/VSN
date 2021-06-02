# !/usr/bin/tclsh

# Main proc at the end #


#------------------------------------------------------------------------------
proc compile_duv { } {
  global Path_DUV
  puts "\nVHDL DUV compilation :"

  vlog $Path_DUV/avalon_generator.sv
}


#------------------------------------------------------------------------------
proc compile_tb { } {
  global Path_TB
  global Path_DUV
  puts "\nVHDL TB compilation :"

  vlog $Path_TB/avalon_assertions.sv
  vlog $Path_TB/avalon_assertions_wrapper.sv
}


#------------------------------------------------------------------------------
proc sim_start {AVALONMODE TESTCASE} {
  # Do not forget the '-voptargs=+acc=a', which enables assertion visibility
  # (otherwise '-assertdebug' will be ignored, and the whole simulation will hang)
  vsim -voptargs=+acc=a -assertdebug -GAVALONMODE=$AVALONMODE -GTESTCASE=$TESTCASE work.avalon_assertions_wrapper
  view assertions
  # atv = Assertion Thead Viewer: graphically shows activation of an assertion
  atv log -enable /avalon_assertions_wrapper/duv/binded
  add wave -r *

  switch $AVALONMODE {
    0 {
        # Add corresponding assertions
        add wave /avalon_assertions_wrapper/duv/binded/assert_waitrequest/assert_waitreq1
    }
    1 {
        # Add corresponding assertions
        add wave /avalon_assertions_wrapper/duv/binded/assert_fixed/assert_fix1
        add wave /avalon_assertions_wrapper/duv/binded/assert_fixed/assert_fix2
    }
    2 {
        # Add corresponding assertions
        add wave /avalon_assertions_wrapper/duv/binded/assert_pipeline_variable/assert_adress_stable
        add wave /avalon_assertions_wrapper/duv/binded/assert_pipeline_variable/assert_rdatavalid_after_waitrequest
        add wave /avalon_assertions_wrapper/duv/binded/assert_pipeline_variable/assert_nb_rdatavalid
    }
    3 {
        # Add corresponding assertions
        add wave /avalon_assertions_wrapper/duv/binded/assert_pipeline_fixed/assert_fixed_delay
        add wave /avalon_assertions_wrapper/duv/binded/assert_pipeline_fixed/assert_adress_stable
        add wave /avalon_assertions_wrapper/duv/binded/assert_pipeline_fixed/assert_rdatavalid_after_waitrequest
        add wave /avalon_assertions_wrapper/duv/binded/assert_pipeline_fixed/assert_nb_rdatavalid
    }
    4 {
        # Add corresponding assertions
        add wave /avalon_assertions_wrapper/duv/binded/assert_burst/assert_rd_waitr_stable
        add wave /avalon_assertions_wrapper/duv/binded/assert_burst/assert_nb_rdatavalid
        add wave /avalon_assertions_wrapper/duv/binded/assert_burst/assert_nb_burst_when_adress_change_during_read
    }
  }
  run -all
}


#------------------------------------------------------------------------------
proc do_all {AVALONMODE TESTCASE} {
  compile_duv
  compile_tb
  sim_start $AVALONMODE $TESTCASE
}


## MAIN #######################################################################
# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  vlib work
}

puts -nonewline "  Path_VHDL => "
set Path_DUV    "../src"
set Path_TB     "../src_tb"

global Path_DUV
global Path_TB

# start of sequence -------------------------------------------------
if {$argc>0} {
  if {$argc>1} {
    do_all $1 $2
  } else {
    do_all $1 0
  }
} else {
  do_all 0 0
}
