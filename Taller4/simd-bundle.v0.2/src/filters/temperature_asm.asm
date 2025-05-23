global temperature_asm

section .data
align 16

NO_ALPHA_MASK: db 0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0x00
SHUFFLE_R_EN_B: db 0x02, 0x01, 0x02, 0x03, 0x06, 0x05, 0x06, 0x07, 0x0a, 0x09, 0x0a, 0x0b, 0x0e, 0x0d, 0x0e, 0x0f
SHUFFLE_G_EN_B: db 0x01, 0x01, 0x02, 0x03, 0x05, 0x05, 0x06, 0x07, 0x09, 0x09, 0x0a, 0x0b, 0x0d, 0x0d, 0x0e, 0x0f
LIMPIAR_TODO_MENOS_B: db 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00

SHUFFLE_B_EN_G: db 0x01, 0x00, 0x02, 0x03, 0x05, 0x04, 0x06, 0x07, 0x09, 0x08, 0x0a, 0x0b, 0x0d, 0x0c, 0x0e, 0x0f
SHUFFLE_B_EN_R: db 0x02, 0x01, 0x00, 0x03, 0x06, 0x05, 0x04, 0x07, 0x0a, 0x09, 0x08, 0x0b, 0x0e, 0x0d, 0x0c, 0x0f

SATURAR_RESULT: dd 255, 255, 255, 255

TRES: dd 3.0, 3.0, 3.0, 3.0

BASE_FST: db 128, 0, 0, 255, 128, 0, 0, 255, 128, 0, 0, 255, 128, 0, 0, 255
BASE_2ND: db 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255
BASE_3RD: db 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255
BASE_4TH: db 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255
BASE_5TH: db 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255

CMP_32_GT: dd 32, 32, 32, 32
CMP_31_GT: dd 31, 31, 31, 31
CMP_96_GT: dd 96, 96, 96, 96
CMP_95_GT: dd 95, 95, 95, 95
CMP_160_GT: dd 160, 160, 160, 160
CMP_159_GT: dd 159, 159, 159, 159
CMP_224_GT: dd 224, 224, 224, 224
CMP_223_GT: dd 223, 223, 223, 223

section .text
;;void temperature_asm(
;;              unsigned char *src, <-- RDI
;;              unsigned char *dst, <-- RSI
;;              int width,          <-- EDX
;;              int height,         <-- ECX alto en pixeles
;;              int src_row_size,   <-- R8D ancho en bytes de la imagen
;;              int dst_row_size);  <-- R9D
;
temperature_asm:
	push rbp
	mov rbp, rsp
	
	mov eax, r8d
	mul ecx
	
.ciclo_main:
	cmp rax, 0
	je .fin
	
	movdqu xmm0, [RDI]
	call calcular_temperatura
	movdqu xmm8, xmm0 ; backup temperatura
    
; t < 32 ------------------------------------------------------------------------------------------------------------------
    movdqu xmm15, xmm8 ; t
    movdqa xmm14, [CMP_32_GT]
    pcmpgtd xmm14, xmm15 ; 32 > t ; para doubleword no interesa si son numeros signados, estan dentro del rango
    movdqu xmm1, xmm8
    pslld xmm1, 2 ; multiplico por 4   
    pminud xmm1, [SATURAR_RESULT]
    movdqa xmm0, [BASE_FST]
    paddusb xmm0, xmm1
    pand xmm0, xmm14
; -------------------------------------------------------------------------------------------------------------------------- 
; t > 31 && 96 > t ------------------------------------------------------------------------------------------------------------------
    movdqu xmm15, xmm8
    movdqa xmm14, [CMP_31_GT]
    pcmpgtd xmm15, xmm14
    movdqu xmm14, xmm8
    movdqa xmm13, [CMP_96_GT]
    pcmpgtd xmm13, xmm14
    pand xmm15, xmm13
    
    movdqu xmm1, xmm8
    movdqa xmm2, [BASE_2ND]
    psubusb xmm1, [CMP_32_GT]
    pslld xmm1, 2
    pminud xmm1, [SATURAR_RESULT]
    pshufb xmm1, [SHUFFLE_B_EN_G]   
    paddusb xmm2, xmm1
    pand xmm2, xmm15
    movdqu xmm1, xmm2
