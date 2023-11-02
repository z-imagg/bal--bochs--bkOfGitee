@echo off
REM 因本文件是utf-8编码, 需要chcp 65001, 否则本文件中的中文将不识别
chcp 65001

d:\msys64\usr\bin\bash  -l /f/crk/bochs/book/[李忠_王晓波]_x86汇编语言-从实模式到保护模式/随书光盘/booktool/配书源码和工具/c11/nasmCompile_ddWriteHDImg.sh



where bochs
REM bochs -f HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB__bochsrc.bxrc
bochsdbg -f HD__20Cylinder_16Header_63SectorsPerTrack__9dot84MB__bochsrc.bxrc
pause