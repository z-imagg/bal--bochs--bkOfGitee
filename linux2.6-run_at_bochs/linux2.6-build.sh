
wget https://mirrors.cloud.tencent.com/linux-kernel/v2.6/linux-2.6.39.4.tar.gz
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v2.6/sha256sums.asc

grep  linux-2.6.39.4.tar.gz  sha256sums.asc | sha256sum --check  -
# linux-2.6.39.4.tar.gz: 成功


#gpg 签名验证 总是报 缺少公钥, 放弃了. 有上面的sha256验证应该足够了。
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
    # # gpg: 无法检查签名：缺少公钥


tar -zxvf linux-2.6.39.4.tar.gz
cd linux-2.6.39.4

make menuconfig
# Exit ---> 保存

grep -Hn  KBUILD_CFLAGS `pwd`/Makefile 
# linux-2.6.39.4/Makefile:358:KBUILD_CFLAGS   := -fno-pie ... #-fno-pie是手工添加的, 否则 make 时 报错:
#     cc1: error: code model kernel does not support PIC mode
