**正常编译 linux-2.6.27.15.tar.gz 在 "真机 i386/ubuntu14.04.6LTS **


#0. 编译环境

```shell
cat /etc/issue
#Ubuntu 14.04.6 LTS \n \l

uname -a
#Linux x 4.4.0-142-generic #168~14.04.1-Ubuntu SMP Sat Jan 19 11:28:33 UTC 2019 i686 i686 i686 GNU/Linux


gcc --version
#gcc (Ubuntu 4.8.4-2ubuntu1~14.04.4) 4.8.4

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

make -V

#正常编译
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




