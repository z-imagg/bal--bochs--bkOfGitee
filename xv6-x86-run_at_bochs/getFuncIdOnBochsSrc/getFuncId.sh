#!/bin/sh

#make_xv6_bochs_run=false ./getFuncId.sh

dos2unix /crk/bochs/xv6-x86-run_at_bochs/make_xv6_bochs_run.sh
test "$make_xv6_bochs_run" != "false" &&  RUN_BOCHS=false sh -x /crk/bochs/xv6-x86-run_at_bochs/make_xv6_bochs_run.sh

rm -fv /crk/bochs/xv6-x86/*.img.lock
gdb -x /crk/bochs/xv6-x86-run_at_bochs/getFuncIdOnBochsSrc/gdb-script-getFuncId.gs --args /crk/bochs/bochs/bochs  -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc
