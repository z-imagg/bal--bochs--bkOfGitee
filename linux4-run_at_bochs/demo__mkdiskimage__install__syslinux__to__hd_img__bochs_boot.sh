#!/usr/bin/bash

#mkdiskimage制作磁盘映像文件hd.img,安装syslinux到磁盘映像文件，bochs正常启动到syslinux

#0. 环境: 操作系统、CPU
cat /etc/issue && \
# Ubuntu 22.04.3 LTS \n \l
uname -a && \
#Linux x 6.2.0-37-generic #38~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Thu Nov  2 18:01:13 UTC 2 x86_64 x86_64 x86_64 GNU/Linux

alias _hdImg_list_loopX="sudo losetup   --raw   --associated  hd.img | cut -d: -f1" && \
alias _hdImg_detach_all_loopX="_hdImg_list_loopX |   xargs -I%  sudo losetup --detach %" && \

err_exitCode_multi_loopX=41 && \
err_msg_multi_loopX_gen=' echo "必须只能有一个回环设备指向hd.img,但此时有多个:【${loopX}】, 可以用命令 'sudo losetup   --raw   --associated  hd.img'自行验证, 退出码 【${err_exitCode_multi_loopX}】 " ' && \

#磁盘CHS几何参数
#C:Cylinders, Heads:H, SectsPerTrk:SectorsPerTrack:S
Cylinders=200 && Heads=16 && SectsPerTrk=32 && \

#0. 清理、还原
_hdImg_detach_all_loopX && \
rm -fv hd.img && \

#1. mkdiskimage制作磁盘映像文件hd.img
#  Part1stBOfst : Partition First Byte Offset : 分区的第一个字节偏移量 ： 相对于 磁盘映像文件hd.img的开头, hd.img内的唯一的分区的第一个字节偏移量
Part1stBOfst=$(mkdiskimage -F -o hd.img $Cylinders $Heads $SectsPerTrk) && \
[ $Part1stBOfst == $((SectsPerTrk*512)) ] && \
# Part1stBOfst == 16384 == 0X4000 == 32个扇区 == SectorsPerTrack个扇区 == 1个Track
# hd.img  固定偏移+0X1C3 处 的 3个 字节  为 CHS 的值, 可以用 xxd 来 做此断言，从而可以部分验证上面的 制作hd.img的 命令mkdiskimage 是否正确.  这里只用xxd来显示了 ，并未断言。
xxd -seek  +0X1C3 -len 3 -plain hd.img && \

#2. 安装syslinux到磁盘映像文件
{ rm -frv hd_img_dir ; mkdir hd_img_dir ;} && \
syslinux --directory /boot/syslinux/ --offset $Part1stBOfst --install hd.img && \


#2B. 显示syslinux安装的文件
sudo mount -o loop,offset=$Part1stBOfst hd.img hd_img_dir && \
find ./hd_img_dir/ -type f  -l && \
sudo umount hd.img &&  sudo losetup -d $loopX && \


#3. bochs正常启动到syslinux

sudo cat << 'EOF' |  tee  demo_bochs.bxrc
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


/crk/bochs/bochs/bochs -f demo_bochs.bxrc
#bochs能正常启动直到syslinux
