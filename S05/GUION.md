# Guión de exposición oral: Semana 05
## Introducción al lenguaje C y ensamblador x86
### IC3101: Arquitectura de computadores

Este documento compila el discurso oral del tutor para las dos sesiones de 90 minutos de la Semana 05.

---

### Diapositiva 01: Portada principal

Hola a todos. Bienvenidos a la quinta semana de tutorías de Arquitectura de Computadores.

En las semanas anteriores cubrimos los fundamentos de la representación numérica digital, los enteros en complemento a dos, el diseño de la ALU y los algoritmos de multiplicación, división y punto flotante IEEE 754.

Hoy daremos un paso trascendental en el curso al explorar la conexión directa entre el software y el hardware: estudiaremos la estructura del lenguaje C, el banco de registros de la arquitectura x86, el mapa de memoria del proceso y las instrucciones fundamentales de transferencia y aritmética en NASM.

---

### Diapositiva 02: Objetivos de la primera sesión

Antes de entrar en materia teórica, repasemos los objetivos de esta primera sesión:

[click] Primero, entenderemos cómo el compilador convierte el código en C en secuencias de instrucciones que el procesador ejecuta directamente.

[click] Segundo, estudiaremos la estructura básica de los programas tanto en C como en ensamblador NASM y sus secciones de memoria.

[click] Tercero, analizaremos el banco de registros de la arquitectura x86 y cómo se dividen en partes de 32, 16 y 8 bits.

[click] Cuarto, examinaremos la organización del mapa de memoria virtual de un proceso en Linux.

[click] Y quinto, dominaremos las instrucciones elementales de movimiento de datos y aritmética básica bajo la sintaxis Intel.

---

### Diapositiva 03: De C al hardware: compilación y modelo mental

Comencemos analizando el vínculo entre el lenguaje C y la arquitectura de la computadora.

C es considerado un lenguaje de nivel medio porque combina estructuras de control estructuradas con un modelo mental muy cercano al hardware.

[click] En el nivel medio, C provee tipos de datos con tamaño físico exacto en memoria y punteros directos sin capas de sobrecarga en tiempo de ejecución.

[click] Al descender al bajo nivel mediante el proceso de compilación, el ensamblador x86 expone directamente las instrucciones de máquina, los registros de la CPU y el bus del sistema.

[click] Observemos en este diagrama la cadena de construcción: el código en C pasa por el preprocesador, el compilador genera código ensamblador, el ensamblador produce código objeto y el enlazador genera el archivo ejecutable binario.


---

### Diapositiva 04: Anatomía de un programa en C

Analicemos la estructura de un programa estándar en lenguaje C y su correspondencia directa con los elementos del sistema.

[click] Primero, las directivas de inclusión como include stdio.h incorporan las cabeceras con los prototipos estándar antes de comenzar la compilación.

[click] Segundo, la función main establece el punto de inicio de la lógica del programa, retornando el código de estado cero al sistema operativo.

[click] Tercero, las variables declaradas con tipos como char, short o int determinan la cantidad exacta de bytes reservados en la memoria física.

[click] Y cuarto, en el bloque central observamos cómo las sentencias y expresiones combinan las variables para producir el resultado final.

---

### Diapositiva 05: Estructura y secciones en NASM

Veamos ahora cómo se estructura un programa equivalente en el ensamblador NASM.

En ensamblador no tenemos funciones automáticas ni tipos abstractos, sino secciones de memoria claramente separadas.

[click] La sección .data en las líneas 1 a 3 almacena variables cuyos valores se conocen de antemano, por lo que quedan grabadas físicamente dentro del archivo binario.

[click] La sección .bss en las líneas 5 y 6 reserva bloques de memoria que el sistema operativo asignará cuando el programa se cargue en RAM, ahorrando espacio en disco.

[click] La sección .text contiene las instrucciones ejecutables y la directiva global start que indica al enlazador dónde comienza la ejecución.

---

### Diapositiva 06: Directivas de memoria en NASM

Revisemos cómo se traduce cada tipo de dato de C a directivas concretas de NASM.

[click] En la sección data utilizamos las directivas de definición: db para un byte, dw para una palabra de dos bytes, dd para una palabra doble de cuatro bytes y dq para una palabra cuádruple de ocho bytes.

