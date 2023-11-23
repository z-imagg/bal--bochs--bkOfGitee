**正常编译 linux-2.6.39.4.tar.gz 在 "宿主机x64 ubuntu23.04 中的 docker实例 i386/ubuntu14.04.6LTS : 注意docker实例中依然是x64环境 并非i386环境" 下 **


#0. 编译环境
```shell
sudo docker pull ubuntu:14.04.6
sudo docker start .... 
sudo docker exec -it ubuntu-1404-i386-a bash
#打开docker版ubuntu14.04.6的bash
```

> 以下命令都是在docker版ubuntu14.04.6的bash下执行的

```shell
cat /etc/issue
#Ubuntu 14.04.6 LTS \n \l

uname -a
#Linux xx 4.15.0-142-generic #146~16.04.1-Ubuntu SMP Tue Apr 13 09:26:57 UTC 2021 i686 i686 i686 GNU/Linux

```

#1. 下载内核源码包并验证签名

```shell

wget https://mirrors.cloud.tencent.com/linux-kernel/v2.6/linux-2.6.39.4.tar.gz
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v2.6/sha256sums.asc

grep  linux-2.6.39.4.tar.gz  sha256sums.asc | sha256sum --check  -
# linux-2.6.39.4.tar.gz: 成功

```


> 有上面的sha256验证应该足够了。
> gpg 签名验证 总是报 缺少公钥(报错如下), 放弃了. 
```shell
    # gzip -d linux-2.6.39.4.tar.gz
    # sudo apt install pgpgpg
    # gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys  517D0F0E
    # wget https://mirrors.cloud.tencent.com/linux-kernel/v2.6/linux-2.6.39.4.tar.sign
    # gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 6092693E
    # gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 517D0F0E
    # gpg --verify linux-2.6.39.4.tar.sign
    # # gpg: 假定被签名的数据在‘linux-2.6.39.4.tar’
    # # gpg: 签名建立于 2013年08月09日 星期五 03时42分00秒 CST
    # # gpg:                使用 RSA 密钥 0D3B3537C4790F9D
    # # gpg: 无法检查签名：缺少公钥  :  gpg 签名验证 总是报 缺少公钥	
```

#2. linux2.6内核编译过程

```
tar -zxvf linux-2.6.39.4.tar.gz
cd linux-2.6.39.4

make menuconfig
# Exit ---> 保存

make

make all

make bzImage

make vmlinux

#正常编译
```

>指定ARCH
```
make ARCH=i386 menuconfig   
make ARCH=i386      

```


#E. 各种报错解决

##E1. make时报错 cc1: error: code model kernel does not support PIC mode

```shell
grep -Hn  KBUILD_CFLAGS `pwd`/Makefile 
# linux-2.6.39.4/Makefile:358:KBUILD_CFLAGS   := -fno-pie ... 
```
### 报错解决:
> ```-fno-pie``` 是手工添加的, 否则 make 时 报错: ```cc1: error: code model kernel does not support PIC mode```

## E2. make menuconfig时报错: Install ncurses (ncurses-devel) and try again.

> ``` make menuconfig``` 报错如下:

```text
  HOSTCC  scripts/basic/fixdep
  HOSTCC  scripts/basic/docproc
  HOSTCC  scripts/kconfig/conf.o
  HOSTCC  scripts/kconfig/kxgettext.o
 *** Unable to find the ncurses libraries or the
 *** required header files.
 *** 'make menuconfig' requires the ncurses libraries.
 *** 
 *** Install ncurses (ncurses-devel) and try again.
 *** 
/crk/bochs/linux2.6-run_at_bochs/linux-2.6.39.4/scripts/kconfig/Makefile:208: recipe for target 'scripts/kconfig/dochecklxdialog' failed
make[1]: *** [scripts/kconfig/dochecklxdialog] Error 1
Makefile:476: recipe for target 'menuconfig' failed
make: *** [menuconfig] Error 2
```
### 报错解决: ```sudo apt install libncurses5-dev```

## E3. make时报错 include/linux/compiler-gcc.h:90:30: fatal error: linux/compiler-gcc5.h: No such file or directory
### 报错解决: linux kernel 2.6 不能使用gcc5编译 应该使用gcc4.9编译.

#### 原本的gcc5、g++5
```shell
gcc --version
#gcc (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609
#Copyright (C) 2015 Free Software Foundation, Inc.
#This is free software; see the source for copying conditions.  There is NO
#warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

g++ --version
#g++ (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609
#Copyright (C) 2015 Free Software Foundation, Inc.
#This is free software; see the source for copying conditions.  There is NO
#warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


```

#### 安装gcc4.9
##### 添加仓库
```shell
sudo add-apt-repository ppa:ubuntu-toolchain-r/test

sudo apt-get update

```

##### 安装gcc-4.9 g++-4.9
```

sudo apt-get install -y gcc-4.9
sudo apt-get install -y g++-4.9

```

##### 切换到gcc-4.9 g++-4.9


