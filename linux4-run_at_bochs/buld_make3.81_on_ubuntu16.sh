

####只需要编译make3.81
wget https://ftp.gnu.org/gnu/make/make-3.81.tar.gz




./configure --prefix=/app/make3.81/  && make  && make install

export PATH=/app/make3.81/bin/:$PATH

which make
#/app/make3.81/bin/make


####
wget https://mirrors.cloud.tencent.com/linux-kernel/v2.6/linux-2.6.27.15.tar.gz
tar -zxf linux-2.6.27.15.tar.gz
cd linux-2.6.27.15
# find . -name Makefile | xargs -I% grep -Hn  "\-m " %
#find . -name Makefile | xargs -I% grep -Hn  "\-m elf_i386" %
#./arch/x86/vdso/Makefile:72:VDSO_LDFLAGS_vdso32.lds = -m elf_i386 -Wl,-soname=linux-gate.so.1
sed -i      's/-m elf_i386/-m32/g' arch/x86/vdso/Makefile

ARCH=i386 make menuconfig
ARCH=i386 make 



#make时报错 :  
# Can't use 'defined(@array)' (Maybe you should just omit the defined()?) at kernel/timeconst.pl line 373
#  perl -v == 5.22.1  , 因一个bug，该版本将defined(@array)去掉了，因此才有上一行perl语法报错
#    解决办法，用 相似版本的  perl 5.20.1-6 替换系统自带的 perl 5.22.1
wget http://launchpadlibrarian.net/206513931/perl-base_5.20.2-6_amd64.deb
dpkg -X perl-base_5.20.2-6_amd64.deb perl-base_5.20.2-6
export PATH=$(pwd)/perl-base_5.20.2-6/usr/bin/:$PATH


# include/linux/kvm.h:240:9: error: duplicate member ‘padding’
# 报错来源:
# make -f scripts/Makefile.build obj=arch/x86/kvm
#  gcc -Wp,-MD,arch/x86/kvm/.svm.o.d  -nostdinc -isystem /usr/lib/gcc/x86_64-linux-gnu/5/include -D__KERNEL__ -Iinclude  -I/home/z/linux-2.6.27.15/arch/x86/include -include include/linux/autoconf.h -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -O2 -m32 -msoft-float -mregparm=3 -freg-struct-return -mpreferred-stack-boundary=2 -march=i686 -ffreestanding -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -Iinclude/asm-x86/mach-default -Wframe-larger-than=1024 -fno-stack-protector -fno-omit-frame-pointer -fno-optimize-sibling-calls -g -pg -Wdeclaration-after-statement -Wno-pointer-sign -Ivirt/kvm -Iarch/x86/kvm -DMODULE -D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(svm)"  -D"KBUILD_MODNAME=KBUILD_STR(kvm_amd)" -c -o arch/x86/kvm/svm.o arch/x86/kvm/svm.c