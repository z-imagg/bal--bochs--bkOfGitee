#!/bin/sh

#编译xv6 产生xv6.img、fs.img
cd /crk/bochs/xv6-x86/ && \
dos2unix sign.pl && \
make clean && \
make img && \
rm -frv *.img.lock

#编译bochs 产生可执行文件 /crk/bochs/bochs/bochs 
cd /crk/bochs/bochs/ && \
make all-clean && \
sh .conf.linux && \
make && \
test "$RUN_BOCHS" != "false" && /crk/bochs/bochs/bochs -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc 
