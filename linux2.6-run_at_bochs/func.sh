
#测试_get_arg:
#x=$(_get_arg bochs2.7boot-grub4dos-linux2.6.27.15.sh 15 "false &&") ; echo $x
#apt-file --help 2>$dNul 1>$dNul

function _get_arg(){
set -x

scriptF=$1
lnK=$2
argPrefix=$3
lnText=$(awk -v line="$lnK" 'NR==line' $scriptF)


trimmedLnText=${lnText##+([[:space:]])}
# argPrefix="false &&"
argText=$(echo "$trimmedLnText" | sed 's/^false &&//')

echo $argText

set +x

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

# scriptF=bochs2.7boot-grub4dos-linux2.6.27.15.sh
argPrefix="false &&"
lnNum=$1
cmdA1=        _get_arg $scriptF   $((lnNum+1))   $argPrefix  #忽略$2
msgCmdA1Good= _get_arg $scriptF   $((lnNum+2))   $argPrefix  #忽略$3
cmdA2=        _get_arg $scriptF   $((lnNum+2))   $argPrefix  #忽略$4
cmdB1=        _get_arg $scriptF   $((lnNum+2))   $argPrefix  #忽略$5
msgCmdB1Good= _get_arg $scriptF   $((lnNum+2))   $argPrefix  #忽略$6


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