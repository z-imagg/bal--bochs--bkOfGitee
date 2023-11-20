#!/bin/sh

#编译xv6 产生xv6.img、fs.img
cd /crk/bochs/xv6-x86/ && \
dos2unix sign.pl && \
make clean  > /dev/null  && \
make img  > /dev/null  && \
rm -frv *.img.lock && \
#编译bochs 产生可执行文件 /crk/bochs/bochs/bochs 
cd /crk/bochs/bochs/ && \
dos2unix .conf.linux  configure && \
make all-clean  > /dev/null  && \
sh .conf.linux > /dev/null && \
make all-clean  > /dev/null  && \
make  > /dev/null && \
test "$RUN_BOCHS" != "false" && rm -fv /crk/bochs/xv6-x86/*.img.lock bochsout.txt && /crk/bochs/bochs/bochs -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc 
