#!/bin/sh

#dos2unix /crk/bochs/xv6-x86-run_at_bochs/run.sh
# /crk/bochs/xv6-x86-run_at_bochs/run.sh

rm -fv /crk/bochs/xv6-x86/*.img.lock
gdb -x /crk/bochs/xv6-x86-run_at_bochs/find-jmp/gdb-script.gs --args /crk/bochs/bochs/bochs  -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc