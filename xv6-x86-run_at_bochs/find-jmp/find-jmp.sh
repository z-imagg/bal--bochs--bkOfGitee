#!/bin/sh

/crk/bochs/xv6-x86-run_at_bochs/run.sh

gdb -x /crk/bochs/xv6-x86-run_at_bochs/find-jmp/gdb-script.gs --args /crk/bochs/bochs/bochs  -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc