global contar_bytes
section .text

contar_bytes:
  push ebp
  mov ebp, esp
  push ebx

  mov eax, 5
  mov ebx, [ebp + 8]
  mov ecx, 0
  int 0x80
  cmp eax, 0
  jl .error_abrir
  mov ebx, eax

  mov eax, 19
  mov ecx, 0
  mov edx, 2
  int 0x80
  push eax

  mov eax, 6
  int 0x80
  pop eax

  jmp .salir

.error_abrir:
  mov eax, -1

.salir:
  pop ebx
  mov esp, ebp
  pop ebp
  ret
