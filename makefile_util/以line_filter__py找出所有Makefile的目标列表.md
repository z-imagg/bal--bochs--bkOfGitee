##  [露出build过程中的makefile](https://gitcode.net/crk/bochs/-/commit/faa84bb0e4ddb9e3d6455ca82b2763a0aa4453ba)

### clone 仓库
```bash
/crk/$  git clone https://prgrmz07:Dcer-RPtKsYZmayT3eyX@gitcode.net/crk/bochs.git  -b   dev/露出build过程中的makefile
```


### 生成配置 (生成Makefile)
```bash
/crk/bochs/bochs$ sh  .conf.linux
```

### 恢复刚刚被 生成配置覆盖的 Makefile  (可选操作)
```bash
 git status
On branch dev/露出build过程中的makefile
Your branch is up to date with 'origin/dev/露出build过程中的makefile'.

Changes not staged for commit:
        modified:   memory/Makefile

/crk/bochs/bochs$ git stash save
Saved working directory and index state WIP on 露出build过程中的makefile: 57902e0ff makefile语法纠错：目标内容开头必须是tab, 不能用空格代替
/crk/bochs/bochs$ git status

```


###  记录 有Makefile的目录列表
```bash
/crk/bochs/$ find `pwd` -name Makefile | xargs -I@ bash  -c  " dirname @ " > target_dir_list

```
> 显示 有Makefile的目录列表 [target_dir_list](https://gitcode.net/crk/bochs/-/blob/dev/%E9%9C%B2%E5%87%BAbuild%E8%BF%87%E7%A8%8B%E4%B8%AD%E7%9A%84makefile/target_dir_list)
```bash
/crk/bochs$ cat target_dir_list
/crk/bochs/bochs-performance/testcases
/crk/bochs/bochs/memory
/crk/bochs/bochs/cpu
/crk/bochs/bochs/cpu/avx
/crk/bochs/bochs/cpu/cpudb
/crk/bochs/bochs/cpu/fpu
/crk/bochs/bochs
/crk/bochs/bochs/misc
/crk/bochs/bochs/instrument/stubs
/crk/bochs/bochs/gui
/crk/bochs/bochs/host/linux/pcidev
/crk/bochs/bochs/iodev/sound
/crk/bochs/bochs/iodev
/crk/bochs/bochs/iodev/hdimage
/crk/bochs/bochs/iodev/usb
/crk/bochs/bochs/iodev/network
/crk/bochs/bochs/iodev/display
/crk/bochs/bochs/build/win32/nsis
/crk/bochs/bochs/bx_debug
/crk/bochs/bochs/doc/docbook
/crk/bochs/bochs/bios

```

>  


### 在每个目录下列出target们


```bash 

/crk/bochs$ cat target_dir_list | xargs -I@ bash -c "cd @ ; echo @; make --question  --print-data-base > Makefile_data-base.txt; python3 /crk/bochs/makefile_util/line_filter.py   Makefile_data-base.txt /crk/bochs/makefile_util/lnFltMap_Makefile_target.py Makefile_targetList.txt "  

 

```

> [targetListPerMakefile.txt](https://gitcode.net/crk/bochs/-/blob/dev/%E9%9C%B2%E5%87%BAbuild%E8%BF%87%E7%A8%8B%E4%B8%AD%E7%9A%84makefile/targetListPerMakefile.txt)
