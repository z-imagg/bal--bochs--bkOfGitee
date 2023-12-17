
# 此脚本用法:
{ \
echo -e "此脚本用法 : \n 默认单核编译: 【 $0】 \n 多核并行编译: 【 multi_build=true $0】"
:;} && \

# 常量
{ \
###
:;} && \



# 加载（依赖、通用变量）（此脚本中的ifelse调试步骤) (关于此脚本中的 【:;}】) (断点1)
{  \
# source /crk/bochs/bash-simplify/func.sh
source /crk/bochs/bash-simplify/dir_util.sh

#CurScriptF为当前脚本的绝对路径
#若$0以/开头 (即 绝对路径) 返回$0, 否则 $0为 相对路径 返回  pwd/$0
{ { [[ $0 == /* ]] && CurScriptF=$0 ;} ||  CurScriptF=$(pwd)/$0 ;} && \

CurScriptNm=$(basename $CurScriptF) && \
CurScriptDir=$(dirname $CurScriptF) && \
#CurScriptDir == /crk/bochs/linux4-run_at_bochs


:;} && \

#######


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
#install-wrap.sh内 会 将假gcc命令所在目录/crk/bin 放到 PATH最前面, 因此需要source执行。
source /crk/bochs/cmd-wrap/install-wrap.sh && \

echo -n "假编译器 指向:" && readlink -f $(which clang) && \

#进入目录 /crk/bochs/linux4-run_at_bochs/
cd $CurScriptDir && \

#ubuntu 22 x64
sudo apt install -y gcc-11-i686-linux-gnu gcc-i686-linux-gnu && \
sudo apt install -y gcc-multilib-i686-linux-gnu && \
# sudo apt-get install -y gcc-multilib g++-multilib

LnxRpBrch="linux-4.14.y-patch" && \
#分支  : https://gitcode.net/crk/linux-stable/-/tree/linux-4.14.y
LinuxRepoD=/crk/linux-stable && \
LnxRpGitD=$LinuxRepoD/.git && \
{ [ -f $LnxRpGitD/config ] || \
  { \
  #从清华镜像获取linux-stable更快
  git clone http://mirrors.tuna.tsinghua.edu.cn/git/linux-stable.git $LinuxRepoD && \ 
  #人工将清华镜像linux-stable放到gitcode上, 并将修改分支放到gitcode仓库上
  #指定gitcode仓库地址
  git remote add my_origin https://prgrmz07:uE4BUZEsymZvFmK2Wm9e@gitcode.net/crk/linux-stable.git ;}
#linux-stable仓库尺寸大约2.56GB，  提交时请提交到 https://gitcode.net/crk/linux-stable.git （此仓库是从上一行清华linux-stable.git仓库克隆来的，是一样的，只是可以更改并提交而已)
} && \
LnxRpBrchCur=$(git --git-dir=$LnxRpGitD branch --show-current) && \
#{重置git仓库
git --git-dir=$LnxRpGitD --work-tree=$LinuxRepoD  reset --hard && \
git --git-dir=$LnxRpGitD --work-tree=$LinuxRepoD  clean -df && \
git --git-dir=$LnxRpGitD --work-tree=$LinuxRepoD  checkout -- && \
#重置git仓库}
#{拉取远程分支
{ git branch -a --list "my_origin/$LnxRpBrch" || \
  { git --git-dir=$LnxRpGitD config pull.rebase false && \
  git --git-dir=$LnxRpGitD pull my_origin $LnxRpBrch:$LnxRpBrch ;}
} && \
#拉取远程分支}
{ [ "X$LnxRpBrchCur" == "X$LnxRpBrch" ]  || \
# 切换到给定分支
  git --git-dir=$LnxRpGitD --work-tree=$LinuxRepoD checkout -B $LnxRpBrch my_origin/$LnxRpBrch
#git checkout -B 覆盖已经存在的本地分支
# -b <branch>           create and checkout a new branch
# -B <branch>           create/reset and checkout a branch
} && \
{
# 记录 当前所用Linux仓库的 分支和commitId
 _RM=/crk/bochs/linux4-run_at_bochs/readme.md && \
 _S1="Linux_Run_At_Bochs对linux-stable分支:" && \
 sed -i "s/^$_S1.*/$_S1 $LnxRpBrchCur , $LnxRpCmtIdCur/" $_RM && \
 cd $LinuxRepoD 
} && \

#并行编译 job数 为 核心数 * 0.7
used_core_n=$(( $(nproc)  * 7 / 10 )) && \
job_n=$(( used_core_n > 1 ? used_core_n: 1 )) && \

{ { [ "X$multi_build" == "X" ] && multi_build=false ;} || : ;} && \
#multi_build默认为false
# 当不指定multi_build时, multi_build取false
{ $multi_build || job_n=1 ;} && \
#默认单进程编译
# multi_build为false，则单进程编译
{ { [ $job_n == 1 ] && echo "单进程编译" ;} || echo "多进程编译：（${job_n}进程编译）";} && \

set -x && \
MakeLogF=/crk/make.log && \
mvFile_AppendCurAbsTime $MakeLogF && \
make mrproper && \
make clean && \
#menuconfig 替换为 : 默认配置defconfig 、 命令改配置 './scripts/config  --file .config' 
# make ARCH=i386 CC=clang menuconfig && \
make ARCH=i386 CC=clang defconfig && \
cp -v .config ~/linux-stable-default-config && \
#等同于 "禁用I915 (Intel 8xx 9xx G3x G4x HD Graphics) Drivers.png": menuconfig 路径 为 'Device Drivers' --> 'Graphics support' --> 不勾选 'Intel 8xx/9xx/G3x/G4x/HD Graphics'
./scripts/config --file .config     --disable CONFIG_DRM_I915   && \
#以多进程编译测试函数id生成服务
{ make ARCH=i386 CC=clang -j $job_n V=1 2>&1 | tee -a $MakeLogF ;} && \
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
