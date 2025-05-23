/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de la tabla de descriptores globales
*/

#include "gdt.h"

/* Aca se inicializa un arreglo de forma estatica
GDT_COUNT es la cantidad de líneas de la GDT y esta definido en defines.h */

gdt_entry_t gdt[GDT_COUNT] = {
    /* Descriptor nulo*/
    /* Offset = 0x00 */
    [GDT_IDX_NULL_DESC] =
    {
        // El descriptor nulo es el primero que debemos definir siempre
        // Cada campo del struct se matchea con el formato que figura en el manual de intel
        // Es una entrada en la GDT.
        .limit_15_0 = 0x0000,
        .base_15_0 = 0x0000,
        .base_23_16 = 0x00,
        .type = 0x0,
        .s = 0x00,
        .dpl = 0x00,
        .p = 0x00,
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0,
        .db = 0x0,
        .g = 0x00,
        .base_31_24 = 0x00,
    },
    [GDT_IDX_CODE_0] =
    {
        .limit_15_0 = GDT_LIMIT_LOW(GDT_LIMIT_4KIB(FLAT_SEGM_SIZE)),
        .base_15_0 = GDT_BASE_LOW(BASE_SEGMENT_FLAT),
        .base_23_16 = GDT_BASE_MID(BASE_SEGMENT_FLAT),
        .type = DESC_TYPE_EXECUTE_READ,
        .s = DESC_CODE_DATA,
        .dpl = DESCRIPTOR_DPL_0,
        .p = DESCRIPTOR_PRESENT,
        .limit_19_16 = GDT_LIMIT_HIGH(GDT_LIMIT_4KIB(FLAT_SEGM_SIZE)),
        .avl = AVL_BIT_SIN_USO,
        .l = BIT_MODE_32,
        .db = D_B_BIT,
        .g = DESCRIPTOR_GRANULARITY_4KB,
        .base_31_24 = GDT_BASE_HIGH(BASE_SEGMENT_FLAT),
    },
    [GDT_IDX_CODE_3] =
    {
        .limit_15_0 = GDT_LIMIT_LOW(GDT_LIMIT_4KIB(FLAT_SEGM_SIZE)),
        .base_15_0 = GDT_BASE_LOW(BASE_SEGMENT_FLAT),
        .base_23_16 = GDT_BASE_MID(BASE_SEGMENT_FLAT),
        .type = DESC_TYPE_EXECUTE_READ,
        .s = DESC_CODE_DATA,
        .dpl = DESCRIPTOR_DPL_3,
        .p = DESCRIPTOR_PRESENT,
        .limit_19_16 = GDT_LIMIT_HIGH(GDT_LIMIT_4KIB(FLAT_SEGM_SIZE)),
        .avl = AVL_BIT_SIN_USO,
        .l = BIT_MODE_32,
        .db = D_B_BIT,
        .g = DESCRIPTOR_GRANULARITY_4KB,
        .base_31_24 = GDT_BASE_HIGH(BASE_SEGMENT_FLAT),
    },
    [GDT_IDX_DATA_0] =
    {
        .limit_15_0 = GDT_LIMIT_LOW(GDT_LIMIT_4KIB(FLAT_SEGM_SIZE)),
        .base_15_0 = GDT_BASE_LOW(BASE_SEGMENT_FLAT),
        .base_23_16 = GDT_BASE_MID(BASE_SEGMENT_FLAT),
        .type = DESC_TYPE_READ_WRITE,
        .s = DESC_CODE_DATA,
        .dpl = DESCRIPTOR_DPL_0,
        .p = DESCRIPTOR_PRESENT,
        .limit_19_16 = GDT_LIMIT_HIGH(GDT_LIMIT_4KIB(FLAT_SEGM_SIZE)),
        .avl = AVL_BIT_SIN_USO,
        .l = BIT_MODE_32,
        .db = D_B_BIT,
        .g = DESCRIPTOR_GRANULARITY_4KB,
        .base_31_24 = GDT_BASE_HIGH(BASE_SEGMENT_FLAT),
    },
    [GDT_IDX_DATA_3] =
    {
        .limit_15_0 = GDT_LIMIT_LOW(GDT_LIMIT_4KIB(FLAT_SEGM_SIZE)),
        .base_15_0 = GDT_BASE_LOW(BASE_SEGMENT_FLAT),
        .base_23_16 = GDT_BASE_MID(BASE_SEGMENT_FLAT),
        .type = DESC_TYPE_READ_WRITE,
        .s = DESC_CODE_DATA,
        .dpl = DESCRIPTOR_DPL_3,
        .p = DESCRIPTOR_PRESENT,
        .limit_19_16 = GDT_LIMIT_HIGH(GDT_LIMIT_4KIB(FLAT_SEGM_SIZE)),
        .avl = AVL_BIT_SIN_USO,
        .l = BIT_MODE_32,
        .db = D_B_BIT,
        .g = DESCRIPTOR_GRANULARITY_4KB,
        .base_31_24 = GDT_BASE_HIGH(BASE_SEGMENT_FLAT),
    },
    [GDT_IDX_VIDEO] =
    {// queremos solamente escribir en la memoria de video, no queremos un segmento flat
        .limit_15_0 = GDT_LIMIT_LOW(GDT_LIMIT_BYTES(VIDEO + VIDEO_MAX_OFFSET)),
        .base_15_0 = GDT_BASE_LOW(VIDEO),
        .base_23_16 = GDT_BASE_MID(VIDEO),
        .type = DESC_TYPE_READ_WRITE,
        .s = DESC_SYSTEM, // es 0 porque solo sera accedido por el kernel este segmento
        .dpl = DESCRIPTOR_DPL_0,
        .p = DESCRIPTOR_PRESENT,
        .limit_19_16 = GDT_LIMIT_HIGH(GDT_LIMIT_BYTES(VIDEO + VIDEO_MAX_OFFSET)),
        .avl = AVL_BIT_SIN_USO,
        .l = BIT_MODE_32,
        .db = D_B_BIT,
        .g = DESCRIPTOR_GRANULARITY_BYTE, // el tamaño del segmento no es tan grande
        .base_31_24 = GDT_BASE_HIGH(VIDEO),
    },
};

// Aca hay una inicializacion estatica de una structura que tiene su primer componente el tamano 
// y en la segunda, la direccion de memoria de la GDT. Observen la notacion que usa. 
gdt_descriptor_t GDT_DESC = {sizeof(gdt) - 1, (uint32_t)&gdt};
