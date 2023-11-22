/////////////////////////////////////////////////////////////////////////
// $Id$
/////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2001-2019  The Bochs Project
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
/////////////////////////////////////////////////////////////////////////

#define NEED_CPU_REG_SHORTCUTS 1
#include "bochs.h"
#include "cpu.h"
#define LOG_THIS BX_CPU_THIS_PTR

#if BX_CPU_LEVEL >= 3

BX_CPP_INLINE void BX_CPP_AttrRegparmN(1) BX_CPU_C::branch_near32(Bit32u new_EIP)
{
  BX_ASSERT(BX_CPU_THIS_PTR cpu_mode != BX_MODE_LONG_64);

  // check always, not only in protected mode
  if (new_EIP > BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS].cache.u.segment.limit_scaled)
  {
    BX_ERROR(("branch_near32: offset outside of CS limits"));
    exception(BX_GP_EXCEPTION, 0);
  }

  EIP = new_EIP;

#if BX_SUPPORT_HANDLERS_CHAINING_SPEEDUPS == 0
  // assert magic async_event to stop trace execution
  BX_CPU_THIS_PTR async_event |= BX_ASYNC_EVENT_STOP_TRACE;
#endif
}

void BX_CPU_C::call_far32(bxInstruction_c *i, Bit16u cs_raw, Bit32u disp32)
{
  BX_INSTR_FAR_BRANCH_ORIGIN();

  invalidate_prefetch_q();

#if BX_DEBUGGER
  BX_CPU_THIS_PTR show_flag |= Flag_call;
#endif

  RSP_SPECULATIVE;

  if (protected_mode()) {
    call_protected(i, cs_raw, disp32);
  }
  else {
    // CS.LIMIT can't change when in real/v8086 mode
    if (disp32 > BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS].cache.u.segment.limit_scaled) {
      BX_ERROR(("%s: instruction pointer not within code segment limits", i->getIaOpcodeNameShort()));
      exception(BX_GP_EXCEPTION, 0);
    }

    push_32(BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS].selector.value);
    push_32(EIP);

    load_seg_reg(&BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS], cs_raw);
    EIP = disp32;
  }

  RSP_COMMIT;

  BX_INSTR_FAR_BRANCH(BX_CPU_ID, BX_INSTR_IS_CALL,
                      FAR_BRANCH_PREV_CS, FAR_BRANCH_PREV_RIP,
                      BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS].selector.value, EIP);
}

