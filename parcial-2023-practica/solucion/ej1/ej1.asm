%define OFFSET_PAGO_T_MONTO 0
%define OFFSET_PAGO_T_APROBADO 1
%define OFFSET_PAGO_T_PAGADOR 8
%define OFFSET_PAGO_T_COBRADOR 16
%define SIZE_OF_PAGO_T 24

%define OFFSET_PAGOSPLITTED_T_CANT_APROBADOS 0
%define OFFSET_PAGOSPLITTED_T_CANT_RECHAZADOS 1
%define OFFSET_PAGOSPLITTED_T_APROBADOS 8
%define OFFSET_PAGOSPLITTED_T_RECHAZADOS 16
%define SIZE_OF_PAGOSPLITTED_T 24

%define OFFSET_LISTELEM_T_DATA 0
%define OFFSET_LISTELEM_T_NEXT 8
%define OFFSET_LISTELEM_T_PREV 16
%define SIZE_OF_LISTELEM_T 24

%define OFFSET_LIST_T_FIRST 0
%define OFFSET_LIST_T_LAST 8
%define SIZE_OF_LIST_T 16

section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp


;########### SECCION DE TEXTO (PROGRAMA)

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
contar_pagos_aprobados_asm:
    push rbp
    mov rbp, rsp
    push r15 
    push r14
    push r13
    push r12

    xor r12b, r12b ; res = 0
    mov r15, [RDI + OFFSET_LIST_T_FIRST] ; nodo_actual = pList->first;
.ciclo_cant_pagos_aprobados:
    cmp r15, qword 0
    je .fin_cant_pagos_aprobados
    
    mov r14, qword [r15 + OFFSET_LISTELEM_T_DATA]
    ; r13b = data->aprobado
    mov r13b, byte [r14 + OFFSET_PAGO_T_APROBADO]
    
    cmp r13b, byte 1
    jne .siguiente_ciclo_pagos_aprobados
    
    mov r14, qword [r14 + OFFSET_PAGO_T_COBRADOR]
    
    push rdi ; desalineado
    push rsi ; alineado
    mov rdi, r14
    call strcmp
    pop rsi
    pop rdi

    cmp al, byte 0
    jne .siguiente_ciclo_pagos_aprobados

    inc r12b

.siguiente_ciclo_pagos_aprobados:
    mov r15, [r15 + OFFSET_LISTELEM_T_NEXT]
    jmp .ciclo_cant_pagos_aprobados

.fin_cant_pagos_aprobados:
    mov rax, r12
    pop r12
    pop r13
    pop r14
    pop r15
    pop rbp
    ret


; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
contar_pagos_rechazados_asm:
    push rbp
    mov rbp, rsp
    push r15 
    push r14
    push r13
    push r12

    xor r12b, r12b ; res = 0
    mov r15, [RDI + OFFSET_LIST_T_FIRST] ; nodo_actual = pList->first;
.ciclo_cant_pagos_rechazados:
    cmp r15, qword 0
    je .fin_cant_pagos_rechazados
    
    mov r14, qword [r15 + OFFSET_LISTELEM_T_DATA]
    ; r13b = data->aprobado
    mov r13b, byte [r14 + OFFSET_PAGO_T_APROBADO]
    
    cmp r13b, byte 0
    jne .siguiente_ciclo_pagos_rechazados
    
    mov r14, qword [r14 + OFFSET_PAGO_T_COBRADOR]
    
    push rdi ; desalineado
    push rsi ; alineado
    mov rdi, r14
    call strcmp
    pop rsi
    pop rdi

    cmp al, byte 0
    jne .siguiente_ciclo_pagos_rechazados

    inc r12b

.siguiente_ciclo_pagos_rechazados:
    mov r15, [r15 + OFFSET_LISTELEM_T_NEXT]
    jmp .ciclo_cant_pagos_rechazados

