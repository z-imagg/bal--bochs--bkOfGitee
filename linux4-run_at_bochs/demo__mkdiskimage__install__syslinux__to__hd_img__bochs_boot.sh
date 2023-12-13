#!/usr/bin/bash

#mkdiskimage制作磁盘映像文件hd.img,安装syslinux到磁盘映像文件，bochs正常启动到syslinux

#0. 环境: 操作系统、CPU
cat /etc/issue && \
# Ubuntu 22.04.3 LTS \n \l
uname -a && \
#Linux x 6.2.0-37-generic #38~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Thu Nov  2 18:01:13 UTC 2 x86_64 x86_64 x86_64 GNU/Linux

#磁盘CHS几何参数
Cylinders=200 && Heads=16 && SectorsPerTrack=32 && \
#1. mkdiskimage制作磁盘映像文件hd.img
rm -fv hd.img && \
Part1stByteIdx=$(mkdiskimage -F -o hd.img $Cylinders $Heads $SectorsPerTrack) && \
[ $Part1stByteIdx == $((SectorsPerTrack*512)) ] && \
# Part1stByteIdx == 16384 == 0X4000 == 32个扇区 == SectorsPerTrack个扇区 == 1个Track
xxd -seek  +0X1C3 -len 3 -plain hd.img && \
#2. 安装syslinux到磁盘映像文件
{ rm -frv hd_img_dir ; mkdir hd_img_dir ;} && \
lopXOffset=$(sudo losetup --offset $Part1stByteIdx --partscan  --find --show  hd.img)  && sudo mount $lopXOffset hd_img_dir && \
lsblk $lopXOffset && \
# NAME      MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
# loop5       7:5    0  50M  0 loop /crk/bochs/linux4-run_at_bochs/hd_img_dir
# └─loop5p1 259:0    0  50M  0 part
sudo mkdir -p  hd_img_dir/boot/syslinux/ && \
# 下一行命令即 : sudo syslinux --directory /boot/syslinux/   --install /dev/loop5 && \
sudo syslinux --directory /boot/syslinux/   --install $lopXOffset && \
# 已经知道 正常运行形式: 'syslinux 指定偏移量 hd.img'.  
# 那么理论上  'syslinux 挂载时已指定偏移loop设备'(即第28行) 也应该能正常运行，但 实际上 第28行 syslinux 报错如下:
# Could not get geometry of device (Inappropriate ioctl for device)
# Could not get geometry of device (Inappropriate ioctl for device)
# Could not get geometry of device (Inappropriate ioctl for device)
# Could not get geometry of device (Inappropriate ioctl for device)
# Could not get geometry of device (Inappropriate ioctl for device)
# Could not get geometry of device (Inappropriate ioctl for device)
sudo umount hd_img_dir &&  sudo losetup --detach $lopXOffset && \
#而 卸载 文件夹hd_img_dir, 不会卸载 该链条之前的节点, 即 依然残存部分链条"hd.img --> /dev/lopX"




#3. bochs正常启动到syslinux

sudo cat << 'EOF' |  tee  bochs.bxrc
megs: 48

romimage: file=/crk/bochs/bochs/bios/BIOS-bochs-latest
vgaromimage: file=/crk/bochs/bochs/bios/VGABIOS-lgpl-latest

ata0-master: type=disk, path="hd.img", cylinders=_cylinders_, heads=_heads_, spt=_spt_
boot: c
log: bochsout.txt
mouse: enabled=0
cpu: ips=15000000
clock: sync=both
EOF

sed -i  -e "s/_cylinders_/$Cylinders/g"  -e "s/_heads_/$Heads/g" -e "s/_spt_/$SectorsPerTrack/g" bochs.bxrc


/crk/bochs/bochs/bochs -f bochs.bxrc
#bochs能正常启动直到syslinux