[click] En la sección bss empleamos las directivas de reserva prefijadas con res, indicando la cantidad de unidades que deseamos apartar.

[click] Adicionalmente, la directiva EQU permite definir constantes numéricas puras que el ensamblador sustituye antes de generar el código objeto.

[click] En la tabla de la derecha vemos la equivalencia exacta: un int en C de 32 bits corresponde directamente a la directiva dd en datos o resd en reserva.

---

### Diapositiva 07: Banco de registros x86

Pasemos a estudiar el corazón operativo del procesador: el banco de registros.

Los registros residen dentro de la CPU y operan a la velocidad del reloj sin incurrir en latencias de bus o memoria RAM.

[click] Los cuatro registros de propósito general principales son EAX, EBX, ECX y EDX, cada uno con roles especializados en operaciones aritméticas, bucles y llamadas al sistema.

[click] Una característica distintiva de x86 es su compatibilidad histórica: podemos acceder a partes individuales del mismo registro físico.

[click] Observemos este esquema. En una arquitectura de 64 bits tenemos RAX. Sus 32 bits inferiores forman EAX. Los 16 bits inferiores forman AX, el cual a su vez se divide en AH para el byte alto y AL para el byte bajo.

---

### Diapositiva 08: Punteros, índices y banderas

Además de los registros generales, la arquitectura dispone de punteros y banderas de condición.

[click] ESI y EDI se emplean como índices para transferencias de bloques de memoria, mientras que ESP y EBP controlan la pila de llamadas y las variables locales.

[click] El registro EIP contiene la dirección de la siguiente instrucción a decodificar por la unidad de control, avanzando automáticamente tras cada ciclo.

[click] A la derecha observamos el registro EFLAGS. Las cuatro banderas principales reflejan el resultado de operaciones aritméticas: ZF detecta resultados nulos, SF indica signo negativo, CF alerta acarreos sin signo y OF señala desbordamientos con signo.

---

### Diapositiva 09: Mapa de memoria del proceso

Comprendamos ahora dónde reside cada elemento dentro de la memoria física y virtual.

Cuando Linux ejecuta un programa, le asigna un espacio de direcciones privado y protegido.

[click] En las direcciones más altas se ubica la pila, que almacena variables locales y parámetros, creciendo hacia abajo a medida que se invocan funciones.

[click] El montículo se sitúa en la zona intermedia y crece hacia arriba cuando solicitamos memoria dinámica mediante malloc o la llamada brk.

[click] En la base encontramos las secciones estáticas: BSS, datos inicializados y el segmento de texto con las instrucciones de solo lectura.

[click] Este diseño ordenado evita colisiones de memoria y optimiza el uso de la memoria virtual en el sistema operativo.

---

### Diapositiva 10: Transferencia de datos: MOV

Entremos al estudio de la instrucción más utilizada en la arquitectura x86: la instrucción MOV.

[click] Bajo la sintaxis Intel, el primer operando representa el destino y el segundo el origen, operando igual que una asignación simple en C.

[click] La primera regla obligatoria es que ambos operandos deben compartir la misma dimensión: no podemos mezclar un registro de 32 bits con uno de 16 bits.

[click] La segunda regla crucial del hardware x86 es que no existe ninguna instrucción que copie directamente de una celda de memoria a otra en un solo paso.

[click] En el código de la derecha vemos las formas válidas y los errores típicos. Si deseamos copiar entre dos variables de memoria, estamos obligados a cargar primero el dato en un registro intermedio.

---

### Diapositiva 11: Aritmética elemental en x86

Veamos ahora las operaciones aritméticas básicas que ofrece la ALU de x86.

[click] ADD y SUB realizan sumas y restas sobre el destino, depositando el resultado en él y actualizando todas las banderas de condición.

[click] Las instrucciones unarias INC y DEC suman o restan una unidad de forma compacta. Un detalle muy importante para exámenes: INC y DEC no modifican la bandera de acarreo CF.

[click] La instrucción NEG invierte el signo matemático calculando el complemento a dos mediante una resta implícita de cero menos el operando.

[click] En la tabla resumen podemos apreciar la correspondencia con las expresiones habituales en C y el conjunto de banderas que resultan afectadas tras su ejecución.

---

