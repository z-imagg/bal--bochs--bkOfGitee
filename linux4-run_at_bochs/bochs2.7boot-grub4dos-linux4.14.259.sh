#!/bin/bash

#当前主机为ubuntu22x64

{ _='加载（依赖、通用变量） 开始' && \
######{此脚本调试步骤:
###{1. 干运行（置空ifelse）以 确定参数行是否都被短路:
#PS4='[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO]: '    bash -x   ./bochs2.7boot-grub4dos-linux2.6.27.15.sh   #bash调试执行 且 显示 行号
#使用 ifelse空函数
# function ifelse(){
#     :
# }
###}


###2. 当 确定参数行都被短路 时, 再 使用 真实 ifelse 函数:
#加载 func.sh中的函数 ifelse
source /crk/bochs/bash-simplify/func.sh
######}


source /crk/bochs/bash-simplify/dir_util.sh

#当前脚本文件名, 此处 CurScriptF=build-linux-2.6.27.15-on-i386_ubuntu14.04.6LTS.sh
CurScriptF=$(pwd)/$0


_='加载（依赖、通用变量） 结束' ;} && \

# read -p "断点1" && \

#-1. 业务内容开始
HdImgF=HD50MB200C16H32S.img
HdImg_C=200 ; HdImg_H=16 ; HdImg_S=32 ;

#0. 安装apt-file命令(非必需步骤)
{ _='安装apt-file命令(非必需步骤)' && \
echo $CurScriptF $LINENO
# read -p "断点1"
# debug_ifelseif=true
{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  apt-file --help 2>/dev/null 1>/dev/null
    "已安装apt-file(搜索命令对应的.deb安装包)"
    {  which mkdiskimage  1>/dev/null 2>/dev/null || apt-file search mkdiskimage ;}
  #else:
    sudo apt install -y apt-file && sudo apt-file update
      "apt-file(搜索命令对应的.deb安装包)安装完毕"
} \
} && [ $__e == 0 ] && \

_='安装apt-file命令(非必需步骤)' ;} && \
# read -p "断点2"

#1. 安装mkdiskimage命令
{ _='安装mkdiskimage命令 开始' && \

function _is_mkdiskimage_installed(){
#测试mkdiskimage 是否存在及正常运行
mkdiskimage  __.img 10 8 32 2>/dev/null 1>/dev/null && _="若 mkdiskimage已经安装," && \
dpkg -S syslinux 2>/dev/null 1>/dev/null  && dpkg -S syslinux-common 2>/dev/null 1>/dev/null && dpkg -S syslinux-efi 2>/dev/null 1>/dev/null    && _="且 syslinux、syslinux-common、syslinux-efi都已经安装,"
}

set msgInstOk="mkdiskimage安装完毕(mkdiskimage由syslinux-util提供, 但是syslinux syslinux-common syslinux-efi都要安装,否则mkdiskimage产生的此 $HdImgF 几何参数不对、且 分区没格式化 )"


{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  _is_mkdiskimage_installed
    "已经安装mkdiskimage"
    rm -fv __.img
  #else:
    sudo apt install -y syslinux syslinux-common syslinux-efi syslinux-utils
      "$msgInstOk"
} \
} && [ $__e == 0 ] && \

_='安装mkdiskimage命令 结束' ;} && \

#2. 制作硬盘镜像、注意磁盘几何参数得符合bochs要求、仅1个fat16分区
{ _='制作硬盘镜像、注意磁盘几何参数得符合bochs要求、仅1个fat16分区 开始' && \

{ sudo umount /mnt/hd_img 2>/dev/null ;  sudo rm -frv /mnt/hd_img ; rm -fv $HdImgF ;} && \

PartitionFirstByteOffset=$(mkdiskimage -o   $HdImgF $HdImg_C $HdImg_H $HdImg_S) && \
#  当只安装syslinux而没安装syslinux-common syslinux-efi时, mkdiskimage可以制作出磁盘映像文件，但 该 磁盘映像文件  的几何尺寸参数 并不是 给定的  参数 200C 16H 32S
#  所以 应该 同时安装了 syslinux syslinux-common syslinux-efi， "步骤1." 已有这样的检测了
# PartitionFirstByteOffset==$((32*512))==16384
set msgErr="mkdiskimage返回的PartitionFirstByteOffset $PartitionFirstByteOffset 不是预期值 $((32*512)), 请人工排查问题, 退出码9" && \
{ \
#测试 mkdiskimage返回的PartitionFirstByteOffset是否为 '预期值 即 $((32*512)) 即 16384'
[ $PartitionFirstByteOffset == $((32*512)) ] || \
"否则 (即 PartitionFirstByteOffset不是预期值)" 2>/dev/null || \
{ echo $msgErr && exit 9 ;} \
;} && \


_='制作硬盘镜像、注意磁盘几何参数得符合bochs要求、仅1个fat16分区 结束' ;} && \

