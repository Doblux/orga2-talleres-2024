/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "defines.h"
#include "i386.h"

#include "kassert.h"

static pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
static pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;

static const uint32_t identity_mapping_end = 0x003FFFFF;
static const uint32_t user_memory_pool_end = 0x02FFFFFF;

static paddr_t next_free_kernel_page = 0x100000;
static paddr_t next_free_user_page = 0x400000;

/**
 * kmemset asigna el valor c a un rango de memoria interpretado
 * como un rango de bytes de largo n que comienza en s
 * @param s es el puntero al comienzo del rango de memoria
 * @param c es el valor a asignar en cada byte de s[0..n-1]
 * @param n es el tamaño en bytes a asignar
 * @return devuelve el puntero al rango modificado (alias de s)
*/
static inline void* kmemset(void* s, int c, size_t n) {
  uint8_t* dst = (uint8_t*)s;
  for (size_t i = 0; i < n; i++) {
    dst[i] = c;
  }
  return dst;
}

/**
 * zero_page limpia el contenido de una página que comienza en addr
 * @param addr es la dirección del comienzo de la página a limpiar
*/
static inline void zero_page(paddr_t addr) {
  kmemset((void*)addr, 0x00, PAGE_SIZE);
}


void mmu_init(void) {}


/**
 * mmu_next_free_kernel_page devuelve la dirección física de la próxima página de kernel disponible. 
 * Las páginas se obtienen en forma incremental, siendo la primera: next_free_kernel_page
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de kernel
 */
