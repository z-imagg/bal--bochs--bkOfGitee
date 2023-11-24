# dg新建10MB.img: 整个磁盘、格式化、不要dos系统
> dg调整磁盘参数: 40 16 32 == 10MB
> .bxrc文件中磁盘参数对应调整到 40 16 32

# grubinst在mbr中写入 grldr.mbr 
```shell
cd /d F:\crk\bochs\linux2.6-run_at_bochs\linux-2.6.27.15-grub0.97
.\grubinst_1.0.1_bin_win\grubinst\grubinst.exe 10MB.img
```
> [grubinst_1.0.1_bin_win.zip](https://sourceforge.net/projects/grub4dos/files/grubinst/grubinst%201.0.1/grubinst_1.0.1_bin_win.zip/download)

# dg复制grldr、menu.lst到10MB的fat12分区根目录下 (grldr.mbr启动分区根目录下的grldr)
> [grub4dos-0.4.6a-2023-10-14.7z](https://github.com/chenall/grub4dos/releases/download/0.4.6a/grub4dos-0.4.6a-2023-10-14.7z)

# bochs启动该10MB.img
> 正常启动到grub的命令行界面下



