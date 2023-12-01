#正常编译 linux-2.6.27.15.tar.gz 在 "真机 i386/ubuntu14.04.6LTS"


CurScriptF=$0
source func.sh

#升级git到2.x版本
#  ubuntu14.04 自带git版本为1.9, lazygit目前主流版本最低支持git2.0, 因此要升级git版本

function _is_git_2x(){
which git && \
curGitVer=`git --version` && \
[[ "$curGitVer" > "git version 2._" ]]
#ascii码表中 '0'>'_' 从而决定了 :  "git version 2.0" > "git version 2._"
}

function _install_git_2x(){
echo "git版本($curGitVer)过低,现在升级git" && \
sudo add-apt-repository --yes ppa:git-core/ppa && \
sudo apt-get update 1>/dev/null && \
 { sudo apt-cache show  git | grep Version ; } && \
#Version: 1:2.29.0-0ppa1~ubuntu14.04.1
sudo apt-get install -y git && \
git --version && \
#git version 2.29.0
sudo add-apt-repository --yes --remove ppa:git-core/ppa && \
curGitVer=`git --version` && \
echo "git版本升级完成,已升级到版本($curGitVer)" ; 

}

ifelse  $CurScriptF $LINENO
  true || _is_git_2x && \
    true || "git版本无需升级,已为2.x:$curGitVer" && \
    true || : && \
  #else:
    true || _install_git_2x && \
      true || "" && \




#报错解决/Error2

#命令1 gcc -Wp,-MD,arch/x86/kvm/.svm.o.d  -nostdinc -isystem /usr/lib/gcc/i686-linux-gnu/4.8/include -D__KERNEL__ -Iinclude  -I/crk/bochs/linux2.6-run_at_bochs/linux-2.6.27.15/arch/x86/include -include include/linux/autoconf.h -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -O2 -m32 -msoft-float -mregparm=3 -freg-struct-return -mpreferred-stack-boundary=2 -march=i686 -mtune=generic -ffreestanding -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -Iinclude/asm-x86/mach-default -Wframe-larger-than=1024 -fno-stack-protector -fno-omit-frame-pointer -fno-optimize-sibling-calls -g -pg -Wdeclaration-after-statement -Wno-pointer-sign -Ivirt/kvm -Iarch/x86/kvm -DMODULE -D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(svm)"  -D"KBUILD_MODNAME=KBUILD_STR(kvm_amd)" -c -o arch/x86/kvm/.tmp_svm.o arch/x86/kvm/svm.c
echo '解决报错/Error2,如下:
make V=1, 报错如下:
命令1 gcc ... arch/x86/kvm/svm.c (完整命令在本脚本此行附近注释)
命令输出中的报错: include/linux/kvm.h:240:9: _error: duplicate member ‘padding’ 
   __u64 padding;
         ^
解决方案: 现在用的是gcc4.8, 换成gcc4.4
'

#替换[gcc|g++]-4.4为[gcc|g++]-4.8
findCmdByDebPkgName(){
# findCmdByDebPkgName gcc-4.8 gcc-4.8
# findCmdByDebPkgName g++-4.8 g++-4.8
# grep --perl-regexp --only-matching   ".*/bin.*/gcc-\d.\d" #草稿备忘
debPkgName=$1
cmdName=$2
[ "x" != "x$debPkgName" ] && [ "x" != "x$cmdName" ] && \
( dpkg -L $1 | xargs -I%  sh -c "  { [ -x % ] && [ -f %  ] &&  echo % ; }  " | grep    ".*/bin.*/$cmdName" )

}

function _is_gcc4_4(){
  #如果有gcc命令，才判断gcc版本.
which gcc && \
#如果是gcc4.4,则不做任何处理
gccVer=$(gcc --version 2>/dev/null | head -n 1  | sed 's/([^)]*)//g') && \
# gcc (Ubuntu 4.8.4-2ubuntu1~14.04.4) 4.8.4
# gcc  4.8.4
{ echo $gccVer | grep "4.4" ; }

}
function _install_gcc4_4() {
{ \
#否则 即不是gcc4.4，则卸载当前gcc 并安装gcc4.4
echo " 开始: 卸载gcc-*、g++-*, 安装gcc-4.4、g++-4.4" && \
dpkg -l | awk '/^ii/ {print $2}' | grep -E '^g\+\+-4\.[0-9]$|^gcc-4\.[0-9]$' | xargs -I% sudo apt remove -y  1>/dev/null %
#gcc-4.4
#gcc-4.8
#^ii 只要ii开头的; $2 只要第一列 即 包名列, 后面还有很多列都不要.
echo " 开始: 安装gcc-4.4、g++-4.4" && \
sudo apt install -y gcc-4.4 g++-4.4 1>/dev/null && \
{ \
 { [ -f /usr/bin/gcc ] && sudo mv /usr/bin/gcc /usr/bin/gcc.old ; \
   [ -f /usr/bin/g++ ] && sudo mv /usr/bin/g++ /usr/bin/g++.old ; } || \
 #这两行并非必须，若不存在 /usr/bin/gcc|g++ 这两行会执行失败，但后续命令应该继续. 因此下一行有个true,确保继续执行后续.
 true ;} && \
gcc_4_4_bin=$(findCmdByDebPkgName gcc-4.4 gcc-4.4) && \
gpp_4_4_bin=$(findCmdByDebPkgName g++-4.4 g++-4.4) && \
[  "x" != "x$gcc_4_4_bin" ] &&  sudo ln -s $gcc_4_4_bin /usr/bin/gcc && \
[  "x" != "x$gpp_4_4_bin" ] &&  sudo ln -s $gpp_4_4_bin /usr/bin/g++ && \
# sudo ln -s /usr/bin/gcc-4.4 /usr/bin/gcc && \
# sudo ln -s /usr/bin/g++-4.4 /usr/bin/g++ && \
echo " 完成: 安装gcc-4.4、g++-4.4" && \
which gcc ; \
}

}

