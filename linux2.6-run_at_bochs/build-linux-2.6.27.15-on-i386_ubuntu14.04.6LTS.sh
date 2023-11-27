#正常编译 linux-2.6.27.15.tar.gz 在 "真机 i386/ubuntu14.04.6LTS"

#升级git到2.x版本
#  ubuntu14.04 自带git版本为1.9, lazygit目前主流版本最低支持git2.0, 因此要升级git版本

{ curGitVer=`git --version` && \
[[ "$curGitVer" > "git version 2._" ]] && \
#ascii码表中 '0'>'_' 从而决定了 :  "git version 2.0" > "git version 2._"
echo "git版本无需升级,已为2.x:$curGitVer" ; } || \
{ echo "git版本($curGitVer)过低,现在升级git" && \
sudo add-apt-repository --yes ppa:git-core/ppa && \
sudo apt-get update 1>/dev/null && \
 { sudo apt-cache show  git | grep Version ; } && \
#Version: 1:2.29.0-0ppa1~ubuntu14.04.1
sudo apt-get install -y git && \
git --version && \
#git version 2.29.0
sudo add-apt-repository --yes --remove ppa:git-core/ppa && \
curGitVer=`git --version` && \
echo "git版本升级完成,已升级到版本($curGitVer)" ; }



#报错解决/Error2

echo 'make -V=1, 报错如下:

命令 gcc -Wp,-MD,arch/x86/kvm/.svm.o.d  -nostdinc -isystem /usr/lib/gcc/i686-linux-gnu/4.8/include -D__KERNEL__ -Iinclude  -I/crk/bochs/linux2.6-run_at_bochs/linux-2.6.27.15/arch/x86/include -include include/linux/autoconf.h -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -O2 -m32 -msoft-float -mregparm=3 -freg-struct-return -mpreferred-stack-boundary=2 -march=i686 -mtune=generic -ffreestanding -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -Iinclude/asm-x86/mach-default -Wframe-larger-than=1024 -fno-stack-protector -fno-omit-frame-pointer -fno-optimize-sibling-calls -g -pg -Wdeclaration-after-statement -Wno-pointer-sign -Ivirt/kvm -Iarch/x86/kvm -DMODULE -D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(svm)"  -D"KBUILD_MODNAME=KBUILD_STR(kvm_amd)" -c -o arch/x86/kvm/.tmp_svm.o arch/x86/kvm/svm.c
命令输出
In file included from include/asm/current.h:6:0,
                 from include/asm/processor.h:15,
                 from include/asm/thread_info.h:22,
                 from include/linux/thread_info.h:47,
                 from include/linux/preempt.h:9,
                 from include/linux/hardirq.h:4,
                 from include/linux/kvm_host.h:10,
                 from arch/x86/kvm/svm.c:16:
include/asm/irq_regs_32.h: In function ‘set_irq_regs’:
include/asm/percpu.h:118:7: warning: variable ‘tmp__’ set but not used [-Wunused-but-set-variable]
   T__ tmp__;    \
       ^
include/asm/percpu.h:166:36: note: in expansion of macro ‘percpu_to_op’
 #define x86_write_percpu(var, val) percpu_to_op("mov", per_cpu__##var, val)
                                    ^
include/asm/irq_regs_32.h:24:2: note: in expansion of macro ‘x86_write_percpu’
  x86_write_percpu(irq_regs, new_regs);
  ^
In file included from include/linux/kvm_host.h:21:0,
                 from arch/x86/kvm/svm.c:16:
include/linux/kvm.h: At top level:
命令输出中的报错: include/linux/kvm.h:240:9: error: duplicate member ‘padding’ 
   __u64 padding;
         ^
arch/x86/kvm/svm.c: In function ‘io_interception’:
arch/x86/kvm/svm.c:1097:30: warning: variable ‘rep’ set but not used [-Wunused-but-set-variable]
  int size, down, in, string, rep;
                              ^
arch/x86/kvm/svm.c:1097:12: warning: variable ‘down’ set but not used [-Wunused-but-set-variable]
  int size, down, in, string, rep;
            ^
make[1]: *** [arch/x86/kvm/svm.o] Error 1
make: *** [arch/x86/kvm] Error 2


 解决方案: 现在用的是gcc4.8, 换成gcc4.4
'

echo " 卸载gcc-4.8, 安装gcc-4.4"

sudo apt remove gcc-4.8 g++-4.8 gcc g++
sudo apt install gcc-4.4 g++-4.4
sudo ln -s /usr/bin/gcc-4.8 /usr/bin/gcc
sudo ln -s /usr/bin/g++-4.8 /usr/bin/g++



#0. 编译环境

cat /etc/issue
#Ubuntu 14.04.6 LTS \n \l

uname -a
#Linux x 4.4.0-142-generic #168~14.04.1-Ubuntu SMP Sat Jan 19 11:28:33 UTC 2019 i686 i686 i686 GNU/Linux


gcc --version
#gcc (Ubuntu/Linaro 4.4.7-8ubuntu1) 4.4.7


#1. 下载内核源码包并验证签名
kernelFUrl="https://mirrors.cloud.tencent.com/linux-kernel/v2.6/linux-2.6.27.15.tar.gz"
kernelSumFUrl=https://mirrors.edge.kernel.org/pub/linux/kernel/v2.6/sha256sums.asc
kernelF="linux-2.6.27.15.tar.gz"
kernelF_="linux-2.6.27.15"
kernelSumF="sha256sums.asc"

{ test -f $kernelF && test -f $kernelSumF && \
grep  $kernelF  $kernelSumF | sha256sum --check  - &&  \
echo "已经下载 : kernelFile=$kernelF,kernelSumF=$kernelSumF" ; } \
|| { wget $kernelFUrl --output-document  $kernelF && \
wget $kernelSumFUrl --output-document $kernelSumF &&  ; } 






#2. linux2.6内核编译过程

#2.1解压内核
tar -zxvf $kernelF
cd $kernelF_

#解决报错/Error1

echo '解决以下报错:
命令 gcc -nostdlib -o arch/x86/vdso/vdso32-int80.so.dbg -fPIC -shared  -Wl,--hash-style=sysv -m elf_i386 -Wl,-soname=linux-gate.so.1 -Wl,-T,arch/x86/vdso/vdso32/vdso32.lds arch/x86/vdso/vdso32/note.o arch/x86/vdso/vdso32/int80.o 
报错:
gcc: error: elf_i386: No such file or directory
gcc: error: unrecognized command line option ‘-m’
原因: gcc 4.6不再支持linker-style架构（我使用的是gcc 4.8.4）。
解决: 替换 "-m elf_i386" 为 "-m32": \'sed -i  "s/-m elf_i386/-m32/" arch/x86/vdso/Makefile\'

sed -i  "s/-m elf_i386/-m32/" arch/x86/vdso/Makefile





make menuconfig
# 人工选择: Exit ---> 保存。  
# 即 不做任何变动

#开始编译
make -V=1

#正常编译完成


#3. 编译产物中的ELF

#pwd==/crk/bochs/linux2.6-run_at_bochs/linux-2.6.27.15
find . -not -name "*.o"  -and -not -name "*.h" -and -not -name "*.c" -and -not -name "*.ko" -and -not -name "*.so" -and -not -name "*.dbg"  -exec file {} \; | grep "ELF 32-bit LSB"




