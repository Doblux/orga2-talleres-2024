holamundo:
	nasm -f elf64 -g -F DWARF holamundo.asm
	ld -o holamundo holamundo.o


run:
	./holamundo


clean:
	rm -rf holamundo
	rm -rf *.o