; -------------------------------------------------------------------------------------------------------------------------- 
; xmm1 y xmm0 aca tienen informacion importante que no hay que tocar hasta el final
; --------------------------------------------------------------------------------------------------------------------------
; t > 95 && 160 > t --------------------------------------------------------------------------------------------------------
    movdqu xmm15, xmm8
    movdqa xmm14, [CMP_95_GT]
    pcmpgtd xmm15, xmm14
    movdqu xmm14, xmm8
    movdqa xmm13, [CMP_160_GT]
    pcmpgtd xmm13, xmm14
    pand xmm15, xmm13
    movdqu xmm2, xmm8
    movdqa xmm3, [BASE_3RD]
    psubusb xmm2, [CMP_96_GT]
    pslld xmm2, 2
    pminud xmm2, [SATURAR_RESULT]
    psubusb xmm3, xmm2
    pshufb xmm2, [SHUFFLE_B_EN_R]
    paddusb xmm3, xmm2
    movdqu xmm2, xmm3
    pand xmm2, xmm15
; --------------------------------------------------------------------------------------------------------------------------
; xmm0, xmm1 y xmm2 --> usar xmm3 y xmm4
; --------------------------------------------------------------------------------------------------------------------------
; t > 159 && 224 > t
    movdqu xmm15, xmm8
    movdqa xmm14, [CMP_159_GT]
    pcmpgtd xmm15, xmm14
    movdqa xmm14, xmm8
    movdqa xmm13, [CMP_224_GT]
    pcmpgtd xmm13, xmm14
    pand xmm15, xmm13
    
    movdqu xmm3, xmm8
    psubusb xmm3, [CMP_160_GT]
    pslld xmm3, 2
    pminud xmm3, [SATURAR_RESULT]
    movdqa xmm4, [BASE_4TH]
    pshufb xmm3, [SHUFFLE_B_EN_G]
    psubusb xmm4, xmm3
    movdqu xmm3, xmm4
    pand xmm3, xmm15
; --------------------------------------------------------------------------------------------------------------------------
; xmm0, xmm1, xmm2 y xmm3 --> usar xmm4 y xmm5
; --------------------------------------------------------------------------------------------------------------------------
;  t >= 224 === t > 223
    movdqu xmm15, xmm8
    movdqa xmm14, [CMP_223_GT]
    pcmpgtd xmm15, xmm14
    
    movdqu xmm4, xmm8
    movdqa xmm5, [BASE_5TH]
    psubusb xmm4, [CMP_224_GT]
    pslld xmm4, 2
    pminud xmm4, [SATURAR_RESULT]
    pshufb xmm4, [SHUFFLE_B_EN_R]
    psubusb xmm5, xmm4
    movdqu xmm4, xmm5
    pand xmm4, xmm15

; --------------------------------------------------------------------------------------------------------------------------
    por xmm0, xmm1
    por xmm0, xmm2
    por xmm0, xmm3
    por xmm0, xmm4

	movdqu [RSI], xmm0
	add rsi, 16
	add rdi, 16
	sub rax, 16
	jmp .ciclo_main	

.fin:
	pop rbp
	ret




