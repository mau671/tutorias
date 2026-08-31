---
theme: default
layout: center
transition: slide-left | slide-right
addons:
  - slidev-component-zoom
---

<div class="text-center">
  <div class="text-3xl text-gray-500 dark:text-gray-400 mb-4 font-mono">Semana 05</div>
  <h1 class="text-5xl font-bold mb-6">Introducción al lenguaje C y ensamblador x86</h1>
  <div class="text-2xl text-blue-600 dark:text-blue-400">IC3101: Arquitectura de computadores</div>
</div>
<!--
Hola a todos. Bienvenidos a la quinta semana de tutorías de Arquitectura de Computadores.

En las semanas anteriores cubrimos los fundamentos de la representación numérica digital, los enteros en complemento a dos, el diseño de la ALU y los algoritmos de multiplicación, división y punto flotante IEEE 754.

Hoy daremos un paso trascendental en el curso al explorar la conexión directa entre el software y el hardware: estudiaremos la estructura del lenguaje C, el banco de registros de la arquitectura x86, el mapa de memoria del proceso y las instrucciones fundamentales de transferencia y aritmética en NASM.
-->

---
transition: fade
---

# Objetivos de la primera sesión

<div class="mb-4 text-sm text-gray-600 dark:text-gray-300">
Comprender los fundamentos del lenguaje C y su mapeo al modelo de ejecución x86:
</div>
<v-clicks>

- **Puente entre alto y bajo nivel:** Analizar cómo el compilador traduce las abstracciones estructuradas de C a instrucciones nativas del procesador.
- **Estructura de programas en C y NASM:** Identificar la función principal, directivas de preprocesador y las secciones de memoria estándar.
- **Banco de registros de la arquitectura x86:** Dominar los registros generales, sus particiones de 64, 32, 16 y 8 bits y los registros de control.
- **Mapa de memoria del proceso en Linux:** Comprender la disposición en memoria virtual de código, datos, montículo y pila.
- **Instrucciones elementales de transferencia y aritmética:** Dominar la sintaxis Intel para <i>MOV</i>, <i>ADD</i>, <i>SUB</i>, <i>INC</i>, <i>DEC</i> y <i>NEG</i>.

</v-clicks>
<!--
Antes de entrar en materia teórica, repasemos los objetivos de esta primera sesión:

[click] Primero, entenderemos cómo el compilador convierte el código en C en secuencias de instrucciones que el procesador ejecuta directamente.

[click] Segundo, estudiaremos la estructura básica de los programas tanto en C como en ensamblador NASM y sus secciones de memoria.

[click] Tercero, analizaremos el banco de registros de la arquitectura x86 y cómo se dividen en partes de 32, 16 y 8 bits.

[click] Cuarto, examinaremos la organización del mapa de memoria virtual de un proceso en Linux.

[click] Y quinto, dominaremos las instrucciones elementales de movimiento de datos y aritmética básica bajo la sintaxis Intel.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# De C al hardware

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
C provee abstracción estructurada manteniendo correspondencia directa con la memoria física:
</div>

<div class="relative pl-3.5 space-y-2.5 text-xs border-l-2 border-gray-200 dark:border-gray-800 ml-1.5 mt-2 font-sans">
  <!-- Nivel medio: Lenguaje C -->
  <div v-click="1" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-blue-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/80 dark:border-blue-500/30 dark:text-blue-300 text-[9.5px] font-semibold">
        Nivel medio
      </span>
      <span class="text-[12px] font-bold text-gray-900 dark:text-gray-100">Lenguaje C</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[10px] leading-snug">
      Tipos con tamaño en bytes predecible, punteros directos a memoria física y ausencia de capas de sobrecarga.
    </p>
  </div>

  <!-- Bajo nivel: Ensamblador x86 -->
  <div v-click="2" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-emerald-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/80 dark:border-emerald-500/30 dark:text-emerald-300 text-[9.5px] font-semibold">
        Bajo nivel
      </span>
      <span class="text-[12px] font-bold text-gray-900 dark:text-gray-100">Ensamblador x86</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[10px] leading-snug">
      Representación mnemotécnica 1 a 1 de instrucciones del CPU, manipulación de registros y acceso a buses.
    </p>
  </div>
</div>


::right::

<div v-click="3" class="flex flex-col items-center justify-center w-full max-w-[420px] mx-auto text-xs font-sans">
  <div class="text-amber-700 dark:text-amber-400 font-bold mb-2 text-[11px] font-mono text-center">
    Cadena de compilación y ensamble
  </div>

  <!-- Stage 1: Código fuente -->
  <div class="flex items-center justify-between w-full">
    <div class="w-[185px] py-1.5 px-2.5 text-center font-semibold text-[10px] bg-white dark:bg-gray-900 border border-gray-300 dark:border-gray-700 rounded-lg shadow-2xs text-gray-900 dark:text-gray-100">
      Código fuente
    </div>
    <div class="flex items-center flex-1 justify-center px-1">
      <svg class="w-10 h-3 text-gray-400 dark:text-gray-500" viewBox="0 0 40 12" fill="none" stroke="currentColor">
        <path d="M2 6h32m-4-3.5l4 3.5-4 3.5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </div>
    <div class="w-[95px] py-1 px-2 text-center font-mono text-[9.5px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40 rounded-md">
      ejemplo.c
    </div>
  </div>

  <!-- Connector 1 -->
  <div class="flex items-center w-full my-0.5">
    <div class="w-[185px] flex flex-col items-center">
      <div class="w-[1.5px] h-1.5 bg-gray-300 dark:bg-gray-600"></div>
      <div class="px-2 py-0.5 text-[8.5px] font-mono font-bold text-gray-600 dark:text-gray-300 bg-gray-100 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded shadow-2xs">
        gcc -E / cpp
      </div>
      <div class="flex flex-col items-center">
        <div class="w-[1.5px] h-1.5 bg-gray-300 dark:bg-gray-600"></div>
        <div class="w-0 h-0 border-l-[3.5px] border-l-transparent border-r-[3.5px] border-r-transparent border-t-[4.5px] border-t-gray-400 dark:border-t-gray-500"></div>
      </div>
    </div>
    <div class="flex-1"></div>
  </div>

  <!-- Stage 2: Código preprocesado -->
  <div class="flex items-center justify-between w-full">
    <div class="w-[185px] py-1.5 px-2.5 text-center font-semibold text-[10px] bg-white dark:bg-gray-900 border border-gray-300 dark:border-gray-700 rounded-lg shadow-2xs text-gray-900 dark:text-gray-100">
      Código preprocesado
    </div>
    <div class="flex items-center flex-1 justify-center px-1">
      <svg class="w-10 h-3 text-gray-400 dark:text-gray-500" viewBox="0 0 40 12" fill="none" stroke="currentColor">
        <path d="M2 6h32m-4-3.5l4 3.5-4 3.5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </div>
    <div class="w-[95px] py-1 px-2 text-center font-mono text-[9.5px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40 rounded-md">
      ejemplo.i
    </div>
  </div>

  <!-- Connector 2 -->
  <div class="flex items-center w-full my-0.5">
    <div class="w-[185px] flex flex-col items-center">
      <div class="w-[1.5px] h-1.5 bg-gray-300 dark:bg-gray-600"></div>
      <div class="px-2 py-0.5 text-[8.5px] font-mono font-bold text-gray-600 dark:text-gray-300 bg-gray-100 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded shadow-2xs">
        gcc -S / cc1
      </div>
      <div class="flex flex-col items-center">
        <div class="w-[1.5px] h-1.5 bg-gray-300 dark:bg-gray-600"></div>
        <div class="w-0 h-0 border-l-[3.5px] border-l-transparent border-r-[3.5px] border-r-transparent border-t-[4.5px] border-t-gray-400 dark:border-t-gray-500"></div>
      </div>
    </div>
    <div class="flex-1"></div>
  </div>

  <!-- Stage 3: Código ensamblador -->
  <div class="flex items-center justify-between w-full">
    <div class="w-[185px] py-1.5 px-2.5 text-center font-semibold text-[10px] bg-white dark:bg-gray-900 border border-gray-300 dark:border-gray-700 rounded-lg shadow-2xs text-gray-900 dark:text-gray-100">
      Código ensamblador
    </div>
    <div class="flex items-center flex-1 justify-center px-1">
      <svg class="w-10 h-3 text-gray-400 dark:text-gray-500" viewBox="0 0 40 12" fill="none" stroke="currentColor">
        <path d="M2 6h32m-4-3.5l4 3.5-4 3.5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </div>
    <div class="w-[95px] py-1 px-2 text-center font-mono text-[9.5px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40 rounded-md">
      ejemplo.s
    </div>
  </div>

  <!-- Connector 3 -->
  <div class="flex items-center w-full my-0.5">
    <div class="w-[185px] flex flex-col items-center">
      <div class="w-[1.5px] h-1.5 bg-gray-300 dark:bg-gray-600"></div>
      <div class="px-2 py-0.5 text-[8.5px] font-mono font-bold text-gray-600 dark:text-gray-300 bg-gray-100 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded shadow-2xs">
        as / nasm
      </div>
      <div class="flex flex-col items-center">
        <div class="w-[1.5px] h-1.5 bg-gray-300 dark:bg-gray-600"></div>
        <div class="w-0 h-0 border-l-[3.5px] border-l-transparent border-r-[3.5px] border-r-transparent border-t-[4.5px] border-t-gray-400 dark:border-t-gray-500"></div>
      </div>
    </div>
    <div class="flex-1"></div>
  </div>

  <!-- Stage 4: Código objeto -->
  <div class="flex items-center justify-between w-full">
    <div class="w-[185px] py-1.5 px-2.5 text-center font-semibold text-[10px] bg-white dark:bg-gray-900 border border-gray-300 dark:border-gray-700 rounded-lg shadow-2xs text-gray-900 dark:text-gray-100">
      Código objeto
    </div>
    <div class="flex items-center flex-1 justify-center px-1">
      <svg class="w-10 h-3 text-gray-400 dark:text-gray-500" viewBox="0 0 40 12" fill="none" stroke="currentColor">
        <path d="M2 6h32m-4-3.5l4 3.5-4 3.5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </div>
    <div class="w-[95px] py-1 px-2 text-center font-mono text-[9.5px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40 rounded-md">
      ejemplo.o
    </div>
  </div>

  <!-- Connector 4 -->
  <div class="flex items-center w-full my-0.5">
    <div class="w-[185px] flex flex-col items-center">
      <div class="w-[1.5px] h-1.5 bg-gray-300 dark:bg-gray-600"></div>
      <div class="px-2 py-0.5 text-[8.5px] font-mono font-bold text-gray-600 dark:text-gray-300 bg-gray-100 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded shadow-2xs">
        ld / collect2
      </div>
      <div class="flex flex-col items-center">
        <div class="w-[1.5px] h-1.5 bg-gray-300 dark:bg-gray-600"></div>
        <div class="w-0 h-0 border-l-[3.5px] border-l-transparent border-r-[3.5px] border-r-transparent border-t-[4.5px] border-t-gray-400 dark:border-t-gray-500"></div>
      </div>
    </div>
    <div class="flex-1"></div>
  </div>

  <!-- Stage 5: Ejecutable ELF -->
  <div class="flex items-center justify-between w-full">
    <div class="w-[185px] py-1.5 px-2.5 text-center font-semibold text-[10px] bg-white dark:bg-gray-900 border border-gray-300 dark:border-gray-700 rounded-lg shadow-2xs text-gray-900 dark:text-gray-100">
      Ejecutable binario
    </div>
    <div class="flex items-center flex-1 justify-center px-1">
      <svg class="w-10 h-3 text-gray-400 dark:text-gray-500" viewBox="0 0 40 12" fill="none" stroke="currentColor">
        <path d="M2 6h32m-4-3.5l4 3.5-4 3.5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </div>
    <div class="w-[95px] py-1 px-2 text-center font-mono text-[9.5px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40 rounded-md">
      a.out
    </div>
  </div>
