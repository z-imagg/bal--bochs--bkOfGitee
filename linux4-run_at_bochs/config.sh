
# 用bash执行此脚本

rm -fv ~/.ssh/known_hosts
SshConnTS=10

SUDO=sudo
HostsF="/etc/hosts"
#mingw(msys)下不需要sudo
[ "$(uname -o)" == "Msys" ] && { SUDO="" && HostF="/c/Windows/System32/drivers/etc/hosts";}


#本文内容，请参照: linux2.6-run_at_bochs\readme.md
read -p "请输入 win10SshPass(密码):"  win10SshPass
export win10SshPass
export win10User=zzz
export w10SshfsRt=/w10.loc-rt
export w10SshPort=22
grep w10.loc $HostsF || { echo "10.0.4.30  w10.loc" | ${SUDO} tee -a $HostsF ;}
#w10.loc: win10x64.local: win10x64.本地网络



read -p "请输入 ubt22Pass(密码):"  ubt22Pass
export ubt22Pass
export ubt22User=z
export ubt22Port=22
grep u22.loc $HostsF || { echo "10.0.4.21  u22.loc" | ${SUDO} tee -a $HostsF ;}
#u22.loc: ubuntu22x64.local: ubuntu22x64.本地网络
