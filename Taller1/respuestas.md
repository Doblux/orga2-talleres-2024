# Ejercicio 1:

- a) la dirección de memoria son 8 bytes = 64 bits, unidad minima a la que podemos direccionar es 1 byte = 8bits

- b) 16 registros de propósito general de 64bits cada uno

- c) el RIP guarda el 64bit offset a la siguiente instrucción. Tiene ese tamaño porque tengo que poder direccionar a memoria de 64bit.

# Ejercicio 2:

- a) las EFLAGS guardan el estado del programa en ejecución y permite un control limitado del procesador. tiene 32 bits.

- b) Flag Cero: para indicar que la instrucción dio 0. 
     posición: bit 6

     Carry: bit 0
     Si la operación Aritmética genera carry o borrow en el mas significativo bit del resultado
     También indica overflow para cuentas aritmeticas de enteros sin signo

     Interrupciones: bit 9 (IF)
     Controla la respuesta del procesador a las interrupciones enmascarables (las habilita en 1)


- c) usa el mismo registro, lo extiende a 64bits y lo llama RFLAGS.


# Ejercicio 3

- a) el stack es memoria (ubicación) que sirve para preservar el valor del estado del programa cuando se llama a una rutina, subrutina o función.
     también sirve para pasar argumentos de función en caso de que no alcancen los registros (rdi, rsi, rdx, rcx, r8, r9).

# Ejercicio 3.1

- a) el registro EBP tiene la dirección de memoria del comienzo del stack. el registro ESP, tiene la dirección de memoria del final del stack.
     consideraciones: solo usarlos para el stack. 

- b) pushea el EIP para que cuando utilicemos la instrucción ret, el flujo del programa siga por el EIP que nos guardamos en el stack.

- c) la instrucción ret, hace pop EIP para saber a donde seguir ejecutando el programa.

- d) que cada add rsp, tenga su sub rsp, y que cada push tenga su pop. para que lo ultimo que quede por hacer pop sea el EIP

- e) Ancho de la pila 32bits, 4bytes ;  Ancho de la pila 64bits = 8bytes

- f) se puede pero no es conveniente porque no sabríamos a donde retornar el EIP. (retorna con ret el EIP a cualquier lugar)


# Ejercicio 4

INC :

1 operando : registro o memoria tamaño de hasta 64bits.

que hace ? : suma 1 al valor del operando

ejemplo:

```assembly

mov eax, 1
inc eax 

```

al terminar la ejecución eax tiene el valor 2



SUB :

2 operandos: todas las combinaciones de:
registro memoria e inmediato pero no admite de memoria a memoria.

que hace ? : resta el valor del segundo operando al primero y lo guarda en el primer operando

ejemplo: 

``` assembly

mov eax, 50
sub eax, 25

```

al terminar la ejecución eax tiene valor 25


XOR: Logical exclusive OR

operandos 2: todas las combinaciones menos memoria a memoria

que hace ? : hace xor entre los 2 operandos y guarda el resultado en el primer operando

ejemplo:

```assembly

xor eax, eax

```

no importa el valor de eax siempre da resultado 0 en eax


JE: jump if equal


que hace ?
si la flag ZF (zero flag) está en 1 y sigue la instrucción jump, cambia el valor del EIP a la etiqueta que está al lado del JE


ejemplo:

```assembly

fun2:
    push rbp
    mov rbp, rsp
   
    mov rax, 9

    pop rbp
    ret

fun1:
    push rbp
    mov rbp, rsp
       
    mov rax, 5
    mov rdi, 10
    mov rsi, 10
    cmp rdi, rsi
    je fun2

    pop rbp
    ret

```

si ZF está en 1, fun2 retorna 9, caso contrario fun1 retorna 5


JZ:

que hace ? jump a la etiqueta que tiene a la derecha si la flag ZF está en 1. tiene el mismo opcode que JE
uno es descriptivo para decir que la operacion aritmetica dio 0 y el otro es descriptivo para decir que son iguales.



