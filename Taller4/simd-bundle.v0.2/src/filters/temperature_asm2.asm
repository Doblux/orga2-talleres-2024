global temperature_asm

section .data
align 16
; representación de pixels en xmm a r g b a r g b a r g b a r g b
;                 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F  
rojo_en_azul : db 0x02, 0x01, 0x00, 0x03, 0x06, 0x05, 0x04, 0x07, 0x0A, 0x09, 0x08, 0x0B, 0x0E, 0x0D, 0x0C, 0x0F  
verde_en_azul :db 0x01, 0x00, 0x02, 0x03, 0x05, 0x04, 0x06, 0x07, 0x09, 0x08, 0x0A, 0x0B, 0x0D, 0x0C, 0x0E, 0x0F  
dejar_azules : db 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00  
cuatro :  db 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00  
tres_en_float: dd 3.0, 3.0, 3.0, 3.0
tres: dd 3, 3, 3, 3

BASE_TEMP_PRIMERO: db 128, 0, 0, 0, 128, 0, 0, 0, 128, 0, 0, 0, 128, 0, 0, 0
BASE_TEMP_SEGUNDO: db 255, 0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0
BASE_TEMP_TERCERO: db 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0
BASE_TEMP_CUARTO: db 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0
BASE_TEMP_ULTIMO: db 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255, 0

TREINTA_Y_DOS:  db 0x20, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00  
NOVENTA_Y_SEIS: db 0x60, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00
CIENTO_SESENTA: db 0xA0, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x00, 0x00
DOCIENTOS_VEINTE_Y_CUATRO: db  0xE0, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00
DOCIENTOS_CINCUENTA_Y_CINCO: db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF  
blanco: times 16 db 0xff
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
    mov rbp , rsp
    
    mov eax , edx
    mul ecx
    shr eax , 2
    movdqa xmm0 , [rojo_en_azul]
    movdqa xmm1 , [verde_en_azul]
    movdqa xmm4 , [dejar_azules]
    movdqa xmm5 , [BASE_TEMP_PRIMERO]
    movdqa xmm6 , [TREINTA_Y_DOS]
    movdqa xmm7 , [NOVENTA_Y_SEIS]
    movdqa xmm8 , [CIENTO_SESENTA]
    movdqa xmm9 , [DOCIENTOS_VEINTE_Y_CUATRO]
    movdqa xmm13, [DOCIENTOS_CINCUENTA_Y_CINCO]

        while_no_procese_todo:
            cmp     eax , 0
            je fin_procesar

            call calcular_temperatura
            add     rdi , 16
            movdqu  xmm3 , xmm2
            paddd   xmm3 , xmm5
                        
            ;------------------------caso t < 32
            movdqu  xmm10 , xmm2
            pslld   xmm10 , 2
            paddusb xmm10 , xmm5
            paddusb xmm10 , xmm13
            ;
            movdqu  xmm14, xmm6
            pcmpgtd xmm14, xmm2 
            pand    xmm10, xmm14
            ;----------------------caso 32 =< t < 96
            movdqu  xmm11, xmm2
            psubusb xmm11, xmm6
            pslld   xmm11, 2
            pshufb  xmm11, xmm1
            paddusb xmm11, xmm4
            paddusb xmm11, xmm13
            
            movdqu  xmm15, xmm7
            pcmpgtd xmm15, xmm2
            movdqu  xmm12, xmm11
            pand    xmm11, xmm15
            pand    xmm12, xmm14
            psubusb xmm11, xmm12
            por     xmm10, xmm11
            ;----------------------caso 96 =< t < 160
            movdqu  xmm11, xmm2
            psubusb xmm11, xmm7
            pslld   xmm11, 2
            movdqu  xmm12, xmm11
            pshufb  xmm11, xmm0
            paddusb xmm11, xmm4
            pshufb  xmm11, xmm1
            paddusb xmm11, xmm4
            psubusb xmm11, xmm12 
            paddusb xmm11, xmm13

            movdqu  xmm14, xmm8
            pcmpgtd xmm14, xmm2
            movdqu  xmm12, xmm11
            pand    xmm11, xmm14
            pand    xmm12, xmm15
            psubusb xmm11, xmm12
            por     xmm10, xmm11
            ;----------------------caso 160 =< t < 224
            movdqu  xmm11, xmm2
            psubusb xmm11, xmm8
            pslld   xmm11, 2           
            movdqu  xmm12, xmm4
            pshufb  xmm12, xmm0
            paddusb xmm12, xmm4 
            pshufb  xmm12, xmm1 
            pshufb  xmm11, xmm1
            psubusb xmm12, xmm11
            paddusb xmm12, xmm13
            
            movdqu  xmm15, xmm9
            pcmpgtd xmm15, xmm2
            movdqu  xmm11, xmm12
            pand    xmm11, xmm15
            pand    xmm12, xmm14
            psubusb xmm11, xmm12
            por     xmm10, xmm11

            ;----------------------caso 224 =< t
            movdqu  xmm11, xmm4
            pshufb  xmm11, xmm0
            movdqu  xmm12, xmm2
            psubusb xmm12, xmm9
            pslld   xmm12, 2
            pshufb  xmm12, xmm0
            psubusb xmm11, xmm12 
            paddusb xmm11, xmm13

            movdqa  xmm12, xmm11
            pand    xmm12, xmm15
            psubusb xmm11, xmm12
            por     xmm10, xmm11
            
            movdqu  [rsi] , xmm10
            sub     eax , 1
            add     rsi , 16
            jmp while_no_procese_todo

    fin_procesar:
    pop rbp
    ret

