#  gdb -x /crk/bochs/xv6-x86-run_at_bochs/getFuncIdOnBochsSrc/gdb-script-getFuncId.gs --args /crk/bochs/bochs/bochs  -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc



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
break ctrl_xfer32.cc:$LineNum
commands
# silent

set $jmp_distance = i->Id()
if $jmp_distance == 9
	printf "ctrl_xfer32.cc:BX_CPU_C::JMP_Jd, jmp_distance:%d \n",$jmp_distance
end
#if 结束

# continue

end
#对该断点的处理过程结束

run
