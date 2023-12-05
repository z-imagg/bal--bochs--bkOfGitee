#ubuntu 22 x64
sudo apt install  gcc-11-i686-linux-gnu gcc-i686-linux-gnu
sudo apt install  gcc-multilib-i686-linux-gnu



wget https://mirrors.cloud.tencent.com/linux-kernel/v3.0/linux-3.0.1.tar.gz
tar -zxf linux-3.0.1.tar.gz
cd linux-3.0.1

#
sudo apt-get install gcc-multilib g++-multilib
make ARCH=i386 CROSS_COMPILE=i686-linux-gnu- defconfig
make ARCH=i386 CROSS_COMPILE=i686-linux-gnu- menuconfig
make ARCH=i386 CROSS_COMPILE=i686-linux-gnu- 



#make时 报错include/linux/compiler-gcc.h:94:1: fatal error: linux/compiler-gcc11.h: No such file or directory
#  解决:
mv  `pwd`/include/linux/compiler-gcc4.h `pwd`/include/linux/compiler-gcc11.h


#make时 继续报错, 准备换到 linux kernel 4试试
#/home/z/linux-3.0.1/arch/x86/include/asm/bug.h:17:9: error: impossible constraint in ‘asm’
   17 |         asm volatile("1:\tud2\n"                                \