#3. 断言 磁盘映像文件几何参数
{ _='断言 磁盘映像文件几何参数 开始' && \
#xxd -seek +0X1C3 -len 3 $HdImgF
#0X1C3:0X0F:15:即16H:即16个磁头, 0X1C4:0X20:32:即32S:即每磁道有32个扇区, 0X1C3:0XC7:199:即200C:即200个柱面

#0f20C7 即  用010editor打开 磁盘映像文件  偏移0X1C3到偏移0X1C3+2 的3个字节
# set 消息条件已满足="磁盘几何参数指定成功"
# set 消息断言失败并退出="磁盘几何参数指定失败, 为确认 请用diskgenius专业版打开该x.img查看几何参数, 退出码为5"
# { \
# #测试 目标条件 是否满足
# test "$(xxd -seek +0X1C3 -len 3  -plain  $HdImgF)" == "0f20C7" && _="若 目标条件 已满足," && \
# #则 显示 消息条件已满足
# echo $消息条件已满足 
# ;} \
# || "否则 (即 消息条件已满足)" 2>/dev/null || \
# { \
# #显示 消息断言失败并退出 并 退出
# echo $消息断言失败并退出 && exit 5 && \
# ;}

#  注意sfdisk显示磁盘的几何参数与diskgenius的不一致,这里认为sfdisk是错误的，而diskgenius是正确的
# sfdisk --show-geometry $HdImgF

#不需要 parted 、 mkfs.vfat 等命令 再格式化分区，因为mkdiskimage制作 磁盘映像文件时 已经 格式化过分区了


_='断言 磁盘映像文件几何参数 结束' ;} && \

#4. 用win10主机上的grubinst.exe安装grldr.mbr到磁盘镜像
{ _='4. 用win10主机上的grubinst.exe安装grldr.mbr到磁盘镜像 开始' && \
echo "执行grubinst.exe前md5sum: $(md5sum $HdImgF)" && \


#借助win10中的grubinst_1.0.1_bin_win安装grldr.mbr

#登录机器信息参照：linux2.6-run_at_bochs\readme.md
ConfigF=config.sh && \
source $ConfigF && \

_='4. 用win10主机上的grubinst.exe安装grldr.mbr到磁盘镜像 结束' ;} && \

# 4.0 必须人工确保win10中的mingw(msys2)中已安装并已启动sshServer
{ _='4.0 必须人工确保win10中的mingw(msys2)中已安装并已启动sshServer 开始' && \

{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  nc -w 3 -zv localhost 22 && nc -w 3  -zv w10.loc $w10LocSshPort
    "本地ssh端口正常,win10Ssh端口正常"
    :
  #else:
    :
      "出错! 必须人工确保win10中的mingw(msys2)中已安装并已启动sshServer; win10中的mingw中安装sshServer, 参照: https://www.msys2.org/wiki/Setting-up-SSHd/  。 请打开mingw终端:输入whoami得mingw ssh登录用户, 输入passwd设置mingw ssh登录密码(目前密码是petNm)"
} \
} && [ $__e == 0 ] && \

_='4.0 必须人工确保win10中的mingw(msys2)中已安装并已启动sshServer 结束' ;} && \


# 4.2 安装sshpass sshfs
{ _='4.2 安装sshpass sshfs 开始' && \
{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  sshpass -V 2>/dev/null 1>/dev/null && sshfs --version 2>/dev/null 1>/dev/null
    "已经安装sshpass sshfs"
    :
  #else:
    sudo apt install -y sshpass sshfs
      "sshpass sshfs 安装完毕"
} \
} && [ $__e == 0 ] && \

