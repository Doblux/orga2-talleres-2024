/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definiciones globales del sistema.
*/

#ifndef __DEFINES_H__
#define __DEFINES_H__

/* Misc */
/* -------------------------------------------------------------------------- */
// Y Filas
#define SIZE_N 40
#define ROWS   SIZE_N

// X Columnas
#define SIZE_M 80
#define COLS   SIZE_M

/* Indices en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_COUNT         35

#define GDT_IDX_NULL_DESC 0
#define GDT_IDX_CODE_0 1
#define GDT_IDX_CODE_3 2
#define GDT_IDX_DATA_0 3
#define GDT_IDX_DATA_3 4
#define GDT_IDX_VIDEO  5


/* Offsets en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_OFF_NULL_DESC (GDT_IDX_NULL_DESC << 3)
#define GDT_OFF_VIDEO  (GDT_IDX_VIDEO << 3)

/* COMPLETAR - Valores para los selectores de segmento de la GDT 
 * Definirlos a partir de los índices de la GDT, definidos más arriba 
 * Hint: usar operadores "<<" y "|" (shift y or) */

#define SYSTEM_ROOT_RPL 0
#define SYSTEM_USER_RPL 3

#define GDT_CODE_0_SEL ( GDT_IDX_CODE_0 << 3 ) | SYSTEM_ROOT_RPL
#define GDT_DATA_0_SEL ( GDT_IDX_DATA_0 << 3 ) | SYSTEM_ROOT_RPL
#define GDT_CODE_3_SEL ( GDT_IDX_CODE_3 << 3 ) | SYSTEM_USER_RPL
#define GDT_DATA_3_SEL ( GDT_IDX_DATA_3 << 3 ) | SYSTEM_USER_RPL


// Macros para trabajar con segmentos de la GDT.

// SEGM_LIMIT_4KIB es el limite de segmento visto como bloques de 4KIB
// principio del ultimo bloque direccionable.
#define GDT_LIMIT_4KIB(X)  (((X) / 4096) - 1)
#define GDT_LIMIT_BYTES(X) ((X)-1)

#define GDT_LIMIT_LOW(limit)  (uint16_t)(((uint32_t)(limit)) & 0x0000FFFF)
#define GDT_LIMIT_HIGH(limit) (uint8_t)((((uint32_t)(limit)) >> 16) & 0x0F)

#define GDT_BASE_LOW(base)  (uint16_t)(((uint32_t)(base)) & 0x0000FFFF)
#define GDT_BASE_MID(base)  (uint8_t)((((uint32_t)(base)) >> 16) & 0xFF)
#define GDT_BASE_HIGH(base) (uint8_t)((((uint32_t)(base)) >> 24) & 0xFF)

#define BASE_SEGMENT_FLAT 0

/* COMPLETAR - Valores de atributos */ 
#define DESC_CODE_DATA 1
#define DESC_SYSTEM    0
#define DESC_TYPE_EXECUTE_READ 10 // si no anda probar en hexa o binario
#define DESC_TYPE_READ_WRITE   2 // si no anda probar hexa o binario

#define DESC_TYPE_32BIT_TSS 0x9

#define DESCRIPTOR_DPL_0 0
#define DESCRIPTOR_DPL_3 3

#define DESCRIPTOR_GRANULARITY_BYTE 0
#define DESCRIPTOR_GRANULARITY_4KB 1

#define DESCRIPTOR_PRESENT 1
#define DESCRIPTOR_NOT_PRESENT 0

#define AVL_BIT_SIN_USO 0

#define BIT_MODE_64 1
#define BIT_MODE_32 0

// This flag should always be set to 1 for 32-bit code and data segments and to 0 for 16-bit code and data segments.
// fuente: manual de intel: pagina 103 (3.4.5 segment descriptors)
// motivo mio para ponerlo en 0 es que (estamos en modo real)
// si no anda cambiarlo a 0
#define D_B_BIT 1 

/* COMPLETAR - Tamaños de segmentos */ 
#define FLAT_SEGM_SIZE   1024 * 1024 * 817
//#define VIDEO_SEGM_SIZE  ?? <-- es lo mismo que VIDEO_MAX_OFFSET
#define VIDEO_MAX_OFFSET 50 * 80 * 2
// osea 2 bytes por cada celda de la pantalla y la pantalla mide 50 x 80
// creo que era el ascii y el color (primera parte segundo checkpoint)


/* Direcciones de memoria */
/* -------------------------------------------------------------------------- */

// direccion fisica de comienzo del bootsector (copiado)
#define BOOTSECTOR 0x00001000
// direccion fisica de comienzo del kernel
#define KERNEL 0x00001200
// direccion fisica del buffer de video
#define VIDEO 0x000B8000
//a dirección física donde va a comenzar el buffer de la pantalla es 0x000B8000 
// direccion fisica de la pagina de memoria compartida
#define SHARED 0x0001D000


/* MMU */
/* -------------------------------------------------------------------------- */
// definan:
#define VIRT_PAGE_OFFSET(X) X & 0xFFF //devuelve el offset dentro de la página, donde X es una dirección virtual
#define VIRT_PAGE_TABLE(X) (X >> 12) & 0x3FF //devuelve la page table entry correspondiente, donde X es una dirección virtual
#define VIRT_PAGE_DIR(X) (X >> 22) & 0x3FF // devuelve el page directory entry, donde X es una dirección virtual
#define CR3_TO_PAGE_DIR(X) X & 0xFFFFF000 //devuelve el page directory, donde X es el contenido del registro CR3
#define MMU_ENTRY_PADDR(X) X << 12 //devuelve la dirección física de la base de un page frame o de un page table, donde X es el campo de 20 bits en una PTE o PDE

#define MMU_P (1 << 0)
#define MMU_W (1 << 1)
#define MMU_U (1 << 2)

#define PAGE_SIZE 4096

// direccion virtual del codigo
#define TASK_CODE_VIRTUAL 0x08000000
#define TASK_CODE_PAGES   2
#define TASK_STACK_BASE   0x08003000
#define TASK_SHARED_PAGE  0x08003000

// direccion virtual de memoria compartida on demand
#define ON_DEMAND_MEM_START_VIRTUAL    0x07000000
#define ON_DEMAND_MEM_END_VIRTUAL      0x07000FFF
#define ON_DEMAND_MEM_START_PHYSICAL   0x03000000

/* Direcciones fisicas de directorios y tablas de paginas del KERNEL */
/* -------------------------------------------------------------------------- */
#define KERNEL_PAGE_DIR     (0x00025000)
#define KERNEL_PAGE_TABLE_0 (0x00026000)
#define KERNEL_STACK        (0x00025000)

#endif //  __DEFINES_H__
