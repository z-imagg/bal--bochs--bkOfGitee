```shell
objdump -d /crk/bochs/xv6-x86/kernel | grep -A 3 -B 3 "83 cf ff"

"""
...

801079a1:	89 e5                	mov    %esp,%ebp
801079a3:	83 ec 08             	sub    $0x8,%esp
801079a6:	eb 09                	jmp    801079b1 <kvmalloc+0x11>  #funcId汇编 指令1
801079a8:	83 cf ff             	or     $0xffffffff,%edi          #funcId汇编 指令2
801079ab:	81 cf a4 68 06 00    	or     $0x668a4,%edi             #funcId汇编 指令3
801079b1:	e8 5a ff ff ff       	call   80107910 <setupkvm>
801079b6:	a3 c4 54 11 80       	mov    %eax,0x801154c4
801079bb:	eb 09                	jmp    801079c6 <kvmalloc+0x26>  #funcId汇编 指令1
801079bd:	83 cf ff             	or     $0xffffffff,%edi          #funcId汇编 指令2
801079c0:	81 cf a5 68 06 00    	or     $0x668a5,%edi             #funcId汇编 指令3
801079c6:	eb 09                	jmp    801079d1 <kvmalloc+0x31>
801079c8:	83 cf ff             	or     $0xffffffff,%edi
801079cb:	81 cf bd 8f 06 00    	or     $0x68fbd,%edi
801079d1:	05 00 00 00 80       	add    $0x80000000,%eax
801079d6:	0f 22 d8             	mov    %eax,%cr3

....
"""

```



```shell
make_xv6_bochs_run=false ./getFuncId.sh

#以下在gdb终端下输入的命令:

info proc mappings

# Start Addr           End Addr       Size     Offset  Perms  objfile
# 0x555555554000     0x5555556a3000   0x14f000        0x0  r--p   /crk/bochs/bochs/bochs
# 0x5555556a3000     0x5555559c6000   0x323000   0x14f000  r-xp   /crk/bochs/bochs/bochs
# 0x5555559c6000     0x555555af1000   0x12b000   0x472000  r--p   /crk/bochs/bochs/bochs
# 0x555555af1000     0x555555afa000     0x9000   0x59c000  r--p   /crk/bochs/bochs/bochs
# 0x555555afa000     0x555555b38000    0x3e000   0x5a5000  rw-p   /crk/bochs/bochs/bochs
# 0x555555b38000     0x55555736b000  0x1833000        0x0  rw-p   [heap]
# 0x55555736b000     0x555557618000   0x2ad000        0x0  rw-p   [heap]
# 0x7fffd5339000     0x7ffff6e00000 0x21ac7000        0x0  rw-p   

find /w 0x555555554000,     0x5555556a3000 ,0x09eb
find /w 0x5555556a3000,     0x5555559c6000 ,0x09eb
find /w 0x5555559c6000,     0x555555af1000 ,0x09eb
find /w 0x555555af1000,     0x555555afa000 ,0x09eb
find /w 0x555555afa000,     0x555555b38000 ,0x09eb
find /w 0x555555b38000,     0x55555736b000 ,0x09eb
find /w 0x55555736b000,     0x555557639000 ,0x09eb

# 0x555555558530  #这里是巧合, 巧合理由间下方 "巧合理由"
# 1 pattern found.
# Pattern not found.
# Pattern not found.
# Pattern not found.
# Pattern not found.
# Pattern not found.
# 0x55555741ff58  #这里是巧合, 巧合理由间下方 "巧合理由"
# warning: Unable to access 7717 bytes of target memory at 0x5555576371dc, halting search.
# 1 pattern found.




# find /w 0x555555554000,     0x5555556a3000 ,0x09eb
# find /w 0x5555556a3000,     0x5555559c6000 ,0x09eb
# find /w 0x5555559c6000,     0x555555af1000 ,0x09eb
# find /w 0x555555af1000,     0x555555afa000 ,0x09eb
# find /w 0x555555afa000,     0x555555b38000 ,0x09eb
# find /w 0x555555b38000,     0x55555736b000 ,0x09eb
# find /w 0x55555736b000,     0x555557639000 ,0x09eb
#巧合

# find /b  0x555555554000,     0x5555556a3000 ,0x83,0xcf
# find /b  0x5555556a3000,     0x5555559c6000 ,0x83,0xcf
# find /b  0x5555559c6000,     0x555555af1000 ,0x83,0xcf
# find /b  0x555555af1000,     0x555555afa000 ,0x83,0xcf
# find /b  0x555555afa000,     0x555555b38000 ,0x83,0xcf
# find /b  0x555555b38000,     0x55555736b000 ,0x83,0xcf
# find /b  0x55555736b000,     0x555557639000 ,0x83,0xcf

x /4xw 0x555555b6f0d1
# 0x555555b6f0d1 <bx_cpu+220241>:	0x5555cf83	0xff000055	0xffffffff	0x00ffffff



find /w 0x555555554000,     0x5555556a3000,  0x83cf
find /w 0x5555556a3000,     0x5555559c6000,  0x83cf
find /w 0x5555559c6000,     0x555555af1000,  0x83cf
find /w 0x555555af1000,     0x555555afa000,  0x83cf
find /w 0x555555afa000,     0x555555b38000,  0x83cf
find /w 0x555555b38000,     0x55555736b000,  0x83cf
find /w 0x55555736b000,     0x555557639000,  0x83cf

# Pattern not found.
# Pattern not found.
# 0x5555559fe7ae <_ZL17BxOpcodeTable0FF3+14>
# 0x555555a37fae <_ZL17BxOpcodeTable0FF3+14>
# 2 patterns found.
# Pattern not found.
# Pattern not found.
# Pattern not found.
# warning: Unable to access 12926 bytes of target memory at 0x555557635d83, halting search.
# Pattern not found.

rwatch *0x5555559fe7ae
#此内存读断点 没有停下来

```



> 巧合理由:
```
(gdb) x /20xw 0x555555558530
0x555555558530:	0x000009eb	0x000009ef	0x000009f2	0x000009f5
0x555555558540:	0x00000000	0x000009f6	0x000009f8	0x000009fc
0x555555558550:	0x000009fe	0x00000a00	0x00000a01	0x00000a02
0x555555558560:	0x00000a04	0x00000000	0x00000a07	0x00000a09
0x555555558570:	0x00000000	0x00000000	0x00000a0a	0x00000a0b
(gdb) x /20xw 0x55555741ff58
0x55555741ff58:	0x000009eb	0x000000cb	0x573b62f0	0x00005555
0x55555741ff68:	0x57420020	0x00005555	0x57420040	0x00005555
0x55555741ff78:	0x57420060	0x00005555	0x00000000	0x00000000
0x55555741ff88:	0x00000000	0x00000000	0x00000000	0x00000000
0x55555741ff98:	0x00000000	0x00000000	0x00000100	0x00000000
#
```