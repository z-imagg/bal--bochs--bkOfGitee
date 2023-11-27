HdImgF=HD50MB200C16H32S.img
HdImg_C=200 ; HdImg_H=16 ; HdImg_S=32 ;
#0. 安装mkdiskimage命令
# { apt-file --help 2>/dev/null 1>/dev/null && echo "已安装apt-file(搜索命令对应的.deb安装包)" && apt-file search mkdiskimage ; } || { sudo apt install -y apt-file && sudo apt-file update && echo "apt-file(搜索命令对应的.deb安装包)安装完毕" ; }
{ mkdiskimage 2>/dev/null 1>/dev/null && echo "已经安装mkdiskimage" ; } || { sudo apt install -y syslinux syslinux-common syslinux-efi syslinux-utils ; echo "mkdiskimage安装完毕(mkdiskimage由syslinux-util提供, 但是syslinux syslinux-common syslinux-efi都要安装,否则mkdiskimage产生的此 $HdImgF 几何参数不对、且 分区没格式化 )"; }

#1. 制作硬盘镜像、注意磁盘几何参数得符合bochs要求、仅1个fat12分区
sudo umount /mnt/hd_img 2>/dev/null ; sudo rm -frv /mnt/hd_img ; rm -fv $HdImgF
PartitionFirstByteOffset=$(mkdiskimage -o   $HdImgF $HdImg_C $HdImg_H $HdImg_S)
#  有可能 此命令 并没有正确设置磁盘映像文件10MB.img的几何参数为 200C 16H 32S
# PartitionFirstByteOffset==$((32*512))==16384


#xxd -seek +0X1C3 -len 3 $HdImgF
#0X1C3:0X0F:15:即16H:即16个磁头, 0X1C4:0X20:32:即32S:即每磁道有32个扇区, 0X1C3:0XC7:199:即200C:即200个柱面

#0f20C7 即  用010editor打开 磁盘映像文件  偏移0X1C3到偏移0X1C3+2 的3个字节
# { test "$(xxd -seek +0X1C3 -len 3  -plain  $HdImgF)" == "0f20C7" && echo "磁盘几何参数指定成功" ; }  || { echo "磁盘几何参数指定失败, 为确认 请用diskgenius专业版打开该x.img查看几何参数" && exit 5; }

echo "注意sfdisk显示磁盘的几何参数与diskgenius的不一致,这里认为sfdisk是错误的，而diskgenius是正确的" && sfdisk --show-geometry $HdImgF

# parted -s  $HdImgF mklabel msdos
# parted -s  $HdImgF mkpart primary fat16 2048s 100%
# parted -s  $HdImgF set 1 boot on

# mkfs.vfat -F 16 -n C $HdImgF





#2. 用grubinst.exe安装grldr.mbr到磁盘镜像
echo "执行grubinst.exe前md5sum: $(md5sum $HdImgF)"


#借助win10中的grubinst_1.0.1_bin_win安装grldr.mbr
echo "win10中的mingw中安装sshServer, 参照: https://www.msys2.org/wiki/Setting-up-SSHd/  。 请打开mingw终端:输入whoami得mingw ssh登录用户, 输入passwd设置mingw ssh登录密码(目前密码是petNm)"

#登录机器信息参照：linux2.6-run_at_bochs\readme.md
win10Host=192.168.1.13
win10SshPort=3022
win10SshPassF=/win10SshPass
{ test -f $win10SshPassF && win10SshPass=`cat $win10SshPassF` ; } || { echo  "必须有文件win10SshPassF:$win10SshPassF , 产生办法 \"echo win10Ssh密码比如1234 > $win10SshPassF\", 且此文件不能放到代码仓库(否则密码泄露), 退出码为7"; exit 7 ; }

#若无sshpass则安装
{ sshpass -V 2>/dev/null 1>/dev/null && echo "已经安装sshpass" ; } || { sudo apt install -y sshpass ; echo "sshpass安装完毕"; }

sshpass -p $win10SshPass scp  -P $win10SshPort $HdImgF zzz@$win10Host:/$HdImgF 

sshpass -p $win10SshPass ssh -p $win10SshPort zzz@$win10Host "test -f  /grubinst_1.0.1_bin_win/grubinst/grubinst.exe || { wget https://sourceforge.net/projects/grub4dos/files/grubinst/grubinst%201.0.1/grubinst_1.0.1_bin_win.zip/download  --output-document   /grubinst_1.0.1_bin_win.zip && pacman --noconfirm -S  unzip && unzip -o /grubinst_1.0.1_bin_win.zip -d / ; }"

sshpass -p $win10SshPass ssh -p $win10SshPort zzz@$win10Host "/grubinst_1.0.1_bin_win/grubinst/grubinst.exe /$HdImgF && echo 'grubinst.exe ok'"

sshpass -p $win10SshPass scp   -P $win10SshPort  zzz@$win10Host:/$HdImgF  $HdImgF
#注: $win10Host:/ == D:\msys64, 所以请实现复制 grubinst_1.0.1_bin_win 到 D:\msys64\下

echo "执行grubinst.exe后md5sum: $(md5sum $HdImgF)"

