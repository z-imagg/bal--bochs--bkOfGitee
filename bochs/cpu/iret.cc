////////////////////////////////////////////////////////////////////////
// $Id$
/////////////////////////////////////////////////////////////////////////
//
//   Copyright (c) 2005-2019 Stanislav Shwartsman
//          Written by Stanislav Shwartsman [sshwarts at sourceforge net]
//
//  This library is free software; you can redistribute it and/or
//  modify it under the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either
//  version 2 of the License, or (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public
//  License along with this library; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA B 02110-1301 USA
//
/////////////////////////////////////////////////////////////////////////

#define NEED_CPU_REG_SHORTCUTS 1
#include "bochs.h"
#include "cpu.h"
#define LOG_THIS BX_CPU_THIS_PTR

  void BX_CPP_AttrRegparmN(1)
BX_CPU_C::iret_protected(bxInstruction_c *i)
{
  Bit16u raw_cs_selector, raw_ss_selector;
  bx_selector_t cs_selector, ss_selector;
  Bit32u dword1, dword2;
  bx_descriptor_t cs_descriptor, ss_descriptor;

#if BX_SUPPORT_X86_64
  if (long_mode()) {
    long_iret(i);
    return;
  }
#endif

  if (BX_CPU_THIS_PTR get_NT())   /* NT = 1: RETURN FROM NESTED TASK */
  {//情况1. IRET: 嵌套任务返回
    /* what's the deal with NT & VM ? */
    Bit16u raw_link_selector;
    bx_selector_t   link_selector;
    bx_descriptor_t tss_descriptor;

    if (BX_CPU_THIS_PTR get_VM())
      BX_PANIC(("iret_protected: VM sholdn't be set here !"));

    BX_DEBUG(("IRET: nested task return; IRET: 嵌套任务返回;"));

    if (BX_CPU_THIS_PTR tr.cache.valid==0)
      BX_PANIC(("IRET: TR not valid"));

    // examine back link selector in TSS addressed by current TR
    raw_link_selector = system_read_word(BX_CPU_THIS_PTR tr.cache.u.segment.base);

    // must specify global, else #TS(new TSS selector)
    parse_selector(raw_link_selector, &link_selector);

    if (link_selector.ti) {
      BX_ERROR(("iret: link selector.ti=1"));
      exception(BX_TS_EXCEPTION, raw_link_selector & 0xfffc);
    }

    // index must be within GDT limits, else #TS(new TSS selector)
    fetch_raw_descriptor(&link_selector, &dword1, &dword2, BX_TS_EXCEPTION);

    // AR byte must specify TSS, else #TS(new TSS selector)
    // new TSS must be busy, else #TS(new TSS selector)
    parse_descriptor(dword1, dword2, &tss_descriptor);
    if (tss_descriptor.valid==0 || tss_descriptor.segment) {
      BX_ERROR(("iret: TSS selector points to bad TSS"));
      exception(BX_TS_EXCEPTION, raw_link_selector & 0xfffc);
    }
    if (tss_descriptor.type != BX_SYS_SEGMENT_BUSY_286_TSS &&
        tss_descriptor.type != BX_SYS_SEGMENT_BUSY_386_TSS)//描述符tss_descriptor类型为 BX_SYS_SEGMENT_BUSY_286_TSS 或 BX_SYS_SEGMENT_BUSY_386_TSS
    {
      BX_ERROR(("iret: TSS selector points to bad TSS"));
      exception(BX_TS_EXCEPTION, raw_link_selector & 0xfffc);
    }

    // TSS must be present, else #NP(new TSS selector)
    if (! IS_PRESENT(tss_descriptor)) {
      BX_ERROR(("iret: task descriptor.p == 0"));
      exception(BX_NP_EXCEPTION, raw_link_selector & 0xfffc);
    }

    // switch tasks (without nesting) to TSS specified by back link selector
    task_switch(i, &link_selector, &tss_descriptor,
                BX_TASK_FROM_IRET, dword1, dword2);
    //记录一条日志, 日志行的字段们： 选择子 link_selector、描述符 tss_descriptor
    std::string link_selector_json_text=BX_CPU_THIS -> selector_json_text("link_selt",&link_selector);
    std::string tss_descriptor_json_text=BX_CPU_THIS -> descriptor_json_text("tss_desc",&tss_descriptor);
    //csv日志=IRET中断返回指令函数模拟内的共用逻辑:iret_protected:@情况1_IRET_嵌套任务返回;link_selector_json_text;tss_descriptor_json_text
    BX_INFO(("~L~=返断程共逻:iret_protected__嵌任返:; %s; %s",link_selector_json_text.c_str(), tss_descriptor_json_text.c_str()));
    return;
  }

  /* NT = 0: INTERRUPT RETURN ON STACK -or STACK_RETURN_TO_V86 */
  unsigned top_nbytes_same;
  Bit32u new_eip = 0, new_esp, temp_ESP, new_eflags = 0;

  /* 16bit opsize  |   32bit opsize
   * ==============================
   * SS     eSP+8  |   SS     eSP+16
   * SP     eSP+6  |   ESP    eSP+12
   * -------------------------------
   * FLAGS  eSP+4  |   EFLAGS eSP+8
   * CS     eSP+2  |   CS     eSP+4
   * IP     eSP+0  |   EIP    eSP+0
   */

  if (i->os32L()) {
    top_nbytes_same = 12;
  }
  else {
    top_nbytes_same = 6;
  }

  if (BX_CPU_THIS_PTR sregs[BX_SEG_REG_SS].cache.u.segment.d_b)
    temp_ESP = ESP;
  else
    temp_ESP = SP;

  if (i->os32L()) {
    new_eflags      =          stack_read_dword(temp_ESP + 8);
    raw_cs_selector = (Bit16u) stack_read_dword(temp_ESP + 4);
    new_eip         =          stack_read_dword(temp_ESP + 0);

    // if VM=1 in flags image on stack then STACK_RETURN_TO_V86
    if (new_eflags & EFlagsVMMask) {
      if (CPL == 0) {
        stack_return_to_v86(new_eip, raw_cs_selector, new_eflags);
        return;
      }
      else BX_INFO(("iret: VM set on stack, CPL!=0"));
    }
  }
  else {
    new_eflags      = stack_read_word(temp_ESP + 4);
    raw_cs_selector = stack_read_word(temp_ESP + 2);
    new_eip         = stack_read_word(temp_ESP + 0);
  }

  parse_selector(raw_cs_selector, &cs_selector);

  // return CS selector must be non-null, else #GP(0)
  if ((raw_cs_selector & 0xfffc) == 0) {
    BX_ERROR(("iret: return CS selector null"));
    exception(BX_GP_EXCEPTION, 0);
  }

  // selector index must be within descriptor table limits,
  // else #GP(return selector)
  fetch_raw_descriptor(&cs_selector, &dword1, &dword2, BX_GP_EXCEPTION);
  parse_descriptor(dword1, dword2, &cs_descriptor);

  // return CS selector RPL must be >= CPL, else #GP(return selector)
  if (cs_selector.rpl < CPL) {
    BX_ERROR(("iret: return selector RPL < CPL"));
    exception(BX_GP_EXCEPTION, raw_cs_selector & 0xfffc);
  }

  // check code-segment descriptor
  check_cs(&cs_descriptor, raw_cs_selector, 0, cs_selector.rpl);

  if (cs_selector.rpl == CPL) {//情况2. 同权级中断返回

    BX_DEBUG(("INTERRUPT RETURN TO SAME PRIVILEGE LEVEL; 同权级中断返回; "));

#if BX_SUPPORT_CET
    if (ShadowStackEnabled(CPL)) {
      SSP = shadow_stack_restore(raw_cs_selector, cs_descriptor, new_eip);
    }
#endif

  Bit32u original_eip=(EIP);
    /* load CS-cache with new code segment descriptor */
    branch_far(&cs_selector, &cs_descriptor, new_eip, cs_selector.rpl);
    //记录一条日志, 日志行的字段们 : cs选择子 cs_selector 、 代码段描述符 cs_descriptor、 新eip new_eip
    std::string cs_selector_json_text=BX_CPU_THIS -> selector_json_text("cs_selt",&cs_selector);
    std::string cs_descriptor_json_text=BX_CPU_THIS -> descriptor_json_text("cs_desc",&cs_descriptor);
    //csv日志=IRET中断返回指令函数模拟内的共用逻辑:iret_protected:@情况2_同权级中断返回;cs_selector_json_text;cs_descriptor_json_text
    BX_INFO(("~L~=返断程共逻:iret_protected__同级返:; %s; %s; 0x%x; 0x%x",cs_selector_json_text.c_str(), cs_descriptor_json_text.c_str(), original_eip,new_eip));

    /* top 6/12 bytes on stack must be within limits, else #SS(0) */
    /* satisfied above */
    if (i->os32L()) {
      // ID,VIP,VIF,AC,VM,RF,x,NT,IOPL,OF,DF,IF,TF,SF,ZF,x,AF,x,PF,x,CF
      Bit32u changeMask = EFlagsOSZAPCMask | EFlagsTFMask |
                              EFlagsDFMask | EFlagsNTMask | EFlagsRFMask;
#if BX_CPU_LEVEL >= 4
      changeMask |= (EFlagsIDMask | EFlagsACMask);  // ID/AC
#endif
      if (CPL <= BX_CPU_THIS_PTR get_IOPL())
        changeMask |= EFlagsIFMask;
      if (CPL == 0)
        changeMask |= EFlagsVIPMask | EFlagsVIFMask | EFlagsIOPLMask;

      // IF only changed if (CPL <= EFLAGS.IOPL)
      // VIF, VIP, IOPL only changed if CPL == 0
      // VM unaffected
      writeEFlags(new_eflags, changeMask);
    }
    else {
      /* load flags with third word on stack */
      write_flags((Bit16u) new_eflags, CPL==0, CPL<=BX_CPU_THIS_PTR get_IOPL());
    }

    /* increment stack by 6/12 */
    if (BX_CPU_THIS_PTR sregs[BX_SEG_REG_SS].cache.u.segment.d_b)
      ESP += top_nbytes_same;
    else
       SP += top_nbytes_same;
  }
  else {//情况3. 外权级中断返回

    BX_DEBUG(("INTERRUPT RETURN TO OUTER PRIVILEGE LEVEL; 外权级中断返回;"));

    /* 16bit opsize  |   32bit opsize
     * ==============================
     * SS     eSP+8  |   SS     eSP+16
     * SP     eSP+6  |   ESP    eSP+12
     * FLAGS  eSP+4  |   EFLAGS eSP+8
     * CS     eSP+2  |   CS     eSP+4
     * IP     eSP+0  |   EIP    eSP+0
     */

    /* examine return SS selector and associated descriptor */
    if (i->os32L()) {
      raw_ss_selector = stack_read_word(temp_ESP + 16);
    }
    else {
      raw_ss_selector = stack_read_word(temp_ESP + 8);
    }

    /* selector must be non-null, else #GP(0) */
    if ((raw_ss_selector & 0xfffc) == 0) {
      BX_ERROR(("iret: SS selector null"));
      exception(BX_GP_EXCEPTION, 0);
    }

    parse_selector(raw_ss_selector, &ss_selector);

    /* selector RPL must = RPL of return CS selector,
     * else #GP(SS selector) */
    if (ss_selector.rpl != cs_selector.rpl) {
      BX_ERROR(("iret: SS.rpl != CS.rpl"));
      exception(BX_GP_EXCEPTION, raw_ss_selector & 0xfffc);
    }

    /* selector index must be within its descriptor table limits,
     * else #GP(SS selector) */
    fetch_raw_descriptor(&ss_selector, &dword1, &dword2, BX_GP_EXCEPTION);

    parse_descriptor(dword1, dword2, &ss_descriptor);

    /* AR byte must indicate a writable data segment,
     * else #GP(SS selector) */
    if (ss_descriptor.valid==0 || ss_descriptor.segment==0 ||
         IS_CODE_SEGMENT(ss_descriptor.type) ||
        !IS_DATA_SEGMENT_WRITEABLE(ss_descriptor.type))
    {
      BX_ERROR(("iret: SS AR byte not writable or code segment"));
      exception(BX_GP_EXCEPTION, raw_ss_selector & 0xfffc);
    }

    /* stack segment DPL must equal the RPL of the return CS selector,
     * else #GP(SS selector) */
    if (ss_descriptor.dpl != cs_selector.rpl) {
      BX_ERROR(("iret: SS.dpl != CS selector RPL"));
      exception(BX_GP_EXCEPTION, raw_ss_selector & 0xfffc);
    }

    /* SS must be present, else #NP(SS selector) */
    if (! IS_PRESENT(ss_descriptor)) {
      BX_ERROR(("iret: SS not present!"));
      exception(BX_NP_EXCEPTION, raw_ss_selector & 0xfffc);
    }

    if (i->os32L()) {
      new_esp = stack_read_dword(temp_ESP + 12);
    }
    else {
      new_esp = stack_read_word(temp_ESP + 6);
    }

    // ID,VIP,VIF,AC,VM,RF,x,NT,IOPL,OF,DF,IF,TF,SF,ZF,x,AF,x,PF,x,CF
    Bit32u changeMask = EFlagsOSZAPCMask | EFlagsTFMask |
                            EFlagsDFMask | EFlagsNTMask | EFlagsRFMask;
#if BX_CPU_LEVEL >= 4
    changeMask |= (EFlagsIDMask | EFlagsACMask);  // ID/AC
#endif
    if (CPL <= BX_CPU_THIS_PTR get_IOPL())
      changeMask |= EFlagsIFMask;
    if (CPL == 0)
      changeMask |= EFlagsVIPMask | EFlagsVIFMask | EFlagsIOPLMask;

    if (! i->os32L()) // 16 bit
      changeMask &= 0xffff;

#if BX_SUPPORT_CET
    unsigned prev_cpl = CPL;
    bx_address new_SSP = BX_CPU_THIS_PTR msr.ia32_pl_ssp[3];
    if (ShadowStackEnabled(CPL)) {
      if (SSP & 0x7) {
        BX_ERROR(("iret_protected: SSP is not 8-byte aligned"));
        exception(BX_CP_EXCEPTION, BX_CP_FAR_RET_IRET);
      }
      if (cs_selector.rpl != 3) {
        new_SSP = shadow_stack_restore(raw_cs_selector, cs_descriptor, new_eip);
      }
    }
#endif

  Bit32u original_eip=(EIP);
    /* load CS:EIP from stack */
    /* load the CS-cache with CS descriptor */
    /* set CPL to the RPL of the return CS selector */
    branch_far(&cs_selector, &cs_descriptor, new_eip, cs_selector.rpl);
    //开始一条日志, 日志行的字段们： cs选择子 cs_selector、代码段描述符cs_descriptor、新eip new_eip
    std::string cs_selector_json_text=BX_CPU_THIS -> selector_json_text("cs_selt",&cs_selector);
    std::string cs_descriptor_json_text=BX_CPU_THIS -> descriptor_json_text("cs_desc",&cs_descriptor);

    // IF only changed if (prev_CPL <= EFLAGS.IOPL)
    // VIF, VIP, IOPL only changed if prev_CPL == 0
    // VM unaffected
    writeEFlags(new_eflags, changeMask);

    // load SS:eSP from stack
    // load the SS-cache with SS descriptor
    load_ss(&ss_selector, &ss_descriptor, cs_selector.rpl);
    //继续日志行，日志行的字段们： 栈选择子 ss_selector 、栈段描述符 ss_descriptor.
    std::string ss_selector_json_text=BX_CPU_THIS -> selector_json_text("ss_selt",&ss_selector);
    std::string ss_descriptor_json_text=BX_CPU_THIS -> descriptor_json_text("ss_desc",&ss_descriptor);
    //结束日志行.

    /**
    csv日志格式描述
    x分类:x名:x功能解释@在x内的区域   , x 属于 {指令模拟函数, 指令模拟函数内的某个子功能}  即 x 属于 {指令, 指令子功能}
    外csv 内json， csv分割符必须是分号， csv复杂json字段内必须不能有分号
    比如: 
    函数分类:函数名:函数功能解释@在函数内的区域
    */
    //csv日志=IRET中断返回指令函数模拟内的共用逻辑:iret_protected:@情况3_外权级中断返回;cs_selector_json_text;cs_descriptor_json_text;new_eip;ss_selector_json_text;ss_descriptor_json_text
    BX_INFO(("~L~=返断程共逻:iret_protected__外级返:; %s; %s; 0x%x; 0x%x; %s; %s",cs_selector_json_text.c_str(), cs_descriptor_json_text.c_str(), original_eip,new_eip, ss_selector_json_text.c_str(),ss_descriptor_json_text.c_str()));

    if (ss_descriptor.u.segment.d_b)
      ESP = new_esp;
    else
      SP  = new_esp;

#if BX_SUPPORT_CET
    bx_address old_SSP = SSP;
    if (ShadowStackEnabled(CPL)) {
      if (GET32H(new_SSP) != 0) {
        BX_ERROR(("iret_protected: 64-bit SSP in legacy mode"));
        exception(BX_GP_EXCEPTION, 0);
      }
      SSP = new_SSP;
    }
    if (ShadowStackEnabled(prev_cpl)) {
      shadow_stack_atomic_clear_busy(old_SSP, prev_cpl);
    }
#endif

    validate_seg_regs();
  }
}

