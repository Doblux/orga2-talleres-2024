/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones de impresion por pantalla.
*/

#include "screen.h"

void print(const char* text, uint32_t x, uint32_t y, uint16_t attr) {
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; 
  int32_t i;
  for (i = 0; text[i] != 0; i++) {
    p[y][x].c = (uint8_t)text[i];
    p[y][x].a = (uint8_t)attr;
    x++;
    if (x == VIDEO_COLS) {
      x = 0;
      y++;
    }
  }
}

void print_dec(uint32_t numero, uint32_t size, uint32_t x, uint32_t y,
               uint16_t attr) {
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; 
  uint32_t i;
  uint8_t letras[16] = "0123456789";

  for (i = 0; i < size; i++) {
    uint32_t resto = numero % 10;
    numero = numero / 10;
    p[y][x + size - i - 1].c = letras[resto];
    p[y][x + size - i - 1].a = attr;
  }
}

void print_hex(uint32_t numero, int32_t size, uint32_t x, uint32_t y,
               uint16_t attr) {
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; 
  int32_t i;
  uint8_t hexa[8];
  uint8_t letras[16] = "0123456789ABCDEF";
  hexa[0] = letras[(numero & 0x0000000F) >> 0];
  hexa[1] = letras[(numero & 0x000000F0) >> 4];
  hexa[2] = letras[(numero & 0x00000F00) >> 8];
  hexa[3] = letras[(numero & 0x0000F000) >> 12];
  hexa[4] = letras[(numero & 0x000F0000) >> 16];
  hexa[5] = letras[(numero & 0x00F00000) >> 20];
  hexa[6] = letras[(numero & 0x0F000000) >> 24];
  hexa[7] = letras[(numero & 0xF0000000) >> 28];
  for (i = 0; i < size; i++) {
    p[y][x + size - i - 1].c = hexa[i];
    p[y][x + size - i - 1].a = attr;
  }
}

void screen_draw_box(uint32_t fInit, uint32_t cInit, uint32_t fSize,
                     uint32_t cSize, uint8_t character, uint8_t attr) {
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO;
  uint32_t f;
  uint32_t c;
  for (f = fInit; f < fInit + fSize; f++) {
    for (c = cInit; c < cInit + cSize; c++) {
      p[f][c].c = character;
      p[f][c].a = attr;
    }
  }
}

void screen_draw_layout(void) {
  // c = caracter ascii  y a para el color (attributos)
  // la primera parte del a (4bits) es el color de letra 
  // la segunda parte del a (4bits) es el color de fondo de pantalla
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; // VIDEO es la direccion de video en defines.h
  // no me queda claro del todo la sintaxis esta, pero se que lo apunto a la memoria de video
  // y si hago p[fila][columna] obtengo el struct ca (copiando la sintaxis de screen_draw_box)
  screen_draw_box(0, 0, FILAS, COLUMNAS, ' ', C_JUNTAR_FG_BG(C_BG_MAGENTA, C_FG_BLACK));
  // pinto toda la pantalla de color magenta
  char nombres[3][11] = {
    { 'R', 'u', 'p', 'e', 'n', ' ', ' ', ' ', ' ', ' ', ' ' },
    { 'D', 'a', 'v', 'i', 'd', ' ', ' ', ' ', ' ', ' ', ' ' },
    { 'M', 'a', 'x', 'i', 'm', 'i', 'l', 'i', 'a', 'n', 'o' }
  };
  // escribo unicamente los nombres en la pantalla
  for (uint32_t i = 0; i < 3; i++){
    for (uint32_t j = 0; j < 11; j++){
      p[i][j].c = nombres[i][j];
      p[i][j].a = C_JUNTAR_FG_BG(C_BG_MAGENTA, C_FG_BLACK);
    }
  }
}
