
# 用bash执行此脚本

rm -fv ~/.ssh/known_hosts
SshConnTimeoutSeconds=10

SUDO=sudo
#mingw(msys)下不需要sudo
[ "$(uname -o)" == "Msys" ] && SUDO=""


#本文内容，请参照: linux2.6-run_at_bochs\readme.md
read -p "请输入 win10SshPass(密码):"  win10SshPass
export win10SshPass
export win10User=zzz
export win10SshPort=3022
export w10LocSshfsRt=/w10.loc-rt
grep win10Host /etc/hosts || { echo "192.168.1.13  win10Host" | ${SUDO} tee -a /etc/hosts ;}
export w10LocSshPort=22
grep w10.loc /etc/hosts || { echo "10.0.4.30  w10.loc" | ${SUDO} tee -a /etc/hosts ;}
#w10.loc: win10x64.local.wire: win10x64.本地网络.有线连接


read -p "请输入 ubuntu14X86Pass(密码):"  ubuntu14X86Pass
export ubuntu14X86Pass
export ubuntu14X86User=z
export ubuntu14X86Port=3022
grep ubuntu14X86Host /etc/hosts || { echo "192.168.1.4  ubuntu14X86Host" | ${SUDO} tee -a /etc/hosts ;}

read -p "请输入 ubt22x64Pass(密码):"  ubt22x64Pass
export ubt22x64Pass
export ubt22x64User=z
export ubt22x64Port=2122
export ubt22LocPort=22
grep ubt22x64Host /etc/hosts || { echo "192.168.1.4  ubt22x64Pass" | ${SUDO} tee -a /etc/hosts ;}
grep u22.loc.wire /etc/hosts || { echo "10.0.4.21  u22.loc.wire" | ${SUDO} tee -a /etc/hosts ;}
#u22.loc.wire: ubuntu22x64.local.wire: ubuntu22x64.本地网络.有线连接
