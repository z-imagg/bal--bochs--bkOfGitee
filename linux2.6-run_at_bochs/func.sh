
function _get_arg(){

}

function ifelseif(){
#此函数 即 ifelseif 实现 如下伪码 ： 
#cmdA1ExitCode=cmdA1()
#if cmdA1ExitCode == 0: #cmdA1正常执行
#   echo $msgCmdA1Good
#   cmdA2()
#else: # 此else 即 cmdA1ExitCode != 0 即 cmdA1异常执行
#   if cmdB1():
#       echo $msgCmdB1Good
##############函数ifelseif伪码结束#################

scriptF=bochs2.7boot-grub4dos-linux2.6.27.15.sh
argPrefix="false &&"
lnNum=$1
# cmdA1= $scriptF 的  第 lnNum+1 行内容 去掉 前缀 $argPrefix  #忽略$2
msgCmdA1Good=$3
# cmdA2= $scriptF 的  第 lnNum+2 行内容 去掉 前缀 $argPrefix  #忽略$4
# cmdB1= $scriptF 的  第 lnNum+2 行内容 去掉 前缀 $argPrefix    #忽略$5
msgCmdB1Good=$4


{ \
#执行 cmdA1
eval $cmdA1 && _="若 cmdA1.返回码 == 正常返回码0 :" && \
#则 先 显示 msgCmdA1Good 再 执行 cmdA2
{ echo $msgCmdA1Good ; eval $cmdA2  ;} \
; } ; [ $? != 0 ] && \
#若 cmdA1.返回码 != 正常返回码0 :
{ \
#则 执行 cmdB1 并 显示 msgCmdB1Good
eval $cmdB1 && _="若cmdB1命令成功,则显示msgCmdB1Good" && \
echo $msgCmdB1Good \
; }


}