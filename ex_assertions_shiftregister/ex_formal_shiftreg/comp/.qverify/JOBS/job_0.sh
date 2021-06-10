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

/opt/mentor/questaformal/${ZI_PLATFORM}/bin/qverifypm --monitor --host reds2021 --port 44309 --wd /home/reds/vsn21_student/ex_assertions_shiftregister/ex_formal_shiftreg/comp --type master --binary /opt/mentor/questaformal/${ZI_PLATFORM}/bin/qverifyfk --id 0 -tool prove -import_db propcheck.db/formal_verify.db -od . -hidden_dir ./.qverify -netcache /tmp/propcheck.6208_90 -gui -pm_host reds2021 -pm_port 44309   
