#!/bin/sh

#Verbose=ture me.sh :输出make完整日志
#RUN_BOCHS=true me.sh : 运行Bochs
#me.sh :只输出make出错日志

DvNl=/dev/null

#意欲以shell实现如下如果、否则如果 判断逻辑:
# if 命令1 返回码为正常 then 动作1 ;
# elseif 命令2 返回码为正常 then 动作2 ;
#且不要if, 则形如以下:
# { 命令1 && 动作1 ;} || { 命令2 && 动作2; }
#或者自含语义表达如下:
# { 返回码条件1 && 动作1 ;} || { 返回码条件2 && 动作2; }

{  dos2unix --version 1>$DvNl 2>$DvNl && echo "已经安装dos2unix"; } || {  sudo apt install -y dos2unix && echo "安装dos2unix成功" ; }

_pkgName="libx11-dev"; {  ldconfig  -p | grep libX11 1>$DvNl 2>$DvNl && echo "已经安装$_pkgName"; } || { sudo apt install  -y libx11-dev && echo "成功安装$_pkgName" ; }


BigInfo="显示 configure|make 的 正常输出(输出量大会刷屏)"
SmallInfo="显示 configure|make 的 错误输出(输出少)"

#编译xv6 产生xv6.img、fs.img
cd /crk/bochs/xv6-x86/ && \
dos2unix sign.pl && \
make clean && \
{ { [ $Verbose ]  && echo $BigInfo && make img ; } || {  echo $SmallInfo &&  make img 1>$DvNl ; } ; } && \
rm -frv *.img.lock

#编译bochs 产生可执行文件 /crk/bochs/bochs/bochs 
cd /crk/bochs/bochs/ && \
dos2unix .conf.linux  configure && \
{ {  [ $Verbose ]  && echo $BigInfo && sh .conf.linux ; } || {  echo $SmallInfo &&  sh .conf.linux 1>$DvNl ; } ; } && \
make all-clean && \
{ {  [ $Verbose ]  && echo $BigInfo && make ; } || {  echo $SmallInfo &&  make 1>$DvNl ; }  ; } && \
[ $RUN_BOCHS ]  && rm -fv bochsout.txt && /crk/bochs/bochs/bochs -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc 