_='4.2 安装sshpass 结束' ;} && \

# 4.2b 利用sshfs挂载远程sshserver主机根目录
{ _='4.2b_1 建立 sshfs远程win10主机根目录' && \
{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  test -d $w10LocSshfsRt
    "sshfs远程win10主机根目录 $w10LocSshfsRt 已存在"
    :
  #else:
    { sudo rm -fr $w10LocSshfsRt ; sudo mkdir $w10LocSshfsRt && sudo chown -R $(id -gn).$(whoami) $w10LocSshfsRt ;}
      "sshfs远程win10主机根目录 $w10LocSshfsRt 新建完毕"
} \
} && [ $__e == 0 ] && \

{ _='4.2b_2 挂载 sshfs远程win10主机根目录' && \
{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  mount | grep  "$w10LocSshfsRt"
    "sshfs远程win10主机根目录 $w10LocSshfsRt 已挂载"
    :
  #else:
    echo $win10SshPass sshfs  -o ConnectTimeout=$SshConnTimeoutSeconds -o StrictHostKeyChecking=no  -p $w10LocSshPort  -o password_stdin z@w10.loc:/ $w10LocSshfsRt 
      "sshfs远程win10主机根目录 $w10LocSshfsRt 挂载完毕"
} \
} && [ $__e == 0 ] && \

# 4.3 磁盘映像文件 复制到 win10主机msys2的根目录下

{ _='4.3 磁盘映像文件 复制到 win10主机msys2的根目录下 开始' && \
IGOW10F=install_grubinst_on_win10_by_msys2.sh

#[ssh | scp ] -o StrictHostKeyChecking=no:
#  Are you sure you want to continue connecting (yes/no/[fingerprint])? yes  (自动答yes)
cp $ConfigF $w10LocSshfsRt/$ConfigF && \
cp $IGOW10F  $w10LocSshfsRt/$IGOW10F && \
sshpass -p $win10SshPass ssh -t -o ConnectTimeout=$SshConnTimeoutSeconds -o StrictHostKeyChecking=no  -p $w10LocSshPort $win10User@w10.loc "HdImgF=$HdImgF bash -x /$IGOW10F" && \
#ssh -t , -t 即 分配  pseudo-terminal 即 分配 伪终端, 否则 交互式命令工作不正常 （比如read -p 提示消息 ，将不显示提示消息）

_='4.3 磁盘映像文件 复制到 win10主机msys2的根目录下 结束' ;} && \

#5 挂载 磁盘映像文件
{ _='挂载 磁盘映像文件 开始' && \
sudo mkdir /mnt/hd_img
sudo mount -o loop,offset=$PartitionFirstByteOffset $HdImgF /mnt/hd_img
# sudo losetup --offset $((32*512)) /dev/loop15 $HdImgF
# sudo mount -o loop /dev/loop15 /mnt/hd_img

_='挂载 磁盘映像文件 结束' ;} && \

