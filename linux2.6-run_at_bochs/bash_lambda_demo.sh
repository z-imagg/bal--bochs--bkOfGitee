#!/usr/bin/env bash

function multiplyBy() {
    X="$1"
	echo "X=$X"
cat <<- 'EOF'
	Y=$1 ; echo $Y
	echo "$X * $Y = $(( $X * $Y ))"
EOF
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

