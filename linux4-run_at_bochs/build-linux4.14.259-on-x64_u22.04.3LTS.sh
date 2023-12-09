
CurScriptF=$(pwd)/$0 && \
CurScriptNm=$(basename $CurScriptF) && \

# 拉代码（包括子模块cmd-wrap） 
#  （这段命令是从lazygit抄来的）
{ cd /crk/bochs/ && \
git pull --no-edit 1> .gitPull.log && cat .gitPull.log && \
git reset HEAD -- cmd-wrap && \
git -C cmd-wrap stash --include-untracked && \
git submodule update --init --force -- cmd-wrap && \
{ \
{ grep $CurScriptNm .gitPull.log &&  echo "已更新代码仓库，由于本脚本可能也更新了，故现在退出，退出码5，请重新执行本脚本" && exit 5;} || true
}
} && \


#cmd-wrap 拦截 gcc 命令
{ [   -e /crk/cmd-wrap ] || ln -s /crk/bochs/cmd-wrap /crk/cmd-wrap ;} && \
#install-wrap.sh内 会 将假gcc命令所在目录/crk/bin 放到 PATH最前面, 因此需要source执行。
source /crk/cmd-wrap/install-wrap.sh && \

#ubuntu 22 x64
sudo apt install -y gcc-11-i686-linux-gnu gcc-i686-linux-gnu && \
sudo apt install -y gcc-multilib-i686-linux-gnu && \
# sudo apt-get install -y gcc-multilib g++-multilib

LINUX_changed=linux-4.14.259-changed && \
LINUX=linux-4.14.259 && \
LINUX_tar_gz="${LINUX}.tar.gz" && \
LINUX_tar_gz_md5sum_F="${LINUX_tar_gz}.md5sum.txt" && \

cd /crk/bochs/linux4-run_at_bochs/ && \

{ \
{ [ -f $LINUX_tar_gz_md5sum_F ] && md5sum --check $LINUX_tar_gz_md5sum_F ;} || { rm -fr $LINUX_tar_gz  $LINUX && \
wget https://mirrors.cloud.tencent.com/linux-kernel/v4.x/linux-4.14.259.tar.gz && \
md5sum $LINUX_tar_gz > $LINUX_tar_gz_md5sum_F ;} \
} && \
tar -zxf $LINUX_tar_gz && \
#diff $LINUX_changed $LINUX && \
#复制修改的文件
cp -rv $LINUX_changed/* $LINUX/ && \
cd $LINUX && \

#并行编译 job数 为 max(核心数-1,1)
job_n=$((nproc-1)) && \
job_n=$(( core_n > 1 ? core_n: 1 )) && \

set -x && \
make ARCH=i386 CROSS_COMPILE=i686-linux-gnu- defconfig && \
make ARCH=i386 CROSS_COMPILE=i686-linux-gnu- menuconfig && \
{ make ARCH=i386 CROSS_COMPILE=i686-linux-gnu- -j $job_n V=1 2>&1 | tee -a /crk/make.log ;} && \
set +x && \

find . -name "*bzImage*" && \
# ./arch/x86/boot/bzImage
# ./arch/x86/boot/.bzImage.cmd
# ./arch/i386/boot/bzImage
ls -lh arch/x86/boot/bzImage && \
# -rw-rw-r-- 1   6.8M  arch/x86/boot/bzImage
file arch/x86/boot/bzImage && \
# arch/x86/boot/bzImage: Linux kernel x86 boot executable bzImage, version 4.14.259 (z@x) #1 SMP Tue Dec 5 19:10:09 CST 2023, RO-rootFS, swap_dev 0X6, Normal VGA

_end=true
