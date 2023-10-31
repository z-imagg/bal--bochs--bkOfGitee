
import sys
print(f"sys.argv:{sys.argv}")
# assert len(sys.argv)>4, """用法: python line_filter.py 输入文本文件 输出文本文件 'lnFlt=lambda x:x[0].contains(":")' """ #暂时不用lambda样式
assert len(sys.argv)>4, """ 用法: python line_filter.py 输入文本文件 输出文本文件 'def lnFlt(lnK,prevLn): return lnK.contains(":")' """ #用函数样式
fn_in=sys.argv[1]
fn_out=sys.argv[2]
filter_expr=sys.argv[3]
exec(filter_expr)
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

outText="".join(outLnLs)
with open(fn_out, "w") as fout:
	fout.write(outText)
	
print(f"len(outLnLs)={len(outLnLs)}")