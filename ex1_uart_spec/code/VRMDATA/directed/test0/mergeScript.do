set mergefile /home/reds/vsn21_student/ex1_uart_spec/code/VRMDATA/merge.ucdb
set cmd [list vcover merge  -out $mergefile]
if {[file readable $mergefile]} {lappend cmd $mergefile}
eval $cmd -inputs /home/reds/vsn21_student/ex1_uart_spec/code/VRMDATA/directed/test0/mergeScript.files
