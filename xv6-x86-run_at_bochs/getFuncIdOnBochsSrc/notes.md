
## 以 bochs 调试器 找到 funcId汇编


```shell
rm -fr /crk/bochs/xv6-x86/*.img.lock
gdb  --args /crk/bochs/bochs/bochs  -f /crk/bochs/xv6-x86-run_at_bochs/xv6-x86.bxrc

```

```shell

(gdb) break fetchDecode32


(gdb) run

# Enable debuginfod for this session? (y or [n]) y

# 1. Restore factory default configuration
# 2. Read options from...
# 3. Edit options
# 4. Save options to...
# 5. Restore the Bochs state from...
# 6. Begin simulation
# 7. Quit now

Please choose one: [6] 直接回车即选择6(bochs开始运行,即开始模拟)



# Event type: PANIC
# Device: [SNDCTL]
# Message: Could not open wave output device

# A PANIC has occurred.  Do you want to:
#   cont       - continue execution
#   alwayscont - continue execution, and don't ask again.
#                This affects only PANIC events from device [SNDCTL]
#   die        - stop execution now
#   abort      - dump core 
#   debug      - continue and return to bochs debugger
Choose one of the actions above: [die] cont  #这里bochs说没有音频设备, 忽略即可, 即输入cont(即continue 即继续运行)


# 引发了gdb断点: 
# Breakpoint 1.2, disasm (opcode=0x55555719eb80 <bx_disasm_ibuf> "\352", <incomplete sequence \340>, is_32=false, is_64=false, disbufptr=0x55555719eba0 <bx_disasm_tbuf> "",   i=0x7fffffffcf50, cs_base=4294901760, rip=65520, style=BX_DISASM_INTEL) at decoder/disasm.cc:887


#但这时为xv6开头的 bios ROM和磁盘引导扇区,因此 继续运行
(gdb) continue 1000

#bochs调试器命令行 
# (0) [0x0000fffffff0] f000:fff0 (unk. ctxt): jmpf 0xf000:e05b          ; ea5be000f0 #看地址   f000:fff0 ,这是bios ROM的第一条指令
#bochs调试器命令行下, 在磁盘引导山区的第一条指令即0x7c00处下断点
<bochs:1> break *0x7c00
#bochs调试器下,继续运行
<bochs:4> continue
#bochs调试器停在磁盘引导扇区第一条指令0x7c00地址处
(0) Breakpoint 1, 0x0000000000007c00 in ?? ()
(0) [0x000000007c00] 0000:7c00 (unk. ctxt): cli                       ; fa

#通过人工next...step...很多次, 发现 bochs调试器 只要执行到地址 0008:0000000000007d81  即 不再出现bochs调试器命令行, 因此 在该地址处下断点:
<bochs:3> break *0x0000000000007d81

#bochs调试器下,继续运行
<bochs:4> continue
(0) Breakpoint 2, 0x0000000000007d81 in ?? ()
(0) [0x000000007d81] 0008:0000000000007d81 (unk. ctxt): call dword ptr ds:0x00010018 ; ff1518000100  #xv6中调用了某个函数, 应该是c代码中的函数

#bochs调试器下, 打印xv6-x86源码的调用栈
<bochs:5> bt
00007be0 -> 00007d81 ((null))
00007bf8 -> 00007c4d (<unknown>)
00000000 -> f000ff53 (<unknown>)
bx_dbg_read_linear: physical memory read error (phy=0x0000f000ff57, lin=0x00000000f000ff57)

#bochs调试器下, 单步执行进入该函数
<bochs:6> step
(0) [0x00000010000c] 0008:000000000010000c (unk. ctxt): mov eax, cr4              ; 0f20e0

#bochs调试器下, 打印该函数的指令
<bochs:7> u /300000  #故意要求bochs调试器反汇编大量行, 以触发gdb调试器在bochs代码的函数disasm上的断点
000000000010000c: (                    ): mov eax, cr4              ; 0f20e0
000000000010000f: (                    ): or eax, 0x00000010        ; 83c810
0000000000100012: (                    ): mov cr4, eax              ; 0f22e0
0000000000100015: (                    ): mov eax, 0x0010a000       ; b800a01000
000000000010001a: (                    ): mov cr3, eax              ; 0f22d8
000000000010001d: (                    ): mov eax, cr0              ; 0f20c0
0000000000100020: (                    ): or eax, 0x80010000        ; 0d00000180
0000000000100025: (                    ): mov cr0, eax              ; 0f22c0
0000000000100028: (                    ): mov esp, 0x801164d0       ; bcd0641180
000000000010002d: (                    ): mov eax, 0x80103630       ; b830361080
0000000000100032: (                    ): jmp eax                   ; ffe0
0000000000100034: (                    ): nop                       ; 6690
0000000000100036: (                    ): nop                       ; 6690
0000000000100038: (                    ): nop                       ; 6690
000000000010003a: (                    ): nop                       ; 6690
000000000010003c: (                    ): nop                       ; 6690
000000000010003e: (                    ): nop                       ; 6690
0000000000100040: (                    ): push ebp                  ; 55
0000000000100041: (                    ): mov ebp, esp              ; 89e5
0000000000100043: (                    ): push ebx                  ; 53
0000000000100044: (                    ): sub esp, 0x0000000c       ; 83ec0c
#这三行是 插入到 xv6-x86 函数开头的 funcId汇编
0000000000100047: (                    ): jmp .+9  (0x00100052)     ; eb09
0000000000100049: (                    ): or edi, 0xffffffff        ; 83cfff
000000000010004c: (                    ): or edi, 0x0002bf20        ; 81cf20bf0200
#
0000000000100052: (                    ): push 0x80107ca0           ; 68a07c1080
0000000000100057: (                    ): mov ebx, 0x8010b554       ; bb54b51080

#触发了gdb断点
-----TODO######

#gdb调试器命令行, 打印bochs源码的调用栈
(gdb) bt
#0  fetchDecode32 (iptr=0x55555719eb80 <bx_disasm_ibuf> "\215pP\3515\377\377\377\203\354\004\215^\260\215\264", is_32=true, i=0x7fffffffc6b0, remainingInPage=16)
    at decoder/fetchdecode32.cc:2375
#1  0x000055555582609f in disasm (opcode=0x55555719eb80 <bx_disasm_ibuf> "\215pP\3515\377\377\377\203\354\004\215^\260\215\264", is_32=true, is_64=false, 
    disbufptr=0x55555719eba0 <bx_disasm_tbuf> "shl eax, 0x04", i=0x7fffffffc6b0, cs_base=0, rip=1050117, style=BX_DISASM_INTEL) at decoder/disasm.cc:891
#2  0x00005555557a1b7d in bx_dbg_disasm_wrapper (is_32=true, is_64=false, cs_base=0, ip=1050117, 
    instr=0x55555719eb80 <bx_disasm_ibuf> "\215pP\3515\377\377\377\203\354\004\215^\260\215\264", disbuf=0x55555719eba0 <bx_disasm_tbuf> "shl eax, 0x04", disasm_style=-1)
    at dbg_main.cc:4449
#3  0x000055555579ea91 in bx_dbg_disassemble_command (format=0x5555578810c0 "/300000", from=1050117, to=18446744073709551615) at dbg_main.cc:3054
#4  0x000055555579e979 in bx_dbg_disassemble_current (format=0x5555578810c0 "/300000") at dbg_main.cc:3019
#5  0x00005555557aa031 in bxparse () at /crk/bochs/bochs/bx_debug/parser.y:998
#6  0x000055555579717e in bx_dbg_interpret_line (cmd=0x55555719a600 <tmp_buf> "u /300000\n") at dbg_main.cc:300
#7  0x00005555557973d2 in bx_dbg_user_input_loop () at dbg_main.cc:353
#8  0x00005555557970f7 in bx_dbg_main () at dbg_main.cc:286
#9  0x000055555563a072 in bx_begin_simulation (argc=3, argv=0x7fffffffdf38) at main.cc:1037
#10 0x000055555584a2fe in bx_real_sim_c::begin_simulation (this=0x5555571b7100, argc=3, argv=0x7fffffffdf38) at siminterface.cc:887
#11 0x000055555585b0dc in bx_text_config_interface (menu=2) at textconfig.cc:465
#12 0x000055555585b440 in bx_text_config_interface (menu=0) at textconfig.cc:509
#13 0x000055555585e434 in text_ci_callback (userdata=0x0, command=CI_START) at textconfig.cc:1116
#14 0x000055555584a2af in bx_real_sim_c::configuration_interface (this=0x5555571b7100, ignore=0x555555886b37 "textconfig", command=CI_START) at siminterface.cc:880
#15 0x00005555556388d4 in bxmain () at main.cc:335
#16 0x0000555555638970 in main (argc=3, argv=0x7fffffffdf38) at main.cc:551


```


