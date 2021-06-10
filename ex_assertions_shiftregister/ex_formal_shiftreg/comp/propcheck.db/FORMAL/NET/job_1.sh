#! /bin/bash 
ZI_PLATFORM="" 

if [[ `uname` -eq "Linux" ]] ; then 
  case `uname -m` in 
    x86_64) 
      ZI_PLATFORM="linux_x86_64" 
    ;; 
    aarch64) 
      ZI_PLATFORM="linux_aarch64" 
    ;; 
  esac 
fi 


export QHOME="/opt/mentor/questaformal/${ZI_PLATFORM}"
export HOME_0IN="/opt/mentor/questaformal/${ZI_PLATFORM}"

/opt/mentor/questaformal/${ZI_PLATFORM}/bin/qverifypm --monitor --host reds2021 --port 46345 --wd /home/reds/vsn21_student/ex_assertions_shiftregister/ex_formal_shiftreg/comp --type slave --binary /opt/mentor/questaformal/${ZI_PLATFORM}/bin/qverifyfk --id 1 -netcache /home/reds/vsn21_student/ex_assertions_shiftregister/ex_formal_shiftreg/comp/propcheck.db/FORMAL/NET -tool prove -hd .qverify -import_db ./propcheck.db/formal_compile.db -slave_mode -mpiport reds2021:40191 -slave_id 1 
