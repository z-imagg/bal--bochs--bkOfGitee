#0. 编译环境
```shell
cat /etc/issue
#Ubuntu 16.04.6 LTS \n \l

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
```


#E. 各种报错解决

##E1. make时报错 cc1: error: code model kernel does not support PIC mode

```shell
grep -Hn  KBUILD_CFLAGS `pwd`/Makefile 
# linux-2.6.39.4/Makefile:358:KBUILD_CFLAGS   := -fno-pie ... 
```
### 报错解决:
> ```-fno-pie``` 是手工添加的, 否则 make 时 报错: ```cc1: error: code model kernel does not support PIC mode```
```
## E2. make menuconfig时报错: Install ncurses (ncurses-devel) and try again.
> ```make menuconfig``` 报错如下:
```
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
### 报错解决: ```sudo apt install libncurses5```

