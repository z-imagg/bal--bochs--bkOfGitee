

set logging file find-jmp-gdb.log
set logging on

set print pretty on
set pagination off

set follow-exec-mode new
set follow-fork-mode child

set breakpoint pending on


# ###############
# #/crk/bochs/bochs/cpu/ctrl_xfer16.cc
# break ctrl_xfer16.cc:BX_CPU_C::JMP_EwR
# commands
# next

# set $jmp_distance=new_IP - IP
# if $jmp_distance <= 10
# 	printf "ctrl_xfer16.cc:BX_CPU_C::JMP_EwR, jmp_distance:%d \n",$jmp_distance
# end
# #if 结束

# continue

# end
# #commands结束


###############
#/crk/bochs/bochs/cpu/ctrl_xfer16.cc
# break ctrl_xfer16.cc:BX_CPU_C::JMP_Jw
# python gdb.execute("set $L=\"aaa\"")
# python gdb.execute("info functions  -q -n BX_CPU_C::JMP_Jw")
# python gdb.lookup_symbol("BX_CPU_C::JMP_Jw")

#python print (gdb.lookup_symbol("BX_CPU_C::JMP_Jw") )
#(<gdb.Symbol object at 0x7f7ff4268f30>, False)
# python print (gdb.lookup_symbol("BX_CPU_C::JMP_Jw")[0].line )
#273

# python pyLineNum = gdb.lookup_symbol("BX_CPU_C::JMP_Jw")[0].line 
# python gdb.execute("set $LineNum=%s"%(pyLineNum))
# set $LineNum=$LineNum+3
# break ctrl_xfer16.cc:$LineNum
# # break ctrl_xfer16.cc:276
# commands
# next

# set $jmp_distance=new_IP - IP
# if $jmp_distance <= 10
# 	printf "ctrl_xfer16.cc:BX_CPU_C::JMP_Jw, jmp_distance:%d \n",$jmp_distance
# end
# #if 结束

# continue

# end
# #commands结束


###############
#/crk/bochs/bochs/cpu/ctrl_xfer32.cc

python pyLineNum = gdb.lookup_global_symbol("BX_CPU_C::JMP_Jd").line 
python gdb.execute("set $LineNum=%s"%(pyLineNum))
print $LineNum
set $LineNum=$LineNum+3
break ctrl_xfer32.cc:$LineNum
commands
# silent

set $jmp_distance = i->Id()
if $jmp_distance <= 10
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
# silent

set $jmp_distance=disp32
if $jmp_distance <= 10
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
# silent

#根据 /crk/bochs/bochs/cpu/cpu.h:84 的宏定义:  
#   #define EIP (BX_CPU_THIS_PTR gen_reg[BX_32BIT_REG_EIP].dword.erx)
#知, 可如下获取EIP: 
set $_EIP=BX_CPU_THIS->gen_reg[BX_32BIT_REG_EIP].dword.erx
#不要写成this->, 要写成BX_CPU_THIS-> . 因为bochs代码中很少写this , 都是用宏代替,所以调试信息中没有符号this
#   并且 调试级别只有-g3 才带有宏定义, 注意 调试级别-g2 无宏定义

set $jmp_distance=new_EIP-$_EIP
if $jmp_distance <= 10
	printf "ctrl_xfer32.cc:BX_CPU_C::JMP_EdR, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
###############


# #/crk/bochs/bochs/cpu/ctrl_xfer64.cc
# break ctrl_xfer64.cc:BX_CPU_C::JMP_Jq
# commands
# next

# set $jmp_distance=new_RIP-RIP
# if $jmp_distance <= 10
# 	printf "ctrl_xfer64.cc:BX_CPU_C::JMP_Jq, jmp_distance:%d \n",$jmp_distance
# end
# #if 结束

# continue

# end
# ###############


# #/crk/bochs/bochs/cpu/ctrl_xfer64.cc
# break ctrl_xfer64.cc:BX_CPU_C::JMP_EqR
# commands
# next

# set $jmp_distance=op1_64-RIP
# if $jmp_distance <= 10
# 	printf "ctrl_xfer64.cc:BX_CPU_C::JMP_EqR, jmp_distance:%d \n",$jmp_distance
# end
# #if 结束

# continue

# end
# ###############

run
