
import sys,os
from types import FunctionType
import pdb
_LnFeed_RN="\r\n"
_LnFeed_N="\n"

#此过滤器 基本能过滤掉大部分非关心目标
#set filter_expr="def lnFlt(lnK,prevLn): return lnK.__contains__(':') and  not lnK.__contains__(':=') and  not lnK.__contains__('%.') and  not lnK.__contains__('%::') and  not lnK.__contains__('(%):') and  not lnK.__contains__(' = ') and not lnK.startswith('#') and not lnK.split(':')[0].endswith('.h') and not lnK.split(':')[0].endswith('.c')  and not lnK.split(':')[0].endswith('.cc') and not lnK.split(':')[0].endswith('.cpp')  and prevLn not in [f'# Not a target:{_LnFeed_N}'  , f'# Not a target:{_LnFeed_RN}' ] " & python bochs\makefile_util\line_filter.py   cpu.txt cpuo.txt & more cpuo.txt

usage_ms_windows=""" 用法: set filter_expr='def lnFlt(lnK,prevLn): return lnK.contains(":")' & python line_filter.py 输入文本文件 输出文本文件 'def lnFlt(lnK,prevLn): return lnK.__contains__(":")' """ #用函数样式
# usage_ms_windows="""用法: set filter_expr='def lnFlt(lnK,prevLn): return lnK.contains(":")' & python line_filter.py 输入文本文件 输出文本文件 'lnFlt=lambda x:x[0].__contains__(":")' """ #暂时不用lambda样式

print(f"sys.argv:{sys.argv} ")
assert os.environ.__contains__('filter_expr') and len(sys.argv)>2, usage_ms_windows
fn_in=sys.argv[1]
fn_out=sys.argv[2]
_filter_expr=os.environ['filter_expr']
filter_expr=eval(_filter_expr)#去掉一层引号 从 '"def lnFlt2(lnK,prevLn): xxx" ' 变成  "def lnFlt2(lnK,prevLn): xxx"
print(f" os.environ['filter_expr']={filter_expr},{type(filter_expr)}")


# exec(filter_expr, globals())
filter_func=compile(filter_expr,"<string>","exec")
print(f" filter_func={filter_func},{type(filter_func)},{filter_func.co_consts}")
# pdb.set_trace()
lnFlt=FunctionType(filter_func.co_consts[0],globals(),"lnFlt")

print(lnFlt,lnFlt("a:b","c"))
#用函数样式: def lnFlt(lnK,prevLn): return lnK.contains(":")
#暂时不用lambda样式: lambda lnFlt x: x[0].contains(":")
with open(fn_in, "r") as fin:
    lnLs= fin.readlines()

outLnLs=[]
for k,lnK in enumerate(lnLs):
	prevLn='' if k==0 else lnLs[k-1]
	# if lnFlt( (lnK,prevLn) ): #这里是lambda样式, 暂时不用
	if lnFlt( lnK,prevLn ):   #这里是函数样式, 暂时用此
		outLnLs.append(lnK)
		# outLnLs.append(f"[{len(lnK)},{lnK}]")#调试用

outText="".join(outLnLs)
with open(fn_out, "w") as fout:
	fout.write(outText)
	
print(f"len(outLnLs)={len(outLnLs)}")