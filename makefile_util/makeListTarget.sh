#!/bin/sh
make --question  --print-data-base | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}'|sort -u
#-qp :  --question  --print-data-base 
# 网上流传的列出Makefile的target们的awk脚本 