calcular_temperatura:
	push rbp
	mov rbp, rsp
	
    movdqa xmm15, [NO_ALPHA_MASK]
    movdqa xmm14, [SHUFFLE_R_EN_B]
    movdqa xmm13, [SHUFFLE_G_EN_B]
    movdqa xmm12, [LIMPIAR_TODO_MENOS_B]

    pand xmm0, xmm15 ; B
    movdqu xmm1, xmm0 ; G
    movdqu xmm2, xmm0 ; R
    
    pshufb xmm1, xmm13
    pshufb xmm2, xmm14
    pand xmm0, xmm12
    pand xmm1, xmm12
    pand xmm2, xmm12
    
    ; no hay saturacion por ser numero muy pequeño para un doubleword
    paddd xmm0, xmm1
    paddd xmm0, xmm2
    
    cvtdq2ps xmm0, xmm0 ;Convert Packed Doubleword Integers to Packed Single Precision Floating-PointValues
    divps xmm0, [TRES] ;
    roundps xmm0, xmm0, 1 ; Redondea para abajo
    cvtps2dq xmm0, xmm0

	pop rbp
	ret

;registro xmm0
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | A3 | R3 | G3 | B3 | A2 | R2 | G2 | B2 | A1 | R1 | G1 | B1 | A0 | R0 | G0 | B0 |
;   00   ff   ff   ff   00   ff   ff   ff   00   ff   ff   ff   00   ff   ff   ff
; pand xmm0, xmm1

; SHUFFLE_R_EN_B:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | 00 | R3 | G3 | B3 | 00 | R2 | G2 | B2 | 00 | R1 | G1 | B1 | 00 | R0 | G0 | B0 |
;   0f   0e   0d   0e   0b   0a   09   0a   07   06   05   06   03   02   01   02

; SHUFFLE_G_EN_B:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | 00 | R3 | G3 | B3 | 00 | R2 | G2 | B2 | 00 | R1 | G1 | B1 | 00 | R0 | G0 | B0 |
;   0f   0e   0d   0d   0b   0a   09   09   07   06   05   05   03   02   01   01

; LIMPIAR_TODO_MENOS_B:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | 00 | R3 | G3 | B3 | 00 | R2 | G2 | B2 | 00 | R1 | G1 | B1 | 00 | R0 | G0 | B0 |
;   00   00   00   ff   00   00   00   ff   00   00   00   ff   00   00   00   ff

;  BASE_FST:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | 00 | R3 | G3 | B3 | 00 | R2 | G2 | B2 | 00 | R1 | G1 | B1 | 00 | R0 | G0 | B0 |
;   255   00   00   128  255   00   00   128  255   00   00   128  255   00   00   128

; BASE_2ND:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | 00 | R3 | G3 | B3 | 00 | R2 | G2 | B2 | 00 | R1 | G1 | B1 | 00 | R0 | G0 | B0 |
;  255,  0,   0    255

; SHUFFLE_B_EN_G:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | 00 | R3 | G3 | B3 | 00 | R2 | G2 | B2 | 00 | R1 | G1 | B1 | 00 | R0 | G0 | B0 |
;   0f   0e   0c   0d   0b   0a   08   09   07   06   04   05   03   02   00   01

; BASE_3RD:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | 00 | R3 | G3 | B3 | 00 | R2 | G2 | B2 | 00 | R1 | G1 | B1 | 00 | R0 | G0 | B0 |
;  255,  0, 255, 255

; SHUFFLE_B_EN_R:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | 00 | R3 | G3 | B3 | 00 | R2 | G2 | B2 | 00 | R1 | G1 | B1 | 00 | R0 | G0 | B0 |
;   0f   0c   0d   0e   0b   08   09   0a   07   04   05   06   03   00   01   02

; BASE_4TH:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | 00 | R3 | G3 | B3 | 00 | R2 | G2 | B2 | 00 | R1 | G1 | B1 | 00 | R0 | G0 | B0 |
;  255, 255, 255, 0

; BASE_5TH:
;   0f   0e   0d   0c   0b   0a   09   08   07   06   05   04   03   02   01   00
; | 00 | R3 | G3 | B3 | 00 | R2 | G2 | B2 | 00 | R1 | G1 | B1 | 00 | R0 | G0 | B0 |
;   255, 255, 0, 0
