#!/usr/bin/bash

#mkdiskimage制作磁盘映像文件hd.img,安装syslinux到磁盘映像文件，bochs正常启动到syslinux


#检测当前是否启动了调试 即 'bash -x'
{ { [[ $- == *x* ]] && _en_dbg=true ;} || _en_dbg=false ;}
echo $_en_dbg
# read -p "xxx"

function _hdImg_list_loopX(){
    { { $_en_dbg && set -x ;} || : ;} && \
    sudo losetup   --raw   --associated  hd.img 
}

function _hdImg_list_loopX_f1(){
    #此函数的输出 要作为变量loopX的值 因此一定不能放开调试 即 不能加 'set -x'
    # set +x && \
    sudo losetup   --raw   --associated  hd.img | cut -d: -f1
    # set +x
}

function _hdImg_detach_all_loopX(){
    { { $_en_dbg && set -x ;} || : ;} && \
    sudo losetup   --raw   --associated  hd.img | cut -d: -f1  |   xargs -I%  sudo losetup --detach %
}


function _hdImg_umount(){
    { { $_en_dbg && set -x ;} || : ;} && \
    _hdImg_detach_all_loopX  && { { sudo umount hd.img ; sudo umount hd_img_dir ;} || : ;}
}


function _hdImgDir_rm(){
    { { $_en_dbg && set -x ;} || : ;} && \
    rm -frv hd_img_dir ; mkdir hd_img_dir
}


function _hdImg_mount(){
    { { $_en_dbg && set -x ;} || : ;} && \

#mount形成链条:  hd.img --> /dev/loopX --> ./hd_img_dir/
sudo mount --verbose --options loop,offset=$Part1stBOfst hd.img hd_img_dir && \
#用losetup 找出上一条mount命令形成的链条中的 loopX
loopX=$( _hdImg_list_loopX_f1 ) && \
#断言 必须只有一个 回环设备 指向 hd.img
{ { [ "X$loopX" != "X" ] &&  [ $(echo   $loopX | wc -l) == 1 ] ;} || { eval $err_msg_multi_loopX_gen && exit $err_exitCode_multi_loopX  ;} ;} && \
lsblk $loopX 
#  NAME  MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
#  loop1   7:1    0  50M  0 loop /crk/bochs/linux4-run_at_bochs/hd_img_dir
}


#0. 环境: 操作系统、CPU
cat /etc/issue && \
# Ubuntu 22.04.3 LTS \n \l
uname -a && \
#Linux x 6.2.0-37-generic #38~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Thu Nov  2 18:01:13 UTC 2 x86_64 x86_64 x86_64 GNU/Linux

err_exitCode_multi_loopX=41 && \
err_msg_multi_loopX_gen=' echo "必须只能有一个回环设备指向hd.img,但此时有多个:【${loopX}】, 可以用命令 'sudo losetup   --raw   --associated  hd.img'自行验证, 退出码 【${err_exitCode_multi_loopX}】 " ' && \

#磁盘CHS几何参数
#C:Cylinders, Heads:H, SectsPerTrk:SectorsPerTrack:S
Cylinders=200 && Heads=16 && SectsPerTrk=32 && \


# -1  制作 syslinux.cfg  

#0. 清理、还原
_hdImg_list_loopX && \
_hdImg_umount && \
rm -fv hd.img && \

#1. mkdiskimage制作磁盘映像文件hd.img
#  Part1stBOfst : Partition First Byte Offset : 分区的第一个字节偏移量 ： 相对于 磁盘映像文件hd.img的开头, hd.img内的唯一的分区的第一个字节偏移量
Part1stBOfst=$(mkdiskimage -F -o hd.img $Cylinders $Heads $SectsPerTrk) && \
echo $Part1stBOfst && \
[ $Part1stBOfst == $((SectsPerTrk*512)) ] && \
# Part1stBOfst == 16384 == 0X4000 == 32个扇区 == SectsPerTrk个扇区 == 1个Track
# hd.img  固定偏移+0X1C3 处 的 3个 字节  为 CHS 的值, 可以用 xxd 来 做此断言，从而可以部分验证上面的 制作hd.img的 命令mkdiskimage 是否正确.  这里只用xxd来显示了 ，并未断言。
xxd -seek  +0X1C3 -len 3 -plain hd.img && \