paddr_t mmu_next_free_kernel_page(void) {
  next_free_kernel_page += PAGE_SIZE;
  return next_free_kernel_page - PAGE_SIZE;
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuarix disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuarix
 */
paddr_t mmu_next_free_user_page(void) {
  next_free_user_page += PAGE_SIZE;
  return next_free_user_page - PAGE_SIZE;
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */
paddr_t mmu_init_kernel_dir(void) {
  // Limpiamos los contenidos del Page-Directory y de la Page-Table
  zero_page(KERNEL_PAGE_DIR);
  zero_page(KERNEL_PAGE_TABLE_0);

  kpd[0].attrs = MMU_P | MMU_W;
  kpd[0].pt = KERNEL_PAGE_TABLE_0 >> 12; // Las entry guardan los bits 31:12 de la dirección.
  // page table entry --> identity_mapping
  // Las páginas ocupan desde 0x000000 hasta 4096 * 1024 = 0x400000
  for (int i = 0; i < 1024; i++) {
    kpt[i].attrs = MMU_P | MMU_W;
    kpt[i].page = i; // numero de pagina
  }
  return KERNEL_PAGE_DIR;
}

/**
 * mmu_map_page agrega las entradas necesarias a las estructuras de paginación de modo de que
 * la dirección virtual virt se traduzca en la dirección física phy con los atributos definidos en attrs
 * @param cr3 el contenido que se ha de cargar en un registro CR3 al realizar la traducción
 * @param virt la dirección virtual que se ha de traducir en phy
 * @param phy la dirección física que debe ser accedida (dirección de destino)
 * @param attrs los atributos a asignar en la entrada de la tabla de páginas
 */
void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs) {
  // Obtenemos la dirección del Page-Directory
  // Cómo está en CR3, damos por hecho que éste está disponible.
  pd_entry_t* pd = (pd_entry_t*)(CR3_TO_PAGE_DIR(cr3));
  uint16_t pd_index = VIRT_PAGE_DIR(virt);
  uint16_t pt_index = VIRT_PAGE_TABLE(virt);

  // Si no hay un Page-Directory Entry en el índice que nos indican, creamos
  // una Page-Table y hacemos que el Page-Directory Entry apunte hacia ella.
  if ((pd[pd_index].attrs & MMU_P) == 0){
    paddr_t pt = (paddr_t) mmu_next_free_kernel_page();
    zero_page(pt); // limpiamos la tabla
    // Ponemos en el Page-Directory una entry que apunte a la nueva tabla.
    // Por defecto ponemos estos atributos en el Page-Directory Entry para que las Page-Table Entry tenga la decisión final sobre qué permisos hay.
    pd[pd_index].attrs = attrs | MMU_P | MMU_U | MMU_W;
    pd[pd_index].pt = pt >> 12;
  }
  // Hacemos que la página en el índice indicado en la memoria virtual, apunte a la dirección física deseada.
  pt_entry_t* pt = (pt_entry_t*)(MMU_ENTRY_PADDR(pd[pd_index].pt));
  pt[pt_index].attrs = attrs | MMU_P;
  pt[pt_index].page = phy >> 12;
  // Flusheamos el caché.
  tlbflush();
}

/**
 * mmu_unmap_page elimina la entrada vinculada a la dirección virt en la tabla de páginas correspondiente
 * @param virt la dirección virtual que se ha de desvincular
 * @return la dirección física de la página desvinculada
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt) {
  // Obtengo la dirección a la Page-Table Entry
  pd_entry_t* pd = (pd_entry_t*)(CR3_TO_PAGE_DIR(cr3));
  uint16_t pd_index = VIRT_PAGE_DIR(virt);
  pt_entry_t* pt = (pt_entry_t*) pd[pd_index].pt;
  uint16_t pt_index = VIRT_PAGE_TABLE(virt);

  // Obtengo la dirección física a la que apunta la página.
  paddr_t phy = pt[pt_index].page << 12;
  // Borro los datos da la Page-Table Entry
  pt[pt_index].attrs = 0; // Pongo los atributos en 0, especialmente el de PRESENT.
  pt[pt_index].page = 0;

  tlbflush();
  return phy;
}

#define DST_VIRT_PAGE 0xA00000 // justo arriba del segmento de video (arriba de la memoria del bios)
#define SRC_VIRT_PAGE 0xB00000 // justo arriba del segmento de video (arriba de la memoria del bios)

/**
 * copy_page copia el contenido de la página física localizada en la dirección src_addr a la página física ubicada en dst_addr
 * @param dst_addr la dirección a cuya página queremos copiar el contenido
 * @param src_addr la dirección de la página cuyo contenido queremos copiar
 *
 * Esta función mapea ambas páginas a las direcciones SRC_VIRT_PAGE y DST_VIRT_PAGE, respectivamente, realiza
 * la copia y luego desmapea las páginas. Usar la función rcr3 definida en i386.h para obtener el cr3 actual
 */
void copy_page(paddr_t dst_addr, paddr_t src_addr) {
  mmu_map_page(rcr3(), SRC_VIRT_PAGE, src_addr, MMU_P | MMU_W);
  mmu_map_page(rcr3(), DST_VIRT_PAGE, dst_addr, MMU_P | MMU_W);

  // Copio la pagina
  uint8_t* dst = (uint8_t*)dst_addr;
  uint8_t* src = (uint8_t*)src_addr;
  for (paddr_t i = 0; i < PAGE_SIZE; i++) dst[i] = src[i];

  // Desmapeo las paginas
  mmu_unmap_page(rcr3(), SRC_VIRT_PAGE);
  mmu_unmap_page(rcr3(), DST_VIRT_PAGE);
}

 /**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @pararm phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
 */
paddr_t mmu_init_task_dir(paddr_t phy_start) {
  // Creamos el Page-Directory para la tarea.
  paddr_t cr3 = mmu_next_free_kernel_page();
  zero_page(cr3);
  // Hacemos el identity mapping solo para el kernel.
  for (int i = 0; i <= identity_mapping_end; i += PAGE_SIZE)
    mmu_map_page(cr3, i, i, MMU_P | MMU_W);
  
  // Mapeamos las 2 páginas de código.
  for (int i = 0; i < TASK_CODE_PAGES; i++) {
    vaddr_t code_virt = TASK_CODE_VIRTUAL + i * PAGE_SIZE;
    paddr_t code_phys = phy_start + i * PAGE_SIZE;
    mmu_map_page(cr3, code_virt, code_phys, MMU_P | MMU_U);
  }
  // Mapeamos el stack de la tarea.
  paddr_t stack_addr = mmu_next_free_user_page();
  mmu_map_page(cr3, TASK_STACK_BASE - PAGE_SIZE, stack_addr, MMU_P | MMU_U | MMU_W);
  // Mapeamos la memoria compartida como solo lectura.
  mmu_map_page(cr3, TASK_SHARED_PAGE, SHARED, MMU_P | MMU_U);

  return cr3;
}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt) {
  print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
  // Chequeemos si el acceso fue dentro del area on-demand
  if (ON_DEMAND_MEM_START_VIRTUAL <= virt && virt <= ON_DEMAND_MEM_END_VIRTUAL) {
    // En caso de que si, mapear la pagina
    mmu_map_page(rcr3(), virt & 0xfffff000, ON_DEMAND_MEM_START_PHYSICAL, MMU_P | MMU_W);
    return true;
  }
  return false;
}
