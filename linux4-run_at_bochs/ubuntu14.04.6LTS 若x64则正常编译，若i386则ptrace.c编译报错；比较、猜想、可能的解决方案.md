### 1.真机 i386/Ubuntu14.04.6LTS, 以下编译命令报错。 
> 真机i386下此编译命令和下面的x64下编译命令主要差异是  -m32:-m64 -O2:-Os -fstack-protector:-fno-stack-protector 等.
```shell
gcc -Wp,-MD,arch/x86/kernel/.ptrace.o.d  -nostdinc -isystem /usr/lib/gcc/i686-linux-gnu/4.8/include -I/crk/bochs/linux2.6-run_at_bochs/linux-2.6.39.4/arch/x86/include -Iinclude  -include include/generated/autoconf.h -D__KERNEL__ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -fno-delete-null-pointer-checks -O2 -m32 -msoft-float -mregparm=3 -freg-struct-return -mpreferred-stack-boundary=2 -march=i686 -mtune=generic -maccumulate-outgoing-args -Wa,-mtune=generic32 -ffreestanding -fstack-protector -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 -DCONFIG_AS_CFI_SECTIONS=1 -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -Wframe-larger-than=1024 -fno-omit-frame-pointer -fno-optimize-sibling-calls -g -pg -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -DCC_HAVE_ASM_GOTO    -D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(ptrace)"  -D"KBUILD_MODNAME=KBUILD_STR(ptrace)" -c -o arch/x86/kernel/.tmp_ptrace.o arch/x86/kernel/ptrace.c;
```


### 2. docker x64/Ubuntu14.04.6LTS , 以下编译命令正常
```shell
gcc -Wp,-MD,arch/x86/kernel/.ptrace.o.d  -nostdinc -isystem /usr/lib/gcc/x86_64-linux-gnu/4.8/include -I/crk/bochs/linux2.6-run_at_bochs/linux-2.6.39.4/arch/x86/include -Iinclude  -include include/generated/autoconf.h -D__KERNEL__ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -fno-delete-null-pointer-checks -Os -m64 -mtune=generic -mno-red-zone -mcmodel=kernel -funit-at-a-time -maccumulate-outgoing-args -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 -DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_FXSAVEQ=1 -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -Wframe-larger-than=2048 -fno-stack-protector -fno-omit-frame-pointer -fno-optimize-sibling-calls -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -DCC_HAVE_ASM_GOTO    -D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(ptrace)"  -D"KBUILD_MODNAME=KBUILD_STR(ptrace)" -c -o arch/x86/kernel/ptrace.o arch/x86/kernel/ptrace.c
```


### 3. docker i386/Ubuntu14.04.6LTS （宿主机是x64 ubuntu23.04), 命令正常.
> 注意看以下编译命令中没有 -m32, 说明 x64宿主机下的docker实例为i386实际上还是处于x64环境. 因此 "docker i386/Ubuntu14.04.6LTS" == "docker x64/Ubuntu14.04.6LTS", 而x64下此编译命令正常。
```shell
gcc -Wp,-MD,arch/x86/kernel/.ptrace.o.d  -nostdinc -isystem /usr/lib/gcc/i686-linux-gnu/4.8/include -I/crk/bochs/linux2.6-run_at_bochs/linux-2.6.39.4/arch/x86/include -Iinclude  -include include/generated/autoconf.h -D__KERNEL__ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -fno-delete-null-pointer-checks -Os -m64 -mtune=generic -mno-red-zone -mcmodel=kernel -funit-at-a-time -maccumulate-outgoing-args -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 -DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_FXSAVEQ=1 -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -Wframe-larger-than=2048 -fno-stack-protector -fno-omit-frame-pointer -fno-optimize-sibling-calls -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -DCC_HAVE_ASM_GOTO    -D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(ptrace)"  -D"KBUILD_MODNAME=KBUILD_STR(ptrace)" -c -o arch/x86/kernel/ptrace.o arch/x86/kernel/ptrace.c;  
```

## 尝试解释原因 并给出 猜想的可能解决方案
### 现象: 
- linux-2.6.39.4.tar.gz 不用修改 就可以在x64 ubuntu14.04.6LST下直接编译
- linux-2.6.39.4.tar.gz 需要修改 也可以在i386 ubuntu14.04.6LST下编译, 但我不想修改, 因为修改是潜在风险.

### 猜想的可能解决方案
- **尝试在 真机 i386/ubuntu14.04.6LTS 下编译 比 linux-2.6.39.4.tar.gz 版本低 的其他2.6 **

> 比如 在 真机 i386/ubuntu14.04.6LTS 下编译 linux-2.6.36.tar.gz , 能否不用修改 即可正常编译? ,

>>> 这里只是举例，实际上  在  i386/ubuntu14.04.6LTS 下编译 linux-2.6.36.tar.gz 也报错


## 备注
### i386 ubuntu14.04.6LST 对 linux-2.6.39.4.tar.gz/arch/x86/include/asm/ptrace.h 修改 以能正常编译  (但我不想修改，因为修改是潜在风险)
```vi arch/x86/include/asm/ptrace.h``` ：
#### 130行 添加 ```#include <linux/linkage.h>```

#### 142 143行 修改代码:
> 原始代码:
```cpp
extern long syscall_trace_enter(struct pt_regs *);
extern void syscall_trace_leave(struct pt_regs *);
```

> 修改后的代码:
```cpp
extern asmregparm long syscall_trace_enter(struct pt_regs *); 
extern asmregparm void syscall_trace_leave(struct pt_regs *);
```


