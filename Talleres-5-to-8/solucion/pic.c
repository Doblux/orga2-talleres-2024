/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Rutinas del controlador de interrupciones.
*/
#include "pic.h"

#define PIC1_PORT 0x20
#define PIC2_PORT 0xA0

static __inline __attribute__((always_inline)) void outb(uint32_t port,
                                                         uint8_t data) {
  __asm __volatile("outb %0,%w1" : : "a"(data), "d"(port));
}
void pic_finish1(void) { outb(PIC1_PORT, 0x20); }
void pic_finish2(void) {
  outb(PIC1_PORT, 0x20);
  outb(PIC2_PORT, 0x20);
}

// COMPLETAR: implementar pic_reset()
void pic_reset() {
  // Inicializar el PIC1 (master)
  
  outb(PIC1_PORT, 0x11); // Initialization Command Word 1 (ICW1) (datos de inicializacion)
  outb(PIC2_PORT, 0x11); // idem

  outb(PIC1_PORT + 1, 0x20); // ICW2: offset del PIC1 en el direccionamiento del puerto (osea en 0x20 que es 32 decimal comienza el pic 1 con el IRQ0)
  outb(PIC2_PORT + 1, 0x28); // ICW2 offset del PIC2 en el direccionamiento del puerto (osea en 0x28 que es 40 decimal comienza el pic 2 con el IRQ8)

  outb(PIC1_PORT + 1, 4);
  outb(PIC2_PORT + 1, 2); // ICW3 identidad del slave, en este caso es 2 ya que esta conectado al IRQ2

  outb(PIC1_PORT + 1, 0xFF); // ICW4: clear IMR
  outb(PIC2_PORT + 1, 0x01); // ICW4
}

void pic_enable() {
  outb(PIC1_PORT + 1, 0x00);
  outb(PIC2_PORT + 1, 0x00);
}

void pic_disable() {
  outb(PIC1_PORT + 1, 0xFF);
  outb(PIC2_PORT + 1, 0xFF);
}
