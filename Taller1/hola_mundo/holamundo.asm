%define SYS_WRITE 1
%define SYS_EXIT 60

section .text
global _start

_start:
	mov rdx, len
	mov rsi, msg
	mov rdi, 1
	mov rax, SYS_WRITE
	syscall

	mov rax, SYS_EXIT
	mov rdi, 0
	syscall

section .data
	msg db 'Hello, world!',0xa, 'Rupén Ishkanian 322/21', 0xa, 'David Villarroel 417/22', 0xa, 'Maximiliano Gonzalez 659/22', 0xa
	len equ $ - msg
