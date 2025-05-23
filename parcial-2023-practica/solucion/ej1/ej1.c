#include "ej1.h"
#include <stdlib.h>
#include <string.h>

list_t* listNew(){
  list_t* l = (list_t*) malloc(sizeof(list_t));
  l->first=NULL;
  l->last=NULL;
  return l;
}

void listAddLast(list_t* pList, pago_t* data){
    listElem_t* new_elem= (listElem_t*) malloc(sizeof(listElem_t));
    new_elem->data=data;
    new_elem->next=NULL;
    new_elem->prev=NULL;
    if(pList->first==NULL){
        pList->first=new_elem;
        pList->last=new_elem;
    } else {
        pList->last->next=new_elem;
        new_elem->prev=pList->last;
        pList->last=new_elem;
    }
}


void listDelete(list_t* pList){
    listElem_t* actual= (pList->first);
    listElem_t* next;
    while(actual != NULL){
        next=actual->next;
        free(actual);
        actual=next;
    }
    free(pList);
}

uint8_t contar_pagos_aprobados(list_t* pList, char* usuario){
    uint8_t res = 0;
    listElem_t* nodo_actual = pList->first;
    while (nodo_actual != NULL) {
        pago_t* data_actual = nodo_actual->data;
        if (strcmp(data_actual->cobrador, usuario) == 0 && data_actual->aprobado == 1){
            res++;   
        }
        nodo_actual = nodo_actual->next;
    }
    return res;
}

uint8_t contar_pagos_rechazados(list_t* pList, char* usuario){
    uint8_t res = 0;
    listElem_t* nodo_actual = pList->first;
    while (nodo_actual != NULL) {
        pago_t* data_actual = nodo_actual->data;
        if (strcmp(data_actual->cobrador, usuario) == 0 && data_actual->aprobado == 0){
            res++;   
        }
        nodo_actual = nodo_actual->next;
    }
    return res;
}

pagoSplitted_t* split_pagos_usuario(list_t* pList, char* usuario){
    pagoSplitted_t* n = malloc(sizeof(pagoSplitted_t));
    n->cant_aprobados = contar_pagos_aprobados(pList, usuario);
    n->cant_rechazados = contar_pagos_rechazados(pList, usuario);
    n->aprobados = malloc(n->cant_aprobados * sizeof(pago_t*));
    n->rechazados = malloc(n->cant_rechazados * sizeof(pago_t*));
    listElem_t* nodo_actual = pList->first;
    int i = 0;
    int j = 0;
    while (nodo_actual != NULL) {
        pago_t* pago_actual = nodo_actual->data;
        if (pago_actual->aprobado == 1 && strcmp(pago_actual->cobrador, usuario) == 0){
            n->aprobados[i] = pago_actual;
            i++;
        } else if (pago_actual->aprobado == 0 && strcmp(pago_actual->cobrador, usuario) == 0){
            n->rechazados[j] = pago_actual;
            j++;
        }
        nodo_actual = nodo_actual->next;
    }
    return n;
}
