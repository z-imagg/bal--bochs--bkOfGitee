
# 用bash执行此脚本

rm -fv ~/.ssh/known_hosts
SshConnTimeoutSeconds=10

SUDO=sudo
HostsF="/etc/hosts"
#mingw(msys)下不需要sudo
[ "$(uname -o)" == "Msys" ] && { SUDO="" HostF="/c/Windows/System32/drivers/etc/hosts";}


#本文内容，请参照: linux2.6-run_at_bochs\readme.md
read -p "请输入 win10SshPass(密码):"  win10SshPass
export win10SshPass
export win10User=zzz
export win10SshPort=3022
export w10LocSshfsRt=/w10.loc-rt
export w10LocSshPort=22
grep w10.loc $HostsF || { echo "10.0.4.30  w10.loc" | ${SUDO} tee -a $HostsF ;}
#w10.loc: win10x64.local: win10x64.本地网络



read -p "请输入 ubt22x64Pass(密码):"  ubt22x64Pass
export ubt22x64Pass
export ubt22x64User=z
export ubt22x64Port=2122
export ubt22LocPort=22
grep u22.loc $HostsF || { echo "10.0.4.21  u22.loc" | ${SUDO} tee -a $HostsF ;}
#u22.loc: ubuntu22x64.local: ubuntu22x64.本地网络
