#file: envPrepare_compile_run-msys2.sh : msys2下环境准备_编译_运行

#0. 环境
# 宿主机: win10x64

#0.5. 安装所需工具
# 下载安装msys2
# https://www.msys2.org/
# wget https://github.com/msys2/msys2-installer/releases/download/2023-10-26/msys2-x86_64-20231026.exe
#  安装msys2-x86_64-20231026.exe 到 d:\msys64
#  shell终端路径: D:\msys64\msys2.exe

# 进入 msys2的shell终端 : 宿主机win10x64下运行 D:\msys64\msys2.exe
#  以下简称 "进入 msys2的shell终端"

# 进入 msys2的shell终端
pacman -S nasm
nasm --version
#NASM version 2.16.01 compiled on Dec 29 2022

#0.6. bochsdbg安装
#  在宿主机win10x64下安装bochs及bochsdbg, 操作 同 'envPrepare_compile_run.sh/0.6. bochsdbg安装/方案1'

#1. 编译(以c08为例)
#进入 msys2的shell终端
nasm c08_mbr.asm -o c08_mbr.bin -f bin -l c08_mbr.list.txt
nasm c08.asm -o c08.bin -f bin -l c08.list.txt




#2. 制作启动硬盘(以c08为例)
#  宿主机win10x64下操作 同 'envPrepare_compile_run.sh/2. 制作启动硬盘'
dd if=/dev/zero of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img bs=512 count=20160
dd if=./c08_mbr.bin of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img conv=notrunc seek=0
dd if=./c08.bin of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img  conv=notrunc  seek=100


#3. bochs启动该软盘(以c08为例)
#  宿主机win10x64下操作 同 'envPrepare_compile_run.sh/3. bochs启动该软盘'
bochs -f HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB__bochsrc.bxrc


#4. bochsdbg启动该软盘 (调试模式启动)(以c08为例)
#  宿主机win10x64下操作 同 'envPrepare_compile_run.sh/4. bochsdbg启动该软盘 (调试模式启动)'
bochsdbg -f HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB__bochsrc.bxrc