

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
%define OFFSET_NODO_T_NEXT 0
%define OFFSET_NODO_T_CATEGORIA 8
%define OFFSET_NODO_T_ARREGLO 16
%define OFFSET_NODO_T_LONGITUD 24
%define SIZEOF_NODO_T 32

%define OFFSET_PACKED_NODO_T_NEXT 0
%define OFFSET_PACKED_NODO_T_CATEGORIA 8
%define OFFSET_PACKED_NODO_T_ARREGLO 9
%define OFFSET_PACKED_NODO_T_LONGITUD 17
%define SIZEOF_PACKED_NODO_T 24

%define NULL 0

%define OFFSET_LISTA_T_HEAD 0
%define OFFSET_LISTA_T_PACKED_HEAD 0
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[RDI]
cantidad_total_de_elementos:
    push rbp ; alineado
    mov rbp, rsp
    
    cmp qword [rdi], NULL ; si el head es null termina la funcion
    je _salir_while

    mov rdi, [rdi+OFFSET_LISTA_T_HEAD] ; aca tengo el lista_t->head

    xor rax, rax ; inicializo el resultado en 0

_main_while:
    
    add eax, [rdi+OFFSET_NODO_T_LONGITUD]
    mov rdi, [rdi+OFFSET_NODO_T_NEXT]

    cmp qword rdi, NULL
    jne _main_while

_salir_while:
    pop rbp
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[RDI]
cantidad_total_de_elementos_packed:
    push rbp ; alineado
    mov rbp, rsp
    
    cmp qword [rdi], NULL ; si el head es null termina la funcion
    je _salir_while_packed

    mov rdi, [rdi+OFFSET_LISTA_T_PACKED_HEAD] ; aca tengo el lista_t->head

    xor rax, rax ; inicializo el resultado en 0

_main_while_packed:
    
    add eax, [rdi+OFFSET_PACKED_NODO_T_LONGITUD]
    mov rdi, [rdi+OFFSET_PACKED_NODO_T_NEXT]

    cmp qword rdi, NULL
    jne _main_while_packed

_salir_while_packed:
    pop rbp
    ret
