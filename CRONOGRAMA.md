# Cronograma maestro de tutorías de Arquitectura de Computadores (IC3101)

Este documento define la planificación oficial, pedagógica y unificada de las dieciséis semanas de tutorías para el curso IC3101 (Arquitectura de Computadores).

---

## 1. Naturaleza y enfoque universal de la tutoría

La tutoría es un espacio de acompañamiento académico, profundización conceptual y práctica técnica guiada. Dado que cada profesor evalúa con su propia metodología, calendario y ponderación, la tutoría está estructurada como un marco de apoyo universal y modular que sirve con máxima eficacia a estudiantes de cualquier grupo:

* **Sin entregas formales ni evaluaciones sumativas:** En la tutoría no se asignan tareas obligatorias, no se reciben entregas de proyectos ni se aplican exámenes formales. La evaluación sumativa pertenece con exclusividad al profesor de cada grupo.
* **Desafíos de consolidación técnica:** En lugar de pruebas calificadas, las sesiones prácticas incorporan retos de integración de bajo nivel, trazados manuales de memoria, resolución de problemas cuantitativos y ejercicios de alta exigencia analítica. Estos desafíos preparan al estudiante para desempeñarse con solidez ante cualquier modalidad de examen o proyecto que aplique su respectivo profesor.
* **Cobertura curricular exhaustiva y modular:** Cada semana se diseña de manera autocontenida para cubrir a profundidad los temas del programa oficial del curso, asegurando que los estudiantes dominen tanto los modelos arquitectónicos de hardware como la programación en ensamblador y lenguaje C.

---

## 2. Diagnóstico y plan de reestructuración de las presentaciones del repositorio

Al revisar el estado actual de los materiales desarrollados en el repositorio, se establecen las siguientes acciones correctivas para alinear las presentaciones existentes con el cronograma real del curso:

### Semana 01 ([S01/slides.md](file:///home/mau/Tutorias/IC3101/S01/slides.md))
* **Estado actual:** Presentación de sesión única (308 líneas) creada antes de estandarizar la directriz bi-sesional.
* **Plan de reestructuración:**
  * Reestructurar el archivo para dividirlo en dos bloques de 90 minutos con una diapositiva divisoria intermedia (`layout: section`).
  * Asignar a la **Sesión 1** la teoría fundamental: arquitectura frente a organización, evolución histórica de computadores, componentes de la máquina de Von Neumann y conceptos base de rendimiento.
  * Asignar a la **Sesión 2** un taller práctico y cuantitativo: ejercicios de cálculo de tiempo de ejecución, ciclos por instrucción (CPI), frecuencia de reloj y aplicación de la ley de Amdahl, concluyendo con un reto formativo de diagnóstico inicial.
  * Incorporar las notas de orador (`<!-- ... -->`) completas con marcadores `[click]` en todo el mazo.

### Semana 04 ([S04/slides.md](file:///home/mau/Tutorias/IC3101/S04/slides.md))
* **Estado actual:** Proyecto bi-sesional completo y robusto (algoritmo de Booth, división no restauradora y estándar IEEE 754).
* **Plan de ajuste:**
  * Mantener el taller de la Sesión 2 enfocado como un reto intensivo de cálculo numérico manual en pizarrón digital (tablas de Booth y codificación hexadecimal IEEE 754 con casos de desbordamiento y cancelación).
  * Garantizar que no existan alusiones a entregas de tareas formales dentro de la tutoría.

### Semana 05 ([S05/slides.md](file:///home/mau/Tutorias/IC3101/S05/slides.md))
* **Estado actual:** Proyecto bi-sesional completo que introduce lenguaje C y ensamblador x86 NASM de 32 bits (registros, secciones de memoria, instrucciones `mov`/`add`/`sub` y depuración con GDB).
* **Plan de ajuste:**
  * Mantener la estructura actual, plenamente alineada con las lecturas recomendadas (Reporte 6: Sivarama capítulos 9 y 10, Libro C capítulos 1 y 2).