</div>

<!--
Comencemos analizando el vínculo entre el lenguaje C y la arquitectura de la computadora.

C es considerado un lenguaje de nivel medio porque combina estructuras de control estructuradas con un modelo mental muy cercano al hardware.

[click] En el nivel medio, C provee tipos de datos con tamaño físico exacto en memoria y punteros directos sin capas de sobrecarga en tiempo de ejecución.

[click] Al descender al bajo nivel mediante el proceso de compilación, el ensamblador x86 expone directamente las instrucciones de máquina, los registros de la CPU y el bus del sistema.

[click] Observemos en este diagrama la cadena de construcción: el código en C pasa por el preprocesador, el compilador genera código ensamblador, el ensamblador produce código objeto y el enlazador genera el archivo ejecutable binario.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Anatomía de un programa en C

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Estructura elemental según el estándar clásico de Kernighan y Ritchie:
</div>

<div class="space-y-3.5 mt-3 text-xs font-sans">
  <!-- 1. Directivas de inclusión -->
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11.5px]">Directivas de inclusión</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">#include &lt;stdio.h&gt;</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Incorpora cabeceras con prototipos de funciones estándar del sistema antes de compilar.
    </p>
  </div>

  <!-- 2. Función principal -->
  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11.5px]">Función principal</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">int main(void)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Punto de inicio de la lógica del usuario, retornando 0 al sistema operativo.
    </p>
  </div>

  <!-- 3. Tipos y variables -->
  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-700 dark:text-amber-400 text-[11.5px]">Tipos y variables</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-amber-800 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">char, short, int</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      <i>char</i> (1B), <i>short</i> (2B), <i>int</i> (4B) y <i>long long</i> (8B) definen el espacio físico en RAM.
    </p>
  </div>
</div>

::right::

<div class="text-xs">

```c {all|1|7,16-17|4-5,9-10|12-15}
#include <stdio.h>

/* Variables globales inicializadas */
int global_a = 15;
int global_b = 20;

int main(void) {
    /* Variables locales */
    int suma = 0;
    int resultado = 0;

    suma = global_a + global_b;
    resultado = suma - 5;

    printf("Resultado: %d\n", resultado);
    return 0;
}
```

</div>
<!--
Analicemos la estructura de un programa estándar en lenguaje C y su mapeo línea por línea.

[click] Primero, las directivas de inclusión como stdio.h en la línea 1 incorporan los encabezados para operaciones estándar del sistema.

[click] Segundo, la función main en la línea 7 constituye el punto de entrada principal donde arranca la ejecución, cerrando con el retorno de estado en la línea 16.

[click] Tercero, las variables declaradas en las líneas 4, 5, 9 y 10 tienen tipos que reservan un número exacto de bytes en la memoria física.

[click] Y cuarto, en el bloque central de las líneas 12 a 15 observamos las operaciones aritméticas que combinan las variables para producir el resultado final.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Estructura y secciones en NASM

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Segmentación del código fuente para el ensamblador en Linux:
</div>

<div class="p-3 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl space-y-2.5 text-xs font-sans mt-2">
  <!-- 1. .data -->
  <div v-click="1" class="space-y-0.5">
    <div class="text-[12px] font-mono font-bold text-emerald-600 dark:text-emerald-400">section .data</div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-2">
      Variables con valores constantes conocidos de antemano. Se almacenan físicamente dentro del archivo binario ejecutable.
    </p>
  </div>

  <div class="border-t border-gray-200 dark:border-gray-800/80 my-1"></div>

  <!-- 2. .bss -->
  <div v-click="2" class="space-y-0.5">
    <div class="text-[12px] font-mono font-bold text-amber-700 dark:text-amber-400">section .bss</div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-2">
      Reserva de memoria para variables de trabajo. El sistema operativo asigna el espacio al cargar el programa, sin inflar el peso en disco.
    </p>
  </div>

  <div class="border-t border-gray-200 dark:border-gray-800/80 my-1"></div>

  <!-- 3. .text -->
  <div v-click="3" class="space-y-0.5">
    <div class="text-[12px] font-mono font-bold text-blue-600 dark:text-blue-400">section .text</div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-2">
      Instrucciones de máquina protegidas contra escritura por el hardware. Contiene la etiqueta pública obligatoria <i>global _start</i>.
    </p>
  </div>
</div>

::right::

<div class="text-xs">

```asm {all|1-3|5-6|8-19}
section .data
    num1:    dd 15          ; Entero de 32 bits
    num2:    dd 20          ; Entero de 32 bits

section .bss
    res:     resd 1         ; Reserva 1 dword (4B)

section .text
    global _start

_start:
    mov eax, [num1]         ; Carga num1 en EAX
    add eax, [num2]         ; EAX = num1 + num2
    mov [res], eax          ; Guarda en memoria

    ; Salida limpia al OS
    mov eax, 1              ; sys_exit
    xor ebx, ebx            ; Código de retorno 0
    int 0x80
```

</div>
<!--
Veamos ahora cómo se estructura un programa equivalente en el ensamblador NASM.

En ensamblador no tenemos funciones automáticas ni tipos abstractos, sino secciones de memoria claramente separadas.

[click] La sección .data en las líneas 1 a 3 almacena variables cuyos valores se conocen de antemano, por lo que quedan grabadas físicamente dentro del archivo binario.

[click] La sección .bss en las líneas 5 y 6 reserva bloques de memoria que el sistema operativo asignará cuando el programa se cargue en RAM, ahorrando espacio en disco.

[click] La sección .text contiene las instrucciones ejecutables y la directiva global start que indica al enlazador dónde comienza la ejecución.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Directivas de memoria en NASM

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Instrucciones al ensamblador para definir y reservar espacio físico:
</div>

<div class="space-y-3 mt-2.5 text-xs font-sans">
  <!-- 1. Definición (.data) -->
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">Definición (.data)</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">db, dw, dd, dq</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Asigna valores explícitos en tiempo de ensamblado, grabando los bytes en el ejecutable (1B, 2B, 4B, 8B).
    </p>
  </div>

  <!-- 2. Reserva (.bss) -->
  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-700 dark:text-amber-400 text-[11px]">Reserva (.bss)</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-amber-800 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">resb, resw, resd, resq</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Aparta espacio en memoria dinámicamente al cargar el proceso, especificando el conteo de elementos.
    </p>
  </div>

  <!-- 3. Constantes simbólicas -->
  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-purple-600 dark:text-purple-400 text-[11px]">Constantes simbólicas</span>
      <span class="text-purple-400 dark:text-purple-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-purple-700 bg-purple-50 border border-purple-200 dark:text-purple-300 dark:bg-purple-950/60 dark:border-purple-800/40 px-1.5 py-0.5 rounded">TAM EQU 100</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Sustitución literal de símbolos en tiempo de ensamblado sin consumir bytes de memoria en RAM.
    </p>
  </div>
</div>

::right::

