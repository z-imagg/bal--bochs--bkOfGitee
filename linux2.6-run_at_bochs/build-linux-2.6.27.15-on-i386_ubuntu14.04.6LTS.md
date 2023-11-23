**正常编译 linux-2.6.27.15.tar.gz 在 "真机 i386/ubuntu14.04.6LTS **


#0. 编译环境

```shell
cat /etc/issue
#Ubuntu 14.04.6 LTS \n \l

uname -a
#Linux x 4.4.0-142-generic #168~14.04.1-Ubuntu SMP Sat Jan 19 11:28:33 UTC 2019 i686 i686 i686 GNU/Linux


gcc --version
#gcc (Ubuntu/Linaro 4.4.7-8ubuntu1) 4.4.7


```

#1. 下载内核源码包并验证签名

```shell

wget https://mirrors.cloud.tencent.com/linux-kernel/v2.6/linux-2.6.27.15.tar.gz
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v2.6/sha256sums.asc

grep  linux-2.6.27.15.tar.gz  sha256sums.asc | sha256sum --check  -
# linux-2.6.27.15.tar.gz: OK


```




#2. linux2.6内核编译过程

```
tar -zxvf linux-2.6.27.15.tar.gz
cd linux-2.6.27.15

make menuconfig
# Exit ---> 保存

make -V=1

#正常编译
```

#3. 编译产物中的ELF

```
#pwd==/crk/bochs/linux2.6-run_at_bochs/linux-2.6.27.15
find . -not -name "*.o"  -and -not -name "*.h" -and -not -name "*.c" -and -not -name "*.ko" -and -not -name "*.so" -and -not -name "*.dbg"  -exec file {} \; | grep "ELF 32-bit LSB"
```

```
./arch/x86/kernel/acpi/realmode/wakeup.elf: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), statically linked, not stripped
./arch/x86/boot/setup.elf: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), statically linked, not stripped
./arch/x86/boot/tools/build: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=e9a432bc6b360a346e933c76cf1d0e0e9ea10cca, not stripped
./arch/x86/boot/mkcpustr: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=c03153d63a2a1b7d0bde950fdabea8e4c2795b15, not stripped
./arch/x86/boot/compressed/vmlinux: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), statically linked, not stripped
./arch/x86/boot/compressed/vmlinux.bin: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), statically linked, BuildID[sha1]=ad17ec6d43fb47c804a50f12afb97a2a5c897345, stripped
./lib/gen_crc32table: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=50c271e39a66d3825201a212f232473a6e7e93e9, not stripped
./drivers/md/mktables: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=2188f3b74fdc36a166e3dfa7b72837e0f79d398e, not stripped
./vmlinux: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), statically linked, BuildID[sha1]=ad17ec6d43fb47c804a50f12afb97a2a5c897345, not stripped
./.tmp_vmlinux2: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), statically linked, BuildID[sha1]=3bb004f74d2e24079f22dd495ca79466106cfb0d, not stripped
./usr/gen_init_cpio: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=94e9d6158eda74fafbb333d67aab02cea290278f, not stripped
./.tmp_vmlinux1: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), statically linked, BuildID[sha1]=59c5f92cab26152f6336558bb9a08be8ef12fe93, not stripped
./scripts/conmakehash: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=b972b1fdedca84f5aec059f2181cc3365537b109, not stripped
./scripts/kallsyms: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=86c30be94c57ecfd6eb317744822a365ba0aa56f, not stripped
./scripts/mod/modpost: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=6c132e1f5126bf6b24c5354ff2d4c8b0742e1b77, not stripped
./scripts/mod/mk_elfconfig: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=4afb84c771b86acd48381a482a97561528637f21, not stripped
./scripts/genksyms/genksyms: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=6d7bb0091b6365e55e8889e6d65a617dba96bdb0, not stripped
./scripts/basic/docproc: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=3cf06b3f4268761a4e206ab7d544d569663fe782, not stripped
./scripts/basic/fixdep: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=e2c9f7116aca8b6190303c6f634bc6a9f8770aeb, not stripped
./scripts/kconfig/conf: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=6b9ed4d28f7726c63d5994424d43839e73de5e0b, not stripped
./scripts/kconfig/mconf: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=3de3969885126cbbe70bb26b18fda60b1875a10e, not stripped
./firmware/ihex2fw: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=48e7e7912c8dc6c4cb486ad79943f7e2bd8c8f36, not stripped

```



#解决报错

## E1

>命令 ```gcc -nostdlib -o arch/x86/vdso/vdso32-int80.so.dbg -fPIC -shared  -Wl,--hash-style=sysv -m elf_i386 -Wl,-soname=linux-gate.so.1 -Wl,-T,arch/x86/vdso/vdso32/vdso32.lds arch/x86/vdso/vdso32/note.o arch/x86/vdso/vdso32/int80.o``` 
> 报错:
```text
gcc: error: elf_i386: No such file or directory
gcc: error: unrecognized command line option ‘-m’
```
> 原因: gcc 4.6不再支持linker-style架构（我使用的是gcc 4.8.4）。
> 解决: 替换 "-m elf_i386" 为 "-m32": ```sed -i  "s/-m elf_i386/-m32/" arch/x86/vdso/Makefile```




## E2

> ```make -V=1```, 报错如下:

```
gcc -Wp,-MD,arch/x86/kvm/.svm.o.d  -nostdinc -isystem /usr/lib/gcc/i686-linux-gnu/4.8/include -D__KERNEL__ -Iinclude  -I/crk/bochs/linux2.6-run_at_bochs/linux-2.6.27.15/arch/x86/include -include include/linux/autoconf.h -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -O2 -m32 -msoft-float -mregparm=3 -freg-struct-return -mpreferred-stack-boundary=2 -march=i686 -mtune=generic -ffreestanding -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -Iinclude/asm-x86/mach-default -Wframe-larger-than=1024 -fno-stack-protector -fno-omit-frame-pointer -fno-optimize-sibling-calls -g -pg -Wdeclaration-after-statement -Wno-pointer-sign -Ivirt/kvm -Iarch/x86/kvm -DMODULE -D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(svm)"  -D"KBUILD_MODNAME=KBUILD_STR(kvm_amd)" -c -o arch/x86/kvm/.tmp_svm.o arch/x86/kvm/svm.c
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
include/linux/kvm.h:240:9: error: duplicate member ‘padding’
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

```

> 解决方案: 现在用的是gcc4.8, 换成gcc4.4

1. 卸载gcc-4.8, 安装gcc-4.4
```shell
sudo apt remove gcc-4.8 g++-4.8 gcc g++
sudo apt install gcc-4.4 g++-4.4
sudo ln -s /usr/bin/gcc-4.8 /usr/bin/gcc
sudo ln -s /usr/bin/g++-4.8 /usr/bin/g++
```
2. 重新编译