ifelse  $CurScriptF $LINENO
  true || _is_gcc4_4 && \
    true || "正确,已经是gcc4.4" && \
    true || : && \
  #else:
    true || _install_gcc4_4 && \
      true ||  "" && \




#0. 编译环境

cat /etc/issue && \
#Ubuntu 14.04.6 LTS \n \l

uname -a && \
#Linux x 4.4.0-142-generic #168~14.04.1-Ubuntu SMP Sat Jan 19 11:28:33 UTC 2019 i686 i686 i686 GNU/Linux


gcc --version && \
#gcc (Ubuntu/Linaro 4.4.7-8ubuntu1) 4.4.7


#1. 下载内核源码包并验证签名
kernelFUrl="https://mirrors.cloud.tencent.com/linux-kernel/v2.6/linux-2.6.27.15.tar.gz" && \
kernelSumFUrl="https://mirrors.cloud.tencent.com/linux-kernel/v2.6/sha256sums.asc" && \
kernelF="linux-2.6.27.15.tar.gz" && \
kernelF_="linux-2.6.27.15" && \
kernelSumF="sha256sums.asc" && \

function _is_kernel_ok(){
test -f $kernelF && test -f $kernelSumF && \
grep  $kernelF  $kernelSumF | sha256sum --check  -
}

function _download_kernel(){
echo "文件$kernelF不存在或校验和不正确，重新下载" && \
wget $kernelFUrl --output-document  $kernelF && \
wget $kernelSumFUrl --output-document $kernelSumF 
}
ifelse  $CurScriptF $LINENO
  true || _is_kernel_ok && \
    true || "正确,无需下载,使用已有文件 : kernelFile=$kernelF,kernelSumF=$kernelSumF" && \
    true || : && \
  #else:
    true || _download_kernel && \
      true || "kernel下载完成" && \




#2. linux2.6内核编译过程

#2.1解压内核
rm -fr $kernelF_ && \
tar -zxf $kernelF && \
cd $kernelF_ && \

#解决报错/Error1

# 命令2 gcc -nostdlib -o arch/x86/vdso/vdso32-int80.so.dbg -fPIC -shared  -Wl,--hash-style=sysv -m elf_i386 -Wl,-soname=linux-gate.so.1 -Wl,-T,arch/x86/vdso/vdso32/vdso32.lds arch/x86/vdso/vdso32/note.o arch/x86/vdso/vdso32/int80.o   (完整命令在本脚本此行附近注释)

echo '解决报错/Error1,如下:
命令2 gcc  -o .../vdso32-int80.so.dbg   (完整命令在本脚本此行附近注释)
报错:
gcc: _error: elf_i386: _No such file or directory
gcc: _error: unrecognized command line option ‘-m’
原因: gcc 4.6不再支持linker-style架构（我使用的是gcc 4.8.4）。
解决: 替换 "-m elf_i386" 为 "-m32": “sed -i  "s/-m elf_i386/-m32/" arch/x86/vdso/Makefile”  '  && \

sed -i  "s/-m elf_i386/-m32/" arch/x86/vdso/Makefile && \





make menuconfig && \
# 人工选择: Exit ---> 保存。  
# 即 不做任何变动

#开始编译
jobCnt=$(( $(nproc)  -1 )) && jobCnt=$(( $jobCnt > 0 ? $jobCnt : 1 )) \
#用 cpu核心数-1个  核 编译
make V=1 -j $jobCnt && \

#正常编译完成


#3. 编译产物中的ELF

#pwd==/crk/bochs/linux2.6-run_at_bochs/linux-2.6.27.15
{ find . -not -name "*.o"  -and -not -name "*.h" -and -not -name "*.c" -and -not -name "*.ko" -and -not -name "*.so" -and -not -name "*.dbg"  -exec file {} \; | grep "ELF 32-bit LSB" ; } && \




_end=true