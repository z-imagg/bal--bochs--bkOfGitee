#0. 环境
#操作系统
cat /etc/issue
#Linux Mint 21.1 Vera
#主机
uname -a
# Linux xx 5.15.0-56-generic #62-Ubuntu SMP Tue Nov 22 19:54:14 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux

#0.5. 安装所需工具
apt install nasm bochs -y
#注意: apt安装是没有bochsdbg的， 需要bochsdbg估计只能自己编译bochs源码
nasm --version
#NASM version 2.15.05

bochs --help
#Bochs x86 Emulator 2.7

#1. 编译
nasm c08_mbr.asm -o c08_mbr.bin -f bin
nasm c08.asm -o c08.bin -f bin


#2. 制作启动软盘
#生成1.44MB软盘镜像
dd if=/dev/zero of=/crk/1440KB_floppy.img bs=512 count=2880

dd if=./c08_mbr.bin of=./1440KB_floppy.img seek=0
#引导扇区写入软盘的第 0+1 个扇区
#可省略"seek=0"


dd if=./c08.bin of=./1440KB_floppy.img seek=99
#用户程序写到软盘的第 99+1 个扇区 ，
#因c08_mbr.asm第6行 指出了 用户程序在软盘的第100个扇区 :" app_lba_start equ 100           ;声明常数（用户程序起始逻辑扇区号）"

#dd命令部分选项解释:
#bs: block size 块尺寸(块字节数),  count: block count 块数
# 写起点为 输出设备(软盘)的第 N+1 个块(扇区):  seek=N          skip N obs-sized blocks at start of output
# 读起点为 输入设备(文件)的第 N+1 个块:  skip=N          skip N ibs-sized blocks at start of input


#3. bochs启动该软盘

