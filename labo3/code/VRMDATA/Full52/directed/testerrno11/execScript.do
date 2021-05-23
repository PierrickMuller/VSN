file delete -force work
set Path_DUV "/home/reds/vsn21_student/labo3/code/src"
set Path_TB  "/home/reds/vsn21_student/labo3/code/src_tb"
global Path_DUV
global Path_TB
vlib common_lib
vcom +cover -work common_lib  -2008 $Path_TB/common_lib/logger_pkg.vhd
vcom +cover -work common_lib  -2008 $Path_TB/common_lib/comparator_pkg.vhd
vcom +cover -work common_lib  -2008 $Path_TB/common_lib/complex_comparator_pkg.vhd
vcom +cover -work common_lib  -2008 $Path_TB/common_lib/common_ctx.vhd
vcom +cover -work project_lib -2008 $Path_TB/project_logger_pkg.vhd
vcom +cover -work project_lib -2008 $Path_TB/project_ctx.vhd
vlib morse
vcom +cover -2008 -work morse $Path_DUV/morse_pkg.vhd
vcom +cover -2008 -work morse $Path_DUV/morse_burst_emitter_pkg.vhd
vlib work
vcom +cover -2008 -work work $Path_DUV/fifo.vhd
vcom +cover -2008 -work work $Path_DUV/morse_char_emitter.vhd
vcom +cover -2008 -work work $Path_DUV/morse_burst_emitter.vhd
vcom +cover -2008 $Path_TB/transactions_pkg.vhd
vcom +cover -2008 $Path_TB/input_agent/input_agent_driver.vhd
vcom +cover -2008 $Path_TB/input_agent/input_agent_monitor.vhd
vcom +cover -2008 $Path_TB/input_agent/input_agent_sequencer.vhd
vcom +cover -2008 $Path_TB/input_agent/input_agent.vhd
vcom +cover -2008 $Path_TB/output_agent/output_agent_monitor.vhd
vcom +cover -2008 $Path_TB/output_agent/output_agent.vhd
vcom +cover -2008 $Path_TB/scoreboard.vhd
vcom +cover -2008 $Path_TB/morse_burst_emitter_tb.vhd
vsim -coverage -t 10ps -GFIFOSIZE=52 -GTESTCASE=0 -GERRNO=11 work.morse_burst_emitter_tb
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run 2 ns
set StdArithNoWarnings 0
set NumericStdNoWarnings 0
run -all
coverage attribute -name TESTNAME -value testerrno11
coverage save ../testerrno11.ucdb
