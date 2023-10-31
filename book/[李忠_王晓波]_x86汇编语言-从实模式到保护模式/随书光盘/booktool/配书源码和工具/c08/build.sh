#0. 环境
#操作系统
cat /etc/issue
#Linux Mint 21.1 Vera
#主机
uname -a
# Linux xx 5.15.0-56-generic #62-Ubuntu SMP Tue Nov 22 19:54:14 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux

#0.5. 安装所需工具
apt install nasm bochs -y
#注意: apt安装是没有bochsdbg的
nasm --version
#NASM version 2.15.05

#bochsdbg安装
# 方案1.在win10下安装Bochs-win64-2.7.exe， 其中含有bochsdbg.exe
#       https://sourceforge.net/projects/bochs/files/bochs/2.7/Bochs-win64-2.7.exe/download
# 方案2.自己编译bochs源码

bochs --help
#Bochs x86 Emulator 2.7

#1. 编译
nasm c08_mbr.asm -o c08_mbr.bin -f bin -l c08_mbr.list.txt
nasm c08.asm -o c08.bin -f bin -l c08.list.txt
# c08_mbr.list.txt 可找到phy_base值为 0x000000C7 ，如下: 
#  151 000000C7 00000100                         phy_base dd 0x10000             ;用户程序被加载的20位物理起始地址



#2. 制作启动软盘
#生成1.44MB软盘镜像
dd if=/dev/zero of=./1440KB_floppy.img bs=512 count=2880

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

#4. bochsdbg启动该软盘 (调试模式启动)
bochsdbg -f .\bochsrc00.bxrc
#以下是bochsdbg命令提示符下的脚本
break 0x7c00
continue
u /5 #查看从当前指令开始的5条指令
step #单步指令,进入call
next #单步执行,不进入call
reg #查看寄存器ax,bx,cx,dx,sp,bp,si,di,ip
sreg #查看段寄存器es,cs,ss,ds,fs,gs,以及 ldtr,gdtr,idtr
creg #查看寄存器CR0,CR2,CR3,CR4,CR8

x /x ds*16


#以下是bochsdbg命令用法
help  #查看bochsdbg命令用法 如下
"""
h|help - show list of debugger commands
h|help command - show short command description
-*- Debugger control -*-
    help, q|quit|exit, set, instrument, show, trace, trace-reg,
    trace-mem, u|disasm, ldsym, slist
-*- Execution control -*-
    c|cont|continue, s|step, p|n|next, modebp, vmexitbp
-*- Breakpoint management -*-
    vb|vbreak, lb|lbreak, pb|pbreak|b|break, sb, sba, blist,
    bpe, bpd, d|del|delete, watch, unwatch
-*- CPU and memory contents -*-
    x, xp, setpmem, writemem, crc, info,
    r|reg|regs|registers, fp|fpu, mmx, sse, sreg, dreg, creg,
    page, set, ptime, print-stack, ?|calc
-*- Working with bochs param tree -*-
    show "param", restore
"""
help u
"""
u|disasm [/count] <start> <end> - disassemble instructions for given linear address
    Optional 'count' is the number of disassembled instructions
"""
help reg
help sreg
help creg
help step
"""
s|step [count] - execute #count instructions on current processor (default is one instruction)
s|step [cpu] <count> - execute #count instructions on processor #cpu
s|step all <count> - execute #count instructions on all the processors
"""
help next
"""
help next
n|next|p - execute instruction stepping over subroutines
"""
help print-stack
"""print-stack [num_words] - print the num_words top 16 bit words on the stack
"""
