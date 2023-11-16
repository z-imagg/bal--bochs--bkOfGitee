#!/bin/sh

#dos2unix /crk/bochs/xv6-x86-run_at_bochs/run.sh
# /crk/bochs/xv6-x86-run_at_bochs/run.sh

rm -fv /crk/bochs/xv6-x86/*.img.lock
gdb -x /crk/bochs/xv6-x86-run_at_bochs/find-jmp/gdb-script.gs --args /crk/bochs/bochs/bochs  -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc

#以上gdb脚本运行完耗时很长,运行一段时间后 强制结束gdb,获得日志文件find-jmp-gdb.log

#人工删掉日志文件find-jmp-gdb.log开头的一些不规则行,

#用以下py脚本,按行分组统计,

# python -c """
# f=open('find-jmp-gdb.log');  
# s=f.readlines(); 
# print(len(s));
# d={}; 
# [d.__setitem__(k, 0 if not d.__contains__(k) else d[k]+1) for k in s]; print(d)
# """

#统计结果如下:
# {'ctrl_xfer32.cc:BX_CPU_C::JMP_Jd, jmp_distance:8 \n': 65, 
# 'ctrl_xfer32.cc:BX_CPU_C::JMP_Jd, jmp_distance:4 \n': 32, 
# 'ctrl_xfer16.cc:BX_CPU_C::JMP_Jw, jmp_distance:2 \n': 76, 
# 'ctrl_xfer16.cc:BX_CPU_C::JMP_Jw, jmp_distance:3 \n': 3, 
# 'ctrl_xfer16.cc:BX_CPU_C::JMP_Jw, jmp_distance:8 \n': 0, 
# 'ctrl_xfer32.cc:BX_CPU_C::JMP_Jd, jmp_distance:9 \n': 159557, 
# 'ctrl_xfer32.cc:BX_CPU_C::JMP_Jd, jmp_distance:6 \n': 0
# }

#由于 xv6-x86代码 中每个 函数  入口 都被插入 函数id汇编
# 函数id汇编 共 三条指令: 
#   jmp指令,  一条操作数固定的or指令作为记号, 一条操作数为函数id的or指令
#因此 函数id汇编中的jmp指令执行次数一定非常巨大

# 而 xv6-x86  在 bochs上模拟运行  


#则 该 函数id汇编中的jmp指令 一定会引发bochs的某个jmp模拟函数 被大量调用

# 而 上面的分组结果 中, bochs中 jmp模拟函数 被调用次数最多的是函数 ctrl_xfer32.cc:BX_CPU_C::JMP_Jd, 且 跳转距离为9个字节.

#结论: xv6-x86 中插入的  函数id汇编 中的 jmp指令   被   bochs的 函数 ctrl_xfer32.cc:BX_CPU_C::JMP_Jd 模拟 ,且跳转距离为9个字节. 
