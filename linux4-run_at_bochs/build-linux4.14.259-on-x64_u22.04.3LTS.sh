#CurScriptF为当前脚本的绝对路径
#若$0以/开头 (即 绝对路径) 返回$0, 否则 $0为 相对路径 返回  pwd/$0
{ { [[ $0 == /* ]] && CurScriptF=$0 ;} ||  CurScriptF=$(pwd)/$0 ;} && \

CurScriptNm=$(basename $CurScriptF) && \
CurScriptDir=$(dirname $CurScriptF) && \
#CurScriptDir == /crk/bochs/linux4-run_at_bochs

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

echo -n "i686-linux-gnu-gcc 指向:" && readlink -f $(which i686-linux-gnu-gcc) && \

#进入目录 /crk/bochs/linux4-run_at_bochs/
cd $CurScriptDir && \

#ubuntu 22 x64
sudo apt install -y gcc-11-i686-linux-gnu gcc-i686-linux-gnu && \
sudo apt install -y gcc-multilib-i686-linux-gnu && \
# sudo apt-get install -y gcc-multilib g++-multilib

LnxRpBrch="linux-4.14.y" && \
LnxRpCmtId="ae1952ac1aac66010a51a69c4592d72724d91ce2" && \
#分支 linux-4.14.y 的最后一次提交 ae1952ac1aac66010a51a69c4592d72724d91ce2 , 链接如下: 
# https://gitcode.net/crk/linux-stable/-/commit/ae1952ac1aac66010a51a69c4592d72724d91ce2
LinuxRepoD=/crk/linux-stable && \
LnxRpGitD=$LinuxRepoD/.git && \
{ [ -f $LnxRpGitD/config ] || \
  git clone http://mirrors.tuna.tsinghua.edu.cn/git/linux-stable.git $LinuxRepoD
#linux-stable仓库尺寸大约2.56GB，  提交时请提交到 https://gitcode.net/crk/linux-stable.git （此仓库是从上一行清华linux-stable.git仓库克隆来的，是一样的，只是可以更改并提交而已)
} && \
LnxRpBrchCur=$(git --git-dir=$LnxRpGitD branch --show-current) && \
LnxRpCmtIdCur=$(git --git-dir=$LnxRpGitD rev-parse HEAD) && \
#{重置git仓库
git --git-dir=$LnxRpGitD --work-tree=$LinuxRepoD  reset --hard && \
git --git-dir=$LnxRpGitD --work-tree=$LinuxRepoD  clean -df && \
git --git-dir=$LnxRpGitD --work-tree=$LinuxRepoD  checkout -- && \
#重置git仓库}
{ [ "X$LnxRpBrchCur" == "X$LnxRpBrch" ]  || \
# 切换到给定分支
  git --git-dir=$LnxRpGitD --work-tree=$LinuxRepoD checkout -B $LnxRpBrch origin/$LnxRpBrch
#git checkout -B 覆盖已经存在的本地分支
# -b <branch>           create and checkout a new branch
# -B <branch>           create/reset and checkout a branch
} && \
{ [ "X$LnxRpCmtIdCur" == "X$LnxRpCmtId" ]  || \
# 切换到给定提交
  git --git-dir=$LnxRpGitD --work-tree=$LinuxRepoD  reset --hard "$LnxRpCmtId"
} && \
{
# 记录 当前所用Linux仓库的 分支和commitId
 _RM=/crk/bochs/linux4-run_at_bochs/readme.md && \
 _S1="Linux_Run_At_Bochs对linux-stable分支:" && \
 sed -i "s/^$_S1.*/$_S1 $LnxRpBrchCur , $LnxRpCmtIdCur/" $_RM && \
 cd $LinuxRepoD 
} && \

#并行编译 job数 为 max(核心数-1,1)
job_n=$((nproc-1)) && \
job_n=$(( core_n > 1 ? core_n: 1 )) && \

set -x && \
MakeLogF=/crk/make.log && \
UniqueId="$MakeLogF-$(date +'%Y%m%d%H%M%S_%s_%N')" && \
[ -f $MakeLogF ] && mv $MakeLogF "$MakeLogF_$UniqueId"
make clean && \
make ARCH=i386 CROSS_COMPILE=i686-linux-gnu- defconfig && \
make ARCH=i386 CROSS_COMPILE=i686-linux-gnu- menuconfig && \
{ make ARCH=i386 CROSS_COMPILE=i686-linux-gnu- -j $job_n V=1 2>&1 | tee -a $MakeLogF ;} && \
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
