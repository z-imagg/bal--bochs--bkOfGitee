#1. 制作硬盘镜像、注意磁盘几何参数得符合bochs要求、仅1个fat12分区
sudo umount /mnt/hd_img ; sudo rm -frv /mnt/hd_img ; rm -fv HD10MB40C16H32S.img
mkdiskimage HD10MB40C16H32S.img 40 16 32
#  有可能 此命令 并没有正确设置磁盘映像文件10MB.img的几何参数为 40C 16H 32S


#xxd -seek +0X1C3 -len 3 HD10MB40C16H32S.img
#0X1C3:0X0F:15:即16H:即16个磁头, 0X1C4:0X20:32:即32S:即每磁道有32个扇区, 0X1C3:0X27:39:即40C:即40个柱面

{ test "$(xxd -seek +0X1C3 -len 3  -plain  HD10MB40C16H32S.img)" == "0f2027" && echo "磁盘几何参数指定成功" ; }  || { echo "磁盘几何参数指定失败, 为确认 请用diskgenius专业版打开该x.img查看几何参数" && exit 5; }

echo "注意sfdisk显示磁盘的几何参数与diskgenius的不一致,这里认为sfdisk是错误的，而diskgenius是正确的" && sfdisk --show-geometry HD10MB40C16H32S.img

# parted -s  HD10MB40C16H32S.img mklabel msdos
# parted -s  HD10MB40C16H32S.img mkpart primary fat16 2048s 100%
# parted -s  HD10MB40C16H32S.img set 1 boot on

# mkfs.vfat -F 16 -n C HD10MB40C16H32S.img





#2. 用grubinst.exe安装grldr.mbr到磁盘镜像
echo "执行grubinst.exe前md5sum: $(md5sum HD10MB40C16H32S.img)"


#借助win10中的grubinst_1.0.1_bin_win安装grldr.mbr
echo "win10中的mingw中安装sshServer, 参照: https://www.msys2.org/wiki/Setting-up-SSHd/  。 请打开mingw终端:输入whoami得mingw ssh登录用户, 输入passwd设置mingw ssh登录密码(目前密码是petNm)"

win10Host=10.0.4.101
scp  HD10MB40C16H32S.img zzz@$win10Host:/HD10MB40C16H32S.img 
ssh zzz@$win10Host "/grubinst_1.0.1_bin_win/grubinst/grubinst.exe /HD10MB40C16H32S.img && echo 'grubinst.exe ok'"
scp   zzz@$win10Host:/HD10MB40C16H32S.img  HD10MB40C16H32S.img
#注: $win10Host:/ == D:\msys64, 所以请实现复制 grubinst_1.0.1_bin_win 到 D:\msys64\下

echo "执行grubinst.exe后md5sum: $(md5sum HD10MB40C16H32S.img)"

sudo mkdir /mnt/hd_img
sudo mount -o loop,offset=$((32*512)) HD10MB40C16H32S.img /mnt/hd_img
# sudo losetup --offset $((32*512)) /dev/loop15 HD10MB40C16H32S.img
# sudo mount -o loop /dev/loop15 /mnt/hd_img
test -f grub4dos-0.4.4.zip || { echo "下载grub4dos-0.4.4.zip" && wget https://jaist.dl.sourceforge.net/project/grub4dos/GRUB4DOS/grub4dos%200.4.4/grub4dos-0.4.4.zip ; }
md5sum --check  grub4dos-0.4.4.zip.md5sum.txt || { echo "grub4dos-0.4.4.zip的md5sum错,退出码为6" && exit 6; }
unzip grub4dos-0.4.4.zip
sudo cp -v grub4dos-0.4.4/grldr grub4dos-0.4.4/menu.lst  /mnt/hd_img/
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

ata0-master: type=disk, path="HD10MB40C16H32S.img", cylinders=40, heads=16, spt=32
boot: c
log: bochsout.txt
mouse: enabled=0
cpu: ips=15000000
clock: sync=both
#display_library: sdl
EOF


/crk/bochs/bochs/bochs -f gen-linux-2.6.27.15-grub0.97.bxrc