<div v-click="4" class="text-xs">
  <div class="text-blue-600 dark:text-blue-400 font-bold mb-2 text-[11px] font-sans">
    Correspondencia C vs NASM
  </div>
  <table class="w-full text-center text-[10px] font-mono border-collapse">
    <thead>
      <tr class="text-gray-500 dark:text-gray-400 border-b border-gray-300 dark:border-gray-700">
        <th class="py-1.5 px-2 text-left">Tipo en C</th>
        <th class="py-1.5 px-2">Tamaño</th>
        <th class="py-1.5 px-2">Directiva .data</th>
        <th class="py-1.5 px-2">Directiva .bss</th>
      </tr>
    </thead>
    <tbody class="divide-y divide-gray-200 dark:divide-gray-800 text-gray-700 dark:text-gray-300">
      <tr>
        <td class="py-1.5 px-2 text-left text-blue-600 dark:text-blue-400 font-sans font-medium">char</td>
        <td class="py-1.5 px-2">1 byte (8b)</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-400 font-bold">db</td>
        <td class="py-1.5 px-2 text-amber-700 dark:text-amber-400 font-bold">resb</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-left text-blue-600 dark:text-blue-400 font-sans font-medium">short</td>
        <td class="py-1.5 px-2">2 bytes (16b)</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-400 font-bold">dw</td>
        <td class="py-1.5 px-2 text-amber-700 dark:text-amber-400 font-bold">resw</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-left text-blue-600 dark:text-blue-400 font-sans font-medium">int / long</td>
        <td class="py-1.5 px-2">4 bytes (32b)</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-400 font-bold">dd</td>
        <td class="py-1.5 px-2 text-amber-700 dark:text-amber-400 font-bold">resd</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-left text-blue-600 dark:text-blue-400 font-sans font-medium">long long</td>
        <td class="py-1.5 px-2">8 bytes (64b)</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-400 font-bold">dq</td>
        <td class="py-1.5 px-2 text-amber-700 dark:text-amber-400 font-bold">resq</td>
      </tr>
    </tbody>
  </table>
</div>
<!--
Revisemos cómo se traduce cada tipo de dato de C a directivas concretas de NASM.

[click] En la sección .data utilizamos las directivas de definición: db para un byte, dw para una palabra de dos bytes, dd para una palabra doble de cuatro bytes y dq para una palabra cuádruple de ocho bytes.

[click] En la sección .bss empleamos las directivas de reserva prefijadas con res, indicando la cantidad de unidades que deseamos apartar.

[click] Adicionalmente, la directiva EQU permite definir constantes numéricas puras que el ensamblador sustituye antes de generar el código objeto.

[click] En la tabla de la derecha vemos la equivalencia exacta: un int en C de 32 bits corresponde directamente a la directiva dd en datos o resd en reserva.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Banco de registros x86

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Memoria interna de máxima velocidad con partición jerárquica:
</div>

<div class="space-y-2 text-xs font-sans">
  <div v-click="1" class="space-y-1.5">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[11px]">Registros de propósito general (32 bits)</div>
    <div class="grid grid-cols-2 gap-1.5 font-mono text-[10px]">
      <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/70 dark:border-gray-800 rounded-lg">
        <div class="flex items-center justify-between mb-1">
          <span class="text-emerald-600 dark:text-emerald-400 font-bold font-mono text-[11px]">EAX</span>
          <span class="text-[8px] font-sans font-semibold px-1.5 py-0.5 rounded bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40">Acumulador</span>
        </div>
        <p class="text-gray-600 dark:text-gray-300 font-sans text-[8.5px] leading-relaxed">
          Cálculos aritméticos, retornos de funciones y servicios del sistema operativo (<i>sys_exit</i>, <i>sys_write</i>).
        </p>
      </div>
      <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/70 dark:border-gray-800 rounded-lg">
        <div class="flex items-center justify-between mb-1">
          <span class="text-blue-600 dark:text-blue-400 font-bold font-mono text-[11px]">EBX</span>
          <span class="text-[8px] font-sans font-semibold px-1.5 py-0.5 rounded bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/60 dark:text-blue-300 dark:border-blue-800/40">Base</span>
        </div>
        <p class="text-gray-600 dark:text-gray-300 font-sans text-[8.5px] leading-relaxed">
          Puntero base para direccionamiento de estructuras en memoria y paso de argumentos en llamadas al kernel.
        </p>
      </div>
      <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/70 dark:border-gray-800 rounded-lg">
        <div class="flex items-center justify-between mb-1">
          <span class="text-amber-700 dark:text-amber-400 font-bold font-mono text-[11px]">ECX</span>
          <span class="text-[8px] font-sans font-semibold px-1.5 py-0.5 rounded bg-amber-50 text-amber-800 border border-amber-200 dark:bg-amber-950/60 dark:text-amber-300 dark:border-amber-800/40">Contador</span>
        </div>
        <p class="text-gray-600 dark:text-gray-300 font-sans text-[8.5px] leading-relaxed">
          Contador implícito en lazos iterativos (<i>LOOP</i>), cadenas con prefijo <i>REP</i> y desplazamiento de bits (<i>CL</i>).
        </p>
      </div>
      <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/70 dark:border-gray-800 rounded-lg">
        <div class="flex items-center justify-between mb-1">
          <span class="text-purple-600 dark:text-purple-400 font-bold font-mono text-[11px]">EDX</span>
          <span class="text-[8px] font-sans font-semibold px-1.5 py-0.5 rounded bg-purple-50 text-purple-700 border border-purple-200 dark:bg-purple-950/60 dark:text-purple-300 dark:border-purple-800/40">Datos</span>
        </div>
        <p class="text-gray-600 dark:text-gray-300 font-sans text-[8.5px] leading-relaxed">
          Extensión de 64 bits para multiplicación y división entera (par <i>EDX:EAX</i>) y puertos de entrada/salida.
        </p>
      </div>
    </div>
  </div>

  <div v-click="2" class="space-y-0.5 pt-1">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold text-[11px]">Acceso por subcampos independientes</div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed">
      Modificar <i>AL</i> altera los 8 bits bajos de <i>EAX</i> sin tocar los bits superiores. Modificar <i>EAX</i> sobreescribe a <i>AX</i>, <i>AH</i> y <i>AL</i>.
    </p>
  </div>
</div>

::right::

<div v-click="3" class="text-xs font-mono w-full">
  <div class="text-blue-600 dark:text-blue-400 font-bold text-center mb-2.5 font-sans text-[11px]">
    Jerarquía del registro acumulador (RAX / EAX)
  </div>
  <div class="border border-blue-400/60 bg-blue-50/40 dark:border-blue-600/60 dark:bg-blue-950/20 rounded-xl p-2">
    <div class="grid grid-cols-2 text-[8.5px] font-bold text-gray-500 dark:text-gray-400 mb-1 px-1">
      <div class="flex justify-between pr-2">
        <span>63</span>
        <span>32</span>
      </div>
      <div class="grid grid-cols-2 pl-1">
        <div class="flex justify-between pr-1">
          <span>31</span>
          <span>16</span>
        </div>
        <div class="grid grid-cols-2">
          <div class="flex justify-between pr-0.5">
            <span>15</span>
            <span>8</span>
          </div>
          <div class="flex justify-between pl-0.5">
            <span>7</span>
            <span>0</span>
          </div>
        </div>
      </div>
    </div>
    <div class="grid grid-cols-2 gap-1.5 items-stretch">
      <div class="bg-blue-100/60 border border-blue-300/80 dark:bg-blue-900/40 dark:border-blue-700/40 rounded-lg p-2 flex items-center justify-center text-center font-bold font-mono text-blue-700 dark:text-blue-300 text-[11px]">
        RAX
      </div>
      <div class="border-2 border-emerald-500/80 bg-emerald-50/60 dark:bg-emerald-950/40 rounded-lg p-1.5 flex flex-col justify-between">
        <div class="text-[10px] font-bold text-emerald-700 dark:text-emerald-400 text-left mb-1 font-sans pl-1">
          EAX
        </div>
        <div class="grid grid-cols-2 gap-1 flex-1 items-stretch">
          <div class="bg-emerald-100/60 border border-emerald-300 dark:bg-emerald-900/40 dark:border-emerald-700/40 rounded p-1 font-bold font-mono text-emerald-800 dark:text-emerald-300 flex items-center justify-center text-center text-[10px]">
            EAX
          </div>
          <div class="border border-amber-500/80 bg-amber-50/60 dark:bg-amber-950/40 rounded p-1 flex flex-col justify-between">
            <div class="text-[9px] font-bold text-amber-800 dark:text-amber-300 text-left mb-1 font-sans pl-0.5">
              AX
            </div>
            <div class="grid grid-cols-2 gap-1">
              <div class="bg-rose-100 border border-rose-300 text-rose-800 dark:bg-rose-900/60 dark:border-transparent dark:text-rose-200 py-1 rounded text-center text-[8.5px] font-bold font-mono">
                AH
              </div>
              <div class="bg-indigo-100 border border-indigo-300 text-indigo-800 dark:bg-indigo-900/60 dark:border-transparent dark:text-indigo-200 py-1 rounded text-center text-[8.5px] font-bold font-mono">
                AL
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<!--
Pasemos a estudiar el corazón operativo del procesador: el banco de registros.

Los registros residen dentro de la CPU y operan a la velocidad del reloj sin incurrir en latencias de bus o memoria RAM.

[click] Los cuatro registros de propósito general principales son EAX, EBX, ECX y EDX, cada uno con roles especializados en operaciones aritméticas, bucles y llamadas al sistema.

[click] Una característica distintiva de x86 es su compatibilidad histórica: podemos acceder a partes individuales del mismo registro físico.

[click] Observemos este esquema. En una arquitectura de 64 bits tenemos RAX. Sus 32 bits inferiores forman EAX. Los 16 bits inferiores forman AX, el cual a su vez se divide en AH para el byte alto y AL para el byte bajo.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Punteros, índices y banderas

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Registros especializados y registro de estado del procesador:
</div>

