#!/bin/sh

grep 记录funcId     /crk/bochs/bochs/bochsout.txt  | cut -d ']' -f 2 | cut -d ':' -f 2 | cut -d ',' -f 1 > bochsout_clean.log

echo 'abs_location_id' | cat - bochsout_clean.log > temp && mv temp bochsout_clean.log
