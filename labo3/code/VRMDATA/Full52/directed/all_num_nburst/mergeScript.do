set mergefile /home/reds/vsn21_student/labo3/code/VRMDATA/merge.ucdb
set cmd [list vcover merge  -out $mergefile]
if {[file readable $mergefile]} {lappend cmd $mergefile}
eval $cmd -inputs /home/reds/vsn21_student/labo3/code/VRMDATA/Full52/directed/all_num_nburst/mergeScript.files
