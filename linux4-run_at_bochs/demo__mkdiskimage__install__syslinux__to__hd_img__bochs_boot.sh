#!/usr/bin/bash

#mkdiskimage制作磁盘映像文件hd.img,安装syslinux到磁盘映像文件，bochs正常启动到syslinux

#0. 环境: 操作系统、CPU
cat /etc/issue && \
# Ubuntu 22.04.3 LTS \n \l
uname -a && \
#Linux x 6.2.0-37-generic #38~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Thu Nov  2 18:01:13 UTC 2 x86_64 x86_64 x86_64 GNU/Linux

#1. mkdiskimage制作磁盘映像文件hd.img
rm -fv hd.img && \
Part1stByteIdx=$(mkdiskimage -F -o hd.img 200 16 32) && \
[ $Part1stByteIdx == $((32*512)) ] && \
# Part1stByteIdx == 16384 == 0X4000 == 32个扇区
xxd -seek  +0X1C3 -len 3 -plain hd.img && \
#2. 安装syslinux到磁盘映像文件
{ rm -frv hd_img_dir ; mkdir hd_img_dir ;} && \
sudo mount -o loop,offset=$Part1stByteIdx hd.img hd_img_dir && \
# 上一行mount做了: hd.img --> /dev/lopX  --> 文件夹hd_img_dir， 命令 sudo losetup  -a | grep hd.img 可显示/dev/lopX
# {显示信息,非必须
# 找出lopX
lopX=$(sudo losetup  -a | grep hd.img | cut -d: -f1) && \
# 显示lopX
lsblk $lopX1 && \
# 显示信息}
sudo mkdir -p  hd_img_dir/boot/syslinux/ && \
#卸载 hd.img 会同时卸载 链条 "hd.img --> /dev/lopX  --> 文件夹hd_img_dir" 后面的全部节点
sudo umount hd.img && \
#而 卸载 文件夹hd_img_dir, 不会卸载 该链条之前的节点, 即 依然残存部分链条"hd.img --> /dev/lopX"
syslinux --directory /boot/syslinux/ --offset $Part1stByteIdx --install hd.img && \




#3. bochs正常启动到syslinux

sudo cat << 'EOF' |  tee  bochs.bxrc
megs: 48

romimage: file=/crk/bochs/bochs/bios/BIOS-bochs-latest
vgaromimage: file=/crk/bochs/bochs/bios/VGABIOS-lgpl-latest

ata0-master: type=disk, path="hd.img", cylinders=200, heads=16, spt=32
boot: c
log: bochsout_demo.txt
mouse: enabled=0
cpu: ips=15000000
clock: sync=both
EOF

/crk/bochs/bochs/bochs -f bochs.bxrc
#bochs能正常启动直到syslinux
