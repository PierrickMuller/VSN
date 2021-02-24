vlib work

vcom html_report_pkg.vhd
vcom html_report_tb.vhd

vsim work.html_report_tb
force date_time_str [clock format [clock second]]
run -all