calcular_temperatura:
    push rbp
    mov  rbp , rsp
    
    movdqu  xmm2 , [rdi]
    movdqu  xmm3 , xmm2
    movdqu  xmm10, xmm2
    pand    xmm2 , xmm4
    pshufb  xmm3 , xmm0
    pshufb  xmm10, xmm1
    pand    xmm3 , xmm4
    pand    xmm10, xmm4

    paddd   xmm2 , xmm10
    paddd   xmm2 , xmm3

    cvtdq2ps xmm2, xmm2 ;Convert Packed Doubleword Integers to Packed Single Precision Floating-PointValues
    divps    xmm2, [tres_en_float]
    roundps  xmm2, xmm2, 1
    cvtps2dq xmm2, xmm2

    pop  rbp
    ret

; xmm0 asi vienen los datos por default
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
; | B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 |
;  para hacer el t < 32 mejor tener el registro con las siguientes instrucciones
;  128,  00   00   00   128  00   00   00   128  00   00   00   128  00   00   00

; NO_ALPHA_MASK
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
; | B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 |
;   FF   FF   FF   00   FF   FF   FF   00   FF   FF   FF   00   FF   FF   FF   00

; B_SOBRE_ALPHA_SHUFFLE:
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
; | B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 |
;   80   80   80   00   80   80   80   04   80   80   80   08   80   80   80   0C

; G_SOBRE_ALPHA_SHUFFLE:
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
; | B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 |
;   80   80   80   01   80   80   80   05   80   80   80   09   80   80   80   0D

; R_SOBRE_ALPHA_SHUFFLE:
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
; | B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 |
;   80   80   80   02   80   80   80   06   80   80   80   0A   80   80   80   0E

; ALPHA_SOBRE_B_SHUFFLE:
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
; | B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 |
;   03   80   80   80   07   80   80   80   0B   80   80   80   0F   80   80   80

; ALPHA_SOBRE_G_SHUFFLE:
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
; | B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 |
;   80   03   80   80   80   07   80   80   80   0B   80   80   80   0F   80   80

; ALPHA_SOBRE_R_SHUFFLE:
;   00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
; | B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 |
;   80   80   03   80   80   80   07   80   80   80   0B   80   80   80   0F   80
