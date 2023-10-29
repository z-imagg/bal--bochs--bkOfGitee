#run me using "git bash"
BochsHome=`pwd`
#BochsHome==/f/crk/bochs
echo $BochsHome

BochsSrcHome=$BochsHome/bochs
echo $BochsSrcHome
#BochsSrcHome==/f/crk/bochs/bochs

vs2019svFHome=`pwd`/bochs/build/win32/vs2019-workspace/vs2019
#vs2019svFHome==vs2019slnVcxprojFileHome
echo  $vs2019svFHome
# /f/crk/bochs/bochs/build/win32/vs2019-workspace/vs2019
ls  $vs2019svFHome
#       bximage.vcxproj             
 
# mv $vs2019svFHome/cpu.vcxproj $BochsSrcHome/cpu/
# mv $vs2019svFHome/fpu.vcxproj $BochsSrcHome/cpu/
# mv $vs2019svFHome/cpudb.vcxproj $BochsSrcHome/cpu/
# mv $vs2019svFHome/avx.vcxproj $BochsSrcHome/cpu/

# mv $vs2019svFHome/memory.vcxproj $BochsSrcHome/memory/

# mv $vs2019svFHome/gui.vcxproj $BochsSrcHome/gui/

# mv $vs2019svFHome/iodev.vcxproj $BochsSrcHome/iodev/
# mv $vs2019svFHome/iodev_usb.vcxproj $BochsSrcHome/iodev/
# mv $vs2019svFHome/iodev_display.vcxproj $BochsSrcHome/iodev/
# mv $vs2019svFHome/iodev_hdimage.vcxproj $BochsSrcHome/iodev/
# mv $vs2019svFHome/iodev_network.vcxproj $BochsSrcHome/iodev/


# mv $vs2019svFHome/bx_debug.vcxproj $BochsSrcHome/bx_debug/


mv $vs2019svFHome  $BochsSrcHome/bx_debug/
