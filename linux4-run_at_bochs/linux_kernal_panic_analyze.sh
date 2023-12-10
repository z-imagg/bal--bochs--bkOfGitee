
#内核崩溃时的日志，其中含 调用栈， 如下:
"
driver
0801            51184 sda1 5324f63e-01
     
Kernel panic - not syncing:VFS：Unable to mount root fs on unknown-block(0,0)
CPU： PID:1 Comm: swapper/0 Not tainted 4.14.332+ #3
Harduare name：  , BIOSBochs2.729/12/2019
Call Trace:
dump_stack+0x65/0x79
panic+0xb3/x1eb
mount_block_root+0x13c/0x1b1
? set_attr_rdpmc+0x90/0x90
? SyS_mknod+0x17/0x20
mount_root+0xf1/0xf8
? SyS_unlink+0x10/0x20
prepare_namespace+0x121/0x152
kernel_init_freeable+0x1d1/0x1e3
? rest_init+0xa0/0xa0
kernel_init+0x13/0x150
ret_from_fork+0x2e/0x38
Kernel Offset: 0x0 from Oxc1000000 (relocation range: 0XC0000000-0xc27effff
--- [ end Kernel panic not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
"

cd /crk/linux-stable/

#所用linux kernel代码仓库 分支、commitId如下:
git branch --show-current
#linux-4.14.y-dev
git rev-parse HEAD
#8115121212cb07bbcc9a0794ace2778e3afb57fb

#牵涉的各函数 所在源文件 如下:
grep mount_block_root funcIdDescLs.txt.csv
    # init/do_mounts.c,382,1,40013,mount_block_root,4,13
    grep mount_root funcIdDescLs.txt.csv
    # init/do_mounts.c,512,1,40015,mount_root,4,15
    grep prepare_namespace funcIdDescLs.txt.csv
    #init/do_mounts.c,549,1,40016,prepare_namespace,4,16
    grep kernel_init_freeable funcIdDescLs.txt.csv
    # init/main.c,1040,1,30029,kernel_init_freeable,3,29
    grep kernel_init funcIdDescLs.txt.csv
    # init/main.c,994,1,30000,kernel_init,3,0
    grep ret_from_fork funcIdDescLs.txt.csv
    #无函数 ret_from_fork



objdump --source     init/do_mounts.o > init/do_mounts.o.my.S
"
000001f4 <mount_block_root>:                                             #0. 此即  mount_block_root == 0X1f4
 1f4:	55                   	push   %ebp
 ...
 32b:	e8 fc ff ff ff       	call   32c <mount_block_root+0x138>      #2.  仔细看此行  mount_block_root+0x138 == 0X32c, 跳转 的 目的地址 0X32C 并不是某指令的开头 此即 跳转到非法指令，因此崩溃。  
 (备注 地址0X32C 附近 只有 地址 0x32b 、 地址0x330 是指令开头）
 330:	f6 45 cc 01          	testb  $0x1,-0x34(%ebp)                  #1.  panic截图CallTrace中的 'mount_block_root+0x13c' == 0X330 即此行, 因此崩溃的是上一行
 334:	75 09                	jne    33f <mount_block_root+0x14b>
 336:	83 4d cc 01          	orl    $0x1,-0x34(%ebp)
 33a:	e9 4e ff ff ff       	jmp    28d <mount_block_root+0x99>

000003a5 <mount_root>:                                       #0. 此即  mount_root == 0X3a5
 3a5:	55                   	push   %ebp
 ...
 491:	e8 fc ff ff ff       	call   492 <mount_root+0xed> #2. mount_root+0xed == 0x492, 跳转 的 目的地址 0x492 并不是某指令的开头 此即 跳转到非法指令，因此崩溃。  
 (备注 地址 0x492 附近 只有 地址 0x491 、 地址0x496 是指令开头）
 496:	8d 65 f8             	lea    -0x8(%ebp),%esp       #1. panic截图CallTrace中的 'mount_root+0xf1' == 0x496 , 即此行，因此奔溃的是上一行.
 499:	5b                   	pop    %ebx
 49a:	5e                   	pop    %esi
 49b:	5d                   	pop    %ebp
 49c:	c3                   	ret    
"

objdump --source init/main.o > init/main.o.my.S
"
0000049d <prepare_namespace>:                                            #0. 此即  prepare_namespace == 0X49d
 49d:	55                   	push   %ebp
 ...
 5b9:	e8 fc ff ff ff       	call   5ba <prepare_namespace+0x11d>     #2. prepare_namespace+0x11d == 0x5ba, 跳转 的 目的地址 0x5ba 并不是某指令的开头 此即 跳转到非法指令，因此崩溃。  
 (备注 地址 0x5ba 附近 只有 地址 0x5b9 、 地址 0x5be 是指令开头）
 5be:	b8 83 00 00 00       	mov    $0x83,%eax                        #1. prepare_namespace+0x121 == 0x5be
 ...
 5ee:	c3       
"