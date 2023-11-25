# 新建10MB.img  （用diskgenius)

## 磁盘映像制作

### diskgenius制作磁盘映像
1. diskgenius新建10MB.img: 整个磁盘、格式化、不要dos系统
2. diskgenius调整磁盘参数: 40柱面c、 16磁头h、 32每磁道扇区数s == 10MB

### linux命令制作磁盘映像
- 环境```cat /etc/issue #Ubuntu 22.04.3 LTS \n \l```
- 安装mkdiskimage
```SHELL
sudo apt install syslinux-utils -y
dpkg -S mkdiskimage
#syslinux-utils: /usr/bin/mkdiskimage
```
- mkdiskimage制作磁盘映像
```shell
mkdiskimage 10MB.img 40 16 32
#但是此命令 并没有正确设置磁盘映像文件10MB.img的几何参数为 40C 16H 32C

sfdisk --show-geometry 10MB.img
#10MB.img: 1 cylinders, 16 heads, 32 sectors/track
#且用diskgenius查看10MB.img的几何参数，和sfdisk结果一致
#由此可知，mkdiskimage没有按照要求设置的几何参数


parted -s  10MB.img mklabel msdos
parted -s  10MB.img mkpart primary fat16 2048s 100%
parted -s  10MB.img set 1 boot on

mkfs.vfat -F 16 -n C 10MB.img


```
## 3. linux-2.6.27.15-grub0.97.bxrc文件中磁盘参数对应调整到 40c 16h 32s
## 4. 关闭diskgenius

# 将写入 grldr.mbr 写入10MB.img的mbr (用grubinst)
```shell
#win10命令行下执行以下命令
cd /d F:\crk\bochs\linux2.6-run_at_bochs\linux-2.6.27.15-grub0.97


D:\7-Zip\7z  x grubinst_1.0.1_bin_win.zip -ogrubinst_1.0.1_bin_win

.\grubinst_1.0.1_bin_win\grubinst\grubinst.exe 10MB.img
```
> [grubinst_1.0.1_bin_win.zip](https://sourceforge.net/projects/grub4dos/files/grubinst/grubinst%201.0.1/grubinst_1.0.1_bin_win.zip/download), 该文件位于[目录grub1.0.1](https://sourceforge.net/projects/grub4dos/files/grubinst/grubinst%201.0.1/)下

# 复制grldr、menu.lst到10MB.img的某分区根目录下

```shell
D:\7-Zip\7z  x grub4dos-0.4.6a-2023-10-14.7z -ogrub4dos-0.4.6a-2023-10-14
```
> [grub4dos-0.4.6a-2023-10-14.7z](https://github.com/chenall/grub4dos/releases/download/0.4.6a/grub4dos-0.4.6a-2023-10-14.7z)， 该文件位于[目录chenall/grub4dos/releases/tag/0.4.6a](https://github.com/chenall/grub4dos/releases/tag/0.4.6a)下
>
> 或 [grub4dos-0.4.4.zip](https://jaist.dl.sourceforge.net/project/grub4dos/GRUB4DOS/grub4dos%200.4.4/grub4dos-0.4.4.zip), 该文件位于[目录sourceforge/grub4dos/0.4.4/](https://jaist.dl.sourceforge.net/project/grub4dos/GRUB4DOS/grub4dos%200.4.4/)下

1. 打开diskgenius
2. diskgenius打开磁盘映像文件10MB.img
3. 复制grldr、menu.lst到10MB.img的唯一一个分区根目录下
>> grldr.mbr启动分区根目录下的grldr
>>
>> 详细过程大概如下:
>>
>> > grldr.mbr会依此寻找每个分区根目录下的grldr, 并启动找到的第一个grldr
4. 关闭diskgenius

# bochs启动该10MB.img

## 编译或安装bochs

### 编译bochs
>参照[make_xv6_bochs_run.sh](https://gitcode.net/crk/bochs/-/blob/bochs-linux2.6/d/xv6-x86-run_at_bochs/make_xv6_bochs_run.sh)的后半段，编译出我修改的bochs2.7。

### 安装bochs
>>或者 ```apt install bochs``` , 并对应调整linux-2.6.27.15-grub0.97.bxrc

## 运行bochs
```shell
#pwd==/crk/bochs/linux2.6-run_at_bochs/linux-2.6.27.15-grub0.97/
/crk/bochs/bochs/bochs -f linux-2.6.27.15-grub0.97.bxrc

```
> 正常启动到grub的命令行界面下


# 以上详细步骤图
![详细步骤图](https://gitcode.net/crk/bochs/-/raw/bochs-linux2.6/d/linux2.6-run_at_bochs/linux-2.6.27.15-grub0.97/all-step.png)





