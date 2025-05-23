# Ejercicio 1
- a) Podemos definir 3 niveles de privilegio en las estructuras de paginación. (sabiendo que la memoria mide 4 GB)
    - Directorio de Tablas de Páginas (Page Directory) que apuntan a 4mb de memoria
    - Tablas de Páginas (Page Table) que dentro de esos 4mb de memoria del directorio apuntan a 4kb de memoria
    - Páginas de Memoria Física (Page Frames) que son esos 4kb de memoria donde podemos obtener un offset y llegar al byte que queramos

- b)
    - virt = dir(10 bits) | table(10 bits) | offset(12 bits)  queremos traducir esta direccion virtual en una fisica

    Dirección de PD (limpiamos CR3) 
    - pd = CR3 & 0xFFFFF000
    Índice de PD (los 10 bits más altos de virt)
    - pd index = (virt >> 22) & 0x3FF
    Dirección de PT (limpiamos la PDE):
    - pt = pd[pd index] & 0xFFFFF000
    Indice de PT (los 10 bits del medio de virt):
    - pt index = (virt >> 12) & 0x3FF
    Dirección de la página (limpiamos la PTE):
    - page addr = pt[pt index] & 0xFFFFF000
    Offset desde el inicio de la página (los 12 bits más bajos de virt):
    - offset = virt & 0xFFF
    Dirección física (sumamos la base de la página y el offset de virt):
    - phys = page addr | offset

- c)
    - D (Dirty) Indica si escribió a memoria controlada por esta page table entry. Lo escribe el processador al traducir
    - A (Accessed) Indica si se accedió a memoria controlada por esta page table entry. Lo escribe el processador al traducir
    - PCD (Page Cache Disable): Deshabilita cachear los datos de la página asociada.
    - PWT (Page Write-Through): Deshabilita hacer write-back al escribir en la página asociada.
    - U/S (User / Supervisor): Determina si un proceso en modo usuario puede acceder a la memoria controlada por esta page table entry.
    - R/W (Read / Write): Determina si un proceso puede escribir a la memoria controlada por esta page table entry (PTE)
    - P (Present): Es el bit 0 (siempre en 1), indica que esta traduccion es valida
