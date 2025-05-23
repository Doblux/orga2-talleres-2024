; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"

global start


; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern GDT_DESC ; la direccion de la GDT
extern IDT_DESC

extern idt_init
extern pic_reset
extern pic_enable
extern screen_draw_layout
extern mmu_init
extern mmu_init_kernel_dir
extern mmu_init_task_dir
extern tss_init
extern tasks_screen_draw
extern sched_init
extern tasks_init
; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
; indice de la gdt shifteado 3 lugares para dar al selector de segmento 
; (los bits de privilegio y ti estan en 0)
%define CS_RING_0_SEL 1 << 3   
%define DS_RING_0_SEL 3 << 3

%define TASK_INITIAL_RING_0_SEL 11 << 3
%define TASK_IDLE_RING_0_SEL 12 << 3

%define PE_BIT 1
%define PG_BIT 0b1 << 31 ; en el registro cr0

%define STACK_BASE 0x25000
BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)
    ; (uso print_text_rm: print text real mode) (el 5 es de 5 parametros)
    ; 0xF es el color que es blanco (la letra)
    print_text_rm start_rm_msg, start_rm_len, 0xF, 0, 0
    ; COMPLETAR - Habilitar A20
    ; (revisar las funciones definidas en a20.asm)
    call A20_enable
    ; COMPLETAR - Cargar la GDT
    lgdt [GDT_DESC] ; carga en el registro GDTR la direccion [GDT_DESC]
    ; COMPLETAR - Setear el bit PE del registro CR0
    ; registro CR0 :
; Bits   31   30   29   28 --- 19    18  17   16  15 --- 6    5    4   3     2    1      0
    ; | PG | CD  | NW | RESERVED  | AM |   | WP | RESERVED | NE | 1 |  TS | EM | MP  |  PE   |
    mov eax, cr0
    or eax, PE_BIT ; pongo el primer bit en 1 (que es el PE)
    mov cr0, eax
    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo
    jmp CS_RING_0_SEL:modo_protegido ; en este punto es donde realmente pasamos a modo protegido

BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    mov ax, DS_RING_0_SEL
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    mov ss, ax
    ; con esto aseguramos que el sistema operativo tenga acceso completo a la memoria del sistema (segun mi entendimiento)
    ; (punto 16 del enunciado)

    ; COMPLETAR - Establecer el tope y la base de la pila
    mov ebp, STACK_BASE
    mov esp, STACK_BASE
    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO
;;  Parametros:
;;      %1: Puntero al mensaje
;;      %2: Longitud del mensaje
;;      %3: Color
;;      %4: Fila
;;      %5: Columna  (print text protected mode), color blanco
    print_text_pm start_pm_msg, start_pm_len, 0xF, 5, 0
    ; COMPLETAR - Inicializar pantalla
    call screen_draw_layout
; interrupciones ---------------------------------------------------------------------
    call idt_init 
    LIDT [IDT_DESC]
    
    ; Inicializo el Page-Directory del kernel
    call mmu_init_kernel_dir
    ; Pongo en CR3 la dirección al Page-Directory
    ; Sé que los 12 bits menos significativos son 0.
    mov cr3, eax ; EAX es el return de mmu_init_kernel_dir
    
    ; Activo la paginación con PG de CR0
    mov eax, cr0
    or eax, PG_BIT
    mov cr0, eax
    ; ya active paginacion
    ; agrego entradas de las tareas inicial e idle a la gdt
    
    ; activo interrupciones ahora si
    call pic_reset
    call pic_enable
	
    ; El PIT (Programmable Interrupt Timer) corre a 1193182Hz.
    ; Cada iteracion del clock decrementa un contador interno, cuando éste llega
    ; a cero se emite la interrupción. El valor inicial es 0x0 que indica 65536,
    ; es decir 18.206 Hz
    mov ax, 1000
    out 0x40, al
    rol ax, 8
    out 0x40, al
	
    int 98

    ; Usamos el mapeo de un task
    mov eax, cr3
    push 0x18000 ; Dirección física de la task según el enunciado.
    call mmu_init_task_dir
    add esp, 4 ; Elimino 0x18000 del stack
    mov ebx, cr3
    mov cr3, eax
    ;mov [0x07000000], BYTE 123 ; area on-demand
    ;mov [0x070000f0], BYTE 123 ; area on-demand
    mov cr3, ebx
    

    call tss_init

    call sched_init

    call tasks_screen_draw

    mov ax, TASK_INITIAL_RING_0_SEL
    LTR ax

    ;mov [0x07000000], BYTE 123
    ;mov [0x07000f40], BYTE 123

    call tasks_init
    jmp TASK_IDLE_RING_0_SEL:0 ; tarea idle
    sti

    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