#2. 放置 syslinux , 安装syslinux ( 复制 ?mbr?、ldlinux.sys 、ldlinux.c32 ) 到 磁盘映像文件 
_hdImgDir_rm && \
_hdImg_mount && \
# 2.0 syslinux 中指定的 目录 /boot/syslinux/ 必须要事先建立.
sudo mkdir -p  hd_img_dir/boot/syslinux/ && \
# 2.1 放置 syslinux 到 磁盘映像文件
sudo cp syslinux.cfg hd_img_dir/boot/syslinux/syslinux.cfg  && \
# 2.2 卸载hd.img后, 再 安装syslinux (  复制 ?mbr?、ldlinux.sys 、ldlinux.c32) 到 hd.img 
_hdImg_umount && \
syslinux --directory /boot/syslinux/ --offset $Part1stBOfst --install hd.img && \

#####

_hdImg_mount && \

#9. 内核bzImage
{  \
bzImageF=/crk/linux-stable/arch/x86/boot/bzImage
:;} && \

#10. 复制 内核bzImage  到 磁盘映像文件
{   \
okMsg1="有内核文件bzImage" && \
errMsg2="错误,内核文件bzImage不存在,退出码8" && \
{ test -f $bzImageF  && echo $okMsg1 && sudo cp -v $bzImageF  hd_img_dir/; } || { echo $errMsg2  && exit 8 ;  } 
:;} && \

#11. 制作 initrd(即 init_ram_filesystem 即 初始_内存_文件系统)

#11.1 下载busybox-i686
{ \

#initrd: busybox作为 init ram disk
# busybox_i686_url="http://ftp.icm.edu.pl/packages/busybox/binaries/1.16.1/busybox-i686"
busybox_i686_url="https://www.busybox.net/downloads/binaries/1.16.1/busybox-i686" && \
{ test -f busybox-i686 ||  wget --no-verbose $busybox_i686_url ;}
chmod +x busybox-i686

:;} && \

# 11.2 创建 init 脚本
{ \

chmod +x init

:;} && \

#11.3  执行 cpio_gzip 以 生成 initRamFS
{     \

initrdF=$(pwd)/initramfs-busybox-i686.cpio.tar.gz
RT=initramfs && \
(rm -frv $RT &&   mkdir $RT && \
cp busybox-i686 init $RT/ &&  cd $RT  && \
# 创建 initrd
{ find . | cpio --create --format=newc   | gzip -9 > $initrdF ; }  ) && \
:;} && \

#12. 复制 initRamFS 到 磁盘映像文件
{  \
sudo cp $initrdF hd_img_dir/

#todo: 或initrd: helloworld.c作为 init ram disk
#未验证的参考: 
# 1. google搜索"bzImage启动initrd"
# 2. 编译Linux内核在qemu中启动 : https://www.baifachuan.com/posts/211b427f.html

:;} && \



# 3 显示syslinux安装的文件
find ./hd_img_dir/ -type f  -ls && \
#   174     59 -r-xr-xr-x    ./hd_img_dir/boot/syslinux/ldlinux.sys
#   175    117 -r-xr-xr-x    ./hd_img_dir/boot/syslinux/ldlinux.c32

_hdImg_umount && \
#####


#4. bochs正常启动到syslinux

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

sed -i  -e "s/_cylinders_/$Cylinders/g"  -e "s/_heads_/$Heads/g" -e "s/_spt_/$SectsPerTrk/g" demo_bochs.bxrc && \
cat demo_bochs.bxrc && \
read -p "回车" && \

rm -fv hd.img.lock && \
/crk/bochs/bochs/bochs -f demo_bochs.bxrc
#bochs能正常启动直到syslinux