void BX_CPU_C::jmp_far32(bxInstruction_c *i, Bit16u cs_raw, Bit32u disp32)
{
  BX_INSTR_FAR_BRANCH_ORIGIN();

  invalidate_prefetch_q();

  // jump_protected doesn't affect ESP so it is ESP safe
  if (protected_mode()) {
    jump_protected(i, cs_raw, disp32);
  }
  else {
    // CS.LIMIT can't change when in real/v8086 mode
    if (disp32 > BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS].cache.u.segment.limit_scaled) {
      BX_ERROR(("%s: instruction pointer not within code segment limits", i->getIaOpcodeNameShort()));
      exception(BX_GP_EXCEPTION, 0);
    }

    load_seg_reg(&BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS], cs_raw);
    EIP = disp32;
  }

  BX_INSTR_FAR_BRANCH(BX_CPU_ID, BX_INSTR_IS_JMP,
                      FAR_BRANCH_PREV_CS, FAR_BRANCH_PREV_RIP,
                      BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS].selector.value, EIP);
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::RETnear32_Iw(bxInstruction_c *i)//模拟RET指令
{
  BX_ASSERT(BX_CPU_THIS_PTR cpu_mode != BX_MODE_LONG_64);

#if BX_DEBUGGER
  BX_CPU_THIS_PTR show_flag |= Flag_ret;
#endif

  RSP_SPECULATIVE;

  Bit32u return_EIP = pop_32();
#if BX_SUPPORT_CET
  if (ShadowStackEnabled(CPL)) {
    Bit32u shadow_EIP = shadow_stack_pop_32();
    if (shadow_EIP != return_EIP)
      exception(BX_CP_EXCEPTION, BX_CP_NEAR_RET);
  }
#endif

  if (return_EIP > BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS].cache.u.segment.limit_scaled)
  {
    BX_ERROR(("%s: offset outside of CS limits", i->getIaOpcodeNameShort()));
    exception(BX_GP_EXCEPTION, 0);
  }
  EIP = return_EIP;

  Bit16u imm16 = i->Iw();
  if (BX_CPU_THIS_PTR sregs[BX_SEG_REG_SS].cache.u.segment.d_b)
    ESP += imm16;
  else
     SP += imm16;

  RSP_COMMIT;

  BX_INSTR_UCNEAR_BRANCH(BX_CPU_ID, BX_INSTR_IS_RET, PREV_RIP, EIP);

  BX_INFO( ("log__RETnear32_Iw;EIP:0x%x", EIP) );
  BX_NEXT_TRACE(i);
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::RETfar32_Iw(bxInstruction_c *i)//模拟RET指令
{
  invalidate_prefetch_q();

  BX_INSTR_FAR_BRANCH_ORIGIN();

#if BX_DEBUGGER
  BX_CPU_THIS_PTR show_flag |= Flag_ret;
#endif

  Bit16u imm16 = i->Iw();

  RSP_SPECULATIVE;

  if (protected_mode()) {
    return_protected(i, imm16);
  }
  else {
    Bit32u eip    =          pop_32();
    Bit16u cs_raw = (Bit16u) pop_32(); /* 32bit pop, MSW discarded */

    // CS.LIMIT can't change when in real/v8086 mode
    if (eip > BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS].cache.u.segment.limit_scaled) {
      BX_ERROR(("%s: instruction pointer not within code segment limits", i->getIaOpcodeNameShort()));
      exception(BX_GP_EXCEPTION, 0);
    }

    load_seg_reg(&BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS], cs_raw);
    EIP = eip;

    if (BX_CPU_THIS_PTR sregs[BX_SEG_REG_SS].cache.u.segment.d_b)
      ESP += imm16;
    else
       SP += imm16;

    //记录一行日志, EIP、cs_raw
    BX_INFO(( "记录日志_指令模拟函数RETfar32_Iw;EIP=0x%x;cs_raw=0x%x", EIP, cs_raw ));
  }

  RSP_COMMIT;

  BX_INSTR_FAR_BRANCH(BX_CPU_ID, BX_INSTR_IS_RET,
                      FAR_BRANCH_PREV_CS, FAR_BRANCH_PREV_RIP,
                      BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS].selector.value, RIP);

  BX_NEXT_TRACE(i);
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::CALL_Jd(bxInstruction_c *i)
{
#if BX_DEBUGGER
  BX_CPU_THIS_PTR show_flag |= Flag_call;
#endif

  RSP_SPECULATIVE;

  /* push 32 bit EA of next instruction */
  push_32(EIP);
#if BX_SUPPORT_CET
  if (ShadowStackEnabled(CPL) && i->Id())
    shadow_stack_push_32(EIP);
#endif

  Bit32u new_EIP = EIP + i->Id();
  branch_near32(new_EIP);

  RSP_COMMIT;

  BX_INSTR_UCNEAR_BRANCH(BX_CPU_ID, BX_INSTR_IS_CALL, PREV_RIP, EIP);

  BX_LINK_TRACE(i);
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::CALL32_Ap(bxInstruction_c *i)//模拟call指令
{
  BX_ASSERT(BX_CPU_THIS_PTR cpu_mode != BX_MODE_LONG_64);

  Bit16u cs_raw = i->Iw2();
  Bit32u disp32 = i->Id();

  call_far32(i, cs_raw, disp32);

  BX_NEXT_TRACE(i);
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::CALL_EdR(bxInstruction_c *i)
{
#if BX_DEBUGGER
  BX_CPU_THIS_PTR show_flag |= Flag_call;
#endif

  Bit32u new_EIP = BX_READ_32BIT_REG(i->dst());

  RSP_SPECULATIVE;

  /* push 32 bit EA of next instruction */
  push_32(EIP);
#if BX_SUPPORT_CET
  if (ShadowStackEnabled(CPL))
    shadow_stack_push_32(EIP);
#endif

  branch_near32(new_EIP);

  RSP_COMMIT;

#if BX_SUPPORT_CET
  track_indirect_if_not_suppressed(i, CPL);
#endif

  BX_INSTR_UCNEAR_BRANCH(BX_CPU_ID, BX_INSTR_IS_CALL_INDIRECT, PREV_RIP, EIP);

  BX_NEXT_TRACE(i);
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::CALL32_Ep(bxInstruction_c *i)
{
  bx_address eaddr = BX_CPU_RESOLVE_ADDR(i);

  Bit32u op1_32 = read_virtual_dword(i->seg(), eaddr);
  Bit16u cs_raw = read_virtual_word (i->seg(), (eaddr+4) & i->asize_mask());

  call_far32(i, cs_raw, op1_32);

  BX_NEXT_TRACE(i);
}

void BX_CPU_C::logXv6X86FuncId(bxInstruction_c *instr){

  //取得 当前指令 紧挨着的 4个字节
  Bit32u or1_instr_appendByte=BX_CPU_THIS->read_linear_dword (instr->seg(),EIP);
  //取得 当前指令地址+3字节 紧挨着的 8个字节
  Bit64u or2_instr_appendWord=BX_CPU_THIS->read_linear_qword (instr->seg(),EIP+3);

  //funcId汇编 含有三条指令: 短jmp, 标记or1, 存funcId的or2
  
  //当前正在执行指令 一条jmp指令,但不确定该jmp后的两条指令  是否为 or1 or2.
  
  //取得 当前指令 紧挨着的 3个字节(称为 疑似or1), 待判定 其  是否为 funcId汇编 中的 标记or1 指令
  Bit32u or1_instr = or1_instr_appendByte & 0x00FFFFFF;
  
  //取得 当前指令+3字节 紧挨着的 8个字节 中的 6个字节(称为 疑似or2), 待判定 其  是否为 funcId汇编 中的 存funcId的or2 指令
  Bit64u or2_instr = or2_instr_appendWord & 0x0000ffFFffFFffFF;

  // 存 疑似or2的 操作码
  Bit64u or2_instr_opcode = or2_instr &     0x000000000000ffFF;


  // 标记or1 常量
  const Bit32u FuncIdAsm_Or1Instr =  0xffcf83;
  // or2操作码 常量
  const Bit32u FuncIdAsm_Or2Instr_Opcode =  0xcf81;

  // 若 疑似or1 不是 or1 , 则结束处理
  if(FuncIdAsm_Or1Instr!=or1_instr){
    return;
  }

  // 若 疑似or2的 操作码 不是 or2操作码 , 则结束处理
  if(FuncIdAsm_Or2Instr_Opcode!=or2_instr_opcode){
    return;
  }

  //or2指令 中提取 funcId , 请 参考: https://gitcode.net/crk/xv6-x86/-/raw/0d1d25271ce959c7b207534caabdd10006ba1295/study/or_edi_machine_code_demo.png

  Bit64u fId = (or2_instr & 0x0000ffFFffFF0000)>>(8*2);

  //fId:0x78563412, 则funcId:0x12345678
  Bit32u funcId = fId;
//    ( (fId & 0x000000FF)>>(8*0)<<(8*3) )  //外层圆括号不可以丢掉, 否则运算符优先级不是预期的.
//  + ( (fId & 0x0000FF00)>>(8*1)<<(8*2) )
//  + ( (fId & 0x00FF0000)>>(8*2)<<(8*1) )
//  + ( (fId & 0xFF000000)>>(8*3)<<(8*0) )
//   ;

  BX_INFO( ("记录funcId:%d,0x%x;",  funcId,funcId) );

}
void BX_CPP_AttrRegparmN(1) BX_CPU_C::JMP_Jd(bxInstruction_c *i)
{
  logXv6X86FuncId(i);
  Bit32u new_EIP = EIP + (Bit32s) i->Id();
  branch_near32(new_EIP);
  BX_INSTR_UCNEAR_BRANCH(BX_CPU_ID, BX_INSTR_IS_JMP, PREV_RIP, new_EIP);

  BX_LINK_TRACE(i);
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JO_Jd(bxInstruction_c *i)
{
  if (get_OF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JNO_Jd(bxInstruction_c *i)
{
  if (! get_OF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JB_Jd(bxInstruction_c *i)
{
  if (get_CF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JNB_Jd(bxInstruction_c *i)
{
  if (! get_CF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JZ_Jd(bxInstruction_c *i)
{
  if (get_ZF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JNZ_Jd(bxInstruction_c *i)
{
  if (! get_ZF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JBE_Jd(bxInstruction_c *i)
{
  if (get_CF() || get_ZF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JNBE_Jd(bxInstruction_c *i)
{
  if (! (get_CF() || get_ZF())) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JS_Jd(bxInstruction_c *i)
{
  if (get_SF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JNS_Jd(bxInstruction_c *i)
{
  if (! get_SF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JP_Jd(bxInstruction_c *i)
{
  if (get_PF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JNP_Jd(bxInstruction_c *i)
{
  if (! get_PF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JL_Jd(bxInstruction_c *i)
{
  if (getB_SF() != getB_OF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JNL_Jd(bxInstruction_c *i)
{
  if (getB_SF() == getB_OF()) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JLE_Jd(bxInstruction_c *i)
{
  if (get_ZF() || (getB_SF() != getB_OF())) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JNLE_Jd(bxInstruction_c *i)
{
  if (! get_ZF() && (getB_SF() == getB_OF())) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_INSTR(i); // trace can continue over non-taken branch
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JMP_Ap(bxInstruction_c *i)
{
  BX_ASSERT(BX_CPU_THIS_PTR cpu_mode != BX_MODE_LONG_64);

  Bit32u disp32;
  Bit16u cs_raw;

  if (i->os32L()) {
    disp32 = i->Id();
  }
  else {
    disp32 = i->Iw();
  }
  cs_raw = i->Iw2();

  jmp_far32(i, cs_raw, disp32);
  //指令JMP_Ap模拟函数, 记录一条日志

  BX_NEXT_TRACE(i);
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JMP_EdR(bxInstruction_c *i)
{
  Bit32u new_EIP = BX_READ_32BIT_REG(i->dst());
  branch_near32(new_EIP);
  BX_INSTR_UCNEAR_BRANCH(BX_CPU_ID, BX_INSTR_IS_JMP_INDIRECT, PREV_RIP, new_EIP);

#if BX_SUPPORT_CET
  track_indirect_if_not_suppressed(i, CPL);
#endif

  BX_NEXT_TRACE(i);
}

/* Far indirect jump */
void BX_CPP_AttrRegparmN(1) BX_CPU_C::JMP32_Ep(bxInstruction_c *i)
{
  bx_address eaddr = BX_CPU_RESOLVE_ADDR(i);

  Bit32u op1_32 = read_virtual_dword(i->seg(), eaddr);
  Bit16u cs_raw = read_virtual_word (i->seg(), (eaddr+4) & i->asize_mask());

  jmp_far32(i, cs_raw, op1_32);
  //记录一条日志

  BX_NEXT_TRACE(i);
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::IRET32(bxInstruction_c *i)//模拟IRET指令
{
  BX_ASSERT(BX_CPU_THIS_PTR cpu_mode != BX_MODE_LONG_64);

  invalidate_prefetch_q();

  BX_INSTR_FAR_BRANCH_ORIGIN();

#if BX_SUPPORT_SVM
  if (BX_CPU_THIS_PTR in_svm_guest) {
    if (SVM_INTERCEPT(SVM_INTERCEPT0_IRET)) Svm_Vmexit(SVM_VMEXIT_IRET);
  }
#endif

#if BX_SUPPORT_VMX
  if (BX_CPU_THIS_PTR in_vmx_guest)
    if (is_masked_event(PIN_VMEXIT(VMX_VM_EXEC_CTRL1_VIRTUAL_NMI) ? BX_EVENT_VMX_VIRTUAL_NMI : BX_EVENT_NMI))
      BX_CPU_THIS_PTR nmi_unblocking_iret = true;

  if (BX_CPU_THIS_PTR in_vmx_guest && PIN_VMEXIT(VMX_VM_EXEC_CTRL1_NMI_EXITING)) {
    if (PIN_VMEXIT(VMX_VM_EXEC_CTRL1_VIRTUAL_NMI)) unmask_event(BX_EVENT_VMX_VIRTUAL_NMI);
  }
  else
#endif
    unmask_event(BX_EVENT_NMI);

#if BX_DEBUGGER
  BX_CPU_THIS_PTR show_flag |= Flag_iret;
#endif

  RSP_SPECULATIVE;

  if (protected_mode()) {
    iret_protected(i);//iret_protected只被 指令模拟函数 IRET32 调用过一次，因此iret_protected中的三种情况可以分别记录一条日志
  }
  else {
    if (v8086_mode()) {
      // IOPL check in stack_return_from_v86()
      iret32_stack_return_from_v86(i);
    }
    else {
      Bit32u eip      =          pop_32();
      Bit16u cs_raw   = (Bit16u) pop_32(); // #SS has higher priority
      Bit32u eflags32 =          pop_32();

      // CS.LIMIT can't change when in real/v8086 mode
      if (eip > BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS].cache.u.segment.limit_scaled) {
        BX_ERROR(("%s: instruction pointer not within code segment limits", i->getIaOpcodeNameShort()));
        exception(BX_GP_EXCEPTION, 0);
      }

      load_seg_reg(&BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS], cs_raw);
      EIP = eip;
      writeEFlags(eflags32, 0x00257fd5); // VIF, VIP, VM unchanged
      
      //记录一行日志, EIP、cs_raw
      BX_INFO(( "记录日志_指令模拟函数IRET32;EIP=0x%x;cs_raw=0x%x", EIP, cs_raw ));
    }
  }

  RSP_COMMIT;

#if BX_SUPPORT_VMX
  BX_CPU_THIS_PTR nmi_unblocking_iret = false;
#endif

  BX_INSTR_FAR_BRANCH(BX_CPU_ID, BX_INSTR_IS_IRET,
                      FAR_BRANCH_PREV_CS, FAR_BRANCH_PREV_RIP,
                      BX_CPU_THIS_PTR sregs[BX_SEG_REG_CS].selector.value, EIP);

  BX_NEXT_TRACE(i);
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::JECXZ_Jb(bxInstruction_c *i)
{
  // it is impossible to get this instruction in long mode
  BX_ASSERT(i->as64L() == 0);

  Bit32u temp_ECX;

  if (i->as32L())
    temp_ECX = ECX;
  else
    temp_ECX = CX;

  if (temp_ECX == 0) {
    Bit32u new_EIP = EIP + (Bit32s) i->Id();
    branch_near32(new_EIP);
    BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    BX_LINK_TRACE(i);
  }

  BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
  BX_NEXT_TRACE(i);
}

//
// There is some weirdness in LOOP instructions definition. If an exception
// was generated during the instruction execution (for example #GP fault
// because EIP was beyond CS segment limits) CPU state should restore the
// state prior to instruction execution.
//
// The final point that we are not allowed to decrement ECX register before
// it is known that no exceptions can happen.
//

void BX_CPP_AttrRegparmN(1) BX_CPU_C::LOOPNE32_Jb(bxInstruction_c *i)
{
  // it is impossible to get this instruction in long mode
  BX_ASSERT(i->as64L() == 0);

  if (i->as32L()) {
    Bit32u count = ECX;

    count--;
    if (count != 0 && (get_ZF()==0)) {
      Bit32u new_EIP = EIP + (Bit32s) i->Id();
      branch_near32(new_EIP);
      BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    }
#if BX_INSTRUMENTATION
    else {
      BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
    }
#endif

    ECX = count;
  }
  else {
    Bit16u count = CX;

    count--;
    if (count != 0 && (get_ZF()==0)) {
      Bit32u new_EIP = EIP + (Bit32s) i->Id();
      branch_near32(new_EIP);
      BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    }
#if BX_INSTRUMENTATION
    else {
      BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
    }
#endif

    CX = count;
  }

  BX_NEXT_TRACE(i);
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::LOOPE32_Jb(bxInstruction_c *i)
{
  // it is impossible to get this instruction in long mode
  BX_ASSERT(i->as64L() == 0);

  if (i->as32L()) {
    Bit32u count = ECX;

    count--;
    if (count != 0 && get_ZF()) {
      Bit32u new_EIP = EIP + (Bit32s) i->Id();
      branch_near32(new_EIP);
      BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    }
#if BX_INSTRUMENTATION
    else {
      BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
    }
#endif

    ECX = count;
  }
  else {
    Bit16u count = CX;

    count--;
    if (count != 0 && get_ZF()) {
      Bit32u new_EIP = EIP + (Bit32s) i->Id();
      branch_near32(new_EIP);
      BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    }
#if BX_INSTRUMENTATION
    else {
      BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
    }
#endif

    CX = count;
  }

  BX_NEXT_TRACE(i);
}

void BX_CPP_AttrRegparmN(1) BX_CPU_C::LOOP32_Jb(bxInstruction_c *i)
{
  // it is impossible to get this instruction in long mode
  BX_ASSERT(i->as64L() == 0);

  if (i->as32L()) {
    Bit32u count = ECX;

    count--;
    if (count != 0) {
      Bit32u new_EIP = EIP + (Bit32s) i->Id();
      branch_near32(new_EIP);
      BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    }
#if BX_INSTRUMENTATION
    else {
      BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
    }
#endif

    ECX = count;
  }
  else {
    Bit16u count = CX;

    count--;
    if (count != 0) {
      Bit32u new_EIP = EIP + (Bit32s) i->Id();
      branch_near32(new_EIP);
      BX_INSTR_CNEAR_BRANCH_TAKEN(BX_CPU_ID, PREV_RIP, new_EIP);
    }
#if BX_INSTRUMENTATION
    else {
      BX_INSTR_CNEAR_BRANCH_NOT_TAKEN(BX_CPU_ID, PREV_RIP);
    }
#endif

    CX = count;
  }

  BX_NEXT_TRACE(i);
}

#endif
