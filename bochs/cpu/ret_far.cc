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
////////////////////////////////////////////////////////////////////////

#define NEED_CPU_REG_SHORTCUTS 1
#include "bochs.h"
#include "cpu.h"
#define LOG_THIS BX_CPU_THIS_PTR

  void BX_CPP_AttrRegparmN(2)
BX_CPU_C::return_protected(bxInstruction_c *i, Bit16u pop_bytes)
{
  Bit16u raw_cs_selector, raw_ss_selector;
  bx_selector_t cs_selector, ss_selector;
  bx_descriptor_t cs_descriptor, ss_descriptor;
  Bit32u stack_param_offset;
  bx_address return_RIP, return_RSP, temp_RSP;
  Bit32u dword1, dword2;
  // str cs_selector_json_text,cs_descriptor_json_text,ss_selector_json_text,ss_descriptor_json_text;

    if (BX_CPU_THIS_PTR sregs[BX_SEG_REG_SS].cache.u.segment.d_b) temp_RSP = ESP;
    else temp_RSP = SP;

  if (i->os32L()) {//若是32位
    raw_cs_selector = (Bit16u) stack_read_dword(temp_RSP + 4);//从栈中取 新代码段选择子CS
    return_RIP      =          stack_read_dword(temp_RSP);//从栈中取  返回地址EIP(该代码段内的偏移量)
    stack_param_offset = 8;//参数从栈偏移8开始
  }
  else {//否则为64为
    raw_cs_selector = stack_read_word(temp_RSP + 2);//从栈中取 新代码段选择子CS
    return_RIP      = stack_read_word(temp_RSP);//从栈中取  返回地址RIP(该代码段内的偏移量)
    stack_param_offset = 4;//参数从栈偏移4开始
  }

  parse_selector(raw_cs_selector, &cs_selector);//解析出 新代码段选择子CS cs_selector

  // 以 下标 取 元素 : 以 数组下标 获取 数组中该下标内的元素
  fetch_raw_descriptor(&cs_selector, &dword1, &dword2, BX_GP_EXCEPTION);//以 下标 取 元素: 以 新代码段选择子CS cs_selector 取 新代码段描述符 

  parse_descriptor(dword1, dword2, &cs_descriptor);//解析出 新代码段描述符cs_descriptor
//转 cs_selector、cs_descriptor 为json_text, 且需要打印return_RIP
// cs_selector_json_text=BX_CPU_THIS->print_selector(&cs_selector);
// cs_descriptor_json_text=BX_CPU_THIS->printDescriptor(&cs_descriptor);

  // check code-segment descriptor
  check_cs(&cs_descriptor, raw_cs_selector, 0, cs_selector.rpl);

  if (cs_selector.rpl == CPL)//若同PL权限级
  {
    branch_far(&cs_selector, &cs_descriptor, return_RIP, CPL);//跳转到 该新代码段(代码段描述符cs_descriptor) 内的 偏移量return_RIP 即可. 
    //即 将 新代码段描述符cs_descriptor 装载入 代码段描述符寄存器, 并 跳转到 该新代码段内 偏移量return_RIP 处.
      if (BX_CPU_THIS_PTR sregs[BX_SEG_REG_SS].cache.u.segment.d_b)
        RSP = ESP + stack_param_offset + pop_bytes;//新栈为当前栈跳过若干字节
      else
         SP += stack_param_offset + pop_bytes;//新栈为当前栈跳过若干字节
  }
  /* RETURN TO OUTER PRIVILEGE LEVEL 否则返回到不同的PL权限级, 从栈中 切换栈SS:SP 并 切换CS:IP */
  else {//否则,不同PL权限级
    /* + 6+N*2: SS      | +12+N*4:     SS | +24+N*8      SS */
    /* + 4+N*2: SP      | + 8+N*4:    ESP | +16+N*8     RSP */
    /*          parm N  | +        parm N | +        parm N */
    /*          parm 3  | +        parm 3 | +        parm 3 */
    /*          parm 2  | +        parm 2 | +        parm 2 */
    /* + 4:     parm 1  | + 8:     parm 1 | +16:     parm 1 */
    /* + 2:     CS      | + 4:         CS | + 8:         CS */
    /* + 0:     IP      | + 0:        EIP | + 0:        RIP */

    if (i->os32L()) {
      raw_ss_selector = stack_read_word(temp_RSP + 12 + pop_bytes);//从 当前栈 中 取 新栈段选择子ss
      return_RSP      = stack_read_dword(temp_RSP + 8 + pop_bytes);//从 当前栈 中 取 新ESP
    }
    else {
      raw_ss_selector = stack_read_word(temp_RSP + 6 + pop_bytes);//从 当前栈 中 取 新栈段选择子ss
      return_RSP      = stack_read_word(temp_RSP + 4 + pop_bytes);//从 当前栈 中 取 新RSP
    }

    parse_selector(raw_ss_selector, &ss_selector);//解析出 新栈段选择子ss ss_selector

      fetch_raw_descriptor(&ss_selector, &dword1, &dword2, BX_GP_EXCEPTION);//以 下标 取 元素: 以 新栈段选择子ss ss_selector 取 新栈段描述符
      parse_descriptor(dword1, dword2, &ss_descriptor);//解析出 新栈段描述符ss_descriptor
    //转  ss_selector、ss_descriptor 为 json_text
// ss_selector_json_text=BX_CPU_THIS->print_selector(&ss_selector);
// ss_descriptor_json_text=BX_CPU_THIS->printDescriptor(&ss_descriptor);

    branch_far(&cs_selector, &cs_descriptor, return_RIP, cs_selector.rpl);//跳转到 该新代码段(新代码段描述符cs_descriptor) 内的 偏移量return_RIP. 
    //即 将 新代码段描述符cs_descriptor 装载入 代码段描述符寄存器, 并 跳转到 该新代码段内 偏移量return_RIP 处.

    if ((raw_ss_selector & 0xfffc) != 0) {
      // load SS:RSP from stack
      // load the SS-cache with SS descriptor
      load_ss(&ss_selector, &ss_descriptor, cs_selector.rpl);//将 新栈段描述符ss_descriptor 装载入 栈段描述符寄存器
    }

      if (ss_descriptor.u.segment.d_b)
        RSP = (Bit32u)(return_RSP + pop_bytes);//新栈与当前栈无关
      else
        SP  = (Bit16u)(return_RSP + pop_bytes);//新栈与当前栈无关

    /* check ES, DS, FS, GS for validity */
    validate_seg_regs();
  }
  //branch_far1 和 branch_far2 只有一个会执行
  //line_text="%s,%s,%s,%s,%s" % (cs_selector_text,cs_descriptor_text,return_RIP,ss_selector_text,ss_descriptor_text)
  //打印日志: BX_INFO(("%s",line_text));

}