### Semana 09 ([S09/slides.md](file:///home/mau/Tutorias/IC3101/S09/slides.md))
* **Estado actual:** Proyecto bi-sesional enfocado en llamadas al sistema con `int 0x80` y descriptores estándar POSIX (`0 = stdin`, `1 = stdout`, `2 = stderr`), con taller práctico centrado en lectura desde teclado (`sys_read`) y despliegue en pantalla (`sys_write`).
* **Diagnóstico del tema de archivos en disco:**
  * La habilidad técnica de interactuar con el sistema de archivos en disco (crear archivos con `sys_creat`, abrir archivos con `sys_open`, leer y escribir registros estructurados en disco y cerrar descriptores con `sys_close`) requiere tiempo dedicado y no cabe pedagógicamente en S09 sin saturar a los estudiantes con exceso de conceptos nuevos de modo núcleo.
  * Además, en el cronograma de lecturas de referencia ([LECTURAS.md](file:///home/mau/Tutorias/IC3101/LECTURAS.md)), el capítulo dedicado a *File I/O* en Linux (Sivarama capítulo 20) corresponde al Reporte 11.
* **Plan de ajuste:**
  * Delimitar formalmente la **Semana 09** como: *Llamadas al sistema e interacción con el sistema operativo (Modo protegido, int 0x80 y entrada/salida por consola)*.
  * Ubicar el tema completo de **Manejo de archivos en disco en ensamblador** en la **Semana 11**, donde se articulará de forma natural con macros y modularización en C + NASM.

### Semana 10 ([S10/slides.md](file:///home/mau/Tutorias/IC3101/S10/slides.md))
* **Estado actual:** Proyecto bi-sesional enfocado en *Procesamiento de cadenas y manipulación de memoria* (`MOVS`, `STOS`, `LODS`, `CMPS`, `SCAS`, prefijos `REP`, y talleres de `strlen`, `memcpy`, `strcpy`, `memset`, `strcmp`).
* **Plan de ajuste:**
  * Convalidar este tema en la Semana 10, ya que responde con fidelidad al Reporte 10 de lecturas (Sivarama capítulo 17) y dota a los estudiantes de herramientas de microcódigo de alto rendimiento para manipulación masiva de buffers antes de entrar a persistencia de archivos en disco.

---

## 3. Estructura bi-sesional estándar (2 sesiones de 1.5 horas semanales)

Cada proyecto semanal de Slidev cubre exactamente dos sesiones de 90 minutos:

```
┌────────────────────────────────────────────────────────────────────────┐
│ SESIÓN 1 (90 min): Fundamentos Teóricos y Modelos Arquitectónicos      │
│ • Introducción conceptual y motivación de diseño (15 min)              │
│ • Desarrollo de arquitectura, fórmulas y diagramas de hardware (45 min) │
│ • Demostración inicial de código o resolución analítica guiada (25 min)│
│ • Síntesis y puente hacia el taller práctico (5 min)                   │
├────────────────────────────────────────────────────────────────────────┤
│ DIAPOSITIVA DIVISORIA: layout: section (Portada de Sesión 2)           │
├────────────────────────────────────────────────────────────────────────┤
│ SESIÓN 2 (90 min): Taller de Bajo Nivel y Desafíos de Consolidación     │
│ • Reactivación conceptual de conceptos de bajo nivel (10 min)          │
│ • Formulación del desafío técnico o mapa de memoria (15 min)           │
│ • Taller guiado paso a paso: trazas, código NASM/C o cálculos (50 min) │
│ • Reto de integración formativo con análisis de trampas comunes (15 min)│
└────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Cronograma maestro semana a semana (S01 a S16)

### Semana 01: Introducción a la arquitectura y organización de computadoras
* **Propósito:** Comprender los fundamentos de la máquina de Von Neumann, diferenciar entre arquitectura y organización, y dominar el modelado cuantitativo de rendimiento.
* **Sesión 1 (Teoría - 90 min):**
  * Conceptos de arquitectura frente a organización.
  * Evolución histórica de las computadoras: desde tubos de vacío hasta procesadores multinúcleo modernos.
  * Visión del programador de bajo nivel: procesador, banco de registros, espacio de direccionamiento de memoria e instrucciones.
  * Métricas de rendimiento: tiempo de ejecución, frecuencia de reloj, ciclos por instrucción (CPI), tasa de instrucciones por segundo y ley de Amdahl.
* **Sesión 2 (Práctica - 90 min):**
  * Taller de modelado de rendimiento: cálculo de tiempos de ejecución comparativos entre procesadores con distintas frecuencias y mezclas de instrucciones.
  * Ejercicios guiados de aceleración con la ley de Amdahl considerando mejoras en subsistemas específicos.
  * Desafío de consolidación: diagnóstico formativo de conceptos de programación básica y sistemas numéricos.
* **Lecturas del curso asociadas:** Stallings (capítulos 1 y 2), Sivarama (capítulos 1 y 4).
* **Propósito pedagógico:** Nivelación inicial del grupo y dominio de fórmulas de rendimiento.
* **Acción en el repositorio:** Reestructurar [S01/slides.md](file:///home/mau/Tutorias/IC3101/S01/slides.md) para añadir la portada de Sesión 2, los talleres de rendimiento y el guión oral completo.

---

### Semana 02: Infraestructura de software y sistemas numéricos
* **Propósito:** Comprender las etapas de transformación del código hasta su ejecución y dominar las representaciones posicionales de números.
* **Sesión 1 (Teoría - 90 min):**
  * Cadena de desarrollo: compilador, preprocesador, ensamblador, enlazador (*linker*), cargador (*loader*) y sistema operativo.
  * Diferencias estructurales entre código fuente, archivo objeto reubicable y archivo binario ejecutable.
  * Sistemas posicionales de numeración: binario, octal, decimal y hexadecimal.
  * Conversión de enteros y partes fraccionarias entre bases.
* **Sesión 2 (Práctica - 90 min):**
  * Taller de conversiones numéricas manuales rápidas mediante agrupación de bits y potencias de dos.
  * Guía de configuración del entorno Linux con NASM, GDB, GCC y herramientas de 32 bits.
  * Desafío de consolidación: ensamblado, enlazado manual con `ld` e inspección del encabezado ELF del primer binario en consola.
* **Lecturas del curso asociadas:** Stallings (capítulo 9), Sivarama (capítulos 5 al 8) correspondiente al Reporte de Lectura 5.
* **Propósito pedagógico:** Asegurar que todos los estudiantes cuenten con un entorno funcional de desarrollo en Linux y fluidez en bases numéricas.
* **Acción en el repositorio:** Pendiente de crear en `S02/`.

---

### Semana 03: Enteros, complemento a dos y unidad aritmético lógica (ALU)
* **Propósito:** Analizar la representación binaria con signo y diseñar a nivel conceptual la arquitectura interna de la ALU.
* **Sesión 1 (Teoría - 90 min):**
  * Representación de enteros: magnitud con signo frente a complemento a dos.
  * Rango simétrico y asimétrico, algoritmo de negación y extensión de signo con preservación de valor.
  * Distinción fundamental entre acarreo de salida (*carry*) y desbordamiento aritmético (*overflow*).
  * Arquitectura funcional de la ALU: sumador/restador binario, compuertas lógicas y desplazadores lógicos y aritméticos.
* **Sesión 2 (Práctica - 90 min):**
  * Taller de resolución manual de operaciones aritméticas en 8, 16 y 32 bits con identificación rigurosa de banderas: cero (ZF), signo (SF), desbordamiento (OF) y acarreo (CF).
  * Verificación en código ensamblador de las instrucciones `add`, `sub`, `neg` y comprobación en vivo de banderas en GDB.
  * Desafío de consolidación: problemas de análisis de banderas en condiciones de frontera y desbordamiento.
* **Lecturas del curso asociadas:** Stallings (capítulo 10, secciones 10.1 a 10.3), Reporte de Lectura 3.
* **Propósito pedagógico:** Fortalecer el razonamiento a nivel de bits y el entendimiento de las banderas del procesador.
* **Acción en el repositorio:** Pendiente de crear en `S03/`.

---

### Semana 04: Multiplicación, división entera y punto flotante (IEEE 754)
* **Propósito:** Dominar los algoritmos de multiplicación y división en hardware, junto con el estándar IEEE 754 de coma flotante.
* **Sesión 1 (Teoría - 90 min):**
  * Multiplicación de enteros sin signo mediante sumas y desplazamientos sucesivos.
  * Algoritmo de Booth para enteros en complemento a dos mediante recodificación de bits contiguos.
  * Algoritmos de división entera: método restaurador frente a división no restauradora.
  * Estructura matemática del estándar IEEE 754: bit de signo, exponente con sesgo y mantisa con bit implícito.
  * Formatos de precisión simple (32 bits) y doble precisión (64 bits).
  * Valores especiales: ceros con signo, infinitos, números desnormalizados y NaN.
* **Sesión 2 (Práctica - 90 min):**
  * Taller de aplicación paso a paso del algoritmo de Booth utilizando tablas de iteración manual.
  * Conversión manual bidireccional entre números decimales reales y representación hexadecimal IEEE 754.
  * Desafío de consolidación: análisis cuantitativo de anomalías numéricas (pérdida de precisión, cancelación y absorción).
* **Lecturas del curso asociadas:** Stallings (capítulo 10, secciones 10.4 y 10.5).
* **Propósito pedagógico:** Consolidación exhaustiva del bloque de aritmética digital y punto flotante.
* **Acción en el repositorio:** Implementada en [S04/slides.md](file:///home/mau/Tutorias/IC3101/S04/slides.md).

---

### Semana 05: Introducción al lenguaje C y ensamblador x86
* **Propósito:** Conectar el modelo de compilación de programas en C con el mapa de memoria y los registros del procesador x86.
* **Sesión 1 (Teoría - 90 min):**
  * Abstracción de C frente a visibilidad directa del procesador.
  * Arquitectura IA-32: registros generales (EAX, EBX, ECX, EDX, ESI, EDI, ESP, EBP) y sus divisiones de 16 y 8 bits.
  * Secciones de memoria del proceso: datos inicializados (`.data`), variables sin inicializar (`.bss`), constantes (`.rodata`) y código de máquina (`.text`).
  * Directivas básicas de asignación: `db`, `dw`, `dd`, `resb`, `resd`.
* **Sesión 2 (Práctica - 90 min):**
  * Taller de traducción de asignaciones simples y declaraciones de C a instrucciones `mov`, `add` y `sub` en NASM.
  * Taller de depuración en consola con GDB: puntos de interrupción con `break`, avance con `stepi`, inspección de registros con `info registers` y examen de memoria con `x/x`.
  * Desafío de consolidación: trazado manual de variables en memoria y verificación en el depurador.
* **Lecturas del curso asociadas:** Sivarama (capítulos 9 y 10), Libro C (capítulos 1 y 2), Reporte de Lectura 6.
* **Propósito pedagógico:** Puente conceptual sólido entre programación estructurada en C y código en ensamblador.
* **Acción en el repositorio:** Implementada en [S05/slides.md](file:///home/mau/Tutorias/IC3101/S05/slides.md).

---

### Semana 06: Formatos de instrucción y modos de direccionamiento
* **Propósito:** Comprender la codificación binaria de instrucciones y dominar el cálculo de direcciones efectivas en memoria.
* **Sesión 1 (Teoría - 90 min):**
  * Anatomía de las instrucciones en máquinas CISC y RISC: opcode, especificadores de registros y modificadores.
  * Modos de direccionamiento en arquitectura x86:
    * Inmediato y por registro.
    * Directo en memoria (etiquetas absolutas).
    * Indirecto por registro (punteros).
    * Base más desplazamiento.
    * Base más índice escalado más desplazamiento: `[base + index * scale + disp]`.
* **Sesión 2 (Práctica - 90 min):**
  * Taller de traducción de expresiones en C que involucran arreglos unidimensionales y bidimensionales utilizando direccionamiento indexado escalado en x86.
  * Decodificación manual de instrucciones máquina a representación binaria.
  * Desafío de consolidación: problemas de cálculo de dirección física efectiva ante diferentes combinaciones de registros base e índice.
* **Lecturas del curso asociadas:** Sivarama (capítulos 11 y 12), Libro C (capítulos 3 y 4), Reporte de Lectura 7.
* **Propósito pedagógico:** Dominar el acceso eficiente a memoria y estructuras de datos en bajo nivel.
* **Acción en el repositorio:** Pendiente de crear en `S06/`.

---

### Semana 07: Operaciones aritméticas, lógicas y estructuras de control de flujo
* **Propósito:** Implementar bifurcaciones condicionales, ciclos repetitivos y operaciones lógicas a nivel de bits.
* **Sesión 1 (Teoría - 90 min):**
  * Comparaciones y pruebas: instrucción `cmp` (resta que solo altera banderas) e instrucción `test` (operación AND que solo altera banderas).
  * Saltos incondicionales (`jmp`).
  * Saltos condicionales para enteros sin signo (`je`, `jne`, `ja`, `jae`, `jb`, `jbe`).
  * Saltos condicionales para enteros con signo (`jg`, `jge`, `jl`, `jle`).
  * Operaciones lógicas a nivel de bits (`and`, `or`, `xor`, `not`) y operaciones de desplazamiento y rotación (`shl`, `shr`, `sar`, `rol`, `ror`).
* **Sesión 2 (Práctica - 90 min):**
  * Taller de construcción de estructuras de control clásicas: `if`, `if-else`, `switch-case` y bucles `while`, `do-while` y `for` en ensamblador.
  * Uso y análisis del costo de la instrucción de ciclo `loop` frente a la alternativa `dec ecx` + `jnz`.
  * Desafío de consolidación: algoritmo de ordenamiento de burbuja o búsqueda lineal sobre un arreglo contiguo en memoria.
* **Lecturas del curso asociadas:** Sivarama (capítulos 13 al 16), Libro C (capítulo 5), Reportes de Lectura 8 y 9.
* **Propósito pedagógico:** Autonomía completa para codificar algoritmos iterativos y decisiones lógicas en ensamblador.
* **Acción en el repositorio:** Pendiente de crear en `S07/`.

---

### Semana 08: Rutinas, pila (*stack*), marco de pila y consolidación de medio término
* **Propósito:** Dominar la mecánica de subrutinas, la convención de llamadas cdecl, la pila de ejecución y afianzar las bases de bajo nivel.
* **Sesión 1 (Teoría - 90 min):**
  * La estructura de la pila: puntero ESP, operaciones `push` y `pop`.
  * Mecánica de llamada y retorno: instrucciones `call` y `ret`.
  * Convención de llamadas estándar en Linux x86 (*cdecl*): paso de argumentos por la pila en orden inverso, valor de retorno en EAX, registros preservados por llamador (*caller-saved*) frente a la función (*callee-saved*).
  * Construcción y desmontaje del marco de pila (*stack frame*): uso del puntero base EBP, reserva de variables locales con `sub esp, N` y desapilado limpio con `leave` o `mov esp, ebp` + `pop ebp`.
  * Subrutinas recursivas y gestión de casos base.
* **Sesión 2 (Práctica - 90 min):**
  * Taller guiado: implementación de funciones recursivas (cálculo de factorial y serie de Fibonacci) en NASM con trazado de la pila en memoria.
  * Desafío de consolidación integral: reto práctico intensivo que combina aritmética, modos de direccionamiento indexados, saltos condicionales y marcos de pila con variables locales.
* **Lecturas del curso asociadas:** Sivarama (capítulos 15, 16 y 19), Libro C (capítulo 6).
* **Propósito pedagógico:** Consolidación de la primera mitad del curso, dotando a los estudiantes de seguridad técnica para afrontar evaluaciones de medio término en sus respectivos grupos.
* **Acción en el repositorio:** Pendiente de crear en `S08/`.

---

### Semana 09: Llamadas al sistema operativo e interacción con el núcleo
* **Propósito:** Comprender la frontera entre modo usuario y modo núcleo, ejecutando operaciones de entrada y salida mediante interrupciones de software.
* **Sesión 1 (Teoría - 90 min):**
  * Modelo de anillos de protección en x86: modo usuario (anillo 3) frente a modo núcleo (anillo 0).
  * Mecanismo de interrupciones de software y tabla de descriptores de interrupción (IDT).
  * Llamada al sistema mediante `int 0x80`: convención de registros en Linux x86 (número de servicio en EAX, argumentos en EBX, ECX, EDX, ESI, EDI).
  * Descriptores de archivo estándar en POSIX: entrada estándar (`0 = stdin`), salida estándar (`1 = stdout`) y error estándar (`2 = stderr`).
  * Llamadas fundamentales: `sys_exit` (1), `sys_read` (3) y `sys_write` (4).
* **Sesión 2 (Práctica - 90 min):**
  * Taller de entrada y salida interactiva por consola: lectura de cadenas desde teclado con `sys_read` hacia un buffer reservado en `.bss`.
  * Tratamiento del carácter de salto de línea (`0x0A`) y conversión a cadena terminada en nulo (`\0`).
  * Emisión de mensajes y cadenas formateadas con `sys_write`.
  * Desafío de consolidación: programa interactivo con validación de entradas numéricas y control de desbordamiento de buffer.
* **Lecturas del curso asociadas:** Sivarama (capítulos 17 y 18), Libro C (capítulo 7), Reporte de Lectura 10.
* **Propósito pedagógico:** Capacitar al estudiante para comunicarse directamente con el núcleo del sistema operativo sin dependencias de alto nivel.
* **Acción en el repositorio:** Implementada en [S09/slides.md](file:///home/mau/Tutorias/IC3101/S09/slides.md).

---

### Semana 10: Procesamiento de cadenas y manipulación masiva de memoria
* **Propósito:** Dominar las instrucciones de bloque por hardware de la arquitectura x86 y los prefijos de repetición por microcódigo.
* **Sesión 1 (Teoría - 90 min):**
  * Formatos de cadenas en memoria: longitud fija frente a terminador centinela nulo (ASCIIZ).
  * Registros especializados para operaciones de bloque: ESI (puntero origen), EDI (puntero destino) y ECX (contador).
  * Control del sentido de recorrido en memoria: bandera de dirección (DF) e instrucciones `cld` (adelante) y `std` (atrás).
  * Instrucciones fundamentales de bloque: `movsb`/`movsd` (copiar), `stosb`/`stosd` (rellenar), `lodsb`/`lodsd` (cargar), `cmpsb`/`cmpsd` (comparar) y `scasb`/`scasd` (escanear).
  * Prefijos de repetición por hardware: repetición incondicional `rep` y repeticiones condicionadas `repe`/`repz` y `repne`/`repnz`.
* **Sesión 2 (Práctica - 90 min):**
  * Taller de implementación en NASM de las funciones estándar de memoria de C:
    * `strlen`: búsqueda del byte nulo mediante `repne scasb`.
    * `memcpy` y `strcpy`: copia optimizada por bloques de 32 bits con `rep movsd` y residuo con `movsb`.
    * `memset`: inicialización inmediata de buffers con `rep stosb`.
    * `strcmp`: comparación léxica rápida con `repe cmpsb`.
  * Desafío de consolidación: comparación cuantitativa de ciclos de CPU entre bucles manuales de software frente a instrucciones de bloque por hardware.
* **Lecturas del curso asociadas:** Sivarama (capítulos 17 y 18), Reporte de Lectura 10.
* **Propósito pedagógico:** Dominio de rutinas optimizadas de manipulación masiva de memoria indispensables para procesamiento de datos.
* **Acción en el repositorio:** Implementada en [S10/slides.md](file:///home/mau/Tutorias/IC3101/S10/slides.md).

---

### Semana 11: Manejo de archivos en disco, macros y modularización (C con NASM)
* **Propósito:** Implementar la persistencia de datos en disco mediante llamadas al sistema, dominar el preprocesador de macros y construir aplicaciones híbridas C + NASM.
* **Sesión 1 (Teoría - 90 min):**
  * Persistencia en el sistema de archivos en Linux:
    * Llamadas al sistema para archivos físicos: `sys_open` (syscall 5), `sys_creat` (syscall 8), `sys_close` (syscall 6) y `sys_lseek` (syscall 19).
    * Modos de acceso y banderas: solo lectura (`O_RDONLY = 0`), solo escritura (`O_WRONLY = 1`), lectura/escritura (`O_RDWR = 2`), creación y truncado (`O_CREAT | O_TRUNC`).
    * Permisos de archivo en formato octal Unix (ej. `0644`).
  * El preprocesador de NASM: constantes con `%define`, inclusión modular con `%include` y creación de macros multiparámetro con `%macro` y `%endmacro`.
  * Modularización y enlace separado: exportación con `global` e importación con `extern`.
  * Integración híbrida C y ensamblador: llamadas a subrutinas NASM desde un programa principal en C y utilización de funciones de la biblioteca estándar (`printf`, `fopen`) desde ensamblador.
* **Sesión 2 (Práctica - 90 min):**
  * Taller 1: Creación de archivo en disco con `sys_creat`, escritura de datos desde un buffer con `sys_write` y cierre seguro con `sys_close`.
  * Taller 2: Apertura de archivo existente con `sys_open`, lectura secuencial en bloques con `sys_read` y procesamiento de su contenido en memoria.
  * Taller 3: Proyecto modular híbrido compilado con `nasm -f elf32` y enlazado con `gcc -m32` respetando la convención cdecl.
  * Desafío de consolidación: diseño e implementación de un módulo de persistencia y parseo de registros estructurados en disco.
* **Lecturas del curso asociadas:** Sivarama (capítulos 19, 20 y 21) correspondiente a los Reportes de Lectura 11 y 12; Libro C (capítulo 8).
* **Propósito pedagógico:** Capacitación integral en persistencia, modularidad y ensamblador híbrido, dotando a los estudiantes de las herramientas para abordar proyectos de programación complejos de cualquier profesor.
* **Acción en el repositorio:** Pendiente de crear en `S11/`.

---

### Semana 12: Arquitectura del procesador, segmentación de cauce (*pipeline*) y riesgos
* **Propósito:** Analizar la microarquitectura interna del procesador, el paralelismo temporal en la ejecución de instrucciones y las técnicas para mitigar riesgos.
* **Sesión 1 (Teoría - 90 min):**
  * Principio de segmentación de cauce (*pipelining*): paralelismo temporal en hardware.
  * Las cinco etapas clásicas: búsqueda (IF), decodificación y lectura de registros (ID), ejecución y cálculo de direcciones (EX), acceso a memoria (MEM) y escritura en registros (WB).
  * Rendimiento ideal: cálculo de ganancia de velocidad (*speedup*) y ciclos por instrucción en régimen permanente.
  * Clasificación rigurosa de riesgos de cauce (*hazards*):
    * Riesgos estructurales: colisión por recursos de hardware compartidos.
    * Riesgos de datos: dependencias RAW (lectura tras escritura), WAR y WAW.
    * Mecanismos de resolución: inserción de burbujas/paradas de reloj (*stalls*) frente a reenvío directo de datos (*forwarding / bypass*).
    * Riesgos de control: penalización por saltos y técnicas básicas de predicción de bifurcaciones.
  * Filosofías de diseño: comparación arquitectónica cuantitativa entre RISC y CISC.
* **Sesión 2 (Práctica - 90 min):**
  * Taller de diagramación temporal de cauce: llenado de tablas de etapas frente a ciclos de reloj.
  * Cálculo cuantitativo de CPI real y ciclos totales ante dependencias de datos con y sin circuitos de reenvío.
  * Desafío de consolidación: reordenamiento manual de fragmentos de código ensamblador por parte del compilador para eliminar paradas de cauce sin alterar la semántica del programa.
* **Lecturas del curso asociadas:** Stallings (capítulos 14, 15 y 16).
* **Propósito pedagógico:** Comprensión profunda de la microarquitectura del procesador y las optimizaciones de ejecución en hardware.
* **Acción en el repositorio:** Pendiente de crear en `S12/`.

---

### Semana 13: Entrada y salida a nivel de hardware y buses de interconexión
* **Propósito:** Comprender la interacción física entre la CPU, la memoria y los controladores de periféricos a través de buses.
* **Sesión 1 (Teoría - 90 min):**
  * Arquitectura de entrada/salida de hardware: módulos de E/S, registros de datos, estado y control.
  * Técnicas de sincronización y transferencia:
    * E/S programada por sondeo periódico (*polling*).
    * E/S controlada por interrupciones de hardware: líneas IRQ, controlador programable de interrupciones (PIC 8259A / APIC) y rutina de servicio de interrupción (ISR).
    * Acceso directo a memoria (DMA): controlador DMA, modo ráfaga y robo de ciclos (*cycle stealing*).
  * Mapeo de espacios: E/S mapeada en memoria (*Memory-Mapped I/O*) frente a E/S aislada por puertos (*Port-Mapped I/O* con instrucciones `in` y `out`).
  * Jerarquía de buses de comunicación: buses del sistema, PCIe, interfaces serie de alta velocidad y protocolos punto a punto.
* **Sesión 2 (Práctica - 90 min):**
  * Taller de cálculo cuantitativo de sobrecarga de CPU: porcentaje de tiempo de procesamiento absorbido por sondeo continuo frente a atención de interrupciones para distintos anchos de banda de periféricos.
  * Cálculo de ciclos requeridos en transferencias masivas de bloques mediante controlador DMA.
  * Desafío de consolidación: problemas cuantitativos de dimensionamiento de buses y tiempos de transferencia de datos.
* **Lecturas del curso asociadas:** Stallings (capítulos 3 y 7).
* **Propósito pedagógico:** Dominar los mecanismos físicos de sincronización y transferencia de datos entre el procesador y el mundo exterior.
* **Acción en el repositorio:** Pendiente de crear en `S13/`.

---

### Semana 14: Jerarquía de memoria y memorias caché
* **Propósito:** Modelar cuantitativamente el impacto de la jerarquía de memoria en el rendimiento y calcular mapeos y tasas de fallos.
* **Sesión 1 (Teoría - 90 min):**
  * La jerarquía de memoria: registros, cachés L1, L2, L3, memoria principal DRAM y almacenamiento masivo.
  * Principios físicos determinantes: localidad temporal y localidad espacial.
  * Anatomía de una línea de caché: etiqueta (*tag*), índice (*set / index*), desplazamiento de byte (*offset*) y bits de estado (validez, suciedad).
  * Funciones de mapeo:
    * Mapeo directo (*Direct Mapped*).
    * Totalmente asociativo (*Fully Associative*).
    * Asociativo por conjuntos de $N$ vías (*N-Way Set Associative*).
  * Políticas de reemplazo de líneas: LRU (menos recientemente usada), FIFO y aleatoria.
  * Políticas de escritura: escritura directa (*Write-Through*) frente a copia posterior (*Write-Back*), y asignación en escritura (*Write-Allocate* frente a *No-Write-Allocate*).
* **Sesión 2 (Práctica - 90 min):**
  * Taller de descomposición de direcciones físicas de memoria en campos de Etiqueta, Conjunto y Desplazamiento.
  * Trazado paso a paso de secuencias de accesos a memoria para clasificar aciertos (*hits*) y fallos (*misses*) de tipo obligatorio, capacidad y conflicto.
  * Cálculo del tiempo de acceso promedio a memoria (AMAT).
  * Desafío de consolidación: análisis de impacto en la tasa de fallos de caché al recorrer matrices multidimensionales por filas frente a columnas.
* **Lecturas del curso asociadas:** Stallings (capítulo 4, apéndice 4A, capítulo 5).
* **Propósito pedagógico:** Dominio analítico riguroso de memoria caché, tema de alta recurrencia y dificultad en evaluaciones numéricas de cualquier grupo.
* **Acción en el repositorio:** Pendiente de crear en `S14/`.

---

### Semana 15: Multiprocesadores, coherencia de caché y sistemas empotrados
* **Propósito:** Estudiar organizaciones paralelas de cómputo, el protocolo de coherencia de caché MESI y las características de sistemas empotrados.
* **Sesión 1 (Teoría - 90 min):**
  * Taxonomía de Flynn: arquitecturas SISD, SIMD, MISD y MIMD.
  * Arquitecturas de memoria compartida: multiprocesamiento simétrico (SMP) frente a acceso no uniforme a memoria (NUMA).
  * Procesadores multinúcleo y subprocesamiento simultáneo por hardware (*Hyper-Threading / SMT*).
  * El problema de la coherencia de caché: técnicas basadas en espionaje de bus (*snooping*) frente a directorios.
  * El protocolo de coherencia MESI: definición de estados Modificado (M), Exclusivo (E), Compartido (S) e Inválido (I), y diagrama de transiciones ante lecturas y escrituras locales y del bus.
  * Instrucciones atómicas para sincronización hardware (`xchg`, `lock cmpxchg`).
  * Fundamentos de sistemas empotrados: microcontroladores, arquitectura ARM y sistemas en un chip (SoC).
* **Sesión 2 (Práctica - 90 min):**
  * Taller de seguimiento de estados en protocolo MESI: llenado de tablas de transición de estado y contenido de caché ante secuencias de accesos concurrentes de múltiples procesadores sobre una misma línea.
  * Análisis de condiciones de carrera a nivel de hardware y diseño de secciones críticas con primitivas atómicas.
  * Desafío de consolidación: problemas de análisis comparativo de rendimiento entre SMP y NUMA bajo cargas de trabajo reales.
* **Lecturas del curso asociadas:** Stallings (capítulos 17 y 18).
* **Propósito pedagógico:** Comprensión de los retos de concurrencia y consistencia de datos en hardware multiprocesador moderno.
* **Acción en el repositorio:** Pendiente de crear en `S15/`.

---

### Semana 16: Repaso integrador final y consolidación integral del curso
* **Propósito:** Articular todos los ejes temáticos del curso de forma transversal y consolidar las habilidades analíticas para el cierre de semestre.
* **Sesión 1 (Teoría - 90 min):**
  * Síntesis transversal de la arquitectura de computadoras:
    * De los sistemas numéricos y representación de datos a la ALU.
    * Del código en C y ensamblador x86 al funcionamiento de la pila, subrutinas y llamadas al sistema operativo.
    * De la ejecución secuencial de instrucciones al paralelismo temporal en cauce (*pipeline*).
    * De los controladores de entrada/salida y DMA a la jerarquía de memoria caché.
    * De los procesadores de un solo núcleo a los sistemas multiprocesador y protocolos de coherencia.
  * Análisis de errores conceptuales típicos y trampas comunes de razonamiento en evaluaciones de fin de curso.
* **Sesión 2 (Práctica - 90 min):**
  * Taller intensivo de consolidación global con problemas avanzados representativos de cierre de curso:
    1. Reto numérico: resta en complemento a dos con inspección de banderas y conversión bidireccional en formato IEEE 754.
    2. Reto de ensamblador: trazado de código con ciclos, arreglos, cadenas o llamadas al sistema, deduciendo el estado final de registros y memoria.
    3. Reto de microarquitectura: trazado de cauce con dependencias de datos, paradas de reloj e inserción de circuitos de reenvío (*forwarding*).
    4. Reto de memoria caché: descomposición de direcciones físicas y cálculo de tiempo de acceso promedio (AMAT).
    5. Reto de sistemas: seguimiento del protocolo MESI ante accesos paralelos y cálculo de sobrecarga de CPU en transferencias de E/S.
  * Discusión guiada de estrategias de resolución analítica y sesión de consultas abiertas.
* **Lecturas del curso asociadas:** Repaso integral de toda la bibliografía del curso (Stallings, Sivarama, Libro C).
* **Propósito pedagógico:** Cierre integral del semestre con dominio transversal para afrontar con éxito cualquier evaluación final.
* **Acción en el repositorio:** Pendiente de crear en `S16/`.

---

## 5. Matriz de correspondencia global (S01 a S16)

| Semana | Eje temático principal | Sesión 1 (Teoría - 90 min) | Sesión 2 (Práctica / Reto - 90 min) | Lecturas recomendadas | Propósito pedagógico | Estado en repo |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **S01** | Fundamentos y rendimiento | Arquitectura vs organización, evolución, CPI y Amdahl | Taller de cálculo de rendimiento y métricas | Stallings 1, 2; Sivarama 1, 4 (Rep. 1, 4) | Diagnóstico formativo inicial | Por reestructurar |
| **S02** | Cadena de desarrollo y bases | Compilador, ensamblador, enlazador, binario y hex | Conversiones manuales, entorno Linux y NASM | Stallings 9; Sivarama 5 a 8 (Rep. 2, 5) | Configuración de entorno Linux | Pendiente |
| **S03** | Enteros y unidad aritmética | Complemento a dos, rangos, arquitectura ALU | Aritmética binaria, banderas ZF/SF/OF/CF, GDB | Stallings 10.1 a 10.3 (Rep. 3) | Acompañamiento en aritmética | Pendiente |
| **S04** | Aritmética avanzada y reales | Booth, división no restauradora, IEEE 754 | Ejercicios de Booth, conversión flotante y anomalías | Stallings 10.4 y 10.5 | Cierre de bloque de aritmética | Implementado |
| **S05** | Introducción a C y x86 | Registros IA-32, mapa de memoria, secciones | Asignaciones C a NASM, `mov`/`add`/`sub`, GDB | Sivarama 9, 10; Libro C 1, 2 (Rep. 6) | Inicio de programación en bajo nivel | Implementado |
| **S06** | Formatos y direccionamiento | Opcode, operandos, modos de direccionamiento | Cálculo de dirección efectiva `[base+idx*esc+disp]` | Sivarama 11, 12; Libro C 3, 4 (Rep. 7) | Dominio de arreglos y memoria | Pendiente |
| **S07** | Aritmética, lógica y saltos | `cmp`, `test`, saltos condicionales, rotaciones | `if-else`, bucles `while`/`for`, ordenamiento | Sivarama 13 a 16; Libro C 5 (Rep. 8, 9) | Consolidación de flujo de control | Pendiente |
| **S08** | Pila, subrutinas y medio término | Pila, `call`/`ret`, convención cdecl, stack frame | Subrutinas recursivas y reto de medio término | Sivarama 15, 16, 19; Libro C 6 | **Refuerzo integral de medio término** | Pendiente |
| **S09** | Llamadas al sistema operativo | Modo dual, `int 0x80`, descriptores POSIX | Captura en buffer de teclado y salida en consola | Sivarama 17, 18; Libro C 7 (Rep. 10) | Interacción directa con el SO | Implementado |
| **S10** | Cadenas e instrucciones bloque | `movs`, `stos`, `lods`, `cmps`, `scas`, prefijos `rep` | `strlen`, `memcpy`, `strcpy`, `memset`, `strcmp` | Sivarama 17, 18 (Rep. 10) | Optimización masiva de memoria | Implementado |
| **S11** | **Archivos en disco y módulos** | **`sys_open`, `sys_creat`, `sys_close`, macros, C+NASM** | **Persistencia en disco y proyectos híbridos C+NASM** | **Sivarama 19 a 21 (Rep. 11, 12); Libro C 8** | **Soporte técnico para proyectos** | Pendiente |
| **S12** | Segmentación (*pipeline*) | Etapas IF-ID-EX-MEM-WB, riesgos de datos/control | Trazas de cauce, paradas, reenvío, reordenamiento | Stallings 14, 15, 16 | Análisis de microarquitectura | Pendiente |
| **S13** | Entrada y salida de hardware | Módulos E/S, polling vs interrupciones IRQ, DMA | Cálculo de sobrecarga de CPU y ancho de banda | Stallings 3, 7 | Acompañamiento en interfaces E/S | Pendiente |
| **S14** | Jerarquía y memorias caché | Localidad, mapeo directo/asociativo, reemplazo | Cálculo de campos de dirección, fallos y AMAT | Stallings 4, 5 | **Refuerzo cuantitativo de caché** | Pendiente |
| **S15** | Multiprocesadores y embebidos | SMP, NUMA, multicore, protocolo MESI, ARM | Trazado de estados MESI y condiciones de carrera | Stallings 17, 18 | Sistemas paralelos y embebidos | Pendiente |
| **S16** | Repaso integrador final | Articulación transversal de todo el programa | Desafío global con problemas de alta exigencia | Toda la bibliografía del semestre | **Preparación para evaluaciones finales** | Pendiente |

---

## 6. Hoja de ruta para el material de tutoría

1. **Reestructuración de la Semana 01 ([S01/slides.md](file:///home/mau/Tutorias/IC3101/S01/slides.md)):** Transformarla al formato bi-sesional formal, separando la teoría introductoria del taller cuantitativo de CPI y ley de Amdahl con su correspondiente portada divisoria y guión oral.
2. **Desarrollo prioritario de la Semana 11 (`S11/`):** Construir la presentación bi-sesional para el manejo de archivos en disco (`sys_open`, `sys_creat`, `sys_read`, `sys_write`, `sys_close`), macros de preensamblado y modularización híbrida C con NASM, dotando a los estudiantes de herramientas universales para cualquier proyecto.
3. **Construcción de las semanas pendientes del Bloque 1 (`S02/`, `S03/`, `S06/`, `S07/`, `S08/`):** Producir las presentaciones y guiones correspondientes con retos de consolidación modular.
4. **Construcción de las semanas de arquitectura de hardware y sistemas (`S12/` a `S16/`):** Desarrollar las presentaciones bi-sesionales para segmentación de cauce, E/S física, jerarquía de cachés, protocolo MESI y el taller integrador final.
