extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global product_9_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[RDI], x2[RSI], x3[RDX], x4[RCX]
alternate_sum_4:
	push rbp ; alineado
	mov rbp, rsp
	
	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx
	
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp
	push r13 ; desalineado
	push r12 ; alineado
	
	mov r13, rdx ; x3
	mov r12, rcx ; x4

	call restar_c
	mov rdi, rax
	mov rsi, r13
	call sumar_c
	mov rdi, rax
	mov rsi, r12
	call restar_c
	
	;epilogo
	pop r12
	pop r13
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[RDI], x2[RSI], x3[RDX], x4[RCX]
alternate_sum_4_simplified:
	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx
	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[RDI], x2[RSI], x3[RDX], x4[RCX], x5[R8], x6[R9], x7[rbp+16], x8[rbp+20]
alternate_sum_8:
	push rbp
	mov rbp, rsp

	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx
	add rax, r8
	sub rax, r9
	add rax, [rbp+16]
	sub rax, [rbp+24]
	
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t* destination, uint32_t x1, float f1);
;registros: destination[RDI], x1[ESI], f1[XMM0]
product_2_f:
	CVTSI2SS XMM1, ESI ; Convertir esi (entero) a xmm1 (float)
	MULSS xmm0, xmm1 ; Multiplicar xmm0 y xmm1 y guardar el resultado en xmm0
	; CVTSS2SI EAX, xmm0  ; resultado sin truncar
    cvttss2si eax, xmm0 ; Truncar los dígitos decimales convirtiendo a entero
	mov DWORD [RDI], EAX
	ret


;extern void product_9_f(uint32_t * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[esi], f1[xmm0], x2[edx], f2[xmm1], x3[ecx], f3[xmm2], x4[r8d], f4[xmm3]
;	, x5[r9d], f5[xmm4], x6[rbp+16], f6[xmm5], x7[rbp+12], f7[xmm6], x8[rbp+8], f8[xmm7],
;	, x9[rbp+12], f9[rbp+8]
; 
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp
    
	;convertimos los flotantes de cada registro xmm en doubles
    cvtss2sd xmm0, xmm0
    cvtss2sd xmm1, xmm1
    cvtss2sd xmm2, xmm2
    cvtss2sd xmm3, xmm3
    cvtss2sd xmm4, xmm4
    cvtss2sd xmm5, xmm5
    cvtss2sd xmm6, xmm6
    cvtss2sd xmm7, xmm7

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
    mulsd xmm0, xmm1
    mulsd xmm0, xmm2
    mulsd xmm0, xmm3
    mulsd xmm0, xmm4
    mulsd xmm0, xmm5
    mulsd xmm0, xmm6
    mulsd xmm0, xmm7

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
    cvtsi2sd xmm8, esi
    cvtsi2sd xmm9, edx
    cvtsi2sd xmm10, ecx
    cvtsi2sd xmm11, r8d
    cvtsi2sd xmm12, r9d
    cvtsi2sd xmm13, [rbp+8]
    cvtsi2sd xmm14, [rbp+12]
    cvtsi2sd xmm15, [rbp+16]

    mulsd xmm0, xmm8
    mulsd xmm0, xmm9
    mulsd xmm0, xmm10
    mulsd xmm0, xmm11
    mulsd xmm0, xmm12
    mulsd xmm0, xmm13
    mulsd xmm0, xmm14
    mulsd xmm0, xmm15

    movdqu [RDI], xmm0

	; epilogo
	pop rbp
	ret


