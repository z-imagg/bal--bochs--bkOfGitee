#ubuntu 22 x64
sudo apt install -y gcc-11-i686-linux-gnu gcc-i686-linux-gnu
sudo apt install -y gcc-multilib-i686-linux-gnu
# sudo apt-get install -y gcc-multilib g++-multilib

rm -fr linux-4.14.259.tar.gz linux-4.14.259
wget https://mirrors.cloud.tencent.com/linux-kernel/v4.x/linux-4.14.259.tar.gz
tar -zxf linux-4.14.259.tar.gz
cd linux-4.14.259

#
make ARCH=i386 CROSS_COMPILE=i686-linux-gnu- defconfig
make ARCH=i386 CROSS_COMPILE=i686-linux-gnu- menuconfig
make ARCH=i386 CROSS_COMPILE=i686-linux-gnu- V=1 | tee -a make.log


find . -name "*bzImage*"
# ./arch/x86/boot/bzImage
# ./arch/x86/boot/.bzImage.cmd
# ./arch/i386/boot/bzImage
ls -lh arch/x86/boot/bzImage
# -rw-rw-r-- 1   6.8M  arch/x86/boot/bzImage
 file arch/x86/boot/bzImage
# arch/x86/boot/bzImage: Linux kernel x86 boot executable bzImage, version 4.14.259 (z@x) #1 SMP Tue Dec 5 19:10:09 CST 2023, RO-rootFS, swap_dev 0X6, Normal VGA

