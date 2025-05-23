extern malloc
extern free
extern fprintf

%define NULL 0

section .data
stringNULL: db "NULL"
string_indicator: db "%s"

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
; a --> RDI
; b --> RSI
; Compara dos strings en orden lexicográfico. Ver https://es.wikipedia.org/wiki/Orden_lexicografico.
; Debe retornar: 
; 0 si son iguales
; 1 si a < b
;-1 si a > b
strCmp:
    push rbp ; alineado
    mov rbp, rsp
    push r15 ; puntero del string a
    push r14 ; puntero del string b
    push r13 ; longitud del string a
    push r12 ; longitud del string b

    mov r15, rdi
    mov r14, rsi

    call son_iguales
    cmp rax, 0
    je _fin_strcmp
        
    mov rdi, r15
    call strLen
    mov r13, rax

    mov rdi, r14
    call strLen
    mov r12, rax

    mov rdi, r13
    mov rsi, r12
    call menor_n
    mov rcx, rax
; cuando encuentra 1 solo que es mayor entonces es mayor

_while_strcmp:
    cmp rcx, 0
    je _fin_strcmp
    
    mov dil, byte [r15]
    mov sil, byte [r14]
    cmp dil, sil
    jg _a_mayor_que_b_strcmp
    jl _a_menor_que_b_strcmp

    inc r15
    inc r14
    dec rcx
    jmp _while_strcmp

_a_mayor_que_b_strcmp:
    mov rax, -1
    jmp _fin_strcmp
_a_menor_que_b_strcmp:
    mov rax, 1
    jmp _fin_strcmp
_fin_strcmp:
    pop r12
    pop r13
    pop r14
    pop r15
    pop rbp
	ret


;funcion auxiliar : dado 2 numeros devuelve el menor
menor_n:
    push rbp
    mov rbp, rsp
    cmp rdi, rsi
    jg _a_mayor_que_b
    jl _b_mayor_que_a

_a_mayor_que_b:
    mov rax, rdi
    jmp _fin_menor_n
_b_mayor_que_a:
    mov rax, rsi
    jmp _fin_menor_n
_fin_menor_n:
    pop rbp
    ret

; funcion auxiliar
; char* a, char b
; a--> RDI b-->RSI
; devuelve 1 byte que es 0 o 1 por RAX, si son iguales devuelve 0 (para el objetivo strcmp)
son_iguales:
    push rbp
    mov rbp, rsp
    push r15 ; puntero al string a
    push r14 ; puntero al string b
    push r13 ; longitud del string a
    push r12 ; longitud del string b
    mov r15, rdi
    mov r14, rsi
    
    call strLen
    mov r13, rax
    
    mov rdi, r14
    call strLen
    mov r12, rax
    
    cmp r13, r12
    jne _no_son_iguales
    
_while_son_iguales:
    cmp r13, 0
    je _son_iguales
    mov dil, byte [r15]
    mov sil, byte [r14]
    cmp dil, sil
    jne _no_son_iguales

    inc r14
    inc r15
    dec r13    
    jmp _while_son_iguales

_son_iguales:
    mov rax, 0
    jmp _fin_son_iguales
_no_son_iguales:
    mov rax, 1
    jmp _fin_son_iguales
_fin_son_iguales:
    pop r12
    pop r13
    pop r14
    pop r15
    pop rbp
    ret

; char* strClone(char* a)
; Genera una copia del string pasado por parámetro. El puntero pasado siempre es válido
; aunque podría corresponderse a la cadena vacía.
; RDI ---> A 
strClone:
    push rbp
    mov rbp, rsp
    push r15 ; tenemos el puntero al string parametro
    push r14 ; tenemos el puntero al inicio del string (copiado)

    mov r15, rdi
    call strLen
    inc rax ; incluimos el null byte

    mov rdi, rax ; parametro de malloc queremos esa misma cantidad de bytes
    call malloc
    mov r14, rax
    
_strclone_while:
    cmp byte [r15], 0 ; comparo con \0 y no el caracter '0' 
    je _fin_strclone
    
    mov dil, byte [r15]
    mov byte [rax], dil

    inc r15
    inc rax
    jmp _strclone_while

_fin_strclone:
    mov byte [rax], 0
    mov rax, r14
    pop r14
    pop r15
    pop rbp
	ret

; void strDelete(char* a)
strDelete:
    push rbp ; alineado para usar funcion free de libc
    mov rbp, rsp
    call free
    pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
    push rbp ; alineado
    mov rbp, rsp
    push r15 ; desalineado
    push r14 ; alineado

    mov r15, rdi ; a
    mov r14, rsi ; pFile

    cmp rdi, NULL
    jne _else_strprint
    je _or_strprint
    mov rdi, r14
    mov rsi, [stringNULL]
    call fprintf
_or_strprint:
    mov rdi, r15
    call strLen
    cmp rax, 0
    jne _else_strprint
    mov rdi, r14
    mov rsi, [stringNULL]
    call fprintf

_else_strprint:
    mov rdi, r14
    mov rsi, [string_indicator]
    mov rdx, r15
    call fprintf

_fin_strprint:
    pop r14
    pop r15
    pop rbp
	ret

; uint32_t strLen(char* a)
strLen:
    push rbp
    mov rbp, rsp

    xor rax, rax
_strlen_while:
    cmp byte [rdi], 0 ; comparo con el null byte
    je _fin_strlen
    inc rax
    inc rdi
    jmp _strlen_while
    
_fin_strlen:
    pop rbp
	ret


