#!/bin/sh

{  dos2unix --version 1>/dev/null 2>/dev/null && echo "已经安装dos2unix"; } || {  sudo apt install -y dos2unix && echo "安装dos2unix成功" ; }

_pkgName="libx11-dev"; {  ldconfig  -p | grep libX11 1>/dev/null 2>/dev/null && echo "已经安装$_pkgName"; } || { sudo apt install  -y libx11-dev && echo "成功安装$_pkgName" ; }



#编译xv6 产生xv6.img、fs.img
cd /crk/bochs/xv6-x86/ && \
dos2unix sign.pl && \
make clean && \
make img && \
rm -frv *.img.lock

#编译bochs 产生可执行文件 /crk/bochs/bochs/bochs 
cd /crk/bochs/bochs/ && \
dos2unix .conf.linux  configure && \
sh .conf.linux && \
make all-clean && \
make && \
test "$RUN_BOCHS" != "false" && rm -fv bochsout.txt && /crk/bochs/bochs/bochs -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc 
