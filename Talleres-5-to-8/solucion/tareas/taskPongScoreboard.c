#include "task_lib.h"

#define WIDTH TASK_VIEWPORT_WIDTH
#define HEIGHT TASK_VIEWPORT_HEIGHT

#define SHARED_SCORE_BASE_VADDR (PAGE_ON_DEMAND_BASE_VADDR + 0xF00)
#define CANT_PONGS 3


void task(void) {
	screen pantalla;
	// ¿Una tarea debe terminar en nuestro sistema? --> no
	while (true)
	{

		// Completar:
		// - Pueden definir funciones auxiliares para imprimir en pantalla
		// - Pueden usar `task_print`, `task_print_dec`, etc. 

		//task_print(pantalla, "Scoreboard del PONG", WIDTH / 2 - 10, 5, C_FG_WHITE | C_BG_RED);

		//Dividir Pantalla
		for(int i = 0; i < 12 ; i++){
			task_print(pantalla,"|",WIDTH/2,i,C_FG_WHITE | C_BG_BLACK);
		}

		for(int i = 0; i < 38 ; i++){
			task_print(pantalla,"_",i,HEIGHT/2,C_FG_WHITE | C_BG_BLACK);
		}
		task_print(pantalla, "PONG 1", 7,3, C_FG_GREEN | C_BG_BLACK);
		task_print(pantalla, "PONG 2", 26,3, C_FG_CYAN | C_BG_BLACK);
		task_print(pantalla, "PONG 3", 16,14, C_FG_MAGENTA | C_BG_BLACK);
		// Imprimir puntuación
		//

		for (int i = 0; i < 3; i++) {
			uint32_t* task_records = (uint32_t*) SHARED_SCORE_BASE_VADDR + ((uint32_t) i * sizeof(uint32_t) * 2);
			if(i == 0){
				task_print_dec(pantalla, task_records[0], 2, 9, 5, C_FG_GREEN | C_BG_BLACK);
				task_print_dec(pantalla, task_records[1], 2, 9, 6, C_FG_GREEN | C_BG_BLACK);	
			}
			if(i == 1){
				task_print_dec(pantalla, task_records[0], 2, 28, 5, C_FG_CYAN | C_BG_BLACK);
				task_print_dec(pantalla, task_records[1], 2, 28, 6, C_FG_CYAN | C_BG_BLACK);	
			}
			if(i == 2){
				task_print_dec(pantalla, task_records[0], 2, 18, 16, C_FG_MAGENTA | C_BG_BLACK);
				task_print_dec(pantalla, task_records[1], 2, 18, 17, C_FG_MAGENTA | C_BG_BLACK);	
			}
		}


		syscall_draw(pantalla);
	}
}
