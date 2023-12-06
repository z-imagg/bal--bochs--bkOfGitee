#!/bin/bash

#当前主机为ubuntu22x64

#本脚本运行例子:
usage_echo_stmt='echo -e "用法:\n【HdImg_C=400 bash $0】（指定 磁盘映像文件 柱面数HdImg_C 为 400）； \n【bash $0】（指定  柱面数HdImg_C 默认为 200）. \n  磁头数HdImg_H固定为${HdImg_H}、每磁道扇区数固定为${HdImg_S}" \n\n' && \

_SectorSize=512 && _Pwr2_10=$((2**10)) && \

# 加载（依赖、通用变量）
{  \
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


:;} && \
# bash中关于 {}  , 结尾的}同一行若有命令x 则 形式必须是 x;} 不能是 x}
#  这里 : 是 空命令, 因此 :;} 符合 形式 x;} 
# :;} 实际 可以写为 } , 写为 :;} 是为了更加醒目 的表示 这是本块业务代码的结束点

# read -p "断点1" && \

#-1. 业务内容开始
#磁盘映像文件 柱面数 HdImg_C ： 外部指定变量HdImg_C的值 或 默认 200
HdImg_C=${HdImg_C:-200} &&  HdImg_H=16 && HdImg_S=32 && \
#显示本命令用法
eval $usage_echo_stmt && \
#计算磁盘映像文件尺寸
_HdImgF_Sz_MB=$(( HdImg_C * HdImg_H * HdImg_S * _SectorSize / ( _Pwr2_10*_Pwr2_10 ) )) && \
#组装磁盘映像文件名
HdImgF="HD${_HdImgF_Sz_MB}MB${HdImg_C}C${HdImg_H}H${HdImg_S}S.img" && \
#显示 磁盘映像文件名
echo "磁盘映像文件【名:${HdImgF}，尺寸:${_HdImgF_Sz_MB}MB】" && \
#提示是否继续
read -p "按回车开始（停止请按Ctrl+C）" && \

#0. 安装apt-file命令(非必需步骤)
{   \
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

:;} && \
# read -p "断点2"

#1. 安装mkdiskimage命令
{  \

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

:;} && \

#2. 制作硬盘镜像、注意磁盘几何参数得符合bochs要求、仅1个fat16分区
{  \

{ sudo umount /mnt/hd_img 2>/dev/null ;  sudo rm -frv /mnt/hd_img ; rm -fv $HdImgF :;} && \

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
} && \


:;} && \

#3. 断言 磁盘映像文件几何参数
{  \
#xxd -seek +0X1C3 -len 3 $HdImgF
#0X1C3:HdImg_H -1 : 0X0F:15:即16H:即16个磁头,  0X1C4: HdImg_S : 0X20:32:即32S:即每磁道有32个扇区, 0X1C3:HdImg_C -1 : 0XC7:199:即200C:即200个柱面

#0f20C7 即  用010editor打开 磁盘映像文件  偏移0X1C3到偏移0X1C3+2 的3个字节
 
function _check_hdimgF_geometry_param_HSC(){
#测试mkdiskimage 是否存在及正常运行
HdImg_C_sub1_hex=$( printf "%02x" $((HdImg_C-1)) ) && \
HdImg_H_hex=$(printf "%02x" $((HdImg_H-1)) ) && \
HdImg_S_hex=$(printf "%02x" $HdImg_S ) && \
_HSC_hex_calc="${HdImg_H_hex}${HdImg_S_hex}${HdImg_C_sub1_hex}" && \
_HSC_hex_xxdRdFromHdImgF="$(xxd -seek +0X1C3 -len 3  -plain  $HdImgF)" && \
test "$_HSC_hex_xxdRdFromHdImgF" == "${_HSC_hex_calc}"
}


{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  _check_hdimgF_geometry_param_HSC
    "磁盘映像文件几何参数HSC正确,_HSC_hex=${_HSC_hex_calc}"
    :
  #else:
    echo "磁盘映像文件几何参数HSC错误【 错误, _HSC_hex_calc=${_HSC_hex_calc} != _HSC_hex_xxdRdFromHdImgF=${_HSC_hex_xxdRdFromHdImgF} 】，退出码为5" && exit 5
      ""
} \
} && [ $__e == 0 ] && \

