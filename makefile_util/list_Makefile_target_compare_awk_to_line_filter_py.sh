
#windows 10 下运行此过滤器
#cd /d f:\crk\bochs\
# python bochs\makefile_util\line_filter.py   cpu.txt bochs\makefile_util\lnFltMap_Makefile_target.py cpuo.txt & type cpuo.txt

#linux下 运行 makefile目标过滤器
cd /crk/bochs/bochs/cpu  && make --question  --print-data-base > /crk/cpu.txt 
python3 /crk/bochs/makefile_util/line_filter.py   /crk/cpu.txt /crk/bochs/makefile_util/lnFltMap_Makefile_target.py /crk/cpu_makefile_target.txt && cat /crk/cpu_makefile_target.txt | sort -u > /crk/bochs/makefile_util/result_cpu_out_py.txt

#awk脚本结果 作为对比
cd /crk/bochs/bochs/cpu/
/crk/bochs/makefile_util/makeListTarget.sh  | grep -v "\.cc"    | grep -v "\.h"   | grep -v "Makefile" |sort -u > /crk/bochs/makefile_util/result_cpu_out_awk.txt

wc -l /crk/bochs/makefile_util/result_cpu_out_py.txt /crk/bochs/makefile_util/result_cpu_out_awk.txt
# 105 /crk/bochs/makefile_util/result_cpu_out_py.txt
# 102 /crk/bochs/makefile_util/result_cpu_out_awk.txt

 
diff  /crk/bochs/makefile_util/result_cpu_out_py.txt /crk/bochs/makefile_util/result_cpu_out_awk.txt
"""
36,38d35
< decoder/disasm.o
< decoder/fetchdecode32.o
< decoder/fetchdecode64.o
"""

#比对结果: /crk/bochs/makefile_util/line_filter.py 优于 /crk/bochs/makefile_util/makeListTarget.sh
# 理由:  /crk/bochs/makefile_util/line_filter.py    丢弃了 decoder/disasm.o、decoder/fetchdecode32.o、decoder/fetchdecode64.o 且 含有空白目标(*.cc、*.h) 和 Makefile(不是目标), 
#     而 /crk/bochs/makefile_util/makeListTarget.sh 含有  decoder/disasm.o、decoder/fetchdecode32.o、decoder/fetchdecode64.o
