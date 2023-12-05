#此时在ubuntu2264下
cd /home/z/linux-4.14.259



#原始命令是 :
#   i686-linux-gnu-gcc -Wp,-MD,net/netfilter/.xt_addrtype.o.d -nostdinc -isystem /usr/lib/gcc-cross/i686-linux-gnu/11/include -I./arch/x86/include -I./arch/x86/include/generated  -I./include -I./arch/x86/include/uapi -I./arch/x86/include/generated/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h -D__KERNEL__ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -fshort-wchar -Werror-implicit-function-declaration -Wno-format-security -std=gnu89 -fno-PIE -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx -fcf-protection=none -m32 -msoft-float -mregparm=3 -freg-struct-return -fno-pic -mpreferred-stack-boundary=2 -march=i686 -mtune=generic -Wa,-mtune=generic32 -ffreestanding -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 -DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_SSSE3=1 -DCONFIG_AS_CRC32=1 -DCONFIG_AS_AVX=1 -DCONFIG_AS_AVX2=1 -DCONFIG_AS_AVX512=1 -DCONFIG_AS_SHA1_NI=1 -DCONFIG_AS_SHA256_NI=1 -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -mindirect-branch=thunk-extern -mindirect-branch-register -fno-jump-tables -fno-delete-null-pointer-checks -Wno-frame-address -Wno-format-truncation -Wno-format-overflow -Wno-int-in-bool-context -Wno-address-of-packed-member -Wno-attribute-alias -O2 -fno-allow-store-data-races -DCC_HAVE_ASM_GOTO -Wframe-larger-than=1024 -fno-stack-protector -Wno-unused-but-set-variable -Wno-unused-const-variable -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-var-tracking-assignments -Wdeclaration-after-statement -Wno-pointer-sign -Wno-stringop-truncation -Wno-zero-length-bounds -Wno-array-bounds -Wno-stringop-overflow -Wno-restrict -Wno-maybe-uninitialized -fno-strict-overflow -fno-merge-all-constants -fmerge-constants -fno-stack-check -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes -Werror=date-time -Werror=incompatible-pointer-types -Werror=designated-init -fmacro-prefix-map=./= -Wno-packed-not-aligned  -DMODULE  -DKBUILD_BASENAME='"xt_addrtype"'  -DKBUILD_MODNAME='"xt_addrtype"' -c -o net/netfilter/xt_addrtype.o net/netfilter/xt_addrtype.c


# -Wa,-mtune=generic32 \
# -Wno-shift-overflow  -Wno-zero-length-array -Wno-shift-overflow  -Wno-uninitialized -Wno-over-aligned -Wunknown-warning-option  # clang选项和gcc选项有差异，这些是clang选项， 根据clang报错 提示 的来的 

#
#直接改造为:
/app/llvm_release_home/clang+llvm-15.0.0-x86_64-linux-gnu-rhel-8.4/bin/clang \
-D__OPTIMIZE__ \
-Wp,-MD,net/netfilter/.xt_addrtype.o.d \
-Wall -Wundef -Wstrict-prototypes -Wno-trigraphs \
-Werror-implicit-function-declaration -Wno-format-security \
-Wno-sign-compare \
-Wno-frame-address -Wno-format-truncation -Wno-format-overflow -Wno-int-in-bool-context -Wno-address-of-packed-member -Wno-attribute-alias \
-Wframe-larger-than=1024 \
-Wno-unused-but-set-variable -Wno-unused-const-variable -fno-omit-frame-pointer \
-Wdeclaration-after-statement -Wno-pointer-sign -Wno-stringop-truncation -Wno-zero-length-bounds -Wno-array-bounds -Wno-stringop-overflow -Wno-restrict -Wno-maybe-uninitialized \
-Werror=implicit-int -Werror=strict-prototypes -Werror=date-time -Werror=incompatible-pointer-types -Werror=designated-init \
-Wno-packed-not-aligned \
 -std=gnu89   -D__KERNEL__    -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 -DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_SSSE3=1 -DCONFIG_AS_CRC32=1 -DCONFIG_AS_AVX=1 -DCONFIG_AS_AVX2=1 -DCONFIG_AS_AVX512=1 -DCONFIG_AS_SHA1_NI=1 -DCONFIG_AS_SHA256_NI=1   -DCC_HAVE_ASM_GOTO   -DMODULE  -DKBUILD_BASENAME='"xt_addrtype"'  -DKBUILD_MODNAME='"xt_addrtype"'  -isystem /usr/lib/gcc-cross/i686-linux-gnu/11/include -I./arch/x86/include -I./arch/x86/include/generated  -I./include -I./arch/x86/include/uapi -I./arch/x86/include/generated/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h  -Xclang   -load -Xclang  /crk/clang-add-funcIdAsm/build/lib/libCTk.so  -Xclang   -add-plugin -Xclang  CTk      -c  net/netfilter/xt_addrtype.c

#   （由于 clang插件只是语法层面的，因此 上述 命令中  后端部分参数    -m32   -march=i686     可以丢弃）

#会报错:


# ./arch/x86/include/asm/ptrace.h:208:16: error: no member named 'ds' in 'pt_regs'
            # offset == offsetof(struct pt_regs, ds) ||
                      # ^                        ~~
# ./include/linux/stddef.h:17:32: note: expanded from macro 'offsetof'
# define offsetof(TYPE, MEMBER)  __compiler_offsetof(TYPE, MEMBER)


# ./arch/x86/include/asm/ptrace.h:209:16: error: no member named 'es' in 'pt_regs'
            # offset == offsetof(struct pt_regs, es) ||
                      # ^                        ~~
# ./include/linux/stddef.h:17:32: note: expanded from macro 'offsetof'
# define offsetof(TYPE, MEMBER)  __compiler_offsetof(TYPE, MEMBER)


