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

## 5.1 建立磁盘
```shell

dd if=/dev/zero of=disk.img count=$((63*16*20))
```

## 5.2 建立分区
```fdisk disk.img ```
>fdisk交互式输入如下:
```text
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0xcb65bf3f.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

Command (m for help): x

Expert command (m for help): m
Command action
   b   move beginning of data in a partition
   c   change number of cylinders
   d   print the raw data in the partition table
   e   list extended partitions
   f   fix partition order
   g   create an IRIX (SGI) partition table
   h   change number of heads
   i   change the disk identifier
   m   print this menu
   p   print the partition table
   q   quit without saving changes
   r   return to main menu
   s   change number of sectors/track
   v   verify the partition table
   w   write table to disk and exit

Expert command (m for help): c
Number of cylinders (1-1048576, default 1): 20

Expert command (m for help): h
Number of heads (1-256, default 255): 16

Expert command (m for help): s
Number of sectors (1-63, default 63): 63

Expert command (m for help): r

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-20159, default 2048): 第2048个扇区 即2048*512
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-20159, default 20159): 
Using default value 20159

Command (m for help): a
Partition number (1-4): 1

Command (m for help): w
The partition table has been altered!

Syncing disks.

```

## 5.3 查看分区
> 打印分区表?
```hexdump -s 0x1BE -x -n 16 disk.img ```


```text
00001be    0080    0221    0f83    133f    0800    0000    46c0    0000
00001ce
```



> 0x1BE == 446
>  查看分区

```fdisk -l -u disk.img ```

```text

Disk disk.img: 10 MB, 10321920 bytes
16 heads, 63 sectors/track, 20 cylinders, total 20160 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0xcb65bf3f

   Device Boot      Start         End      Blocks   Id  System
disk.img1   *        2048       20159        9056   83  Linux

```



## 5.4 格式化分区
```man losetup```

```text
losetup - set up and control loop devices
```
---

```sudo losetup --offset $((4*512)) /dev/loop0 disk.img```

---

```sudo mkdosfs /dev/loop0```
```text
mkfs.fat 3.0.26 (2014-03-07)
Loop device does not match a floppy size, using default hd params
```

---
```fdisk disk.img```

```text
Command (m for help): t
Selected partition 1
Hex code (type L to list codes): L

 0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris        
 1  FAT12           27  Hidden NTFS Win 82  Linux swap / So c1  DRDOS/sec (FAT-
 2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
 3  XENIX usr       3c  PartitionMagic  84  OS/2 hidden C:  c6  DRDOS/sec (FAT-
 4  FAT16 <32M      40  Venix 80286     85  Linux extended  c7  Syrinx         
 5  Extended        41  PPC PReP Boot   86  NTFS volume set da  Non-FS data    
 6  FAT16           42  SFS             87  NTFS volume set db  CP/M / CTOS / .
 7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux plaintext de  Dell Utility   
 8  AIX             4e  QNX4.x 2nd part 8e  Linux LVM       df  BootIt         
 9  AIX bootable    4f  QNX4.x 3rd part 93  Amoeba          e1  DOS access     
 a  OS/2 Boot Manag 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O        
 b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor      
 c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad hi eb  BeOS fs        
 e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         ee  GPT            
 f  W95 Ext'd (LBA) 54  OnTrackDM6      a6  OpenBSD         ef  EFI (FAT-12/16/
10  OPUS            55  EZ-Drive        a7  NeXTSTEP        f0  Linux/PA-RISC b
11  Hidden FAT12    56  Golden Bow      a8  Darwin UFS      f1  SpeedStor      
12  Compaq diagnost 5c  Priam Edisk     a9  NetBSD          f4  SpeedStor      
14  Hidden FAT16 <3 61  SpeedStor       ab  Darwin boot     f2  DOS secondary  
16  Hidden FAT16    63  GNU HURD or Sys af  HFS / HFS+      fb  VMware VMFS    
17  Hidden HPFS/NTF 64  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE 
18  AST SmartSleep  65  Novell Netware  b8  BSDI swap       fd  Linux raid auto
1b  Hidden W95 FAT3 70  DiskSecure Mult bb  Boot Wizard hid fe  LANstep        
1c  Hidden W95 FAT3 75  PC/IX           be  Solaris boot    ff  BBT            
1e  Hidden W95 FAT1 80  Old Minix      
Hex code (type L to list codes): 4
Changed system type of partition 1 to 4 (FAT16 <32M)

Command (m for help): w
The partition table has been altered!


WARNING: If you have created or modified any DOS 6.x
partitions, please see the fdisk manual page for additional
information.
Syncing disks.
```

---
```hexdump -s 0x1BE -x -n 16 disk.img```
```text
00001be    0080    0221    0f04    133f    0800    0000    46c0    0000
00001ce
```
---

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