#if BX_SUPPORT_X86_64
  void BX_CPP_AttrRegparmN(1)
BX_CPU_C::long_iret(bxInstruction_c *i)
{
  Bit16u raw_cs_selector, raw_ss_selector;
  bx_selector_t cs_selector, ss_selector;
  Bit32u dword1, dword2;
  bx_descriptor_t cs_descriptor, ss_descriptor;
  Bit32u new_eflags;
  Bit64u new_rip, new_rsp, temp_RSP;

  BX_DEBUG (("LONG MODE IRET"));

  if (BX_CPU_THIS_PTR get_NT()) {
    BX_ERROR(("iret64: return from nested task in x86-64 mode !"));
    exception(BX_GP_EXCEPTION, 0);
  }

  /* 64bit opsize
   * ============
   * SS     eSP+32
   * ESP    eSP+24
   * -------------
   * EFLAGS eSP+16
   * CS     eSP+8
   * EIP    eSP+0
   */

  if (long64_mode()) temp_RSP = RSP;
  else {
    if (BX_CPU_THIS_PTR sregs[BX_SEG_REG_SS].cache.u.segment.d_b) temp_RSP = ESP;
    else temp_RSP = SP;
  }

  unsigned top_nbytes_same = 0; /* stop compiler warnings */

#if BX_SUPPORT_X86_64
  if (i->os64L()) {
    new_eflags      = (Bit32u) stack_read_qword(temp_RSP + 16);
    raw_cs_selector = (Bit16u) stack_read_qword(temp_RSP +  8);
    new_rip         =          stack_read_qword(temp_RSP +  0);
    top_nbytes_same = 24;
  }
  else
#endif
  if (i->os32L()) {
    new_eflags      =          stack_read_dword(temp_RSP + 8);
    raw_cs_selector = (Bit16u) stack_read_dword(temp_RSP + 4);
    new_rip         = (Bit64u) stack_read_dword(temp_RSP + 0);
    top_nbytes_same = 12;
  }
  else {
    new_eflags      =          stack_read_word(temp_RSP + 4);
    raw_cs_selector =          stack_read_word(temp_RSP + 2);
    new_rip         = (Bit64u) stack_read_word(temp_RSP + 0);
    top_nbytes_same = 6;
  }

  // ignore VM flag in long mode
  new_eflags &= ~EFlagsVMMask;

  parse_selector(raw_cs_selector, &cs_selector);

  // return CS selector must be non-null, else #GP(0)
  if ((raw_cs_selector & 0xfffc) == 0) {
    BX_ERROR(("iret64: return CS selector null"));
    exception(BX_GP_EXCEPTION, 0);
  }

  // selector index must be within descriptor table limits,
  // else #GP(return selector)
  fetch_raw_descriptor(&cs_selector, &dword1, &dword2, BX_GP_EXCEPTION);
  parse_descriptor(dword1, dword2, &cs_descriptor);

  // return CS selector RPL must be >= CPL, else #GP(return selector)
  if (cs_selector.rpl < CPL) {
    BX_ERROR(("iret64: return selector RPL < CPL"));
    exception(BX_GP_EXCEPTION, raw_cs_selector & 0xfffc);
  }

  // check code-segment descriptor
  check_cs(&cs_descriptor, raw_cs_selector, 0, cs_selector.rpl);

  /* INTERRUPT RETURN TO SAME PRIVILEGE LEVEL */
  if (cs_selector.rpl == CPL && !i->os64L())
  {
    BX_DEBUG(("LONG MODE INTERRUPT RETURN TO SAME PRIVILEGE LEVEL"));

    /* top 24 bytes on stack must be within limits, else #SS(0) */
    /* satisfied above */

#if BX_SUPPORT_CET
    if (ShadowStackEnabled(CPL)) {
      bx_address prev_SSP = SSP;
      SSP = shadow_stack_restore(raw_cs_selector, cs_descriptor, new_rip);
      if (SSP != prev_SSP) {
        shadow_stack_atomic_clear_busy(SSP, CPL);
      }
    }
#endif

    /* load CS:EIP from stack */
    /* load CS-cache with new code segment descriptor */
    branch_far(&cs_selector, &cs_descriptor, new_rip, CPL);

    // ID,VIP,VIF,AC,VM,RF,x,NT,IOPL,OF,DF,IF,TF,SF,ZF,x,AF,x,PF,x,CF
    Bit32u changeMask = EFlagsOSZAPCMask | EFlagsTFMask | EFlagsDFMask |
                            EFlagsNTMask | EFlagsRFMask | EFlagsIDMask | EFlagsACMask;
    if (CPL <= BX_CPU_THIS_PTR get_IOPL())
      changeMask |= EFlagsIFMask;
    if (CPL == 0)
      changeMask |= EFlagsVIPMask | EFlagsVIFMask | EFlagsIOPLMask;

    if (! i->os32L()) // 16 bit
      changeMask &= 0xffff;

    // IF only changed if (CPL <= EFLAGS.IOPL)
    // VIF, VIP, IOPL only changed if CPL == 0
    // VM unaffected
    writeEFlags(new_eflags, changeMask);

    /* we are NOT in 64-bit mode */
    if (BX_CPU_THIS_PTR sregs[BX_SEG_REG_SS].cache.u.segment.d_b)
      ESP += top_nbytes_same;
    else
       SP += top_nbytes_same;
  }
  else {

    BX_DEBUG(("LONG MODE INTERRUPT RETURN TO OUTER PRIVILEGE LEVEL or 64 BIT MODE"));

    /* 64bit opsize
     * ============
     * SS     eSP+32
     * ESP    eSP+24
     * EFLAGS eSP+16
     * CS     eSP+8
     * EIP    eSP+0
     */

    /* examine return SS selector and associated descriptor */
#if BX_SUPPORT_X86_64
    if (i->os64L()) {
      raw_ss_selector = (Bit16u) stack_read_qword(temp_RSP + 32);
      new_rsp         =          stack_read_qword(temp_RSP + 24);
    }
    else
#endif
    {
      if (i->os32L()) {
        raw_ss_selector = (Bit16u) stack_read_dword(temp_RSP + 16);
        new_rsp         = (Bit64u) stack_read_dword(temp_RSP + 12);
      }
      else {
        raw_ss_selector =          stack_read_word(temp_RSP + 8);
        new_rsp         = (Bit64u) stack_read_word(temp_RSP + 6);
      }
    }

    if ((raw_ss_selector & 0xfffc) == 0) {
      if (! IS_LONG64_SEGMENT(cs_descriptor) || cs_selector.rpl == 3) {
        BX_ERROR(("iret64: SS selector null"));
        exception(BX_GP_EXCEPTION, 0);
      }
    }
    else {
      parse_selector(raw_ss_selector, &ss_selector);

      /* selector RPL must = RPL of return CS selector,
       * else #GP(SS selector) */
      if (ss_selector.rpl != cs_selector.rpl) {
        BX_ERROR(("iret64: SS.rpl != CS.rpl"));
        exception(BX_GP_EXCEPTION, raw_ss_selector & 0xfffc);
      }

      /* selector index must be within its descriptor table limits,
       * else #GP(SS selector) */
      fetch_raw_descriptor(&ss_selector, &dword1, &dword2, BX_GP_EXCEPTION);
      parse_descriptor(dword1, dword2, &ss_descriptor);

      /* AR byte must indicate a writable data segment,
       * else #GP(SS selector) */
      if (ss_descriptor.valid==0 || ss_descriptor.segment==0 ||
          IS_CODE_SEGMENT(ss_descriptor.type) ||
         !IS_DATA_SEGMENT_WRITEABLE(ss_descriptor.type))
      {
        BX_ERROR(("iret64: SS AR byte not writable or code segment"));
        exception(BX_GP_EXCEPTION, raw_ss_selector & 0xfffc);
      }

      /* stack segment DPL must equal the RPL of the return CS selector,
       * else #GP(SS selector) */
      if (ss_descriptor.dpl != cs_selector.rpl) {
        BX_ERROR(("iret64: SS.dpl != CS selector RPL"));
        exception(BX_GP_EXCEPTION, raw_ss_selector & 0xfffc);
      }

      /* SS must be present, else #NP(SS selector) */
      if (! IS_PRESENT(ss_descriptor)) {
        BX_ERROR(("iret64: SS not present!"));
        exception(BX_NP_EXCEPTION, raw_ss_selector & 0xfffc);
      }
    }

    Bit8u prev_cpl = CPL; /* previous CPL */

    // ID,VIP,VIF,AC,VM,RF,x,NT,IOPL,OF,DF,IF,TF,SF,ZF,x,AF,x,PF,x,CF
    Bit32u changeMask = EFlagsOSZAPCMask | EFlagsTFMask | EFlagsDFMask |
                            EFlagsNTMask | EFlagsRFMask | EFlagsIDMask | EFlagsACMask;
    if (prev_cpl <= BX_CPU_THIS_PTR get_IOPL())
      changeMask |= EFlagsIFMask;
    if (prev_cpl == 0)
      changeMask |= EFlagsVIPMask | EFlagsVIFMask | EFlagsIOPLMask;

    if (! i->os32L()) // 16 bit
      changeMask &= 0xffff;

#if BX_SUPPORT_CET
    bx_address new_SSP = BX_CPU_THIS_PTR msr.ia32_pl_ssp[3];
    if (ShadowStackEnabled(CPL)) {
      if (SSP & 0x7) {
        BX_ERROR(("iret64: SSP is not 8-byte aligned"));
        exception(BX_CP_EXCEPTION, BX_CP_FAR_RET_IRET);
      }
      if (cs_selector.rpl != 3) {
        new_SSP = shadow_stack_restore(raw_cs_selector, cs_descriptor, new_rip);
      }
    }
#endif

    /* set CPL to the RPL of the return CS selector */
    branch_far(&cs_selector, &cs_descriptor, new_rip, cs_selector.rpl);

    // IF only changed if (prev_CPL <= EFLAGS.IOPL)
    // VIF, VIP, IOPL only changed if prev_CPL == 0
    // VM unaffected
    writeEFlags(new_eflags, changeMask);

    if ((raw_ss_selector & 0xfffc) != 0) {
      // load SS:RSP from stack
      // load the SS-cache with SS descriptor
      load_ss(&ss_selector, &ss_descriptor, cs_selector.rpl);
    }
    else {
      // we are in 64-bit mode !
      load_null_selector(&BX_CPU_THIS_PTR sregs[BX_SEG_REG_SS], raw_ss_selector);
    }

    if (long64_mode()) RSP = new_rsp;
    else {
      if (ss_descriptor.u.segment.d_b) ESP = (Bit32u) new_rsp;
      else SP = (Bit16u) new_rsp;
    }

#if BX_SUPPORT_CET
    bx_address old_SSP = SSP;
    if (ShadowStackEnabled(CPL)) {
      if (!long64_mode() && GET32H(new_SSP) != 0) {
        BX_ERROR(("iret64: 64-bit SSP in legacy mode"));
        exception(BX_GP_EXCEPTION, 0);
      }
      SSP = new_SSP;
    }
    if (ShadowStackEnabled(prev_cpl)) {
      shadow_stack_atomic_clear_busy(old_SSP, prev_cpl);
    }
#endif

    if (prev_cpl != CPL) validate_seg_regs();
  }
}
#endif