### Diapositiva 12: Síntesis de la primera sesión

Con esto concluimos la primera sesión teórica. Hemos cubierto la relación entre C y ensamblador, la organización de secciones, el banco de registros y las reglas fundamentales de transferencia y aritmética.

[click] Les dejo esta pregunta para reflexionar antes de pasar al taller práctico: ¿por qué la arquitectura no permite sumar directamente dos variables de memoria y cómo comprobaremos el cambio con el depurador?

---

### Diapositiva 13: Sesión 02: Práctica guiada

¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de la estructura de programas, el banco de registros y las instrucciones elementales, dedicaremos esta jornada completa a la programación práctica, traducción guiada de sentencias de C a NASM y depuración en vivo con GDB.

---

### Diapositiva 14: Objetivos de la segunda sesión

Antes de iniciar los ejercicios prácticos, repasemos los objetivos de esta segunda jornada:

[click] Primero, crearemos nuestro primer programa ejecutable autónomo con terminación limpia mediante llamadas al sistema.

[click] Segundo, traduciremos expresiones y asignaciones de lenguaje C a instrucciones optimizadas en ensamblador.

[click] Tercero, aplicaremos operadores unarios y la instrucción de intercambio de registros XCHG.

[click] Cuarto, dominaremos el flujo de herramientas en Linux con NASM, LD y GCC.

[click] Y quinto, utilizaremos el depurador GDB para inspeccionar el estado de la CPU y la memoria en tiempo real.

---

### Diapositiva 15: Práctica: Programa mínimo en NASM

Comencemos con nuestro primer taller práctico construyendo el programa ejecutable mínimo en NASM.

[click] Para que el enlazador reconozca el inicio del código binario, definimos la directiva global start.

[click] Al finalizar nuestras operaciones, debemos invocar explícitamente el servicio sys_exit colocando el número 1 en EAX y el código de retorno en EBX.

[click] Si olvidamos esta llamada, el contador de programa EIP continuará avanzando sobre memoria no asignada y Linux abortará el proceso con un fallo de segmentación.

[click] En el código de la derecha observamos cómo cargamos el valor 42 en EAX, lo almacenamos en la variable de reserva y cerramos el programa de manera impecable.

---

### Diapositiva 16: Práctica: Traducción de C a NASM

En este segundo taller traduciremos una expresión matemática típica de C a ensamblador x86.

[click] Supongamos que deseamos calcular z igual a x más y menos cinco.

[click] La estrategia consiste en cargar la primera variable en el registro EAX, operar con la segunda variable directamente desde memoria, restar el valor inmediato cinco y finalmente almacenar el acumulador en la variable z.

[click] Este método reduce al mínimo indispensable los accesos al bus de memoria principal, aprovechando la velocidad interna de los registros de la CPU.

[click] Al compilar y ejecutar este programa, podemos consultar el código de retorno en la terminal con la variable interrogante para verificar que devuelva exactamente treinta.

---

### Diapositiva 17: Práctica: Operadores unarios y XCHG

Veamos ahora la traducción de operadores unarios y el intercambio eficiente de variables.

[click] Los operadores de incremento, decremento y cambio de signo en C tienen un mapeo directo y de alta velocidad con las instrucciones INC, DEC y NEG.

[click] Cuando intercambiamos dos variables en C, normalmente necesitamos declarar una variable auxiliar temporal.

[click] En ensamblador x86 disponemos de la instrucción especializada XCHG, la cual intercambia los contenidos de dos operandos de manera compacta.

[click] Observemos el código: tras cargar val_a en EAX y val_b en EBX, ejecutamos xchg eax, ebx y ambos registros quedan automáticamente permutados.

---

### Diapositiva 18: Práctica: Compilación y ensamble

Practiquemos ahora los comandos de consola en Linux para construir nuestros programas.

[click] Primero ejecutamos nasm con el formato elf32 y los modificadores -g -F dwarf, los cuales incrustan la información de depuración necesaria para inspeccionar variables por nombre.

[click] Segundo invocamos el enlazador ld con la bandera -m elf_i386 para enlazar el archivo objeto y producir el binario ejecutable final.

[click] Tercero ejecutamos el programa y consultamos la variable especial de Bash para comprobar el código de retorno.

