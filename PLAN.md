Tomé como base el programa oficial: el curso combina **programación en ensamblador** con conceptos generales de arquitectura, y recomienda impartir ambos temas de forma **intercalada**, no completamente por bloques. También contempla evaluaciones alrededor de las semanas 8 y 16. 

Este plan funciona bien para una tutoría semanal de 2–3 horas. En cada sesión procura usar esta estructura: **30–45 min de teoría + 60–90 min de ejercicios/guiados en ensamblador + 15 min de repaso o quiz corto**.

| Semana | Tema principal                                         | Qué enseñar y practicar                                                                                                                                                                                                                                                                                                                                                   |
| ------ | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1**  | Introducción a arquitectura de computadoras            | Diferencia entre **arquitectura** y **organización**. Repaso histórico: de computadoras tempranas a procesadores modernos. Qué ve un programador de bajo nivel: CPU, registros, memoria e instrucciones. Introduce rendimiento: tiempo de ejecución, frecuencia, CPI e instrucciones por segundo. Haz un diagnóstico corto de binario, hexadecimal y programación básica. |
| **2**  | Infraestructura de software + sistemas numéricos       | Qué hacen el **ensamblador, linker, loader y sistema operativo**. Diferencia entre código fuente, objeto y ejecutable. Repaso de binario, decimal, hexadecimal y conversiones. Práctica: convertir números y reconocer cómo se almacenan en memoria.                                                                                                                      |
| **3**  | Enteros, complemento a dos y ALU                       | Enteros con y sin signo, rango de valores, overflow y complemento a dos. Explica el funcionamiento básico de una **ALU**: suma, resta, AND, OR, XOR, NOT y desplazamientos. Práctica: resolver operaciones binarias y detectar overflow.                                                                                                                                  |
| **4**  | Multiplicación, división y punto flotante              | Cómo se realizan multiplicación y división a nivel de hardware. Introducción a IEEE 754: signo, exponente, mantisa, errores de precisión y aproximaciones. Práctica: representar números sencillos en punto flotante y analizar errores. Deja la **Tarea 1**: ejercicios de representación numérica y ALU.                                                                |
| **5**  | Introducción al lenguaje ensamblador                   | Arquitectura elegida para las tutorías: idealmente ARM, MIPS, RISC-V o x86, según use el curso. Registros, memoria, instrucciones, etiquetas, comentarios y estructura básica de un programa. Práctica: programas que muevan datos entre registros y memoria.                                                                                                             |
| **6**  | Formatos de instrucción y modos de direccionamiento    | Campos de una instrucción: opcode, registros, inmediatos y desplazamientos. Modos de direccionamiento: inmediato, directo, indirecto, por registro, indexado y relativo. Práctica: traducir instrucciones simples entre pseudocódigo, ensamblador y lenguaje máquina.                                                                                                     |
| **7**  | Operaciones aritméticas y flujo de control             | Instrucciones aritméticas y lógicas. Banderas o flags. Comparaciones, saltos condicionales e incondicionales. Práctica: construir `if`, `if-else`, `while` y `for` en ensamblador. Deja la **Tarea 2**: programa con decisiones y ciclos.                                                                                                                                 |
| **8**  | Rutinas, stack y evaluación intermedia                 | Paso de parámetros, llamadas a funciones, retorno, stack frame y registros preservados. Práctica: función que sume, encuentre máximo o calcule factorial. Después realiza un **repaso estructurado y simulacro de examen** de los temas de semanas 1–7.                                                                                                                   |
| **9**  | Ensamblaje, desensamblaje y directivas                 | Proceso de ensamblaje y desensamblaje. Directivas para datos, constantes, secciones de código y memoria. Diferencia entre instrucciones y directivas. Práctica: declarar arreglos, cadenas y variables; recorrer arreglos desde ensamblador.                                                                                                                              |
| **10** | Macros, modularización, linking y loading              | Macros y preensamblaje. Archivos fuente separados, módulos objeto, símbolos externos y linking. Formatos ejecutables de forma conceptual. Práctica: dividir un programa en dos módulos y enlazarlos. Inicia el **Proyecto de ensamblador**.                                                                                                                               |
| **11** | Pipeline y riesgos                                     | Qué es pipeline y por qué mejora el rendimiento. Etapas típicas: fetch, decode, execute, memory y write-back. Riesgos estructurales, de datos y de control. Práctica: dibujar diagramas de pipeline y calcular ciclos con y sin riesgos.                                                                                                                                  |
| **12** | Predicción de saltos, RISC vs. CISC                    | Técnicas básicas de predicción de bifurcaciones. Introducción a superscalar, paralelismo a nivel de instrucción y otros modelos de alto rendimiento. Luego compara **RISC y CISC**: tamaño de instrucciones, modos de direccionamiento, microcódigo, simplicidad y rendimiento. Deja la **Tarea 3**: comparación de dos arquitecturas.                                    |
| **13** | Entrada/Salida                                         | Dispositivos de E/S, controladores, polling, interrupciones y buffers. E/S mapeada a memoria y DMA. Relación entre CPU, memoria, dispositivos y sistema operativo. Práctica: diagramar el flujo de una interrupción y comparar polling vs. interrupciones.                                                                                                                |
| **14** | Multiprocesadores y multicore                          | Diferencia entre concurrencia y paralelismo. Multiprocesadores, multicore, threads de hardware y organizaciones SMP/NUMA. Redes de interconexión. Introduce problemas de sincronización: condiciones de carrera, exclusión mutua y comunicación entre hilos.                                                                                                              |
| **15** | Jerarquía de memoria, coherencia y sistemas empotrados | Memoria compartida, cachés y protocolos de coherencia. Concepto de cache coherence y por qué aparece el problema de datos desactualizados. Luego sistemas embebidos: microcontroladores, SoC, limitaciones de energía, memoria y tiempo real. Cierra el **Proyecto de ensamblador** y deja la **Tarea 4**.                                                                |
| **16** | Repaso final y preparación de examen                   | Repaso por bloques: aritmética, ensamblador, pipeline, E/S, multiprocesadores y sistemas embebidos. Haz un examen de práctica con preguntas teóricas y ejercicios de ensamblador. Revisa errores recurrentes: complemento a dos, stack, saltos, direccionamiento, hazards y coherencia de caché.                                                                          |

### Evaluaciones sugeridas

Para que las tutorías sigan una secuencia parecida al curso, puedes organizarlo así:

* **Semana 4:** Tarea 1 — sistemas numéricos, complemento a dos y ALU.
* **Semana 7:** Tarea 2 — programa básico en ensamblador con ciclos y condicionales.
* **Semana 8:** Examen corto o simulacro de primer examen.
* **Semana 10–15:** Proyecto de ensamblador por etapas.
* **Semana 12:** Tarea 3 — pipeline, rendimiento y comparación RISC/CISC.
* **Semana 15:** Tarea 4 — E/S, multiprocesadores o sistemas embebidos.
* **Semana 16:** Simulacro final o preparación intensiva del examen final.

### Proyecto de ensamblador recomendado

Un proyecto progresivo puede ser un programa que haga análisis de datos en un arreglo:

1. Leer o definir un arreglo de enteros.
2. Calcular suma, promedio, máximo y mínimo.
3. Contar positivos, negativos y ceros.
4. Ordenar parcialmente o buscar un elemento.
5. Separar funciones en rutinas con parámetros.
6. Dividir el código en módulos y enlazarlos.
7. Documentar registros usados, stack y flujo del programa.

Así el estudiante practica casi todos los elementos del curso: aritmética, registros, memoria, ciclos, saltos, funciones, stack, directivas, módulos y linking.
