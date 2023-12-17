#!/usr/bin/env bash

source /crk/bochs/bash-simplify/dir_util.sh
getCurScriptDirName $0
#当前脚本文件 绝对路径 CurScriptF, 当前脚本文件 名 CurScriptNm, 当前脚本文件 所在目录 绝对路径 CurScriptNm
#CurScriptDir == /crk/bochs/clang-add-funcIdAsm/
cd $CurScriptDir && \

#获取调用者 是否开启了 bash -x  即 是否开启 bash 调试
#返回变量 _out_en_dbg, _out_dbg
get_out_en_dbg && \
echo "$_out_en_dbg,【$_out_dbg】" && \


bash $_out_dbg /crk/bochs/clang-add-funcIdAsm/build-libfmt.sh
#兼容bochs所用的fmt目录 /pubx/fmt/
FMT_REPO_HOME=/crk/bochs/clang-add-funcIdAsm/fmtlib-fmt && \
FMT4BOCHS_PRT="/pubx" && \
#FMT4BOCHS_PRT == /crk/pubx
FMT4BOCHS="$FMT4BOCHS_PRT/fmt" && \
{ [ -e $FMT4BOCHS_PRT ] ||  mkdir $FMT4BOCHS_PRT ;} && \
{ [ -e $FMT4BOCHS ] || \
ln -s $FMT_REPO_HOME $FMT4BOCHS ;} && \

BOCHS_SRC="/crk/bochs/bochs/" && \
cd $BOCHS_SRC && \
sudo apt install libx11-dev -y && \
sudo apt install gcc-multilib -y && \
sudo apt-get install g++ -y && \
sudo apt-get install build-essential && \
sh .conf.linux && \
make && \
file $BOCHS_SRC/bochs && \

_end=true