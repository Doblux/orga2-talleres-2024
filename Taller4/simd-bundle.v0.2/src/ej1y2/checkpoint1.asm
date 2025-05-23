
section .text

global dot_product_asm

; uint32_t dot_product_asm(uint16_t *p, uint16_t *q, uint32_t length);
; implementacion simd de producto punto

dot_product_asm:
	push rbp
	mov rbp, rsp
	push r14
	sub rsp, 8	

	shr rdx, 3	

	xor eax, eax
_while_dot_product:
	cmp edx, 0
	je _fin_dot_product
	
	movdqu xmm0, [RDI] ; 8 words ; xmm0 | d7 | d6 | d5 | d4 | d3 | d2 | d1 | d0 |
	movdqu xmm1, [RSI] ; 8 words ; xmm1 | b7 | b6 | b5 | b4 | b3 | b2 | b1 | b0 |
	PMADDWD xmm0, xmm1 ; 4 doublewords ; | R3 = d7*b7+d6*b6 | R2 = d5*b5+d4*b4 | R1 = d3*b3+d2*b2 | R0=d1*b1+d0*b0 |
	PHADDD xmm0, xmm0
	PHADDD xmm0, xmm0
	MOVD r14d, xmm0		
	ADD EAX, r14d	

	dec edx
	add RDI, 16
	add RSI, 16
	jmp _while_dot_product

_fin_dot_product:
	add rsp, 8
	pop r14
	pop rbp
	ret