###### debian系 update-alternatives管理命令 用法
- 查看全部 ```sudo update-alternatives --all```
- 查看 ```sudo update-alternatives --config cc```
- 安装 
```sudo update-alternatives --install /usr/bin/gcc cc /usr/bin/gcc-5 100```
```sudo update-alternatives --install /usr/bin/gcc cc /usr/bin/gcc-4.9 99```
- 删除
```sudo update-alternatives --remove cc /usr/bin/gcc-4.9```
- 更改
```sudo update-alternatives --config cc```


###### 切换到gcc4.9  g++-4.9 

####### 切换到gcc4.9
```shell
#查看全部
sudo update-alternatives --all

#查看
sudo update-alternatives --config cc

#删除
sudo update-alternatives --remove cc /usr/bin/gcc-4.9
sudo update-alternatives --remove cc /usr/bin/gcc-5

#安装
sudo update-alternatives --install /usr/bin/gcc cc /usr/bin/gcc-4.9 100
sudo update-alternatives --install /usr/bin/gcc cc /usr/bin/gcc-5 99
#优先级 : 100比99 更优先

```

> 实测: 已切换到 gcc-4.9 
```shell
gcc --version
#gcc (Ubuntu 4.9.4-2ubuntu1~16.04) 4.9.4

```


####### 切换到g++4.9
```shell
#查看全部
sudo update-alternatives --all

#查看
sudo update-alternatives --config c++

#删除
sudo update-alternatives --remove c++ /usr/bin/g++-4.9
sudo update-alternatives --remove c++ /usr/bin/g++-5

#安装
sudo update-alternatives --install /usr/bin/g++ c++ /usr/bin/g++-4.9 100
sudo update-alternatives --install /usr/bin/g++ c++ /usr/bin/g++-5 99
#优先级 : 100比99 更优先

```

> 实测: 已切换到 g++-4.9
```shell
g++ --version
#g++ (Ubuntu 4.9.4-2ubuntu1~16.04) 4.9.4

```


## E4. make时报错:arch/x86/kernel/ptrace.c:1366:17: error: conflicting types for ‘syscall_trace_enter’
```text
  CC      arch/x86/kernel/ptrace.o
arch/x86/kernel/ptrace.c:1366:17: error: conflicting types for ‘syscall_trace_enter’
 asmregparm long syscall_trace_enter(struct pt_regs *regs)
                 ^
In file included from /crk/bochs/linux2.6-run_at_bochs/linux-2.6.39.4/arch/x86/include/asm/vm86.h:130:0,
                 from /crk/bochs/linux2.6-run_at_bochs/linux-2.6.39.4/arch/x86/include/asm/processor.h:10,
                 from /crk/bochs/linux2.6-run_at_bochs/linux-2.6.39.4/arch/x86/include/asm/thread_info.h:22,
                 from include/linux/thread_info.h:53,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/seqlock.h:29,
                 from include/linux/time.h:8,
                 from include/linux/timex.h:56,
                 from include/linux/sched.h:57,
                 from arch/x86/kernel/ptrace.c:8:
/crk/bochs/linux2.6-run_at_bochs/linux-2.6.39.4/arch/x86/include/asm/ptrace.h:146:13: note: previous declaration of ‘syscall_trace_enter’ was here
 extern long syscall_trace_enter(struct pt_regs *);
             ^
arch/x86/kernel/ptrace.c:1411:17: error: conflicting types for ‘syscall_trace_leave’
 asmregparm void syscall_trace_leave(struct pt_regs *regs)
                 ^
In file included from /crk/bochs/linux2.6-run_at_bochs/linux-2.6.39.4/arch/x86/include/asm/vm86.h:130:0,
                 from /crk/bochs/linux2.6-run_at_bochs/linux-2.6.39.4/arch/x86/include/asm/processor.h:10,
                 from /crk/bochs/linux2.6-run_at_bochs/linux-2.6.39.4/arch/x86/include/asm/thread_info.h:22,
                 from include/linux/thread_info.h:53,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/seqlock.h:29,
                 from include/linux/time.h:8,
                 from include/linux/timex.h:56,
                 from include/linux/sched.h:57,
                 from arch/x86/kernel/ptrace.c:8:
/crk/bochs/linux2.6-run_at_bochs/linux-2.6.39.4/arch/x86/include/asm/ptrace.h:147:13: note: previous declaration of ‘syscall_trace_leave’ was here
 extern void syscall_trace_leave(struct pt_regs *);
             ^
scripts/Makefile.build:283: recipe for target 'arch/x86/kernel/ptrace.o' failed
make[2]: *** [arch/x86/kernel/ptrace.o] Error 1
scripts/Makefile.build:419: recipe for target 'arch/x86/kernel' failed
make[1]: *** [arch/x86/kernel] Error 2
Makefile:919: recipe for target 'arch/x86' failed
make: *** [arch/x86] Error 2

```

### 解决方法： 放弃真机ubuntu16.04 ，而改用docker下的ubuntu14.04
> 因为 ubuntu16.04自带gcc-5, 
> 而   ubuntu14.04自带gcc-4.8
