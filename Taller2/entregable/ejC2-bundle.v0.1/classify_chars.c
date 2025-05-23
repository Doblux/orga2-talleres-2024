#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void classify_chars_in_string(char* string, char** vowels_and_cons) {
    if ( string == NULL ){
        return;
    }
        int i = 0;
        int vowels_index = 0;
        int cons_index = 0;
        while (string[i] != '\0') {
            if (string[i] == 'a' || string[i] == 'e' ||  string[i] == 'i' || string[i] == 'o' || string[i] == 'u' ){
                vowels_and_cons[0][vowels_index] = string[i];
                vowels_index++;
            } else {
                vowels_and_cons[1][cons_index] = string[i];
                cons_index++;
            }
            i++;
        }
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    for ( uint64_t i = 0; i < size_of_array; i++){
        char* vocales = calloc(64, sizeof(char));
        char* consonantes = calloc(64, sizeof(char));
        array[i].vowels_and_consonants = calloc(2, sizeof(char*));
        array[i].vowels_and_consonants[0] = vocales;
        array[i].vowels_and_consonants[1] = consonantes;
        classify_chars_in_string(array[i].string, array[i].vowels_and_consonants);
    }
}
