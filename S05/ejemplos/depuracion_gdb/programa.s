.intel_syntax noprefix
.section .data
val_a:     .int 30
val_b:     .int 12
resultado: .int 0

.section .text
.globl _start
_start:
    mov eax, [val_a]
    mov ebx, [val_b]
    add eax, ebx
    mov [resultado], eax
    mov eax, 1
    mov ebx, 0
    int 0x80
