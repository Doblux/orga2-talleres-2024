section .rodata
; | 11110000 | <- esto es 1 byte y lo quiero de esta forma
    align 16
    FILTRAR_POR_VALUE_MASK: times 16 db 0x0F
    CMP_EQ_SHUFFLE: db 0x00, 0x00, 0x00, 0x00, 0x04, 0x04, 0x04, 0x04, 0x08, 0x08, 0x08, 0x08, 0x0C, 0x0C, 0x0C, 0x0C
    UNOS_DOUBLEWORD: times 4 dd 0xFFFFFFFF
    UNO: db 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
section .text

global four_of_a_kind_asm

; uint32_t four_of_a_kind_asm(card_t *hands, uint32_t n);
four_of_a_kind_asm:
	push rbp
	mov rbp, rsp
    ; n es la cantidad de manos (DWORDS)
	sar esi, 2 ; me traigo de a 4 manos a la vez ( 16 cartas ) divido por 4
    xor eax, eax

    movdqa  xmm15 , [FILTRAR_POR_VALUE_MASK]
    movdqa  xmm14 , [CMP_EQ_SHUFFLE]
    pxor    xmm13 , xmm13
_main_while_foak:
	cmp esi, 0
    je _salir_while
    
    movdqu  xmm8, [RDI]
    pand    xmm8, xmm15
    movdqu  xmm9, xmm8
    pshufb  xmm9, xmm14     ; me armo una mascara con las primeras caras repertidas
    pcmpeqd xmm9, xmm8
    psrld   xmm9, 31        ; en caso de ffff lo paso a 1
    paddd   xmm13, xmm9     ; acumolo las manos que cumplen de a 4
    
    add RDI, 16
    dec esi
	jmp _main_while_foak	


_salir_while:
	phaddd xmm13, xmm13
    phaddd xmm13, xmm13
    movd eax ,xmm13
    pop rbp
	ret

; xmm8
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
; | A0 | A1 | A2 | A3 | B0 | B1 | B2 | B3 | C0 | C1 | C2 | C3 | D0 | D1 | D2 | D3 |
;   00   00   00   00   04   04   04   04   08   08   08   08   0C   0C   0C   0C
; 
; xmm9 despues del shuffle
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
; | A0 | A0 | A0 | A0 | B0 | B0 | B0 | B0 | C0 | C0 | C0 | C0 | D0 | D0 | D0 | D0 |
;
; despues del compare un ejemplo (pcmpeqb xmm8, xmm9)
; xmm8
; | FF | FF | FF | FF | 00 | FF | 00 | FF | 00 | 00 | 00 | FF | 00 | FF | FF | FF |
; despues del segundo shuffle ejemplo:
; xmm8
; | FF | FF | FF | FF | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 |
; despues del and bit a bit en este ejemplo
; xmm8
; | 00 | 00 | 00 | 01 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 |