#6 下载 grub4dos-0.4.4.zip
{ _='下载 grub4dos-0.4.4.zip 开始' && \
test -f grub4dos-0.4.4.zip || { echo "下载grub4dos-0.4.4.zip" && wget https://jaist.dl.sourceforge.net/project/grub4dos/GRUB4DOS/grub4dos%200.4.4/grub4dos-0.4.4.zip ; }
md5sum --check  md5sum.grub4dos-0.4.4.zip.txt || { echo "grub4dos-0.4.4.zip的md5sum错,退出码为6" && exit 6; }
unzip -o -q grub4dos-0.4.4.zip
#unzip --help : -o  overwrite files WITHOUT prompting

_='下载 grub4dos-0.4.4.zip 结束' ;} && \

#7 制作 文件menu.lst
{ _='制作 文件menu.lst 开始' && \

_='制作 文件menu.lst 结束' ;} && \

#8. 复制grldr、menu.lst 到 磁盘映像文件
{ _='复制grldr、menu.lst 到 磁盘映像文件 开始' && \
sudo cp -v grub4dos-0.4.4/grldr  menu.lst  /mnt/hd_img/
_='复制grldr、menu.lst 到 磁盘映像文件 结束' ;} && \

#9. 内核编译机器为本机ubuntu22, 假设 已经编译好内核
bzImageF=/crk/bochs/linux4-run_at_bochs/linux-4.14.259/arch/x86/boot/bzImage && \

#10. 复制 内核bzImage  到 磁盘映像文件
{ _='复制 内核bzImage  到 磁盘映像文件 开始' && \

okMsg1="正常,发现linux内核编译产物:$bzImageF"
errMsg2="错误,内核未编译（没发现内核编译产物:$bzImageF,退出码为8"
#复制内核.  ??大文件(3MB)bzImage放到fat12分区中, bochs的bios或mbr界面无grub.??
#问题现象:  
# 0. 若复制3MB的bzImage，则bochs的bios或mbr启动界面没进grub.  反之, bochs启动界面bios能进grub.
# 1. diskgenious下打开.img 内无文件. (提交 de98c29a7bc2e284473c222b1c9a7e4ec82872ec 也有此问题，但bochs正常进入grub菜单)
{ test -f $bzImageF  && echo $okMsg1 && sudo cp -v $bzImageF  /mnt/hd_img/; } || { echo $errMsg2  && exit 8 ;  } 

_='复制 内核bzImage  到 磁盘映像文件 结束' ;} && \

#11. 制作 initrd(即 init_ram_filesystem 即 初始_内存_文件系统)

#11.1 下载busybox-i686
{ _='下载busybox-i686 开始' && \

#initrd: busybox作为 init ram disk
test -f busybox-i686 ||  wget https://www.busybox.net/downloads/binaries/1.16.1/busybox-i686
chmod +x busybox-i686

_='下载busybox-i686 结束' ;} && \

# 11.2 创建 init 脚本
{ _='创建 init 脚本 开始' && \

chmod +x init

_='创建 init 脚本 结束' ;} && \

#11.3  执行 cpio_gzip 以 生成 initRamFS
{ _='执行 cpio_gzip 以 生成 initRamFS 开始' && \

initrdF=$(pwd)/initramfs-busybox-i686.cpio.tar.gz
RT=initramfs && \
(rm -frv $RT &&   mkdir $RT && \
cp busybox-i686 init $RT/ &&  cd $RT  && \
# 创建 initrd
{ find . | cpio --create --format=newc   | gzip -9 > $initrdF ; }  ) && \
_='执行 cpio_gzip 以 生成 initRamFS 结束' ;} && \

#12. 复制 initRamFS 到 磁盘映像文件
{ _='复制 initRamFS 到 磁盘映像文件 开始' && \
sudo cp $initrdF /mnt/hd_img/

#todo: 或initrd: helloworld.c作为 init ram disk
#未验证的参考: 
# 1. google搜索"bzImage启动initrd"
# 2. 编译Linux内核在qemu中启动 : https://www.baifachuan.com/posts/211b427f.html

_='复制 initRamFS 到 磁盘映像文件 结束' ;} && \

#13. 卸载 磁盘映像文件
{ _='卸载 磁盘映像文件 开始' && \
read -p "即将卸载"
sudo umount /mnt/hd_img
sudo rm -frv /mnt/hd_img

_='卸载 磁盘映像文件 结束' ;} && \

#14. 生成 bxrc文件（引用 磁盘映像文件）
{ _='生成 bxrc文件（引用 磁盘映像文件） 开始' && \

sed "s/\$HdImgF/$HdImgF/g" linux-2.6.27.15-grub0.97.bxrc.template > gen-linux-2.6.27.15-grub0.97.bxrc

_='生成 bxrc文件（引用 磁盘映像文件） 结束' ;} && \

#15. bochs 执行 bxrc文件( 即 磁盘映像文件 即 grubinst.exe安装产物{grldr.mbr}、grub4dos组件{grldr、menu.lst}、内核bzImage、初始内存文件系统initRamFS{busybox-i686})
{ _='bochs 执行 bxrc文件 开始' && \
/crk/bochs/bochs/bochs -f gen-linux-2.6.27.15-grub0.97.bxrc
_='bochs 执行 bxrc文件 结束' ;} && \

_=end