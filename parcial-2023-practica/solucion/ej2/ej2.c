#include "ej2.h"
#include <stdint.h>

void mezclarColores_c( uint8_t *X, uint8_t *Y, uint32_t width, uint32_t height){
    uint32_t res_pixeles = width * height;
    for (uint32_t i = 0; i < res_pixeles; i++){
        uint8_t b = X[i * 4 + 0];
        uint8_t g = X[i * 4 + 1];
        uint8_t r = X[i * 4 + 2];
        uint8_t a = X[i * 4 + 3];
        if (r > g && g > b) {
            Y[i*4+2] = b;
            Y[i*4+1] = r;
            Y[i*4+0] = g;
            Y[i*4+3] = 0;
        } else if (b > g && g > r) {
            Y[i*4+2] = g;
            Y[i*4+1] = b;
            Y[i*4+0] = r;
            Y[i*4+3] = 0;
        } else {
            Y[i*4+2] = r;
            Y[i*4+1] = g;
            Y[i*4+0] = b;
            Y[i*4+3] = 0;
        }
    }
}