<div class="space-y-3 mt-2.5 text-xs font-sans">
  <!-- 1. Índices y punteros -->
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-cyan-700 dark:text-cyan-400 text-[11px]">Índices de bloque</span>
      <span class="text-cyan-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-cyan-800 bg-cyan-50 border border-cyan-200 dark:text-cyan-300 dark:bg-cyan-950/60 dark:border-cyan-800/40 px-1.5 py-0.5 rounded">ESI, EDI</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Punteros fuente (<i>Source Index</i>) y destino (<i>Destination Index</i>) para copias masivas.
    </p>
  </div>

  <!-- 2. Punteros de pila -->
  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">Control de pila</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">ESP, EBP</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      <i>ESP</i> apunta al tope activo de la pila y <i>EBP</i> fija la base del marco de variables locales.
    </p>
  </div>

  <!-- 3. Puntero de instrucción -->
  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-rose-600 dark:text-rose-400 text-[11px]">Flujo de control</span>
      <span class="text-rose-400 dark:text-rose-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-rose-700 bg-rose-50 border border-rose-200 dark:text-rose-300 dark:bg-rose-950/60 dark:border-rose-800/40 px-1.5 py-0.5 rounded">EIP / RIP</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Almacena la dirección de memoria de la próxima instrucción que la CPU decodificará.
    </p>
  </div>
</div>

::right::

<div v-click="4" class="text-xs font-mono w-full">
  <div class="text-amber-700 dark:text-amber-400 font-bold text-center mb-2 font-sans text-[11px]">
    Estructura del registro de banderas FLAGS (16 bits)
  </div>

  <!-- Barra segmentada de bits del registro FLAGS (Bits 15 a 0) -->
  <div class="w-full mb-2 font-mono">
    <!-- Números de bits superiores -->
    <div style="display: grid; grid-template-columns: repeat(16, minmax(0, 1fr));" class="text-[7px] text-gray-500 dark:text-gray-400 text-center mb-1">
      <span>15</span><span>14</span><span>13</span><span>12</span><span>11</span><span>10</span><span>9</span><span>8</span><span>7</span><span>6</span><span>5</span><span>4</span><span>3</span><span>2</span><span>1</span><span>0</span>
    </div>
    <!-- Celdas de bits -->
    <div style="display: grid; grid-template-columns: repeat(16, minmax(0, 1fr));" class="gap-0.5 text-center text-[7.5px] font-bold">
      <div class="bg-gray-100 dark:bg-gray-800 text-gray-400 py-1 rounded-sm border border-gray-200 dark:border-gray-700">0</div>
      <div class="bg-blue-100 text-blue-800 border border-blue-300 dark:bg-blue-900/60 dark:border-transparent dark:text-blue-200 py-1 rounded-sm">NT</div>
      <div class="col-span-2 bg-blue-100 text-blue-800 border border-blue-300 dark:bg-blue-900/60 dark:border-transparent dark:text-blue-200 py-1 rounded-sm">IOPL</div>
      <div class="bg-rose-100 text-rose-800 border border-rose-300 dark:bg-rose-900/60 dark:border-transparent dark:text-rose-200 py-1 rounded-sm">OF</div>
      <div class="bg-emerald-100 text-emerald-800 border border-emerald-300 dark:bg-emerald-900/60 dark:border-transparent dark:text-emerald-200 py-1 rounded-sm">DF</div>
      <div class="bg-emerald-100 text-emerald-800 border border-emerald-300 dark:bg-emerald-900/60 dark:border-transparent dark:text-emerald-200 py-1 rounded-sm">IF</div>
      <div class="bg-blue-100 text-blue-800 border border-blue-300 dark:bg-blue-900/60 dark:border-transparent dark:text-blue-200 py-1 rounded-sm">TF</div>
      <div class="bg-rose-100 text-rose-800 border border-rose-300 dark:bg-rose-900/60 dark:border-transparent dark:text-rose-200 py-1 rounded-sm">SF</div>
      <div class="bg-rose-100 text-rose-800 border border-rose-300 dark:bg-rose-900/60 dark:border-transparent dark:text-rose-200 py-1 rounded-sm">ZF</div>
      <div class="bg-gray-100 dark:bg-gray-800 text-gray-400 py-1 rounded-sm border border-gray-200 dark:border-gray-700">0</div>
      <div class="bg-rose-100 text-rose-800 border border-rose-300 dark:bg-rose-900/60 dark:border-transparent dark:text-rose-200 py-1 rounded-sm">AF</div>
      <div class="bg-gray-100 dark:bg-gray-800 text-gray-400 py-1 rounded-sm border border-gray-200 dark:border-gray-700">0</div>
      <div class="bg-rose-100 text-rose-800 border border-rose-300 dark:bg-rose-900/60 dark:border-transparent dark:text-rose-200 py-1 rounded-sm">PF</div>
      <div class="bg-gray-100 dark:bg-gray-800 text-gray-400 py-1 rounded-sm border border-gray-200 dark:border-gray-700">1</div>
      <div class="bg-rose-100 text-rose-800 border border-rose-300 dark:bg-rose-900/60 dark:border-transparent dark:text-rose-200 py-1 rounded-sm">CF</div>
    </div>
    <!-- Leyenda de categorías -->
    <div class="flex justify-center items-center gap-3 text-[7.5px] font-sans text-gray-600 dark:text-gray-400 mt-1.5 pt-1 border-t border-gray-200 dark:border-gray-800">
      <span class="flex items-center gap-1"><span class="w-2 h-2 rounded-full bg-rose-500"></span> Estado de la ALU</span>
      <span class="flex items-center gap-1"><span class="w-2 h-2 rounded-full bg-emerald-500"></span> Control</span>
      <span class="flex items-center gap-1"><span class="w-2 h-2 rounded-full bg-blue-500"></span> Sistema</span>
      <span class="flex items-center gap-1"><span class="w-2 h-2 rounded-full bg-gray-400"></span> Reservado</span>
    </div>
  </div>

  <!-- Desglose estructurado de banderas individuales -->
  <div class="grid grid-cols-2 gap-1.5 font-mono text-[9px] mt-1.5">
    <div class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/70 dark:border-gray-800 rounded-lg">
      <div class="flex items-center justify-between mb-0.5">
        <span class="text-rose-600 dark:text-rose-400 font-bold font-mono text-[10px]">CF</span>
        <span class="text-[7.5px] font-sans font-semibold px-1 rounded bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/60 dark:text-rose-300 dark:border-rose-800/40">Acarreo</span>
      </div>
      <p class="text-gray-600 dark:text-gray-300 text-[8px] font-sans leading-tight">
        Acarreo o préstamo en operaciones sin signo.
      </p>
    </div>
    <div class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/70 dark:border-gray-800 rounded-lg">
      <div class="flex items-center justify-between mb-0.5">
        <span class="text-rose-600 dark:text-rose-400 font-bold font-mono text-[10px]">ZF</span>
        <span class="text-[7.5px] font-sans font-semibold px-1 rounded bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/60 dark:text-rose-300 dark:border-rose-800/40">Cero</span>
      </div>
      <p class="text-gray-600 dark:text-gray-300 text-[8px] font-sans leading-tight">
        Se activa en 1 si el resultado fue cero.
      </p>
    </div>
    <div class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/70 dark:border-gray-800 rounded-lg">
      <div class="flex items-center justify-between mb-0.5">
        <span class="text-rose-600 dark:text-rose-400 font-bold font-mono text-[10px]">SF</span>
        <span class="text-[7.5px] font-sans font-semibold px-1 rounded bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/60 dark:text-rose-300 dark:border-rose-800/40">Signo</span>
      </div>
      <p class="text-gray-600 dark:text-gray-300 text-[8px] font-sans leading-tight">
        Copia el bit MSB (1 si es negativo).
      </p>
    </div>
    <div class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/70 dark:border-gray-800 rounded-lg">
      <div class="flex items-center justify-between mb-0.5">
        <span class="text-rose-600 dark:text-rose-400 font-bold font-mono text-[10px]">OF</span>
        <span class="text-[7.5px] font-sans font-semibold px-1 rounded bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/60 dark:text-rose-300 dark:border-rose-800/40">Desborde</span>
      </div>
      <p class="text-gray-600 dark:text-gray-300 text-[8px] font-sans leading-tight">
        Desbordamiento en aritmética con signo.
      </p>
    </div>
    <div class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/70 dark:border-gray-800 rounded-lg">
      <div class="flex items-center justify-between mb-0.5">
        <span class="text-emerald-600 dark:text-emerald-400 font-bold font-mono text-[10px]">DF</span>
        <span class="text-[7.5px] font-sans font-semibold px-1 rounded bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40">Dirección</span>
      </div>
      <p class="text-gray-600 dark:text-gray-300 text-[8px] font-sans leading-tight">
        0 = autoincremento, 1 = decremento en cadenas.
      </p>
    </div>
    <div class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/70 dark:border-gray-800 rounded-lg">
      <div class="flex items-center justify-between mb-0.5">
        <span class="text-emerald-600 dark:text-emerald-400 font-bold font-mono text-[10px]">IF</span>
        <span class="text-[7.5px] font-sans font-semibold px-1 rounded bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40">Interrupción</span>
      </div>
      <p class="text-gray-600 dark:text-gray-300 text-[8px] font-sans leading-tight">
        Habilita interrupciones externas (STI/CLI).
      </p>
    </div>
  </div>
</div>
<!--
Además de los registros generales, la arquitectura dispone de punteros y banderas de condición.

[click] ESI y EDI se emplean como índices para transferencias de bloques de memoria.

[click] ESP y EBP controlan el tope de la pila y la base del marco de variables locales en cada función.

[click] El registro EIP contiene la dirección de la siguiente instrucción a decodificar por la unidad de control.

[click] A la derecha observamos el registro EFLAGS: ZF detecta resultados nulos, SF indica signo negativo, CF alerta acarreos sin signo y OF señala desbordamientos con signo.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Mapa de memoria del proceso

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Espacio de direcciones virtuales estructurado por el sistema operativo:
</div>

