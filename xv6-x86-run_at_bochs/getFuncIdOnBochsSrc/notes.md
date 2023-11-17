
## 以 bochs 调试器 找到 funcId汇编


``` /crk/bochs/bochs/bochs  -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc  ```




```shell

# 0008:0000000000007d81

break *0x7c00
step #很多次,直到地址变成32位的

break 0x0000000000007d81
continue


'
(0) Breakpoint 2, 0x0000000000007d81 in ?? ()
(0) [0x000000007d81] 0008:0000000000007d81 (unk. ctxt): call dword ptr ds:0x00010018 ; ff1518000100

<bochs:26> bt

00007be0 -> 00007d81 ((null))
00007bf8 -> 00007c4d (<unknown>)
00000000 -> f000ff53 (<unknown>)
bx_dbg_read_linear: physical memory read error (phy=0x0000f000ff57, lin=0x00000000f000ff57)

<bochs:27> reg
...
rip: 00000000_00007d81

<bochs:28> u /30
0000000000007d81: (                    ): call dword ptr ds:0x00010018 ; ff1518000100
....



<bochs:29> step

(0) [0x00000010000c] 0008:000000000010000c (unk. ctxt): mov eax, cr4              ; 0f20e0

<bochs:30> u /30
000000000010000c: (                    ): mov eax, cr4              ; 0f20e0
...
#这三条指令就是 funcId汇编
0000000000100047: (                    ): jmp .+9  (0x00100052)     ; eb09
0000000000100049: (                    ): or edi, 0xffffffff        ; 83cfff
000000000010004c: (                    ): or edi, 0x0002bf20        ; 81cf20bf0200
...
'



<bochs:31> break *0x0000000000100047

<bochs:32> continue
(0) Breakpoint 3, 0x0000000080100047 in ?? ()

(0) [0x000000100047] 0008:0000000080100047 (unk. ctxt): jmp .+9  (0x80100052)     ; eb09

<bochs:33> u /5
0000000080100047: (                    ): jmp .+9  (0x80100052)     ; eb09
0000000080100049: (                    ): or edi, 0xffffffff        ; 83cfff
000000008010004c: (                    ): or edi, 0x0002bf20        ; 81cf20bf0200
...

<bochs:38> reg
...
rip: 00000000_80100047
...

```