.fin_cant_pagos_rechazados:
    mov rax, r12
    pop r12
    pop r13
    pop r14
    pop r15
    pop rbp
    ret

; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
split_pagos_usuario_asm:
    push rbp
    mov rbp, rsp
    push r15
    push r14
    push r13
    push r12
    push r11
    push r10

    push rdi
    push rsi
    mov rdi, SIZE_OF_PAGOSPLITTED_T
    call malloc
    pop rsi
    pop rdi
    
    mov r15, qword rax ; (puntero)  en r15 guardo pagoSplitted_t* n (ya le hicimos malloc)
    
    push rdi
    push rsi
    call contar_pagos_aprobados_asm
    pop rsi
    pop rdi
    
    mov byte [r15 + OFFSET_PAGOSPLITTED_T_CANT_APROBADOS], al
    mov byte r12b, al ; r12 pagos aprobados cant

    push rdi
    push rsi
    call contar_pagos_rechazados_asm
    pop rsi
    pop rdi

    mov byte [r15 + OFFSET_PAGOSPLITTED_T_CANT_RECHAZADOS], al
    mov byte r13b, al ; r13 pagos rechazados cant
    
    mov r14, r15 ; pagoSplitted_t* n sobre r14
    add r14, OFFSET_PAGOSPLITTED_T_APROBADOS ; r14 = pago_t** es un arreglo de punteros a pago_t
    
    push rdi
    push rsi
    mov dil, r12b
    sal dil, 3 
    call malloc
    pop rsi
    pop rdi

    mov [r14], qword rax ; n->aprobados = malloc(n->cant_aprobados * sizeof(pago_t*))
    mov r14, r15 ; pagoSplitted_t* n sobre r14
    add r14, OFFSET_PAGOSPLITTED_T_RECHAZADOS
    
    push rdi
    push rsi
    mov dil, r13b
    sal dil, 3
    call malloc
    pop rsi
    pop rdi

    mov [r14], rax
    
; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
; una vez que termine de inicializar la estructura recien ahora comienza la funcion
; estado actual: r15 = pagoSplitted_t* n
    mov r14, qword [RDI + OFFSET_LIST_T_FIRST] ; (puntero) al primer elemento
    xor r13, r13 ; i
    xor r12, r12 ; j
.ciclo_pagosp:
    cmp r14, qword 0
    je .fin_pagosp
    
    mov r11, r14 ; nodo_actual
    add r11, OFFSET_LISTELEM_T_DATA
    ; r11 = puntero al pago_actual
    mov r10, r14
    add r10, OFFSET_PAGO_T_COBRADOR
    
    push rdi
    push rsi
    mov rdi, r10
    call strcmp
    pop rsi
    pop rdi
    cmp al, byte 0
    jne .siguiente_pagosp
    
    mov r11b, byte [r11 + OFFSET_PAGO_T_APROBADO]
    cmp r11b, byte 1
    jne .pago_desaprobado

.pago_aprobado:
    mov r10, r15
    add r10, OFFSET_PAGOSPLITTED_T_APROBADOS
    
    push r13
    sub rsp, 8
    imul r13, SIZE_OF_PAGO_T
    mov r10, [r10 + r13]
    mov [r10], r11
    add rsp, 8
    pop r13
    
    inc r13
    jmp .siguiente_pagosp
.pago_desaprobado:
    mov r10, r15
    add r10, OFFSET_PAGOSPLITTED_T_APROBADOS
    
    push r12
    sub rsp, 8
    imul r12, SIZE_OF_PAGO_T
    mov r10, [r10 + r12]
    mov [r10], r11
    add rsp, 8
    pop r12
    
    inc r12

.siguiente_pagosp:
    mov r14, [r14 + OFFSET_LISTELEM_T_NEXT]
    jmp .ciclo_pagosp

.fin_pagosp:
    mov rax, r15
    pop r10
    pop r11
    pop r12
    pop r13
    pop r14
    pop r15
    pop rbp
    ret
