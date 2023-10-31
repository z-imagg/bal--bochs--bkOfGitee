###  参考
- [露出build过程中的makefile](https://gitcode.net/crk/bochs/-/commit/faa84bb0e4ddb9e3d6455ca82b2763a0aa4453ba)

### clone 仓库
```bash
/crk/$  git clone https://prgrmz07:Dcer-RPtKsYZmayT3eyX@gitcode.net/crk/bochs.git  -b   master
```


### 生成配置 (生成Makefile)
```bash
/crk/bochs/bochs$ sh  .conf.linux
```

 


###  记录 有Makefile的目录列表
```bash
/crk/bochs/$ find `pwd` -name Makefile | xargs -I@ bash  -c  " dirname @ " > target_dir_list

```
> 显示 有Makefile的目录列表 [target_dir_list](https://gitcode.net/crk/bochs/-/blob/dev/master/target_dir_list)

 


### 在每个目录下列出target们


```bash 

/crk/bochs$ cat target_dir_list | xargs -I@ bash -c "cd @ ; echo -n  \"@ \"; make --question  --print-data-base > Makefile_data-base.txt; python3 /crk/bochs/makefile_util/line_filter.py   Makefile_data-base.txt /crk/bochs/makefile_util/lnFltMap_Makefile_target.py Makefile_targetList.txt > /dev/null; wc -l Makefile_targetList.txt "  


 """
/crk/bochs/bochs-performance/testcases 25 Makefile_targetList.txt
/crk/bochs/bochs/memory 7 Makefile_targetList.txt
/crk/bochs/bochs/cpu 105 Makefile_targetList.txt
/crk/bochs/bochs/cpu/avx 31 Makefile_targetList.txt
/crk/bochs/bochs/cpu/cpudb 31 Makefile_targetList.txt
/crk/bochs/bochs/cpu/fpu 25 Makefile_targetList.txt
/crk/bochs/bochs 147 Makefile_targetList.txt
/crk/bochs/bochs/misc 5 Makefile_targetList.txt
/crk/bochs/bochs/instrument/stubs 4 Makefile_targetList.txt
/crk/bochs/bochs/gui 80 Makefile_targetList.txt
/crk/bochs/bochs/host/linux/pcidev 8 Makefile_targetList.txt
/crk/bochs/bochs/iodev/sound 39 Makefile_targetList.txt
/crk/bochs/bochs/iodev 73 Makefile_targetList.txt
/crk/bochs/bochs/iodev/hdimage 34 Makefile_targetList.txt
/crk/bochs/bochs/iodev/usb 50 Makefile_targetList.txt
/crk/bochs/bochs/iodev/network 87 Makefile_targetList.txt
/crk/bochs/bochs/iodev/display 25 Makefile_targetList.txt
/crk/bochs/bochs/build/win32/nsis 4 Makefile_targetList.txt
/crk/bochs/bochs/bx_debug 11 Makefile_targetList.txt
/crk/bochs/bochs/doc/docbook 14 Makefile_targetList.txt
/crk/bochs/bochs/bios 13 Makefile_targetList.txt
"""

```

> 
