# 1

- a) Convencion de llamadas es el "contrato" entre el programador y el procesador.

- Definicion para llamar a funciones: registros en orden RDI, RSI, RDX, RCX, R8, R9 y si todavia falta se pasa por stack ([rbp+16]...) para 64bit
- Todo push / sub tiene q tener su add / pop
- los floats se pasan por xmm0,... xmm7
- para llamar a funciones de libc tendriamos q alinear el stack a 16bytes, sino 8 y si estamos en 32bit a 4
- valor de retorno RAX, y los floats en XMM0
- Registros no volatiles: RBX, RBP, R12, R13, R14, R15

- b) en C el compilador en ASM nosotros.


- c) el stack frame es: argumentos de funciones ( [rbp+16] .... [rbp + (8n + 16)] ) ,  RIP para saber donde volver cuando se hace RET, el RBP del stack anterior, el espacio para guardar variables ( [rbp - 8] .... [rbp-128] ) y la red zone a partir de [rbp-128]


- d) PUSH o sub rsp, ... Y mov a la direccion donde hice sub rsp

- e) 16 bytes, 
	si la pila esta alineada a 16bytes, cuando se llama con un call se guarda el RIP para saber donde volver por lo tanto estaría desalineado por 8 bytes. Y despues del prólogo (push rbp   mov rbp, rsp) la pila está alineada a 16bytes.


- f) 
- Cambia el offset de los datos.
- Ahora el registro RDI tiene float* array y el registro RSI tiene uint64_t tamaño 
- al principio guardaba el resultado en la parte baja de RAX (AX) y ahora guarda en RAX.
- ahora la parte baja del registro RDI, es de tipo uint64_t , antes recibia el parametro por DI, ahora lo recibe por RDI
- no sucede nada porque el primer parametro entra por XMM0 y el segundo por RDI en las 2 ocasiones.

- No es posible saber que sucedería porque si tenemos llamadas de funciones, podría esperar algo de tipo char* y le estaríamos pasando algo de tipo uint32_t*.

