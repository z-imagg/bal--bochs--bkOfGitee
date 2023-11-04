# pwd
me=$(basename "$0")
curWD=$(dirname "$0")

echo "开始执行$me"

cd $curWD
echo -n "当前目录:"; pwd
rm -fv *.bin *.img
# read -p  "按回车开始编译"

nasm c13_mbr.asm -o c13_mbr.bin -f bin -l c13_mbr.list.txt

nasm c13_core.asm -o c13_core.bin -f bin -l c13_core.list.txt

nasm c13.asm -o c13.bin -f bin -l c13.list.txt

#新建硬盘镜像
dd if=/dev/zero of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img bs=512 count=20160

#阅读 "[李忠_王晓波]_x86汇编语言-从实模式到保护模式.pdf/13.6 代码的编译、运行和调试" 获知, 各 .bin文件写入的目的扇区号 如下:

#c13_mbr.bin 写入0号扇区
dd if=./c13_mbr.bin of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img conv=notrunc seek=0

#c13_core.bin 写入1号扇区
dd if=./c13_core.bin of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img conv=notrunc seek=1

#c13.bin 写入50号扇区
dd if=./c13.bin of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img conv=notrunc seek=50

#diskdata.txt 写入100号扇区
dd if=./diskdata.txt of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img conv=notrunc seek=100

# read -p  "按回车退出$me"