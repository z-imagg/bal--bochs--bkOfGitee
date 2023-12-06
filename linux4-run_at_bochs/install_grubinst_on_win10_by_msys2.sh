
# win10x64主机的 必须的准备:  启动 mingw(msys2)的sshd服务, 请人工参考 https://www.msys2.org/wiki/Setting-up-SSHd/ 

#用bash执行此脚本




set -e


pwd
cd /
source  config.sh

sshpass -V || pacman --noconfirm -S   sshpass

echo "ubt22x64Pass=$ubt22x64Pass"

# 4.3 磁盘映像文件 复制到 ubt22x64主机msys2的根目录下


sshpass -p $ubt22x64Pass scp  -o ConnectTimeout=$SshConnTimeoutSeconds -o StrictHostKeyChecking=no -P $ubt22x64Port  $ubt22x64User@u22.loc:/crk/bochs/linux2.6-run_at_bochs/$HdImgF /$HdImgF && \

echo "执行grubinst.exe前md5sum: $(md5sum $HdImgF)" && \

# 4.4 ubt22x64主机上msys2: 下载 grubinst_1.0.1_bin_win.zip,   安装unzip, 用 unzip 解压 grubinst_1.0.1_bin_win.zip


test -f  /grubinst_1.0.1_bin_win/grubinst/grubinst.exe || \
{ \
wget https://sourceforge.net/projects/grub4dos/files/grubinst/grubinst%201.0.1/grubinst_1.0.1_bin_win.zip/download  --output-document   /grubinst_1.0.1_bin_win.zip && \
pacman --noconfirm -S  unzip && \
unzip -o /grubinst_1.0.1_bin_win.zip -d / \
;} && \



# 4.5 ubt22x64主机上msys2:  用 grubinst.exe 对 磁盘映像文件 安装 grldr.mbr
/grubinst_1.0.1_bin_win/grubinst/grubinst.exe /$HdImgF && echo 'grubinst.exe ok'
#4.6 传回已 安装 grldr.mbr 的 磁盘映像文件
sshpass -p $ubt22x64Pass scp  -o ConnectTimeout=$SshConnTimeoutSeconds  -o StrictHostKeyChecking=no -P $ubt22x64Port  /$HdImgF  $ubt22x64User@u22.loc:/crk/bochs/linux2.6-run_at_bochs/$HdImgF  && \
#注: (win10主机.本地)w10.loc:/ == D:\msys64, 所以请事先复制 grubinst_1.0.1_bin_win 到 D:\msys64\下

echo "执行grubinst.exe后md5sum: $(md5sum $HdImgF)"