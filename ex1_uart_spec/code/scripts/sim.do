#!/usr/bin/tclsh

# Main proc at the end #

#------------------------------------------------------------------------------
proc vhdl_compil { } {
  global Path_VHDL
  global Path_TB

  puts "\nVHDL compilation :"

  vlib work

  vcom -2008 $Path_VHDL/uart.vhd

  vcom -2008 $Path_TB/uart_tb.vhd
}

#------------------------------------------------------------------------------
proc sim_start {error filename } {

  vsim -t 1ns -GERRNO=$error -GLOGFILENAME=$filename work.uart_tb

  add wave -r *
  wave refresh
  run -all
}
#------------------------------------------------------------------------------
proc sim_start_quiet {error filename } {

  vsim -t 1ns -GERRNO=$error -GLOGFILENAME=$filename work.uart_sender_tb
  run -all
}

#------------------------------------------------------------------------------
proc do_validate_all { } {
  vhdl_compil
  file mkdir report
  sim_start_quiet 0 "report/errno0.txt"
  sim_start_quiet 1 "report/errno1.txt"
  sim_start_quiet 2 "report/errno2.txt"
  sim_start_quiet 3 "report/errno3.txt"
  sim_start_quiet 4 "report/errno4.txt"
  sim_start_quiet 5 "report/errno5.txt"
  sim_start_quiet 6 "report/errno6.txt"
  sim_start_quiet 7 "report/errno7.txt"
  sim_start_quiet 8 "report/errno8.txt"
  sim_start_quiet 9 "report/errno9.txt"
  sim_start_quiet 10 "report/errno10.txt"
  sim_start_quiet 11 "report/errno11.txt"
  sim_start_quiet 12 "report/errno12.txt"
  sim_start_quiet 13 "report/errno13.txt"
  sim_start_quiet 14 "report/errno14.txt"
  sim_start_quiet 15 "report/errno15.txt"
  sim_start_quiet 16 "report/errno16.txt"
  sim_start_quiet 17 "report/errno17.txt"
  sim_start_quiet 18 "report/errno18.txt"
  sim_start_quiet 19 "report/errno19.txt"
}

#------------------------------------------------------------------------------
proc do_all { } {
  vhdl_compil
  file mkdir report
  sim_start 0 "report/errno0.txt"
}

#------------------------------------------------------------------------------
proc set_arg { } {
  global cmd
  global cmd_quit cmd_vhdl cmd_sv cmd_sim cmd_all

  set cmd_quit 0
  set cmd_all  1
  set cmd_vhdl 2
  set cmd_sv   3
  set cmd_sim  4
  set cmd_validate 5

  while { 1 } {
    puts "\nList of operations :\n"
    puts "  $cmd_all  : do all"
    puts "  $cmd_vhdl  : vhdl compilation"
    puts "  $cmd_sim  : simulation"
    puts "  $cmd_validate  : validate all"
    puts ""
    puts "  $cmd_quit  : exit\n"
    puts -nonewline " enter your choice number => "

    set cmd [gets stdin]
  #  if {$cmd == 10} {
  #    break
  #  } else
    if { $cmd <0 || $cmd > 3 } {
      puts "\n Incorrect Value \n"
      set cmd -1
    } else {
      break
    }
  }

}

## MAIN #######################################################################

# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  vlib work
}

puts -nonewline "  Path_VHDL => "
set Path_VHDL     "../src_vhdl"
set Path_TB     "../src_tb"

global Path_VHDL
global Path_TB

# start of sequence -------------------------------------------------

if {$argc==1} {
  if {[string compare $1 "all"] == 0} {
    do_all
  } elseif {[string compare $1 "validate"] == 0} {
    do_validate_all
  } elseif {[string compare $1 "comp_vhdl"] == 0} {
    vhdl_compil
  } elseif {[string compare $1 "sim"] == 0} {
    sim_start
  }

} else {
  set_arg

  if {$cmd == $cmd_all} {
    do_all
  } elseif {$cmd == $cmd_validate} {
    do_validate_all
  } elseif {$cmd == $cmd_vhdl} {
    vhdl_compil
  } elseif {$cmd == $cmd_sim} {
    sim_start
  }
}