<div class="relative pl-3.5 space-y-2.5 text-xs border-l-2 border-gray-200 dark:border-gray-800 ml-1.5 mt-2 font-sans">
  <!-- Pila -->
  <div v-click="1" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-rose-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/80 dark:border-rose-500/30 dark:text-rose-300 text-[9.5px] font-semibold">
        Direcciones altas
      </span>
      <span class="text-[12px] font-bold text-gray-900 dark:text-gray-100">Pila</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[10px] leading-snug">
      Variables locales y direcciones de retorno. Crece dinámicamente hacia direcciones bajas (&darr;).
    </p>
  </div>

  <!-- Montículo -->
  <div v-click="2" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-amber-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-amber-50 text-amber-800 border border-amber-200 dark:bg-amber-950/80 dark:border-amber-500/30 dark:text-amber-300 text-[9.5px] font-semibold">
        Dinámico
      </span>
      <span class="text-[12px] font-bold text-gray-900 dark:text-gray-100">Montículo</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[10px] leading-snug">
      Memoria dinámica solicitada con <i>malloc</i> / llamada <i>brk</i>. Crece hacia direcciones altas (&uarr;).
    </p>
  </div>

  <!-- Segmentos estáticos -->
  <div v-click="3" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-blue-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/80 dark:border-blue-500/30 dark:text-blue-300 text-[9.5px] font-semibold">
        Direcciones bajas
      </span>
      <span class="text-[12px] font-bold text-gray-900 dark:text-gray-100">BSS, Data y Text</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[10px] leading-snug">
      Variables estáticas y código binario en direcciones fijas de solo lectura.
    </p>
  </div>
</div>

::right::

<div v-click="4" class="w-full text-center font-mono text-[9px] max-w-[240px] mx-auto">
  <div class="text-gray-500 dark:text-gray-400 text-[8.5px] mb-1.5">0xFFFFFFFF &bull; Direcciones altas</div>
  <div class="space-y-1.5">
    <div class="bg-rose-50 border border-rose-300 text-rose-800 dark:bg-rose-950/60 dark:border-rose-700/60 dark:text-rose-200 py-1.5 px-2 rounded-lg">
      <div class="font-bold text-[10.5px]">Pila</div>
      <div class="text-[8px] text-rose-600 dark:text-rose-300">&darr; Crece hacia abajo (ESP)</div>
    </div>
    <div class="py-3.5 px-2 text-gray-500 dark:text-gray-400 border border-dashed border-gray-300 dark:border-gray-700 rounded-lg text-[8.5px] bg-gray-50/60 dark:bg-gray-900/40 flex items-center justify-center">
      Espacio libre compartido
    </div>
    <div class="bg-amber-50 border border-amber-300 text-amber-800 dark:bg-amber-950/60 dark:border-amber-700/60 dark:text-amber-200 py-1.5 px-2 rounded-lg">
      <div class="text-[8px] text-amber-600 dark:text-amber-300">&uarr; Crece hacia arriba (brk)</div>
      <div class="font-bold text-[10.5px]">Montículo</div>
    </div>
    <div class="bg-indigo-50 border border-indigo-200 text-indigo-800 dark:bg-indigo-950/60 dark:border-indigo-800/40 dark:text-indigo-200 py-1 px-2 rounded-md font-semibold text-[9.5px]">
      Sección .bss
    </div>
    <div class="bg-emerald-50 border border-emerald-200 text-emerald-800 dark:bg-emerald-950/60 dark:border-emerald-800/40 dark:text-emerald-200 py-1 px-2 rounded-md font-semibold text-[9.5px]">
      Sección .data
    </div>
    <div class="bg-blue-50 border border-blue-200 text-blue-800 dark:bg-blue-950/60 dark:border-blue-800/40 dark:text-blue-200 py-1 px-2 rounded-md font-semibold text-[9.5px]">
      Sección .text
    </div>
  </div>
  <div class="text-gray-500 dark:text-gray-400 text-[8.5px] mt-1.5">0x08048000 &bull; Direcciones bajas</div>
</div>
<!--
Comprendamos ahora dónde reside cada elemento dentro de la memoria física y virtual.

Cuando Linux ejecuta un programa, le asigna un espacio de direcciones privado y protegido.

[click] En las direcciones más altas se ubica la pila, que almacena variables locales y parámetros, creciendo hacia abajo a medida que se invocan funciones.

[click] El montículo se sitúa en la zona intermedia y crece hacia arriba cuando solicitamos memoria dinámica mediante malloc o la llamada brk.

[click] En la base encontramos las secciones estáticas: BSS, datos inicializados y el segmento de texto con las instrucciones de solo lectura.

[click] Este diseño ordenado evita colisiones de memoria y optimiza el uso de la memoria virtual en el sistema operativo.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Transferencia de datos: MOV

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Copia el contenido del operando origen en el operando destino:
</div>

<div class="space-y-3 mt-2 text-xs font-sans">
  <!-- 1. Sintaxis -->
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">Sintaxis Intel</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">mov dest, src</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Equivale semánticamente a la asignación escalar <i>destino = origen</i> en lenguaje C.
    </p>
  </div>

  <!-- 2. Regla 1 -->
  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">Regla 1: Dimensión</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <span class="text-gray-600 dark:text-gray-400 text-[9.5px]">Mismo ancho de bits</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Ambos operandos deben coincidir exactamente en su tamaño físico (8b, 16b o 32b).
    </p>
  </div>

  <!-- 3. Regla 2 -->
  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-rose-600 dark:text-rose-400 text-[11px]">Regla 2: Restricción</span>
      <span class="text-rose-400 dark:text-rose-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <span class="text-rose-600 dark:text-rose-300 text-[9.5px] font-semibold">Prohibido Mem &rarr; Mem</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Ninguna instrucción x86 permite transferir entre dos celdas de RAM en un solo paso.
    </p>
  </div>
</div>

::right::

<div class="text-xs">

```asm {all|1-6|8-12}
; Ejemplos válidos
mov eax, 25            ; Registro <- Inmediato
mov ebx, eax           ; Registro <- Registro
mov eax, [num1]        ; Registro <- Memoria
mov [res], ebx         ; Memoria  <- Registro
mov byte [cadena], 'A' ; Memoria  <- Inmediato

; Ejemplos INVÁLIDOS (Errores de ensamblado)
; mov [res], [num1]    ; Error: Memoria a memoria
; mov eax, bx          ; Error: 32 bits y 16 bits
; mov 25, eax          ; Error: Destino inmediato
```

<div v-click="4" class="mt-2 p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/90 dark:border-gray-800 rounded-lg text-[10px] text-gray-700 dark:text-gray-300 font-sans">
  <strong class="text-amber-700 dark:text-amber-400">Solución a memoria a memoria:</strong> Utilizar un registro acumulador como <i>EAX</i> para canalizar el dato.
</div>

</div>
<!--
Entremos al estudio de la instrucción más utilizada en la arquitectura x86: la instrucción MOV.

[click] Bajo la sintaxis Intel, el primer operando representa el destino y el segundo el origen, operando igual que una asignación simple en C.

[click] La primera regla obligatoria es que ambos operandos deben compartir la misma dimensión: no podemos mezclar un registro de 32 bits con uno de 16 bits.

[click] La segunda regla crucial del hardware x86 es que no existe ninguna instrucción que copie directamente de una celda de memoria a otra en un solo paso.

[click] En el código de la derecha vemos las formas válidas y los errores típicos. Si deseamos copiar entre dos variables de memoria, estamos obligados a cargar primero el dato en un registro intermedio.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Aritmética elemental en x86

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Operaciones aritméticas sobre registros y variables de memoria:
</div>

<div class="space-y-3 mt-2 text-xs font-sans">
  <!-- 1. Suma y resta -->
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">Suma y resta diádica</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">add, sub</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      <i>add dest, src</i> (<i>dest += src</i>) y <i>sub dest, src</i> (<i>dest -= src</i>). Actualizan todas las banderas.
    </p>
  </div>

  <!-- 2. Incremento y decremento -->
  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-700 dark:text-amber-400 text-[11px]">Operadores unarios</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-amber-800 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">inc, dec</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      <i>inc op</i> (<i>op++</i>) y <i>dec op</i> (<i>op--</i>). Modifican <i>ZF</i>, <i>SF</i>, <i>OF</i> pero <strong>preservan CF</strong>.
    </p>
  </div>

  <!-- 3. Cambio de signo -->
  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-rose-600 dark:text-rose-400 text-[11px]">Cambio de signo</span>
      <span class="text-rose-400 dark:text-rose-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-rose-700 bg-rose-50 border border-rose-200 dark:text-rose-300 dark:bg-rose-950/60 dark:border-rose-800/40 px-1.5 py-0.5 rounded">neg op</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Calcula el complemento a dos matemático (<i>op = 0 - op</i>) actualizando todas las banderas.
    </p>
  </div>
</div>

::right::

