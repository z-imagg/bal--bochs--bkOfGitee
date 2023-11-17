#  gdb -x /crk/bochs/xv6-x86-run_at_bochs/getFuncIdOnBochsSrc/gdb-script-getFuncId.gs --args /crk/bochs/bochs/bochs  -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc


set history save on

set logging file getFuncId.log
set logging on

set print pretty on
set pagination off

set follow-exec-mode new
set follow-fork-mode child

set breakpoint pending on



###############
#/crk/bochs/bochs/cpu/ctrl_xfer32.cc

python pyLineNum = gdb.lookup_global_symbol("BX_CPU_C::JMP_Jd").line 
python gdb.execute("set $LineNum=%s"%(pyLineNum))
print $LineNum
set $LineNum=$LineNum+3
break ctrl_xfer32.cc:$LineNum if  i->Id() == 9

commands
silent

set $or1_instr_appendByte=BX_CPU_THIS->read_linear_dword (i->seg(),EIP)
set $or2_instr_appendWord=BX_CPU_THIS->read_linear_qword (i->seg(),EIP+3)

set $or1_instr = $or1_instr_appendByte & 0x00FFFFFF
set $or2_instr = $or2_instr_appendWord & 0x0000ffFFffFFffFF
printf "EIP=0x%x,or1=0x%x,or2=0x%lx,or2_instr_appendWord=0x%lx\n",EIP,$or1_instr,$or2_instr,$or2_instr_appendWord

continue

end
#commands结束


run

#bochs调试器 运行后 , 
#在bochs调试器命令行下 , 输入 continue, 即 如下
#<bochs:1>  continue
#bochs调试器才会继续运行xv6-x86