sudo mkdir /mnt/hd_img
sudo mount -o loop,offset=$PartitionFirstByteOffset $HdImgF /mnt/hd_img
# sudo losetup --offset $((32*512)) /dev/loop15 $HdImgF
# sudo mount -o loop /dev/loop15 /mnt/hd_img
test -f grub4dos-0.4.4.zip || { echo "下载grub4dos-0.4.4.zip" && wget https://jaist.dl.sourceforge.net/project/grub4dos/GRUB4DOS/grub4dos%200.4.4/grub4dos-0.4.4.zip ; }
md5sum --check  md5sum.grub4dos-0.4.4.zip.txt || { echo "grub4dos-0.4.4.zip的md5sum错,退出码为6" && exit 6; }
unzip -o -q grub4dos-0.4.4.zip
#unzip --help : -o  overwrite files WITHOUT prompting

cat << 'EOF' > menu.lst
title=OS2Bochs
root (hd0,0)
kernel /bzImage init=/busybox-i686
initrd /initramfs-busybox-i686.cpio.tar.gz
EOF

#去内核编译机器ubuntu14X86下载已经编译好的内核
#登录机器信息参照：linux2.6-run_at_bochs\readme.md
ubuntu14X86Host=192.168.1.4
ubuntu14X86Port=3022
ubuntu14X86PassF=/ubuntu14X86SshPass
{ test -f $ubuntu14X86PassF && ubuntu14X86Pass=`cat $ubuntu14X86PassF` ; } || { echo  "必须有文件ubuntu14X86PassF:$ubuntu14X86PassF , 产生办法 \"echo ubuntu14X86密码比如1234 > $ubuntu14X86PassF\", 且此文件不能放到代码仓库(否则密码泄露), 退出码为9"; exit 9 ; }
bzImageAtUbuntu14X86=/crk/bochs/linux2.6-run_at_bochs/linux-2.6.27.15/arch/x86/boot/bzImage
bzImageF=bzImage
sshpass -p $ubuntu14X86Pass scp  -o StrictHostKeyChecking=no -P $ubuntu14X86Port  z@$ubuntu14X86Host:$bzImageAtUbuntu14X86 $bzImageF

okMsg1="正常,发现linux内核编译产物:$bzImageF"
errMsg2="错误,内核未编译（没发现内核编译产物:$bzImageF,退出码为8"

#复制grldr、menu.lst
sudo cp -v grub4dos-0.4.4/grldr  menu.lst  /mnt/hd_img/
#复制内核.  ??大文件(3MB)bzImage放到fat12分区中, bochs的bios或mbr界面无grub.??
#问题现象:  
# 0. 若复制3MB的bzImage，则bochs的bios或mbr启动界面没进grub.  反之, bochs启动界面bios能进grub.
# 1. diskgenious下打开.img 内无文件. (提交 de98c29a7bc2e284473c222b1c9a7e4ec82872ec 也有此问题，但bochs正常进入grub菜单)
{ test -f $bzImageF  && echo $okMsg1 && sudo cp -v $bzImageF  /mnt/hd_img/; } || { echo $errMsg2  && exit 8 ;  } 

#initrd: busybox作为 init ram disk
test -f busybox-i686 ||  wget https://www.busybox.net/downloads/binaries/1.16.1/busybox-i686
RT=initramfs && rm -frv $RT &&   mkdir $RT && cp busybox-i686 $RT/ && chmod +x $RT/busybox-i686 &&  cd $RT  &&  { find . | cpio   --create      --format=newc | gzip > ../initramfs-busybox-i686.cpio.tar.gz ; } && cd -
sudo cp initramfs-busybox-i686.cpio.tar.gz /mnt/hd_img/

#todo: 或initrd: helloworld.c作为 init ram disk
#未验证的参考: 
# 1. google搜索"bzImage启动initrd"
# 2. 编译Linux内核在qemu中启动 : https://www.baifachuan.com/posts/211b427f.html

#卸载磁盘映像文件
read -p "即将卸载"
sudo umount /mnt/hd_img
sudo rm -frv /mnt/hd_img



cat << 'EOF' > gen-linux-2.6.27.15-grub0.97.bxrc
megs: 32

#romimage: file=/usr/share/bochs/BIOS-bochs-latest
#vgaromimage: file=/usr/share/bochs/VGABIOS-lgpl-latest

romimage: file=/crk/bochs/bochs/bios/BIOS-bochs-latest
vgaromimage: file=/crk/bochs/bochs/bios/VGABIOS-lgpl-latest

#romimage: file=D:\Bochs-2.6.11\BIOS-bochs-latest
#vgaromimage: file=D:\Bochs-2.6.11\VGABIOS-lgpl-latest

ata0-master: type=disk, path="$HdImgF", cylinders=40, heads=16, spt=32
boot: c
log: bochsout.txt
mouse: enabled=0
cpu: ips=15000000
clock: sync=both
#display_library: sdl
EOF

sed -i "s/\$HdImgF/$HdImgF/g" gen-linux-2.6.27.15-grub0.97.bxrc

/crk/bochs/bochs/bochs -f gen-linux-2.6.27.15-grub0.97.bxrc