# ./arch/x86/include/asm/ptrace.h:210:16: error: no member named 'fs' in 'pt_regs'
            # offset == offsetof(struct pt_regs, fs) ||

#修复报错 BUILD_BUG_ON :
#  根据 linux-4.14.259/include/linux/build_bug.h : 67 行: 可知 ，打开宏 __OPTIMIZE__ (即增加选项-D__OPTIMIZE__）  即可 关闭 BUILD_BUG_ON，
#ifndef __OPTIMIZE__
#define BUILD_BUG_ON(condition) ((void)sizeof(char[1 - 2*!!(condition)]))
#else
#define BUILD_BUG_ON(condition) \
	BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
#endif

# ./include/net/dst.h:255:2: error: array size is negative
        # BUILD_BUG_ON(offsetof(struct dst_entry, __refcnt) & 63);
 
# ./include/net/dst.h:255:2: error: array size is negative
        # BUILD_BUG_ON(offsetof(struct dst_entry, __refcnt) & 63);


#   ...

# 但是 clang插件 修改了部分函数, 但 xt_addrtype.c:240行 的  函数 "static void __exit addrtype_mt_exit(void)" 没有修改
grep -Hn -B 1  "\{"  net/netfilter/xt_addrtype.c
#   以下结果 手工删除了无关内容
# net/netfilter/xt_addrtype.c-38-                     const struct in6_addr *addr, u16 mask)
# net/netfilter/xt_addrtype.c:39:{__asm__  __volatile__ (   "jmp 0f \n\t"    "or $0xFFFFFFFF,%%edi \n\t"    "or $0,%%edi \n\t"    "0: \n\t" : : ); /*filePath=net/netfilter/xt_addrtype.c,line=38,column=1,abs_location_id=0,funcName=match_lookup_rt6,srcFileId=0,locationId=0*/

# net/netfilter/xt_addrtype.c-82-                         const struct in6_addr *addr, u16 mask)
# net/netfilter/xt_addrtype.c:83:{__asm__  __volatile__ (   "jmp 0f \n\t"    "or $0xFFFFFFFF,%%edi \n\t"    "or $1,%%edi \n\t"    "0: \n\t" : : ); /*filePath=net/netfilter/xt_addrtype.c,line=82,column=1,abs_location_id=1,funcName=match_type6,srcFileId=0,locationId=1*/

# net/netfilter/xt_addrtype.c-102-        const struct sk_buff *skb, const struct xt_addrtype_info_v1 *info)
# net/netfilter/xt_addrtype.c:103:{__asm__  __volatile__ (   "jmp 0f \n\t"    "or $0xFFFFFFFF,%%edi \n\t"    "or $2,%%edi \n\t"    "0: \n\t" : : ); /*filePath=net/netfilter/xt_addrtype.c,line=102,column=1,abs_location_id=2,funcName=addrtype_mt6,srcFileId=0,locationId=2*/

# net/netfilter/xt_addrtype.c-118-                              __be32 addr, u_int16_t mask)
# net/netfilter/xt_addrtype.c:119:{__asm__  __volatile__ (   "jmp 0f \n\t"    "or $0xFFFFFFFF,%%edi \n\t"    "or $3,%%edi \n\t"    "0: \n\t" : : ); /*filePath=net/netfilter/xt_addrtype.c,line=118,column=1,abs_location_id=3,funcName=match_type,srcFileId=0,locationId=3*/

# net/netfilter/xt_addrtype.c-124-addrtype_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
# net/netfilter/xt_addrtype.c:125:{__asm__  __volatile__ (   "jmp 0f \n\t"    "or $0xFFFFFFFF,%%edi \n\t"    "or $4,%%edi \n\t"    "0: \n\t" : : ); /*filePath=net/netfilter/xt_addrtype.c,line=124,column=1,abs_location_id=4,funcName=addrtype_mt_v0,srcFileId=0,locationId=4*/

# net/netfilter/xt_addrtype.c-142-addrtype_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
# net/netfilter/xt_addrtype.c:143:{__asm__  __volatile__ (   "jmp 0f \n\t"    "or $0xFFFFFFFF,%%edi \n\t"    "or $5,%%edi \n\t"    "0: \n\t" : : ); /*filePath=net/netfilter/xt_addrtype.c,line=142,column=1,abs_location_id=5,funcName=addrtype_mt_v1,srcFileId=0,locationId=5*/

# net/netfilter/xt_addrtype.c-169-static int addrtype_mt_checkentry_v1(const struct xt_mtchk_param *par)
# net/netfilter/xt_addrtype.c:170:{__asm__  __volatile__ (   "jmp 0f \n\t"    "or $0xFFFFFFFF,%%edi \n\t"    "or $6,%%edi \n\t"    "0: \n\t" : : ); /*filePath=net/netfilter/xt_addrtype.c,line=169,column=1,abs_location_id=6,funcName=addrtype_mt_checkentry_v1,srcFileId=0,locationId=6*/

# net/netfilter/xt_addrtype.c-234-static int __init addrtype_mt_init(void)
# net/netfilter/xt_addrtype.c:235:{__asm__  __volatile__ (   "jmp 0f \n\t"    "or $0xFFFFFFFF,%%edi \n\t"    "or $7,%%edi \n\t"    "0: \n\t" : : ); /*filePath=net/netfilter/xt_addrtype.c,line=234,column=1,abs_location_id=7,funcName=addrtype_mt_init,srcFileId=0,locationId=7*/

# net/netfilter/xt_addrtype.c-240-static void __exit addrtype_mt_exit(void)   #这里看 函数 "static void __exit addrtype_mt_exit(void)" 没有被修改
# net/netfilter/xt_addrtype.c:241:{    
