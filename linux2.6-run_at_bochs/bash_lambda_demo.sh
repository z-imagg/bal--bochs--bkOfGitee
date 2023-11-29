#!/usr/bin/env bash

set -e

function multiplyBy() {
    X="$1"
	
	echo "X=$X"
	
# 输入重定向: << 'EOF' 与 <<- 'EOF'  区别如下
# <<- 'EOF' 允许缩进，可读性高
# << 'EOF'  每行必须顶格写（不能缩进），可读性低

echo 'Y=$1; echo $Y'
echo 'echo "$X * $Y = $(( $X * $Y ))"'

# cat <<- 'EOF'
	# Y=\\$1 ; echo $Y
	# echo "$X * $Y = \$(( $X * $Y ))"
# EOF
}

function callFunc() {
    CODE="$1"
	shift #; echo "\$1:$1"
    echo "CODE:[# $CODE #]"

    eval "$CODE"
}

MULT_BY_2=`multiplyBy 2`
# echo "MULT_BY_2:$MULT_BY_2"
callFunc "$MULT_BY_2" 10

#./bash_lambda_demo.sh  #执行后输出如下:
#CODE:[# X=2
#Y=$1; echo $Y
#echo "$X * $Y = $(( $X * $Y ))" #]
#10
#2 * 10 = 20