<div v-click="4" class="text-xs">
  <div class="text-blue-600 dark:text-blue-400 font-bold mb-2 text-[11px] font-sans">
    Resumen de operaciones y banderas
  </div>
  <table class="w-full text-center text-[9.5px] font-mono border-collapse">
    <thead>
      <tr class="text-gray-500 dark:text-gray-400 border-b border-gray-300 dark:border-gray-700">
        <th class="py-1.5 px-2 text-left">Instrucción</th>
        <th class="py-1.5 px-2">Equivalente C</th>
        <th class="py-1.5 px-2">Banderas afectadas</th>
      </tr>
    </thead>
    <tbody class="divide-y divide-gray-200 dark:divide-gray-800 text-gray-700 dark:text-gray-300">
      <tr>
        <td class="py-1.5 px-2 text-left text-emerald-600 dark:text-emerald-400 font-bold">add dest, src</td>
        <td class="py-1.5 px-2 text-gray-700 dark:text-gray-300 font-sans">dest += src</td>
        <td class="py-1.5 px-2 text-blue-600 dark:text-blue-400 font-bold">OF, SF, ZF, CF</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-left text-emerald-600 dark:text-emerald-400 font-bold">sub dest, src</td>
        <td class="py-1.5 px-2 text-gray-700 dark:text-gray-300 font-sans">dest -= src</td>
        <td class="py-1.5 px-2 text-blue-600 dark:text-blue-400 font-bold">OF, SF, ZF, CF</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-left text-amber-700 dark:text-amber-400 font-bold">inc op</td>
        <td class="py-1.5 px-2 text-gray-700 dark:text-gray-300 font-sans">op++</td>
        <td class="py-1.5 px-2 text-blue-600 dark:text-blue-400 font-bold">OF, SF, ZF (No CF)</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-left text-amber-700 dark:text-amber-400 font-bold">dec op</td>
        <td class="py-1.5 px-2 text-gray-700 dark:text-gray-300 font-sans">op--</td>
        <td class="py-1.5 px-2 text-blue-600 dark:text-blue-400 font-bold">OF, SF, ZF (No CF)</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-left text-rose-600 dark:text-rose-400 font-bold">neg op</td>
        <td class="py-1.5 px-2 text-gray-700 dark:text-gray-300 font-sans">op = -op</td>
        <td class="py-1.5 px-2 text-blue-600 dark:text-blue-400 font-bold">OF, SF, ZF, CF</td>
      </tr>
    </tbody>
  </table>
</div>
<!--
Veamos ahora las operaciones aritméticas básicas que ofrece la ALU de x86.

[click] ADD y SUB realizan sumas y restas sobre el destino, depositando el resultado en él y actualizando todas las banderas de condición.

[click] Las instrucciones unarias INC y DEC suman o restan una unidad de forma compacta. Un detalle muy importante para exámenes: INC y DEC no modifican la bandera de acarreo CF.

[click] La instrucción NEG invierte el signo matemático calculando el complemento a dos mediante una resta implícita de cero menos el operando.

[click] En la tabla resumen podemos apreciar la correspondencia con las expresiones habituales en C y el conjunto de banderas que resultan afectadas tras su ejecución.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Síntesis de la primera sesión

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Resumen de los fundamentos conceptuales de bajo nivel:
</div>

<div class="relative pl-3.5 space-y-2.5 text-xs border-l-2 border-gray-200 dark:border-gray-800 ml-1.5 mt-2 font-sans">
  <div v-click="1" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-blue-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="text-[12px] font-bold text-blue-600 dark:text-blue-300">Mapeo estricto de memoria</div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-snug mt-0.5">
      Los tipos escalares de C se traducen a directivas físicas de NASM (<i>db</i>, <i>dw</i>, <i>dd</i>) en secciones dedicadas.
    </p>
  </div>

  <div v-click="2" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-emerald-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="text-[12px] font-bold text-emerald-600 dark:text-emerald-300">Jerarquía de registros x86</div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-snug mt-0.5">
      Acceso modular a registros de 32 bits y subcampos de 16 y 8 bits (<i>RAX &rarr; EAX &rarr; AX &rarr; AH/AL</i>).
    </p>
  </div>

  <div v-click="3" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-amber-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="text-[12px] font-bold text-amber-700 dark:text-amber-300">Restricción de bus y memoria</div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-snug mt-0.5">
      Prohibición de transferencias simultáneas memoria a memoria en una sola instrucción.
    </p>
  </div>
</div>

::right::

<div v-click="4" class="p-3 bg-gray-50 border border-gray-200 dark:bg-gray-900/90 dark:border-gray-800 rounded-xl text-xs font-sans">
  <div class="text-amber-700 dark:text-amber-400 font-bold mb-1.5 text-[11px]">Pregunta para la sesión 2</div>
  <p class="text-gray-700 dark:text-gray-200 text-[10.5px] leading-relaxed">
    Al traducir la sentencia en C:
  </p>
  <div class="p-1.5 bg-white border border-gray-200 text-emerald-700 dark:bg-black/50 dark:border-gray-700 dark:text-emerald-300 rounded font-mono text-[10px] my-1.5 text-center">
    resultado = var_a + var_b;
  </div>
  <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed">
    ¿Por qué la arquitectura x86 nos exige emplear al menos un registro intermedio para completar la operación y cómo podemos verificar en GDB que los valores en memoria cambiaron?
  </p>
</div>
<!--
Con esto concluimos la primera sesión teórica. Hemos cubierto la relación entre C y ensamblador, la organización de secciones, el banco de registros y las reglas fundamentales de transferencia y aritmética.

[click] Les dejo esta pregunta para reflexionar antes de pasar al taller práctico: ¿por qué la arquitectura no permite sumar directamente dos variables de memoria y cómo comprobaremos el cambio con el depurador?
-->

---
layout: center
transition: slide-up | slide-down
---

<div class="text-center">
  <div class="text-3xl text-gray-500 dark:text-gray-400 mb-4 font-mono">Semana 05</div>
  <h1 class="text-6xl font-bold mb-8">Sesión 02: Taller práctico</h1>
  <div class="text-2xl text-blue-600 dark:text-blue-500 mt-4">IC3101: Arquitectura de computadores</div>
</div>
<!--
¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de la estructura de programas, el banco de registros y las instrucciones elementales, dedicaremos esta jornada completa a la programación práctica, traducción guiada de sentencias de C a NASM y depuración en vivo con GDB.
-->

---
transition: fade
---

# Objetivos de la segunda sesión

<div class="mb-4 text-sm text-gray-600 dark:text-gray-300">
Desarrollar destrezas prácticas de programación en ensamblador x86, traducción de C y depuración con GDB:
</div>
<v-clicks>

- **Primer programa autónomo en NASM:** Escribir, ensamblar y enlazar un programa con terminación controlada mediante <i>sys_exit</i>.
- **Traducción de expresiones aritméticas:** Traducir asignaciones escalares y cálculos compuestos de C a secuencias óptimas en ensamblador.
- **Manipulación de operadores unarios e intercambio:** Implementar incrementos, decrementos, cambio de signo e intercambio atómico con <i>XCHG</i>.
- **Cadena de herramientas en Linux:** Compilar, ensamblar y generar ejecutables con GCC, NASM y LD en terminal.
- **Depuración interactiva con GDB:** Inspeccionar registros, examinar posiciones de memoria y ejecutar instrucciones paso a paso con la interfaz TUI.

</v-clicks>
<!--
Antes de iniciar los ejercicios prácticos, repasemos los objetivos de esta segunda jornada:

[click] Primero, crearemos nuestro primer programa ejecutable autónomo con terminación limpia mediante llamadas al sistema.

[click] Segundo, traduciremos expresiones y asignaciones de lenguaje C a instrucciones optimizadas en ensamblador.

[click] Tercero, aplicaremos operadores unarios y la instrucción de intercambio de registros XCHG.

[click] Cuarto, dominaremos el flujo de herramientas en Linux con NASM, LD y GCC.

[click] Y quinto, utilizaremos el depurador GDB para inspeccionar el estado de la CPU y la memoria en tiempo real.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Taller 1: Programa mínimo en NASM

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Estructura básica y retorno controlado al sistema operativo:
</div>

<div class="space-y-3 mt-2 text-xs font-sans">
  <!-- 1. Punto de entrada -->
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">Punto de entrada</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">global _start</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Declara el símbolo público para que el enlazador <i>ld</i> ubique la primera instrucción.
    </p>
  </div>

  <!-- 2. sys_exit -->
  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">Llamada sys_exit</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">int 0x80 (Servicio 1)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      <i>EAX = 1</i> (código de servicio) y <i>EBX = 0</i> (código de retorno OK). Cede control al kernel.
    </p>
  </div>

  <!-- 3. Omisión -->
  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-rose-600 dark:text-rose-400 text-[11px]">Omisión de salida</span>
      <span class="text-rose-400 dark:text-rose-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <span class="text-rose-600 dark:text-rose-300 text-[9.5px] font-semibold">Segmentation Fault</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Sin <i>sys_exit</i>, el CPU continúa ejecutando bytes contiguos no válidos provocando el aborto del proceso.
    </p>
  </div>
</div>

::right::

<div class="text-xs">

```asm {all|2-7|11-14|16-19}
; minimo.asm - Programa elemental x86
section .data
    valor:   dd 42          ; Entero inicializado

section .bss
    copia:   resd 1         ; Reserva de 4 bytes

section .text
    global _start

_start:
    ; Copia de dato en memoria
    mov eax, [valor]        ; EAX = 42
    mov [copia], eax        ; copia = 42

    ; Terminación limpia del proceso
    mov eax, 1              ; ID de llamada sys_exit
    mov ebx, 0              ; Código de retorno (0 = OK)
    int 0x80                ; Invoca al núcleo de Linux
```

</div>
<!--
Comencemos con nuestro primer taller práctico construyendo el programa ejecutable mínimo en NASM.

[click] Para que el enlazador reconozca el inicio del código binario, definimos la directiva global start.

[click] Al finalizar nuestras operaciones, debemos invocar explícitamente el servicio sys_exit colocando el número 1 en EAX y el código de retorno en EBX.

[click] Si olvidamos esta llamada, el contador de programa EIP continuará avanzando sobre memoria no asignada y Linux abortará el proceso con un fallo de segmentación.

[click] En el código de la derecha observamos cómo cargamos el valor 42 en EAX, lo almacenamos en la variable de reserva y cerramos el programa de manera impecable.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Taller 2: Traducción de C a NASM

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Mapeo metódico de sentencias de asignación y cálculos compuestos:
</div>

