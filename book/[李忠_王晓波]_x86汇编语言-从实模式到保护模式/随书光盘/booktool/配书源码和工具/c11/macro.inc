; zs  即 segment_selector 即 段选择子  即 段寄存器
; usage: gen_zs GDIdx, TI, RPL
;        %1: GDIdx:  dw
;        %2: TI:    1bit
;        %3: RPL:    2bit
%macro gen_zs 3
	 dw	(%1    << 3) |  & (%2 << 2) | (%3) )	 ;   详见  [李忠_王晓波]_《x86汇编语言-从实模式到保护模式》的"图11-10 段选择子的组成"   
    ;dw	(GDIdx << 3) |  & (TI << 2) | (RPL) )	 ;    此行作为上一行的注释
%endmacro ; 共 2 字节