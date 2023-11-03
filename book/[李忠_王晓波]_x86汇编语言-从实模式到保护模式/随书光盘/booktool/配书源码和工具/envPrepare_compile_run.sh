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

#0.6. bochsdbg安装
# 方案1.在win10下安装Bochs-win64-2.7.exe， 其中含有bochsdbg.exe
#       https://sourceforge.net/projects/bochs/files/bochs/2.7/Bochs-win64-2.7.exe/download
# 方案2.自己编译bochs源码

#这里选用 "方案1.在win10下安装Bochs-win64-2.7.exe"
where bochs
# D:\Bochs-2.6.11\bochs.exe
where bochsdbg
# D:\Bochs-2.6.11\bochsdbg.exe


bochs --help
#Bochs x86 Emulator 2.7

#1. 编译(以c08为例)
nasm c08_mbr.asm -o c08_mbr.bin -f bin -l c08_mbr.list.txt
nasm c08.asm -o c08.bin -f bin -l c08.list.txt
# c08_mbr.list.txt 可找到phy_base值为 0x000000C7 ，如下: 
#  151 000000C7 00000100                         phy_base dd 0x10000             ;用户程序被加载的20位物理起始地址



#2. 制作启动硬盘(以c08为例)
#生成9.84MB硬盘(20Cylinder柱面 16Header磁头 63SectorsPerTrack扇区每磁道)镜像
#20*16*63*512 Byte==10321920 Byte=9.84375 MByte
#10321920 Byte == 20160 * 512 Byte, 因此以下dd命令中的 count=20160
dd if=/dev/zero of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img bs=512 count=20160
dd if=./c08_mbr.bin of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img conv=notrunc seek=0
dd if=./c08.bin of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img  conv=notrunc  seek=100
#c08_mbr.asm第6行"app_lba_start equ 100" 读取第app_lba_start+1个(即第101个)扇区 因此跳过前100个扇区(即seek=100)
#dd选项 conv=notrunc 可替换目标设备中的一部分 

#3B.  链接bxrc中文目录为英文目录

#windows下:
mklink /D F:\crk\bxrc-book-x86FromRealToProtectMode__cdrom__booktool__srcAndTool F:\crk\bochs\book\[李忠_王晓波]_x86汇编语言-从实模式到保护模式\随书光盘\booktool\配书源码和工具

#linux下:
ln -s "/crk/bochs/book/[李忠_王晓波]_x86汇编语言-从实模式到保护模式/随书光盘/booktool/配书源码和工具/" /crk/bxrc-book-x86FromRealToProtectMode__cdrom__booktool__srcAndTool

#3. bochs启动该软盘(以c08为例)
bochs -f HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB__bochsrc.bxrc
#.bxrc文件中 的硬盘镜像路径 是windows下的路径:  "F:\crk\bochs\book\[李忠_王晓波]_x86汇编语言-从实模式到保护模式\随书光盘\booktool\配书源码和工具\c08\HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img",

#4. bochsdbg启动该软盘 (调试模式启动)(以c08为例)
bochsdbg -f HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB__bochsrc.bxrc
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

#若异常退出bochs, 需要删除 *.img.lock文件， 否则下次启动bochs会失败.
del HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img.lock