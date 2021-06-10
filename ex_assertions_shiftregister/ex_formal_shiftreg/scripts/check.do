proc check_sva { } {

  vlog -sv ../src_tb/shiftregister_assertions.sv ../src_tb/shiftregister_wrapper.sv
  vlog -sv ../src_sv/shiftregister.sv
  #vcom ../src_sv/shiftregister.vhd

  formal compile -d shiftregister_wrapper -G DATASIZE=2 -work work

  formal verify
}


check_sva
