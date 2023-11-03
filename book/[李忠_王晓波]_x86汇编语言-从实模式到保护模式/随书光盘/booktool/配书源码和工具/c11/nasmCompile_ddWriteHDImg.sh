#d:\msys64\usr\bin\mintty.exe -w hide /bin/env MSYSTEM=MINGW64 /bin/bash -x -l /f/crk/bochs/book/[李忠_王晓波]_x86汇编语言-从实模式到保护模式/随书光盘/booktool/配书源码和工具/c11/runme.sh
# pwd
me=$(basename "$0")
curWD=$(dirname "$0")

echo "开始执行$me"

cd $curWD
echo -n "当前目录:"; pwd
rm -fv *.bin *.img
# read -p  "按回车开始编译"
nasm c11_mbr.asm -o c11_mbr.bin -f bin -l c11_mbr.list.txt
dd if=/dev/zero of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img bs=512 count=20160
dd if=./c11_mbr.bin of=./HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB.img conv=notrunc seek=0

read -p  "按回车退出$me"