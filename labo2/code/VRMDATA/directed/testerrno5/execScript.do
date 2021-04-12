file delete -force work
set Path_DUV "/home/reds/vsn21_student/labo2/code/src"
set Path_TB  "/home/reds/vsn21_student/labo2/code/code3/src_tb"
global Path_DUV
global Path_TB
vlib work
vcom +cover -work project_lib -2008 $Path_DUV/com_store_velux.vhdp
vcom +cover -work common_lib  -2008 $Path_TB/common_lib/logger_pkg.vhd
vcom +cover -work common_lib  -2008 $Path_TB/common_lib/comparator_pkg.vhd
vcom +cover -work common_lib  -2008 $Path_TB/common_lib/complex_comparator_pkg.vhd
vcom +cover -work common_lib  -2008 $Path_TB/common_lib/common_ctx.vhd
vcom +cover -work project_lib -2008 $Path_TB/project_logger_pkg.vhd
vcom +cover -work project_lib -2008 $Path_TB/projet_ctx.vhd
vcom +cover -work project_lib -2008 $Path_TB/com_store_velux_tb.vhd
vsim -coverage -t 10ps -GN=3 -GTESTCASE=0 -GERRNO=5 project_lib.com_store_velux_tb
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run 2 ns
set StdArithNoWarnings 0
set NumericStdNoWarnings 0
run -all
coverage attribute -name TESTNAME -value testerrno5
coverage save ../testerrno5.ucdb
