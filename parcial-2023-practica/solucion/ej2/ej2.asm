global mezclarColores

section .rodata
align 16
QUITAR_TODO_MENOS_B: db 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
SHUFFLE_R_EN_B: db 0x02, 0x01, 0x00, 0x03, 0x06, 0x05, 0x04, 0x07, 0x0a, 0x09, 0x08, 0x0b, 0x0e, 0x0d, 0x0c, 0x0f
SHUFFLE_G_EN_B: db 0x01, 0x00, 0x02, 0x03, 0x05, 0x04, 0x06, 0x07, 0x09, 0x08, 0x0a, 0x0b, 0x0d, 0x0c, 0x0e, 0x0f
RES_PRIMER_CMP: db 0x01, 0x02, 0x00, 0x03, 0x05, 0x06, 0x04, 0x07, 0x09, 0x0a, 0x08, 0x0b, 0x0d, 0x0e, 0x0c, 0x0f
RES_SEGUNDO_CMP: db 0x02, 0x00, 0x01, 0x03, 0x06, 0x04, 0x05, 0x07, 0x0a, 0x08, 0x09, 0x0b, 0x0e, 0x0c, 0x0d, 0x0f
ALPHA_EN_00: db 0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0x00

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void mezclarColores( 
; uint8_t *X,  --> RDI
; uint8_t *Y,  --> RSI
;uint32_t width, --> EDX
;uint32_t height); --> ECX
mezclarColores:
    push rbp
    mov rbp, rsp
    
    mov eax, edx
    imul eax, ecx
.main_ciclo:
    cmp eax, 0
    je .fin_ciclo
    
    movdqu xmm0, [RDI]

; ---------------------------------------------------------------------------------------------
    movdqu xmm15, xmm0 ; B
    movdqu xmm14, xmm0 ; G
    movdqu xmm13, xmm0 ; R
    pshufb xmm14, [SHUFFLE_G_EN_B]
    pshufb xmm13, [SHUFFLE_R_EN_B]
    pand xmm15, [QUITAR_TODO_MENOS_B]
    pand xmm14, [QUITAR_TODO_MENOS_B]
    pand xmm13, [QUITAR_TODO_MENOS_B]
    movdqu xmm8, xmm15 ; B
    movdqu xmm9, xmm14 ; G 
    movdqu xmm10, xmm13 ; R

    pcmpgtd xmm13, xmm14 ; R > G
    pcmpgtd xmm14, xmm15 ; G > B
    pand xmm13, xmm14 ; primera condicion sobre xmm13   R > G && G > B
    
    pcmpgtd xmm8, xmm9 ; B > G
    pcmpgtd xmm9, xmm10 ; G > R
    pand xmm8, xmm9 ; B > G && G > R
    
    movdqu xmm15, xmm13 ; primera condicion
    movdqu xmm14, xmm8 ; segunda condicion
    
    movdqu xmm10, xmm15
    movdqu xmm11, xmm14
    por xmm10, xmm11
    pcmpeqd xmm11, xmm11 ; lleno el registro de 1
    pandn xmm10, xmm11 ; niego el registro xmm10
    movdqu xmm13, xmm10 ; tercer condicion

; primer condicion xmm15
; segunda condicion xmm14
; tercer condicion xmm13
    movdqu xmm1, xmm0
    movdqu xmm2, xmm0
    pshufb xmm1, [RES_PRIMER_CMP]
    pshufb xmm2, [RES_SEGUNDO_CMP]
    pand xmm1, xmm15
    pand xmm2, xmm14
    pand xmm0, xmm13
    por xmm0, xmm1
    por xmm0, xmm2
    pand xmm0, [ALPHA_EN_00]


    movdqu [RSI], xmm0
    add rdi, 16
    add rsi, 16
    sub eax, 4
    jmp .main_ciclo
    
.fin_ciclo:
    pop rbp
    ret

; QUITAR_TODO_MENOS_B
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | A3 | R3 | G3 | B3 | A2 | R2 | G2 | B2 | A1 | R1 | G1 | B1 | A0 | R0 | G0 | B0 |
;   00   00   00   ff   00   00   00   ff   00   00   00   ff   00   00   00   ff

; SHUFFLE_R_EN_B:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | A3 | R3 | G3 | B3 | A2 | R2 | G2 | B2 | A1 | R1 | G1 | B1 | A0 | R0 | G0 | B0 |
;   0f   0c   0d   0e   0b   08   09   0a   07   04   05   06   03   00   01   02

; SHUFFLE_G_EN_B:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | A3 | R3 | G3 | B3 | A2 | R2 | G2 | B2 | A1 | R1 | G1 | B1 | A0 | R0 | G0 | B0 |
;   0f   0e   0c   0d   0b   0a   08   09   07   06   04   05   03   02   00   01

; RES_PRIMER_CMP:
;  R=B && G=R && B=G
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | A3 | R3 | G3 | B3 | A2 | R2 | G2 | B2 | A1 | R1 | G1 | B1 | A0 | R0 | G0 | B0 |
;   0f   0c   0e   0d   0b   08   0a   09   07   04   06   05   03   00   02   01

; RES_SEGUNDO_CMP:
;  R=G && G=B && B=R
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | A3 | R3 | G3 | B3 | A2 | R2 | G2 | B2 | A1 | R1 | G1 | B1 | A0 | R0 | G0 | B0 |
;   0f   0d   0c   0e   0b   09   08   0a   07   05   04   06   03   01   00   02

; ALPHA_EN_00:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | A3 | R3 | G3 | B3 | A2 | R2 | G2 | B2 | A1 | R1 | G1 | B1 | A0 | R0 | G0 | B0 |
;   00   ff   ff   ff   00   ff   ff   ff   00   ff   ff   ff   00   ff   ff   ff
