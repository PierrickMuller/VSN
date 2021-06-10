file delete -force work
set Path_DUV "/home/reds/vsn21_student/labo5/code/src"
set Path_TB  "/home/reds/vsn21_student/labo5/code/src_tb"
global Path_DUV
global Path_TB
vlib morse
vcom -mixedsvvh -2008 -work morse $Path_DUV/morse_pkg.vhd
vlib work
vcom -mixedsvvh -2008 $Path_DUV/morse_pkg.vhd
vcom +cover -mixedsvvh -2008 $Path_DUV/morse_char_receiver.vhdp
vlog +cover -mixedsvvh -sv $Path_TB/morse_char_receiver_tb.sv
vsim -coverage -t 1ns -GLOG_RELATIVE_MARGIN=0 -GTESTCASE=0 -GERRNO=11 work.morse_char_receiver_tb
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run 2 ns
set StdArithNoWarnings 0
set NumericStdNoWarnings 0
run -all
coverage attribute -name TESTNAME -value testerrno11
coverage save ../testerrno11.ucdb
