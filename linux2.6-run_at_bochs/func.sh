
#测试_get_arg:
#debug__get_arg=true; x=$(_get_arg bochs2.7boot-grub4dos-linux2.6.27.15.sh 15 "false &&") ; echo $x
#apt-file --help 2>$dNul 1>$dNul

function _get_arg(){
#if $debug__get_arg is null : debug__get_arg=true
[ "x"  == "x$debug__get_arg"  ] && debug__get_arg=false

$debug__get_arg && set -x

scriptF=$1
lnK=$2
argPrefix=$3
retF=$4
# argPrefix="false &&"
lnText=$(awk -v line="$lnK" 'NR==line' $scriptF)

# argText=$(echo "$trimmedLnText" | sed "s/^ *${argPrefix}//")

argText=$(echo "$lnText" | sed 's/^ *false &&//')


echo  "$argText" > $retF
echo "$argText"

{ $debug__get_arg  &&  set +x ;}  ; unset debug__get_arg

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

#if $debug_ifelseif is null : debug_ifelseif=true
[ "x"  == "x$debug_ifelseif"  ] && debug_ifelseif=false
$debug_ifelseif && set -x


argPrefix='false &&'
scriptF=$1
lnNum=$2
# set +x
# debug__get_arg=true
cmdA1=        $(_get_arg $scriptF   $((lnNum+1))   "$argPrefix"  "/tmp/_get_arg__retF_$(date +%s%N)" )  #忽略$3
msgCmdA1Good= $(_get_arg $scriptF   $((lnNum+2))   "$argPrefix"  "/tmp/_get_arg__retF_$(date +%s%N)" )  #忽略$4
cmdA2=        $(_get_arg $scriptF   $((lnNum+3))   "$argPrefix"  "/tmp/_get_arg__retF_$(date +%s%N)" )  #忽略$5
cmdB1=        $(_get_arg $scriptF   $((lnNum+4))   "$argPrefix"  "/tmp/_get_arg__retF_$(date +%s%N)" )  #忽略$6
msgCmdB1Good= $(_get_arg $scriptF   $((lnNum+5))   "$argPrefix"  "/tmp/_get_arg__retF_$(date +%s%N)" )  #忽略$7
# $debug_ifelseif && set -x

echo "cmdA1:$cmdA1, msgCmdA1Good:$msgCmdA1Good, cmda2:$cmda2, cmdB1:$cmdB1, msgCmdB1Good:$msgCmdB1Good"

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

{ $debug_ifelseif  &&  set +x ;}  ; unset debug_ifelseif

}