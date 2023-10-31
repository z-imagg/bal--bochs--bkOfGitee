
import sys,os
from types import FunctionType
import pdb

#此过滤器 基本能过滤掉大部分非关心目标
#  python bochs\makefile_util\line_filter.py   cpu.txt bochs\makefile_util\lnFltMap_Makefile_target.py cpuo.txt & type cpuo.txt



usage_ms_windows="""   python line_filter.py 输入文本文件 lnFltMap_xxx.py 输出文本文件  """  


print(f"sys.argv:{sys.argv} ")
assert os.environ.__contains__('filter_expr') and len(sys.argv)>3, usage_ms_windows
fn_in=sys.argv[1]
fn_filter_expr=sys.argv[2]
fn_out=sys.argv[3]
with open(fn_filter_expr, "r",encoding="utf-8") as fin_filter_expr:
    filter_expr= fin_filter_expr.read()
print(f"filter_expr=【{filter_expr}】")


# exec(filter_expr, globals())
filter_func=compile(filter_expr,"<string>","exec")
print(f" filter_func={filter_func},{type(filter_func)},{filter_func.co_consts}")
# pdb.set_trace()
lnFltMap=FunctionType(filter_func.co_consts[0],globals(),"lnFltMap")

print(lnFltMap,lnFltMap("a:b","c"))
#用函数样式: def lnFltMap(lnK,prevLn): return lnK.contains(":")
#暂时不用lambda样式: lambda lnFltMap x: x[0].contains(":")
with open(fn_in, "r") as fin:
    lnLs= fin.readlines()

outLnLs=[]
for k,lnK in enumerate(lnLs):
	prevLn='' if k==0 else lnLs[k-1]
	#   lnFltMap( (lnK,prevLn) ): #这里是lambda样式, 暂时不用
	keep,lnKMapped=lnFltMap( lnK,prevLn ) #这里是函数样式, 暂时用此
	if keep:   
		outLnLs.append(lnKMapped)
		# outLnLs.append(f"[{len(lnK)},{lnK}]")#调试用

outText="".join(outLnLs)
with open(fn_out, "w") as fout:
	fout.write(outText)
	
print(f"len(outLnLs)={len(outLnLs)}")