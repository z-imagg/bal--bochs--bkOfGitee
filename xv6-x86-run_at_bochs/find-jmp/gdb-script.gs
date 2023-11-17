
set history save on

set logging file find-jmp-gdb.log
set logging on

set print pretty on
set pagination off

set follow-exec-mode new
set follow-fork-mode child

set breakpoint pending on


#感兴趣的 距离为9以内的跳转(因为funcId的汇编写的是向高地址跳)
set $IntrstDist=9

###############
#/crk/bochs/bochs/cpu/ctrl_xfer16.cc
python pyLineNum = gdb.lookup_global_symbol("BX_CPU_C::JMP_EwR").line 
python gdb.execute("set $LineNum=%s"%(pyLineNum))
print $LineNum
set $LineNum=$LineNum+3

break ctrl_xfer16.cc:$LineNum
commands
silent

set $jmp_distance=new_IP - IP
if $jmp_distance >=0 && $jmp_distance <= $IntrstDist
	printf "ctrl_xfer16.cc:BX_CPU_C::JMP_EwR, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
#commands结束


##############
# /crk/bochs/bochs/cpu/ctrl_xfer16.cc
python pyLineNum = gdb.lookup_global_symbol("BX_CPU_C::JMP_Jw").line 
python gdb.execute("set $LineNum=%s"%(pyLineNum))
print $LineNum
set $LineNum=$LineNum+3

break ctrl_xfer16.cc:$LineNum
commands
silent

set $jmp_distance=new_IP - IP
if $jmp_distance >=0 && $jmp_distance <= $IntrstDist
	printf "ctrl_xfer16.cc:BX_CPU_C::JMP_Jw, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
#commands结束


###############
#/crk/bochs/bochs/cpu/ctrl_xfer32.cc

python pyLineNum = gdb.lookup_global_symbol("BX_CPU_C::JMP_Jd").line 
python gdb.execute("set $LineNum=%s"%(pyLineNum))
print $LineNum
set $LineNum=$LineNum+3
break ctrl_xfer32.cc:$LineNum
commands
silent

set $jmp_distance = i->Id()
if $jmp_distance >=0 && $jmp_distance <= $IntrstDist
	printf "ctrl_xfer32.cc:BX_CPU_C::JMP_Jd, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
#对该断点的处理过程结束
###############

#/crk/bochs/bochs/cpu/ctrl_xfer32.cc
#gdb函数名断点(break 函数名) 的处理过程内 , 想要停止在该函数的第N行源码处 :
###  不可用的方案:
#  1. gdb不支持 在 断点处理过程内  使用 'next N',  来执行N行源码以到达目标位置
#  2. 若在断点处理内使用stepi M来执行M条指令 又不好估计多少条指令后可以到达第N行源码

### 可用方案:
#  0.  以gdb python脚本获得该函数行号 并传递到gdb变量中 , 该变量自加N, 动态设置断点(break 源文件名:该变量) 
#    以下即是此可用方案的演示:

#1. gdb内置python找到目标函数所在行号
# python pyLineNum = gdb.lookup_global_symbol("BX_CPU_C::JMP_Ap")[0].line 
python pyLineNum = gdb.lookup_global_symbol("BX_CPU_C::JMP_Ap").line 
python gdb.execute("set $LineNum=%s"%(pyLineNum))
print $LineNum
#  490
#2. 人工阅读该函数源码,确定要在该函数内第12行下断点 
set $LineNum=$LineNum+12
#3. 根据该行号变量下断点(行号 存在变量中,而非写死的数值)
break ctrl_xfer32.cc:$LineNum
#4. 对该断点的处理过程如下:
commands
silent

set $jmp_distance=disp32
if $jmp_distance >=0 && $jmp_distance <= $IntrstDist
	printf "ctrl_xfer32.cc:BX_CPU_C::JMP_Ap, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
#对该断点的处理过程结束
###############


#/crk/bochs/bochs/cpu/ctrl_xfer32.cc

python pyLineNum = gdb.lookup_global_symbol("BX_CPU_C::JMP_EdR").line 
python gdb.execute("set $LineNum=%s"%(pyLineNum))
print $LineNum
set $LineNum=$LineNum+3
break ctrl_xfer32.cc:$LineNum
commands
silent

#根据 /crk/bochs/bochs/cpu/cpu.h:84 的宏定义:  
#   #define EIP (BX_CPU_THIS_PTR gen_reg[BX_32BIT_REG_EIP].dword.erx)
#知,  EIP 是宏 
#  编译时只有用调试级别-g3才会带有宏定义, 
#  编译时若使用调试级别-g2(不带宏定义), 则无法使用宏名
#  -g3 == -g2 + 宏定义

#不要写成this->, 要写成BX_CPU_THIS-> . 因为bochs代码中很少写this , 都是用宏代替,所以调试信息中没有符号this

set $jmp_distance=new_EIP-EIP
if $jmp_distance >=0 && $jmp_distance <= $IntrstDist
	printf "ctrl_xfer32.cc:BX_CPU_C::JMP_EdR, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
###############


#/crk/bochs/bochs/cpu/ctrl_xfer64.cc
python pyLineNum = gdb.lookup_global_symbol("BX_CPU_C::JMP_Jq").line 
python gdb.execute("set $LineNum=%s"%(pyLineNum))
print $LineNum
set $LineNum=$LineNum+3
break ctrl_xfer64.cc:$LineNum

commands
silent

set $jmp_distance=new_RIP-RIP
if $jmp_distance >=0 && $jmp_distance <= $IntrstDist
	printf "ctrl_xfer64.cc:BX_CPU_C::JMP_Jq, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
###############


#/crk/bochs/bochs/cpu/ctrl_xfer64.cc
python pyLineNum = gdb.lookup_global_symbol("BX_CPU_C::JMP_EqR").line 
python gdb.execute("set $LineNum=%s"%(pyLineNum))
print $LineNum
set $LineNum=$LineNum+3
break ctrl_xfer64.cc:$LineNum


commands
silent

set $jmp_distance=op1_64-RIP
if $jmp_distance >=0 && $jmp_distance <= $IntrstDist
	printf "ctrl_xfer64.cc:BX_CPU_C::JMP_EqR, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
###############

run
