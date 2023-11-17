#!/bin/sh

#make_xv6_bochs_run=false ./getFuncId.sh

#找出 xv6-x86 中的 funcId汇编 
objdump -d /crk/bochs/xv6-x86/kernel | grep -A 3 -B 1 "83 cf ff" > xv6-x86-kernel-grep-jmpInFuncIdAsm-0x83cfff.txt

dos2unix /crk/bochs/xv6-x86-run_at_bochs/make_xv6_bochs_run.sh
test "$make_xv6_bochs_run" != "false" &&  RUN_BOCHS=false sh -x /crk/bochs/xv6-x86-run_at_bochs/make_xv6_bochs_run.sh

rm -fv /crk/bochs/xv6-x86/*.img.lock
#此gdb估计需要很久很久才能运行完,因为断下来次数太多 且 每次断点处理耗时多, 推荐 运行一会儿 日志足够了 就 Ctrl+C 强制结束
gdb -x /crk/bochs/xv6-x86-run_at_bochs/getFuncIdOnBochsSrc/gdb-script-getFuncId.gs --args /crk/bochs/bochs/bochs  -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc

# 由于   xv6-x86-kernel-grep-jmpInFuncIdAsm-0x83cfff.txt  中 记录了 xv6-x86 中的 funcId汇编们的样子,  
# 因此 对比 xv6-x86-kernel-grep-jmpInFuncIdAsm-0x83cfff.txt 和 getFuncIdOnBochsSrc.log,  
#    可以知道 gdb-script-getFuncId.gs 拿到的 是不是 funcId汇编,
#    简单对比 可知 gdb-script-getFuncId.gs 拿到的 的确是 funcId汇编.