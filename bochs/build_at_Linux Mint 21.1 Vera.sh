#make报错1:
"""
make[1]: 进入目录“/crk/bochs/bochs/gui”
/bin/bash ../libtool --mode=compile --tag CXX c++ -c -D_FILE_OFFSET_BITS=64 -D_LARGE_FILES -I.. -I./.. -I../iodev -I./../iodev -I../instrument/stubs -I./../instrument/stubs -Wall -O3 -fomit-frame-pointer -pipe -D_FILE_OFFSET_BITS=64 -D_LARGE_FILES      x.cc -o x.lo
mkdir .libs
 c++ -c -D_FILE_OFFSET_BITS=64 -D_LARGE_FILES -I.. -I./.. -I../iodev -I./../iodev -I../instrument/stubs -I./../instrument/stubs -Wall -O3 -fomit-frame-pointer -pipe -D_FILE_OFFSET_BITS=64 -D_LARGE_FILES x.cc  -fPIC -DPIC -o .libs/x.o
x.cc:37:10: fatal error: X11/Xlib.h: No such file or directory
   37 | #include <X11/Xlib.h>
      |          ^~~~~~~~~~~~
compilation terminated.
make[1]: *** [Makefile:124：x.lo] 错误 1
"""
#make报错1解决:
sudo apt install libx11-dev -y

#sh .conf.linux 报错2:
"""config.log中报错详情:
/usr/bin/ld: cannot find Scrt1.o: No such file or directory
"""
#sh .conf.linux 报错2解决:
sudo apt install gcc-multilib -y


#构建工具安装:
apt-get install build-essential
apt-get install g++ -y

#编译bochs过程:
cd /crk/bochs/bochs/
sh .conf.linux
make


/crk/bochs/bochs/bochs --help
"""
00000000000i[      ] LTDL_LIBRARY_PATH not set. using compile time default '/usr/local/lib/bochs/plugins'
========================================================================
                      Bochs x86 Emulator 2.7.svn
               Built from SVN snapshot after release 2.7
                  Compiled on Oct 28 2023 at 16:05:23
========================================================================
Usage: bochs [flags] [bochsrc options]

  -n               no configuration file
  -f configfile    specify configuration file
  -q               quick start (skip configuration interface)
  -benchmark N     run Bochs in benchmark mode for N millions of emulated ticks
  -dumpstats N     dump Bochs stats every N millions of emulated ticks
  -r path          restore the Bochs state from path
  -log filename    specify Bochs log file name
  -unlock          unlock Bochs images leftover from previous session
  --help           display this help and exit
  --help features  display available features / devices and exit
  --help cpu       display supported CPU models and exit

For information on Bochs configuration file arguments, see the
bochsrc section in the user documentation or the man page of bochsrc.
00000000000i[SIM   ] quit_sim called with exit code 0

"""
ls -lh /crk/bochs/bochs/bochs
-rwxrwxr-x 1 z z 4.5M 10月 28 16:06 /crk/bochs/bochs/bochs

