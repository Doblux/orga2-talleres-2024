section .rodata
cuatro_blancos : times 16 db 0xff
cuatro_negros  : db 		 0x00,0x00,0x00,0xff,0x00,0x00,0x00,0xff,0x00,0x00,0x00,0xff,0x00,0x00,0x00,0xff
primero_negro  : db			 0x00,0x00,0x00,0xff,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff 
ultimo_negro   : db 		 0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0xff,0x00,0x00,0x00,0xff

section .text
global Pintar_asm

;void Pintar_asm(unsigned char *src [RDI],
;              unsigned char *dst [RSI],
;              int width [EDX],
;              int height [ECX],
;              int src_row_size [R8D],
;              int dst_row_size)[R9D];



Pintar_asm:
	push rbp
	mov rbp , rsp 
	mov R12D , 0
	mov R13D , ECX
	dec R13D
	mov R14D , EDX
	sub R14D , 4
	mov R15D , R13D
	dec	R15D
    movdqu xmm8  , [cuatro_blancos]
	movdqu xmm9  , [cuatro_negros]
    movdqu xmm10 , [primero_negro]
    movdqu xmm11 , [ultimo_negro]
    procesar_fila:
		
		cmp R12D , ECX
		je  fin_fila
		xor R11D , R11D
		
		procesar_columan:
			cmp R11D , EDX   			;fin de la iteracion
			je fin_columna  

			cmp R12D , 0				; chequeo de primera o ultima fila
			je todo_negro
			cmp R12D , R13D
			je todo_negro
			
			cmp R12D , 1				; chequeo de primera o ultima fila
			je todo_negro
			cmp R12D , R15D
			je todo_negro

			cmp R11D , 0
			je p_negro

			cmp R11D , R14D
			je u_negro
			
			movdqu xmm12 , xmm8
			jmp pintar
			
			p_negro:
			movdqu  xmm12 , xmm10
			jmp pintar
			
			u_negro:
			movdqu  xmm12 , xmm11
			jmp pintar
			
			todo_negro:
			movdqu  xmm12 , xmm9

			pintar:
			
			movdqu	[RSI], xmm12
			add RSI , 16
			add R11D, 4
	
			jmp procesar_columan
		fin_columna:
		add R12D , 1
		jmp procesar_fila
	
	fin_fila:
	pop rbp
	ret