#if BX_SUPPORT_CET
  bx_address BX_CPP_AttrRegparmN(3)
BX_CPU_C::shadow_stack_restore(Bit16u raw_cs_selector, const bx_descriptor_t &cs_descriptor, bx_address return_rip)
{
  bx_address return_lip = return_rip;
  if (! long_mode() || ! cs_descriptor.u.segment.l)
    return_lip = (Bit32u) (return_lip + cs_descriptor.u.segment.base);

  if (SSP & 0x7) {
    BX_ERROR(("return_protected: SSP must be 8-byte aligned"));
    exception(BX_CP_EXCEPTION, BX_CP_FAR_RET_IRET);
  }

  Bit64u prevSSP   = shadow_stack_pop_64();
  Bit64u shadowLIP = shadow_stack_pop_64();
  Bit64u shadowCS  = shadow_stack_pop_64();

  if (raw_cs_selector != shadowCS) {
    BX_ERROR(("shadow_stack_restore: CS mismatch"));
    exception(BX_CP_EXCEPTION, BX_CP_FAR_RET_IRET);
  }
  if (return_lip != shadowLIP) {
    BX_ERROR(("shadow_stack_restore: LIP mismatch"));
    exception(BX_CP_EXCEPTION, BX_CP_FAR_RET_IRET);
  }
  if (prevSSP & 0x3) {
    BX_ERROR(("shadow_stack_restore: prevSSP must be 4-byte aligned"));
    exception(BX_CP_EXCEPTION, BX_CP_FAR_RET_IRET);
  }
  if (!long64_mode() && (prevSSP>>32)!=0) {
    BX_ERROR(("shadow_stack_restore: prevSSP must be 32-bit in 32-bit mode"));
    exception(BX_GP_EXCEPTION, 0);
  }

  return prevSSP;
}
#endif
