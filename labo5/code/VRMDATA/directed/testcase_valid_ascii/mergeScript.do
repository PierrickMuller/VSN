set mergefile /home/reds/vsn21_student/labo5/code/VRMDATA/merge.ucdb
set cmd [list vcover merge  -out $mergefile]
if {[file readable $mergefile]} {lappend cmd $mergefile}
eval $cmd -inputs /home/reds/vsn21_student/labo5/code/VRMDATA/directed/testcase_valid_ascii/mergeScript.files