<div class="space-y-3 mt-2 text-xs font-sans">
  <!-- 1. Expresión C -->
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">Expresión en C</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">z = (x + y) - 5;</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Evaluación de dos variables de memoria con resta de una constante literal.
    </p>
  </div>

  <!-- 2. Estrategia -->
  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">Cómputo en registros</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">mov eax, [x] &bull; add</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Cargar <i>x</i> en <i>EAX</i>, sumar <i>y</i> directamente desde memoria y restar 5 en la ALU.
    </p>
  </div>

  <!-- 3. Guardado -->
  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-700 dark:text-amber-400 text-[11px]">Almacenamiento</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-amber-800 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">mov [z], eax</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Minimiza accesos a memoria manteniendo todos los cálculos intermedios en registros.
    </p>
  </div>
</div>

::right::

<div class="text-xs">

```asm {all|2-6|11-15|17-20}
section .data
    x:       dd 15          ; int x = 15;
    y:       dd 20          ; int y = 20;

section .bss
    z:       resd 1         ; int z;

section .text
    global _start

_start:
    ; Traducción de z = (x + y) - 5;
    mov eax, [x]            ; EAX = x (15)
    add eax, [y]            ; EAX = EAX + y (35)
    sub eax, 5              ; EAX = EAX - 5 (30)
    mov [z], eax            ; z = 30

    ; Salida del programa con código en z
    mov ebx, [z]            ; Retorna z como código ($?)
    mov eax, 1              ; sys_exit
    int 0x80
```

</div>
<!--
En este segundo taller traduciremos una expresión matemática típica de C a ensamblador x86.

[click] Supongamos que deseamos calcular z igual a x más y menos cinco.

[click] La estrategia consiste en cargar la primera variable en el registro EAX, operar con la segunda variable directamente desde memoria, restar el valor inmediato cinco y finalmente almacenar el acumulador en la variable z.

[click] Este método reduce al mínimo indispensable los accesos al bus de memoria principal, aprovechando la velocidad interna de los registros de la CPU.

[click] Al compilar y ejecutar este programa, podemos consultar el código de retorno en la terminal con la variable interrogante para verificar que devuelva exactamente treinta.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Taller 3: Operadores unarios y XCHG

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Operadores unarios de C e instrucción de intercambio atómico:
</div>

<div class="space-y-3 mt-2 text-xs font-sans">
  <!-- 1. Operadores unarios -->
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">Operadores unarios</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">inc, dec, neg</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      <i>a++</i> &rarr; <i>inc dword [a]</i>, <i>b--</i> &rarr; <i>dec dword [b]</i>, <i>c = -c</i> &rarr; <i>neg dword [c]</i>.
    </p>
  </div>

  <!-- 2. Intercambio C -->
  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">Intercambio en C</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <span class="text-gray-600 dark:text-gray-400 text-[9.5px]">Requiere variable temporal</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      <i>int temp = a; a = b; b = temp;</i> consume memoria extra y 3 instrucciones MOV.
    </p>
  </div>

  <!-- 3. XCHG -->
  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-700 dark:text-amber-400 text-[11px]">Instrucción XCHG</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[10px] font-mono text-amber-800 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">xchg eax, ebx</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Permutación atómica y directa entre dos registros en una sola instrucción sin auxiliar.
    </p>
  </div>
</div>

::right::

<div class="text-xs">

```asm {all|8-11|13-17|19-24}
section .data
    val_a:   dd 100
    val_b:   dd 200

section .text
    global _start

_start:
    ; Incremento y cambio de signo
    inc dword [val_a]       ; val_a = 101
    neg dword [val_b]       ; val_b = -200

    ; Intercambio con XCHG
    mov eax, [val_a]        ; EAX = 101
    mov ebx, [val_b]        ; EBX = -200
    xchg eax, ebx           ; EAX = -200, EBX = 101

    ; Guardado en posiciones opuestas
    mov [val_a], eax        ; val_a = -200
    mov [val_b], ebx        ; val_b = 101

    mov eax, 1              ; sys_exit
    xor ebx, ebx
    int 0x80
```

</div>
<!--
Veamos ahora la traducción de operadores unarios y el intercambio eficiente de variables.

[click] Los operadores de incremento, decremento y cambio de signo en C tienen un mapeo directo y de alta velocidad con las instrucciones INC, DEC y NEG.

[click] Cuando intercambiamos dos variables en C, normalmente necesitamos declarar una variable auxiliar temporal.

[click] En ensamblador x86 disponemos de la instrucción especializada XCHG, la cual intercambia los contenidos de dos operandos de manera compacta.

[click] Observemos el código: tras cargar val_a en EAX y val_b en EBX, ejecutamos xchg eax, ebx y ambos registros quedan automáticamente permutados.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Taller 4: Compilación y ensamble

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Flujo completo de construcción desde la línea de comandos en Linux:
</div>

<div class="space-y-3 mt-2 text-xs font-sans">
  <!-- 1. NASM -->
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">1. Ensamblado</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">nasm -f elf32 -g -F dwarf</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Genera el archivo objeto <code>prog.o</code> incrustando símbolos DWARF para depuración.
    </p>
  </div>

  <!-- 2. LD -->
  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">2. Enlace</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">ld -m elf_i386 prog.o -o prog</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Enlaza el objeto produciendo el binario ejecutable ELF final para arquitectura IA-32.
    </p>
  </div>

  <!-- 3. Run -->
  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-700 dark:text-amber-400 text-[11px]">3. Verificación</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-amber-800 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">./prog ; echo $?</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Ejecuta el binario y consulta el código de retorno retornado en la variable especial de Bash.
    </p>
  </div>
</div>

::right::

<div v-click="4" class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/90 dark:border-gray-800 rounded-xl text-xs font-sans">
  <div class="text-purple-600 dark:text-purple-400 font-bold mb-1.5 text-[10.5px] font-mono text-center">Inspección de ensamblador desde GCC</div>
  <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed mb-2">
    Para observar exactamente qué ensamblador genera el compilador de C sin optimizaciones:
  </p>
  <div class="p-2 bg-white border border-gray-200 text-blue-700 dark:bg-black/60 dark:border-gray-700 dark:text-blue-300 rounded font-mono text-[9.5px] mb-2">
    gcc -m32 -O0 -S programa.c -o programa.s -masm=intel
  </div>
  <ul class="text-[9.5px] text-gray-700 dark:text-gray-300 space-y-1">
    <li>&bull; <span class="text-amber-700 dark:text-amber-300 font-mono">-m32</span>: Genera código para procesadores de 32 bits.</li>
    <li>&bull; <span class="text-amber-700 dark:text-amber-300 font-mono">-O0</span>: Desactiva optimizaciones para ver el código literal.</li>
    <li>&bull; <span class="text-amber-700 dark:text-amber-300 font-mono">-S</span>: Detiene el compilador antes de ensamblar.</li>
    <li>&bull; <span class="text-amber-700 dark:text-amber-300 font-mono">-masm=intel</span>: Utiliza la sintaxis Intel legible.</li>
  </ul>
</div>
<!--
Practiquemos ahora los comandos de consola en Linux para construir nuestros programas.

[click] Primero ejecutamos nasm con el formato elf32 y los modificadores -g -F dwarf, los cuales incrustan la información de depuración necesaria para inspeccionar variables por nombre.

[click] Segundo invocamos el enlazador ld con la bandera -m elf_i386 para enlazar el archivo objeto y producir el binario ejecutable final.

[click] Tercero ejecutamos el programa y consultamos la variable especial de Bash para comprobar el código de retorno.

[click] A la derecha observamos un comando fundamental para el curso: gcc con la bandera -S y -masm=intel nos permite ver directamente cómo el compilador de C traduce nuestras sentencias a código ensamblador idéntico al que estamos programando.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Taller 5: Depuración con GDB

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Control paso a paso e inspección de registros en tiempo de ejecución:
</div>

<div class="space-y-2.5 mt-2 text-xs font-sans">
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <code class="text-[10.5px] font-mono text-blue-600 dark:text-blue-400 font-bold">gdb ./programa</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug pl-1">
      Inicia el depurador con los símbolos y el binario cargados en memoria.
    </p>
  </div>

  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <code class="text-[10.5px] font-mono text-emerald-600 dark:text-emerald-400 font-bold">break _start &bull; run</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug pl-1">
      Fija el punto de interrupción en la entrada e inicia la ejecución controlada.
    </p>
  </div>

  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <code class="text-[10.5px] font-mono text-amber-700 dark:text-amber-400 font-bold">stepi &bull; nexti</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug pl-1">
      Avanza exactamente una instrucción de máquina a la vez por el flujo de CPU.
    </p>
  </div>

  <div v-click="4" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <code class="text-[10.5px] font-mono text-purple-600 dark:text-purple-400 font-bold">info registers &bull; x/xw &var</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug pl-1">
      Inspecciona los registros del procesador y examina celdas de RAM en hexadecimal.
    </p>
  </div>
</div>

::right::

<div v-click="5" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/90 dark:border-gray-800 rounded-xl text-xs font-mono">
  <div class="text-blue-600 dark:text-blue-400 font-bold text-center mb-1 font-sans text-[10.5px]">Interfaz visual GDB (TUI: layout asm / regs)</div>
  <div class="bg-gray-950 border border-gray-800 text-gray-100 rounded p-1.5 text-[9px]">
    <div class="text-gray-400 border-b border-gray-800 pb-0.5 mb-1 flex justify-between">
      <span>Registro</span><span>Hexadecimal</span><span>Decimal</span>
    </div>
    <div class="text-emerald-400">eax &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0x0000001e &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 30</div>
    <div class="text-gray-300">ebx &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0x00000000 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0</div>
    <div class="text-gray-300">eip &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0x0804900a &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;_start+10&gt;</div>
    <div class="border-t border-gray-800 my-1 pt-1 text-gray-400 font-sans">
      Desensamblado interactivo:
    </div>
    <div class="text-gray-500">0x08049000 &lt;_start&gt;: &nbsp;&nbsp;&nbsp; mov eax, ds:0x804a000</div>
    <div class="text-gray-500">0x08049005 &lt;_start+5&gt;: &nbsp; add eax, ds:0x804a004</div>
    <div class="text-amber-300 font-bold bg-amber-950/40">&gt; 0x0804900a &lt;_start+10&gt;: sub eax, 0x5</div>
    <div class="text-gray-500">0x0804900d &lt;_start+13&gt;: mov ds:0x804a008, eax</div>
  </div>
  <div class="text-[9px] text-gray-500 dark:text-gray-400 text-center font-sans mt-1">
    Activar con <i>layout asm</i> y <i>layout regs</i> (Salir con <i>Ctrl+X A</i>)
  </div>
