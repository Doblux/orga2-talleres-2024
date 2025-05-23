#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
	lista_t* nueva = malloc(sizeof(lista_t));
	nueva->head = NULL;
	
	return nueva;
}

uint32_t longitud(lista_t* lista) {
	nodo_t* actual = lista->head;
	uint32_t res = 0;
	while (actual != NULL){
		res++;
		actual = actual->next;
	}
	return res;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
	if (lista == NULL){
		exit(99);
		// lista = nueva_lista();
		// lista->head = malloc(sizeof(nodo_t));
		// lista->head->arreglo = malloc(longitud * sizeof(uint32_t));
		// lista->head->next = NULL;
		// lista->head->longitud = longitud;
		// for (uint64_t i = 0; i < longitud; i++){
		// 	lista->head->arreglo[i] = arreglo[i];
		// }
	} else if (lista->head == NULL) {
		lista->head = malloc(sizeof(nodo_t));
		lista->head->arreglo = malloc(longitud * sizeof(uint32_t));
		lista->head->next = NULL;
		lista->head->longitud = longitud;
		for (uint64_t i = 0; i < longitud; i++){
			lista->head->arreglo[i] = arreglo[i];
		}
	} else {
		nodo_t* actual = lista->head;
		while (actual->next != NULL){
			actual = actual->next;
		}
		actual->next = malloc(sizeof(nodo_t));
		actual->next->arreglo = malloc(longitud * sizeof(uint32_t));
		actual->next->next = NULL;
		actual->next->longitud = longitud;
		for (uint64_t i = 0; i < longitud; i++){
			actual->next->arreglo[i] = arreglo[i];
		}
	}
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
	nodo_t* actual = lista->head;
	while (i > 0){
		i--;
		actual = actual->next;
	}
	return actual;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {
	uint64_t res = 0;
	if (lista == NULL || lista->head == NULL){
		return (uint64_t)0;
	} else {
		nodo_t* actual = lista->head;
		while (actual != NULL){
			res += actual->longitud;
			actual = actual->next;
		}	
	}
	return res;
}

void imprimir_lista(lista_t* lista) {
	if (lista == NULL || lista->head == NULL){
		printf("null");
	} else {
		nodo_t* actual = lista->head;
		printf("| ");
		while (actual->next != NULL){
			printf("%li |", actual->longitud);
			printf(" -> | ");
			actual = actual->next;
		}
		printf("-> null");	
	}
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
	for (uint64_t i = 0; i < size_of_array; i++){
		if (array[i] == elemento_a_buscar){
			return 1;
		}
	}
	return 0;
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {
	if (lista == NULL || lista->head == NULL){
		return 0;
	} else {
		nodo_t* actual = lista->head;
		while (actual != NULL){
			if (array_contiene_elemento(actual->arreglo, actual->longitud, elemento_a_buscar) == 1){
				return 1;
			}
			actual = actual->next;
		}
	}
	return 0;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
	if (lista != NULL){
		if (lista->head == NULL){
			free(lista);
		} else {
			nodo_t* actual = lista->head;
			nodo_t* siguiente = actual->next;
			while (siguiente != NULL){
				free(actual->arreglo);
				free(actual);
				actual = siguiente;
				siguiente = siguiente->next;
			}
			free(actual->arreglo);
			free(actual);
			free(lista);
		}
	}
}
