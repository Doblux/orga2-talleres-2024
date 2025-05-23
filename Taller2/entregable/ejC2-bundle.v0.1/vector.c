#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
    vector_t* nuevo = malloc(sizeof(vector_t));
    nuevo->array = malloc(2 * sizeof(uint32_t));
    nuevo->size = 0;
    nuevo->capacity = 2;
    return  nuevo;
}

uint64_t get_size(vector_t* vector) {
    return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {
    if (vector == NULL){
        return;
    }
    if ( vector->size == vector->capacity ) {
        uint64_t nueva_capacidad = 2 * vector->capacity;
        uint32_t* reasignar_array = realloc(vector->array, nueva_capacidad * sizeof(uint32_t));
        if ( reasignar_array != NULL ){
            vector->array = reasignar_array;
            vector->capacity = nueva_capacidad;
        }
    } 
    vector->array[vector->size] = elemento;
    vector->size++;
}



int son_iguales(vector_t* v1, vector_t* v2) {
    if (v1->size != v2->size){
        return 0;
    } else {
        int res = 1;
        for (uint32_t i = 0; (i < v1->size && res == 1); i++){
            res = res && (v1->array[i] == v2->array[i]);
        }
        return res;
    }
}

uint32_t iesimo(vector_t* vector, size_t index) {
    if ( (vector == NULL) || (index > vector->size) || (index < 0) ){
        return 0;
    } else {
        return vector->array[index];
    }
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out){
    *out = vector->array[index];
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
    if ( array_de_vectores == NULL || longitud_del_array == (size_t)0 ){
        return NULL;
    } else {
        uint64_t maximo = array_de_vectores[0]->size;
        vector_t* res = array_de_vectores[0];
        for (size_t i = 1; i < longitud_del_array; i++){
            if ( array_de_vectores[i]->size > maximo ) {
                maximo = array_de_vectores[i]->size;
                res = array_de_vectores[i];
            }
        }
        return res;
    }
}