#  注意sfdisk显示磁盘的几何参数与diskgenius的不一致,这里认为sfdisk是错误的，而diskgenius是正确的
# sfdisk --show-geometry $HdImgF

#不需要 parted 、 mkfs.vfat 等命令 再格式化分区，因为mkdiskimage制作 磁盘映像文件时 已经 格式化过分区了

:;} && \
 


 

#4. 用win10主机上的grubinst.exe安装grldr.mbr到磁盘镜像
{  \
echo "执行grubinst.exe前md5sum: $(md5sum $HdImgF)" && \


#借助win10中的grubinst_1.0.1_bin_win安装grldr.mbr

#登录机器信息参照：linux2.6-run_at_bochs\readme.md
ConfigF=config.sh && \
source $ConfigF && \

:;} && \

# 4.0 必须人工确保win10中的mingw(msys2)中已安装并已启动sshServer
{  \
okMsg="本地ssh端口正常,win10Ssh端口正常"
errMsg="出错! 必须人工确保win10中的mingw(msys2)中已安装并已启动sshServer; win10中的mingw中安装sshServer, 参照: https://www.msys2.org/wiki/Setting-up-SSHd/  。 请打开mingw终端:输入whoami得mingw ssh登录用户, 输入passwd设置mingw ssh登录密码(目前密码是petNm)"
{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  nc -w 3 -zv localhost 22 && nc -w 3  -zv w10.loc $w10SshPort
    okMsg
    :
  #else:
    :
      errMsg
} \
} && [ $__e == 0 ] && \

:;} && \


# 4.2 安装sshpass sshfs
{  \
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

:;} && \

# 4.2b 利用sshfs挂载远程sshserver主机根目录
{  \
{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  test -d $w10SshfsRt
    "sshfs远程win10主机根目录 $w10SshfsRt 已存在"
    :
  #else:
    { sudo rm -fr $w10SshfsRt ; sudo mkdir $w10SshfsRt && sudo chown -R $(id -gn).$(whoami) $w10SshfsRt ;}
      "sshfs远程win10主机根目录 $w10SshfsRt 新建完毕"
} \
} && [ $__e == 0 ] && \
:;} && \

{  \
{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  mount | grep  "$w10SshfsRt"
    "sshfs远程win10主机根目录 $w10SshfsRt 已挂载"
    :
  #else:
    echo $win10SshPass | sshfs  -o ConnectTimeout=$SshConnTS -o StrictHostKeyChecking=no  -p $w10SshPort  -o password_stdin $win10User@w10.loc:/ $w10SshfsRt 
      "sshfs远程win10主机根目录 $w10SshfsRt 挂载完毕"
} \
} && [ $__e == 0 ] && \
:;} && \

# 4.3 磁盘映像文件 复制到 win10主机msys2的根目录下

{   \
IGOW10F=install_grubinst_on_win10_by_msys2.sh

#[ssh | scp ] -o StrictHostKeyChecking=no:
#  Are you sure you want to continue connecting (yes/no/[fingerprint])? yes  (自动答yes)
cp $ConfigF $w10SshfsRt/  && \
cp $IGOW10F $w10SshfsRt/  && \
# 4.3 磁盘映像文件 复制到 ubt22x64主机msys2的根目录下
cp $HdImgF $w10SshfsRt/  && \
sshpass -p $win10SshPass ssh -t -o ConnectTimeout=$SshConnTS -o StrictHostKeyChecking=no  -p $w10SshPort $win10User@w10.loc "HdImgF=$HdImgF bash  /$IGOW10F" && \
#ssh -t , -t 即 分配  pseudo-terminal 即 分配 伪终端, 否则 交互式命令工作不正常 （比如read -p 提示消息 ，将不显示提示消息）
#4.6 传回已 安装 grldr.mbr 的 磁盘映像文件
cp  $w10SshfsRt/$HdImgF $HdImgF && \
:;} && \

