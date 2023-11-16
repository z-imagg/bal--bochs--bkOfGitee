
###############
#/crk/bochs/bochs/cpu/ctrl_xfer16.cc
break ctrl_xfer16.cc:BX_CPU_C::JMP_EwR
commands
next

set $jmp_distance=new_IP - IP
if $jmp_distance <= 10
	printf "ctrl_xfer16.cc:BX_CPU_C::JMP_EwR, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
#commands结束


###############
#/crk/bochs/bochs/cpu/ctrl_xfer16.cc
break ctrl_xfer16.cc:BX_CPU_C::JMP_Jw
commands
next

set $jmp_distance=new_IP - IP
if $jmp_distance <= 10
	printf "ctrl_xfer16.cc:BX_CPU_C::JMP_Jw, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
#commands结束


###############
#/crk/bochs/bochs/cpu/ctrl_xfer32.cc
break ctrl_xfer32.cc:BX_CPU_C::JMP_Jd
commands
next

set $jmp_distance=new_EIP - EIP
if $jmp_distance <= 10
	printf "ctrl_xfer32.cc:BX_CPU_C::JMP_Jd, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
###############

#/crk/bochs/bochs/cpu/ctrl_xfer32.cc
break ctrl_xfer32.cc:BX_CPU_C::JMP_Ap
commands
next 10

set $jmp_distance=disp32
if $jmp_distance <= 10
	printf "ctrl_xfer32.cc:BX_CPU_C::JMP_Ap, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
###############


#/crk/bochs/bochs/cpu/ctrl_xfer32.cc
break ctrl_xfer32.cc:BX_CPU_C::JMP_EdR
commands
next

set $jmp_distance=new_EIP-EIP
if $jmp_distance <= 10
	printf "ctrl_xfer32.cc:BX_CPU_C::JMP_EdR, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
###############


#/crk/bochs/bochs/cpu/ctrl_xfer64.cc
break ctrl_xfer64.cc:BX_CPU_C::JMP_Jq
commands
next

set $jmp_distance=new_RIP-RIP
if $jmp_distance <= 10
	printf "ctrl_xfer64.cc:BX_CPU_C::JMP_Jq, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
###############


#/crk/bochs/bochs/cpu/ctrl_xfer64.cc
break ctrl_xfer64.cc:BX_CPU_C::JMP_EqR
commands
next

set $jmp_distance=op1_64-RIP
if $jmp_distance <= 10
	printf "ctrl_xfer64.cc:BX_CPU_C::JMP_EqR, jmp_distance:%d \n",$jmp_distance
end
#if 结束

continue

end
###############

###############

###############
