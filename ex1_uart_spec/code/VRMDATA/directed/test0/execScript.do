file delete -force work
set Path_DUV "/home/reds/vsn21_student/ex1_uart_spec/code/src_vhdl"
set Path_TB  "/home/reds/vsn21_student/ex1_uart_spec/code/src_tb"
global Path_DUV
global Path_TB
vlib work
vcom +cover -2008 $Path_DUV/uart.vhd
vcom +cover -2008 $Path_TB/uart_tb.vhd
vsim -coverage -t 10ps -GFIFOSIZE=8 -GTESTCASE=0 -GLOGFILENAME="log.txt" work.uart_tb
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run 2 ns
set StdArithNoWarnings 0
set NumericStdNoWarnings 0
run -all
coverage attribute -name TESTNAME -value test0
coverage save ../test0.ucdb
