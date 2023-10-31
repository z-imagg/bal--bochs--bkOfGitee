
#lnFltMap例子: makefile目标过滤器
def lnFltMap_demo_Makefile_target(lnK,prevLn): 
	OUT_LN_FEED="\n" #若结果想以空格隔开，这个改为空格即可
	keep= lnK.__contains__(':') \
	and  not lnK.__contains__(':=') \
	and  not lnK.__contains__('%.') \
	and  not lnK.__contains__('%::') \
	and  not lnK.__contains__('(%):') \
	and  not lnK.__contains__(' = ') \
	and not lnK.startswith('#') \
	and not lnK.startswith('.') \
	and not lnK.split(':')[0].endswith('.h') \
	and not lnK.split(':')[0].endswith('.c')  \
	and not lnK.split(':')[0].endswith('.cc') \
	and not lnK.split(':')[0].endswith('.cpp')  \
	and prevLn not in ['# Not a target:\n'  , '# Not a target:\r\n' ]
	return (keep,f"{lnK.split(':')[0]}{OUT_LN_FEED}") 