[click] A la derecha observamos un comando fundamental para el curso: gcc con la bandera -S y -masm=intel nos permite ver directamente cómo el compilador de C traduce nuestras sentencias a código ensamblador idéntico al que estamos programando.

---

### Diapositiva 19: Práctica: Depuración con GDB

Pasemos a la herramienta más poderosa para comprender y depurar código a bajo nivel: GDB.

[click] Al ejecutar gdb con nuestro programa cargado, tomamos el control total de la ejecución.

[click] Fijamos un punto de interrupción en la etiqueta start con el comando break y arrancamos con run.

[click] Con stepi avanzamos exactamente una instrucción de máquina a la vez, viendo cómo el contador de programa EIP se desplaza instrucción por instrucción.

[click] Con info registers consultamos el contenido de toda la CPU y con el comando examine inspeccionamos la memoria RAM.

[click] A la derecha vemos la interfaz visual de GDB. Al escribir layout asm y layout regs, la pantalla se divide mostrando en tiempo real los registros y la línea exacta de código que se está ejecutando.

---

### Diapositiva 20: Trampas comunes en x86

Revisemos los errores más comunes que suelen presentarse en prácticas y evaluaciones.

[click] El primer error radica en intentar transferir datos entre registros o celdas de distinto tamaño sin una instrucción de extensión adecuada.

[click] El segundo error consiste en intentar copiar directamente entre dos variables en memoria, lo cual viola el diseño del juego de instrucciones x86.

[click] El tercer error ocurre al mover un valor numérico inmediato a una dirección de memoria sin calificar su tamaño con byte, word o dword.

[click] En la tabla de la derecha tenemos las soluciones canónicas para cada uno de estos escenarios problemáticos.

---

### Diapositiva 21: Ejercicios de práctica

Evaluemos lo aprendido con esta primera ronda de ejercicios prácticos de consolidación.

Pregunta uno: ¿Por qué la instrucción mov [varB], [varA] produce un error de ensamblado?
[click] Correcto, porque en x86 la arquitectura no soporta dos operandos de memoria en una misma instrucción.

Pregunta dos: Si EAX vale 0x12345678 y modificamos AL con 0x99, ¿cuánto vale EAX?
[click] Exactamente, 0x12345699, porque AL solo altera el byte menos significativo.

Pregunta tres: ¿Qué diferencia existe entre inc eax y add eax, 1?
[click] Muy bien, la instrucción INC preserva intacta la bandera de acarreo CF, propiedad fundamental cuando se implementa aritmética multiprecisión.

---

### Diapositiva 22: Ejercicios de práctica

Continuemos con la segunda ronda de ejercicios prácticos de consolidación.

Pregunta cuatro: Analicemos la traza de memoria. Cargamos diez en EAX y veinticinco en EBX. Al aplicar XCHG, los registros se permutan. Luego sumamos cinco a EAX, resultando treinta, y lo almacenamos en la variable a.
[click] Muy bien, la respuesta es la B: a queda en treinta y b continúa valiendo veinticinco, pues nunca modificamos la celda de memoria de b.

Pregunta cinco: ¿Qué comando de GDB nos permite inspeccionar cuatro palabras dobles consecutivas en hexadecimal?
[click] Excelente, la respuesta correcta es x/4xw &datos. La x invoca el comando examine, el cuatro la cantidad, la segunda x el formato hexadecimal y la w el tamaño de palabra de cuatro bytes.

Pregunta seis: Para cerrar nuestro proceso y devolver el control al sistema operativo sin errores:
[click] Exactamente, la opción B: cargamos el identificador de servicio uno en EAX y el código cero en EBX antes de disparar la interrupción cero por ochenta.

---

### Diapositiva 23: Conclusiones y siguiente paso

Con esto concluimos la quinta semana de tutorías de Arquitectura de Computadores.

Hemos construido los cimientos indispensables del lenguaje ensamblador, comprendiendo cómo dialogan el código en C, el compilador, las secciones de memoria y los registros del procesador.

En la próxima semana profundizaremos en los formatos de instrucción de máquina y los sofisticados modos de direccionamiento que permiten recorrer arreglos y estructuras de datos con máxima eficiencia.

¡Excelente trabajo a todos y nos vemos en la siguiente sesión!
