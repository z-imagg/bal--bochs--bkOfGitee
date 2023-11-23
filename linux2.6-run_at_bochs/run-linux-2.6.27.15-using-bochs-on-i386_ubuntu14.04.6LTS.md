前置步骤: ** build-linux-2.6.27.15-on-i386_ubuntu14.04.6LTS.md **


# 环境 == build-linux-2.6.27.15-on-i386_ubuntu14.04.6LTS.md:编译环境



#4. 安装bochs

```shell

apt-cache show bochs
#Package: bochs
#Architecture: i386
#Version: 2.4.6-6

sudo apt install bochs bochs-x

bochs --version
#Bochs x86 Emulator 2.4.6
#Build from CVS snapshot, on February 22, 2011
#Compiled at Jun  8 2013, 05:16:39


```



> 参考jeanleo博文[Bochs调试linux内核环境搭建笔记（2）: "grub0.97+bzImage"-->disk.img, 并用bochs启动disk.img](https://www.jeanleo.com/?p=40)
#5. 用bochs启动grub0.97

> 第5节内 当前目录都是 ```#pwd==/crk/bochs/linux2.6-run_at_bochs/linux-2.6.27.15-grub0.97/```


> 5.1 - 5.4 用disk-genius完成
## 5.1 建立磁盘
 

## 5.2 建立分区
 

## 5.3 查看分区
 


## 5.4 格式化分区



## 5.5 挂载分区
```sudo mount -o loop /dev/loop0 /mnt```
---
```df -h```
```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/loop1      9.8M     0  9.8M   0% /mnt
```
---

## 5.6 下载grup0.97并解压
>参考: https://www.aioboot.com/en/grub-legacy/
- 下载
```shell
wget http://mirrors.edge.kernel.org/ubuntu/pool/main/g/grub/grub_0.97-29ubuntu68_i386.deb
```
- 解压
```
rm -fr grub_0.97
mkdir grub_0.97
cd grub_0.97
ar vx ../grub_0.97-29ubuntu68_i386.deb
cd -
xz -d grub_0.97/data.tar.xz
tar -xf  grub_0.97/data.tar  -C grub_0.97/
ls grub_0.97/usr/lib/grub/i386-pc/
#e2fs_stage1_5  fat_stage1_5  jfs_stage1_5  minix_stage1_5  reiserfs_stage1_5  stage1  stage2  stage2_eltorito  xfs_stage1_5
```


## 5.6 安装grub0.97到分区
```shell
sudo mkdir -p /mnt/boot/grub

gSrc=`pwd`/grub_0.97/usr/lib/grub/i386-pc/
sudo cp -v $gSrc/fat_stage1_5 $gSrc/stage1 $gSrc/stage2 /mnt/boot/grub/
```
## 5.7 填写grub的menu.lst
echo '
default=0
timeout=500
title=OS2Bochs
root (hd0,0)
kernel /kernel.bin
' | sudo tee /mnt/boot/grub/menu.lst

## 5.8 卸载分区
```shell
sudo umount /mnt
sudo losetup --detach /dev/loop0
```

#6. grub0.97引导vmlinux


```shell

```
> 以下参考jeanleo博文[Bochs调试linux内核环境搭建笔记（1）: "grub2+bzImage"-->hd0.img, 并用bochs启动hd0.img](https://www.jeanleo.com/?p=38)
#5. 用bochs启动grub2

```shell

```


#6. grub2引导vmlinux

```shell

```