</div>
<!--
Pasemos a la herramienta más poderosa para comprender y depurar código a bajo nivel: GDB.

[click] Al ejecutar gdb con nuestro programa cargado, tomamos el control total de la ejecución.

[click] Fijamos un punto de interrupción en la etiqueta start con el comando break y arrancamos con run.

[click] Con stepi avanzamos exactamente una instrucción de máquina a la vez, viendo cómo el contador de programa EIP se desplaza instrucción por instrucción.

[click] Con info registers consultamos el contenido de toda la CPU y con el comando examine inspeccionamos la memoria RAM.

[click] A la derecha vemos el modo visual TUI. Al escribir layout asm y layout regs, la pantalla se divide mostrando en tiempo real los registros y la línea exacta de código que se está ejecutando.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Trampas comunes en x86

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Errores frecuentes de principiantes y cómo diagnosticarlos:
</div>

<div class="space-y-3 mt-2 text-xs font-sans">
  <!-- 1. Discrepancia -->
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-rose-600 dark:text-rose-400 text-[11px]">1. Discrepancia de tamaño</span>
      <span class="text-rose-400 dark:text-rose-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-rose-700 bg-rose-50 border border-rose-200 dark:text-rose-300 dark:bg-rose-950/60 dark:border-rose-800/40 px-1.5 py-0.5 rounded">mov al, [entero_32b]</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Mezclar registros o celdas de diferente ancho sin calificador explícito.
    </p>
  </div>

  <!-- 2. Memoria a memoria -->
  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-700 dark:text-amber-400 text-[11px]">2. Memoria a memoria</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-amber-800 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">mov [dest], [orig]</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Intentar copiar directamente entre dos variables. Requiere siempre un registro intermedio.
    </p>
  </div>

  <!-- 3. Ambigüedad -->
  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">3. Ambigüedad de inmediato</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">mov [ptr], 10</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Mover un valor literal a memoria sin especificar si es <i>byte</i>, <i>word</i> o <i>dword</i>.
    </p>
  </div>
</div>

::right::

<div v-click="4" class="text-xs">
  <div class="text-emerald-600 dark:text-emerald-400 font-bold mb-2 text-[11px] font-sans">
    Corrección formal de patrones
  </div>
  <table class="w-full text-left text-[9.5px] border-collapse font-mono">
    <thead>
      <tr class="text-gray-500 dark:text-gray-400 border-b border-gray-300 dark:border-gray-700 font-sans">
        <th class="py-1.5 px-2">Patrón erróneo</th>
        <th class="py-1.5 px-2">Patrón correcto</th>
      </tr>
    </thead>
    <tbody class="divide-y divide-gray-200 dark:divide-gray-800">
      <tr>
        <td class="py-1.5 px-2 text-rose-600 dark:text-rose-300">mov [y], [x]</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-300">mov eax, [x]<br/>mov [y], eax</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-rose-600 dark:text-rose-300">mov [p], 1</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-300">mov dword [p], 1</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-rose-600 dark:text-rose-300">add eax, bx</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-300">movzx ebx, bx<br/>add eax, ebx</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-rose-600 dark:text-rose-300">inc eax (CF?)</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-300">add eax, 1 (si requiere CF)</td>
      </tr>
    </tbody>
  </table>
</div>
<!--
Revisemos los errores más comunes que suelen presentarse en prácticas y evaluaciones.

[click] El primer error radica en intentar transferir datos entre registros o celdas de distinto tamaño sin una instrucción de extensión adecuada.

[click] El segundo error consiste en intentar copiar directamente entre dos variables en memoria, lo cual viola el diseño del juego de instrucciones x86.

[click] El tercer error ocurre al mover un valor numérico inmediato a una dirección de memoria sin calificar su tamaño con byte, word o dword.

[click] En la tabla de la derecha tenemos las soluciones canónicas para cada uno de estos escenarios problemáticos.
-->

---
transition: fade
---

# Mini-quiz formativo (Sesión 2)

<div class="space-y-2 mt-3 text-xs font-sans">
<div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
  <strong class="text-blue-600 dark:text-blue-400 text-[11px]">1. ¿Por qué la instrucción mov [varB], [varA] genera un error en el ensamblador x86?</strong>
  <p class="text-gray-700 dark:text-gray-300 mt-0.5 text-[10px]">
    A) Porque las variables no están en la pila &nbsp;&nbsp;&nbsp; B) Porque la arquitectura x86 no soporta transferencias de memoria a memoria en una sola instrucción &nbsp;&nbsp;&nbsp; C) Porque los nombres de variables deben llevar prefijo
  </p>
  <div v-click="1" class="text-emerald-600 dark:text-emerald-400 mt-0.5 text-[10px] font-bold">
    &rarr; Respuesta correcta: B) En x86 ningún opcode estándar permite dos operandos de memoria simultáneos, requiriendo un registro intermediario.
  </div>
</div>
<div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
  <strong class="text-amber-700 dark:text-amber-400 text-[11px]">2. Si EAX contiene 0x12345678 y ejecutamos mov al, 0x99, ¿cuál es el nuevo valor en EAX?</strong>
  <p class="text-gray-700 dark:text-gray-300 mt-0.5 font-mono text-[10px]">
    A) 0x99345678 &nbsp;&nbsp;&nbsp; B) 0x00000099 &nbsp;&nbsp;&nbsp; C) 0x12345699 &nbsp;&nbsp;&nbsp; D) 0x12349978
  </p>
  <div v-click="2" class="text-emerald-600 dark:text-emerald-400 mt-0.5 text-[10px] font-bold">
    &rarr; Respuesta correcta: C) 0x12345699, ya que AL modifica estrictamente los 8 bits inferiores (bits 7 a 0) preservando el resto de EAX.
  </div>
</div>
<div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
  <strong class="text-purple-600 dark:text-purple-400 text-[11px]">3. ¿Qué diferencia clave existe entre inc eax y add eax, 1?</strong>
  <p class="text-gray-700 dark:text-gray-300 mt-0.5 text-[10px]">
    A) INC es más lenta &nbsp;&nbsp;&nbsp; B) INC no altera la bandera de acarreo CF &nbsp;&nbsp;&nbsp; C) ADD no altera la bandera de cero ZF
  </p>
  <div v-click="3" class="text-emerald-600 dark:text-emerald-400 mt-0.5 text-[10px] font-bold">
    &rarr; Respuesta correcta: B) La instrucción INC preserva intacta la bandera de acarreo CF, mientras que ADD actualiza todas las banderas.
  </div>
</div>
</div>
<!--
Evaluemos lo aprendido con este breve cuestionario interactivo.

Pregunta uno: ¿Por qué la instrucción mov [varB], [varA] produce un error de ensamblado?
[click] Correcto, porque en x86 la arquitectura no soporta dos operandos de memoria en una misma instrucción.

Pregunta dos: Si EAX vale 0x12345678 y modificamos AL con 0x99, ¿cuánto vale EAX?
[click] Exactamente, 0x12345699, porque AL solo altera el byte menos significativo.

Pregunta tres: ¿Qué diferencia existe entre inc eax y add eax, 1?
[click] Muy bien, la instrucción INC preserva intacta la bandera de acarreo CF, propiedad fundamental cuando se implementa aritmética multiprecisión.
-->

---
layout: center
transition: fade
---

<div class="text-center max-w-xl mx-auto font-sans">
  <h1 class="text-3xl font-bold mb-3 text-gray-900 dark:text-white">Conclusiones y siguiente paso</h1>
  <div class="p-3.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl text-left text-xs text-gray-700 dark:text-gray-300 space-y-1.5 mt-3">
    <p>
      &bull; Comprendimos la relación entre las estructuras de lenguaje C y su materialización en instrucciones x86 y secciones de memoria.
    </p>
    <p>
      &bull; Dominamos la jerarquía del banco de registros, las directivas de datos y las instrucciones <i>MOV</i>, <i>ADD</i>, <i>SUB</i>, <i>INC</i>, <i>DEC</i> y <i>NEG</i>.
    </p>
    <p>
      &bull; Adquirimos destreza práctica ensamblando con NASM, enlazando con LD y depurando visualmente con GDB.
    </p>
    <p>
      &bull; En la <strong>Semana 06</strong> estudiaremos los <strong>formatos de instrucción y modos de direccionamiento avanzados</strong> (inmediato, directo, indirecto por registro y direccionamiento base más índice con escala y desplazamiento).
    </p>
  </div>
  <div class="text-blue-600 dark:text-blue-400 font-semibold mt-3 text-xs">
    ¡Muchas gracias por su atención y nos vemos en la Semana 06!
  </div>
</div>
<!--
Con esto concluimos la quinta semana de tutorías de Arquitectura de Computadores.

Hemos construido los cimientos indispensables del lenguaje ensamblador, comprendiendo cómo dialogan el código en C, el compilador, las secciones de memoria y los registros del procesador.

En la próxima semana profundizaremos en los formatos de instrucción de máquina y los sofisticados modos de direccionamiento que permiten recorrer arreglos y estructuras de datos con máxima eficiencia.

¡Excelente trabajo a todos y nos vemos en la siguiente sesión!
-->