#5 挂载 磁盘映像文件
{   \
sudo mkdir /mnt/hd_img
sudo mount -o loop,offset=$PartitionFirstByteOffset $HdImgF /mnt/hd_img
# sudo losetup --offset $((32*512)) /dev/loop15 $HdImgF
# sudo mount -o loop /dev/loop15 /mnt/hd_img

:;} && \

#6 下载 grub4dos-0.4.4.zip
{ \
#原始下载地址 https://jaist.dl.sourceforge.net/project/grub4dos/GRUB4DOS/grub4dos%200.4.4/grub4dos-0.4.4.zip 太慢了
grub4dos_zip_url="https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/util/boot/grub4dos/grub4dos-0.4.4.zip"
test -f grub4dos-0.4.4.zip || { echo "下载grub4dos-0.4.4.zip" && wget --no-verbose $grub4dos_zip_url ; }
md5sum --check  md5sum.grub4dos-0.4.4.zip.txt || { echo "grub4dos-0.4.4.zip的md5sum错,退出码为6" && exit 6; }
unzip -o -q grub4dos-0.4.4.zip
#unzip --help : -o  overwrite files WITHOUT prompting

:;} && \

#7 制作 文件menu.lst
{   \

:;} && \

#8. 复制grldr、menu.lst 到 磁盘映像文件
{  \
sudo cp -v grub4dos-0.4.4/grldr  menu.lst  /mnt/hd_img/
:;} && \

#9. 编译内核 内核编译机器为本机ubuntu22
{  \
bzImageF=linux-4.14.259/arch/x86/boot/bzImage && ls -lh $bzImageF && \
{ test -f $bzImageF || bash build-linux4.14.259-on-x64_u22.04.3LTS.sh :;} && \
:;} && \

#10. 复制 内核bzImage  到 磁盘映像文件
{   \

okMsg1="正常,发现linux内核编译产物:$bzImageF"
errMsg2="错误,内核未编译（没发现内核编译产物:$bzImageF,退出码为8"
#复制内核.  ??大文件(3MB)bzImage放到fat12分区中, bochs的bios或mbr界面无grub.??
#问题现象:  
# 0. 若复制3MB的bzImage，则bochs的bios或mbr启动界面没进grub.  反之, bochs启动界面bios能进grub.
# 1. diskgenious下打开.img 内无文件. (提交 de98c29a7bc2e284473c222b1c9a7e4ec82872ec 也有此问题，但bochs正常进入grub菜单)
{ test -f $bzImageF  && echo $okMsg1 && sudo cp -v $bzImageF  /mnt/hd_img/; } || { echo $errMsg2  && exit 8 ;  } 

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
sudo cp $initrdF /mnt/hd_img/

#todo: 或initrd: helloworld.c作为 init ram disk
#未验证的参考: 
# 1. google搜索"bzImage启动initrd"
# 2. 编译Linux内核在qemu中启动 : https://www.baifachuan.com/posts/211b427f.html

:;} && \

#13. 卸载 磁盘映像文件
{  \
read -p "按回车即将卸载"
sudo umount /mnt/hd_img
sudo rm -frv /mnt/hd_img

:;} && \

#14. 生成 bxrc文件（引用 磁盘映像文件）
{  \

sed "s/\$HdImgF/$HdImgF/g" linux-2.6.27.15-grub0.97.bxrc.template > gen-linux-2.6.27.15-grub0.97.bxrc

:;} && \

#15. bochs 执行 bxrc文件( 即 磁盘映像文件 即 grubinst.exe安装产物{grldr.mbr}、grub4dos组件{grldr、menu.lst}、内核bzImage、初始内存文件系统initRamFS{busybox-i686})
{  \
/crk/bochs/bochs/bochs -f gen-linux-2.6.27.15-grub0.97.bxrc
:;} && \

_=end