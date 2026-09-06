#include <stdio.h>

extern int contar_bytes(const char *ruta);

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printf("Uso: %s <archivo>\n", argv[0]);
    return 1;
  }
  int total = contar_bytes(argv[1]);
  if (total < 0) {
    printf("Error: no se pudo abrir '%s'\n", argv[1]);
    return 1;
  }
  printf("El archivo '%s' mide %d bytes\n", argv[1], total);
  return 0;
}
