# Guión de exposición oral: Semana 10
## Procesamiento de cadenas y manipulación de bloques de memoria
### IC3101: Arquitectura de computadores

Este documento compila el discurso oral del tutor para las dos sesiones de 90 minutos de la Semana 10.

---

### Diapositiva 01: Diapositiva 1

Sin notas registradas.

---

### Diapositiva 02: Diapositiva 2

Hola a todos. Bienvenidos a la décima semana de tutorías de Arquitectura de Computadores.

En la semana anterior aprendimos a comunicarnos con el sistema operativo para realizar operaciones de entrada y salida mediante llamadas al sistema.

Hoy abordaremos uno de los mecanismos más potentes y optimizados de la arquitectura x86: las instrucciones especializadas para procesamiento de cadenas y transferencia de bloques de memoria, junto con los prefijos de repetición por hardware.

---

### Diapositiva 03: Diapositiva 3

Sin notas registradas.

---

### Diapositiva 04: Objetivos de la primera sesión

Revisemos los objetivos para esta primera sesión teórica:

[click] Primero, entenderemos cómo se representan las cadenas de caracteres y los arreglos en la memoria principal.

[click] Segundo, analizaremos los registros dedicados de la arquitectura x86 que soportan estas operaciones de manera automática.

[click] Tercero, estudiaremos la bandera de dirección para controlar si el procesamiento avanza hacia adelante o retrocede en memoria.

[click] Cuarto, examinaremos las cinco instrucciones de manipulación de bloques en sus diferentes tamaños de datos.

[click] Y quinto, dominaremos los prefijos de repetición que permiten ejecutar bucles completos a nivel de microcódigo en el procesador.

---

### Diapositiva 05: Diapositiva 5

Sin notas registradas.

---

### Diapositiva 06: Representación de cadenas en memoria

Comencemos revisando la forma en que representamos cadenas en bajo nivel.

[click] La primera alternativa son las cadenas de longitud fija, donde reservamos un espacio constante y rellenamos los sobrantes.

[click] La segunda alternativa, y la más extendida, son las cadenas de longitud variable terminadas en nulo, también conocidas como cadenas ASCIIZ.

[click] Observemos en este mapa de memoria cómo cada letra ocupa exactamente un byte y la secuencia finaliza con el valor hexadecimal cero.

[click] Un aspecto vital es que las instrucciones de cadenas no se limitan a texto, sino que funcionan para manipular cualquier bloque continuo de memoria como arreglos numéricos o estructuras de datos.

---

### Diapositiva 07: Diapositiva 7

Sin notas registradas.

---

### Diapositiva 08: Registros dedicados en cadenas

Analicemos los registros dedicados en IA-32 para el manejo de cadenas.

[click] El registro ESI actúa como puntero al bloque fuente u origen de los datos.

[click] El registro EDI actúa como puntero al bloque de destino donde escribiremos o compararemos.

[click] El registro ECX sirve de contador automático de repeticiones en las instrucciones iterativas.

[click] Y el registro acumulador, ya sea AL, AX o EAX, almacena el valor transferido o el patrón buscado.

[click] Cada instrucción de cadena posee tres variantes según el tamaño: sufijo B para bytes con avance de un paso, sufijo W para palabras de dos bytes y sufijo D para palabras dobles de cuatro bytes.

[click] Notemos que el hardware se encarga de modificar los punteros en cada iteración de manera automática.

---

### Diapositiva 09: Diapositiva 9

Sin notas registradas.

---

### Diapositiva 10: Control de dirección (Bandera DF)

Estudiemos la bandera de dirección y su control en ensamblador.

[click] La instrucción cld limpia la bandera estableciendo DF en cero. Esto provoca que ESI y EDI avancen hacia adelante incrementando sus direcciones de memoria.

[click] La instrucción std establece la bandera en uno. Esto hace que los punteros retrocedan hacia direcciones de memoria inferiores.

[click] En el diagrama observamos con claridad la dirección del flujo de datos en ambos escenarios.

[click] Una regla indispensable de buena práctica es ejecutar siempre la instrucción cld antes de cualquier rutina de cadenas para evitar comportamientos imprevistos.

---

### Diapositiva 11: Diapositiva 11

Sin notas registradas.

---

### Diapositiva 12: Transferencia: LODS, STOS y MOVS

Veamos las tres instrucciones fundamentales para mover información en memoria.

[click] LODSB carga en el acumulador el byte apuntado por ESI y desplaza dicho puntero al siguiente byte.

[click] STOSB toma el valor actual del acumulador y lo deposita en la dirección apuntada por EDI, avanzando este último.

[click] MOVSB combina ambas tareas transfiriendo el byte directamente desde la dirección origen ESI hacia la dirección destino EDI en un solo paso y actualizando ambos punteros a la vez.

[click] Notemos en este resumen cómo actúa cada instrucción sobre los registros y la memoria.

[click] La instrucción MOVSB es sumamente rápida porque realiza la transferencia de memoria a memoria de forma optimizada por microcódigo.

---

### Diapositiva 13: Diapositiva 13

Sin notas registradas.

---

### Diapositiva 14: Inspección: CMPS y SCAS

Analicemos ahora las instrucciones para comparar y buscar en memoria.

[click] CMPSB compara el byte de la fuente apuntado por ESI contra el byte del destino apuntado por EDI mediante una resta interna, actualizando las banderas como ZF y CF antes de desplazar ambos punteros.

[click] SCASB compara el valor que tenemos en el acumulador AL contra el byte en la dirección EDI. Es la instrucción predilecta para buscar caracteres en una cadena.

[click] Observemos cómo la bandera ZF se pone en uno cuando los elementos son iguales y en cero cuando difieren.

[click] Esta bandera de cero será evaluada en cada iteración cuando combinemos estas instrucciones con los prefijos de repetición condicional.

---

### Diapositiva 15: Diapositiva 15

Sin notas registradas.

---

### Diapositiva 16: Prefijo incondicional: REP

Veamos el prefijo de repetición incondicional REP.

[click] Al anteponer REP a MOVSB, el procesador transfiere tantos bytes como indique el registro ECX, decrementando dicho contador hasta llegar a cero.

[click] Si lo usamos con STOSB, rellenamos rápidamente un área de memoria con un valor fijo, equivalente a la función memset de C.

[click] Apreciemos el flujo interno ejecutado por la unidad de control en este diagrama de estados.

[click] Este mecanismo es órdenes de magnitud más veloz que escribir un bucle manual con saltos, ya que la iteración ocurre directamente en el microcódigo del chip.

---

### Diapositiva 17: Diapositiva 17

Sin notas registradas.

---

### Diapositiva 18: Prefijos condicionales: REPE y REPNE

Llegamos a los prefijos condicionales, uno de los temas más evaluados en el curso.

[click] REPE o REPZ repite la operación mientras los datos comparados sean idénticos, es decir, mientras la bandera ZF permanezca en uno. En el instante en que detecta una diferencia, la instrucción finaliza de inmediato.

[click] Por el contrario, REPNE o REPNZ repite la operación mientras no haya coincidencia, o sea mientras ZF sea cero. Se detiene tan pronto encuentra el elemento buscado.

[click] En esta tabla resumimos los dos grandes casos de uso: comparar dos cadenas completas con REPE CMPSB y buscar el carácter de fin de cadena con REPNE SCASB.

[click] Tengamos en cuenta que REPE y REPZ generan exactamente el mismo byte de instrucción en la máquina.

---

### Diapositiva 19: Diapositiva 19

Sin notas registradas.

---

### Diapositiva 20: Síntesis de la primera sesión

Con esto concluimos la primera sesión teórica. Hemos cubierto los registros especializados, el sentido de avance con la bandera DF y los prefijos de repetición.

[click] Les dejo esta pregunta detonante para reflexionar antes del taller práctico: ¿cómo convertimos el valor residual de ECX en la longitud exacta de la cadena usando operaciones lógicas?

---

### Diapositiva 21: Diapositiva 21

Sin notas registradas.

---

### Diapositiva 22: Diapositiva 22

¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de las instrucciones de cadena y los prefijos de repetición, dedicaremos esta jornada completa a la implementación práctica de rutinas de alto rendimiento.

---

### Diapositiva 23: Diapositiva 23

Sin notas registradas.

---

### Diapositiva 24: Objetivos de la segunda sesión

Antes de iniciar los ejercicios, repasemos los objetivos de esta segunda sesión práctica:

[click] Primero, implementaremos la función strlen utilizando el prefijo REPNE SCASB para buscar el fin de cadena.

[click] Segundo, construiremos una rutina de copia de memoria optimizada por palabras dobles de 32 bits.

[click] Tercero, aprenderemos a inicializar buffers de forma instantánea con REP STOSB.

[click] Cuarto, implementaremos la comparación de textos con REPE CMPSB detectando discrepancias.

[click] Y quinto, analizaremos por qué estas instrucciones en microcódigo superan ampliamente a los bucles tradicionales con saltos.

---

### Diapositiva 25: Diapositiva 25

Sin notas registradas.

---

### Diapositiva 26: Taller 1: Longitud de cadena (strlen)

Analicemos la implementación clásica de strlen con instrucciones de bloque.

[click] Primero aseguramos la dirección con cld, colocamos ECX en menos uno y limpiamos AL con xor al, al.

[click] Al ejecutar repne scasb, el procesador escanea la memoria a máxima velocidad hasta hallar el byte cero.

[click] Notemos este truco matemático: al aplicar la instrucción NOT sobre ECX y decrementar una unidad, obtenemos con precisión matemática el número exacto de caracteres de la cadena.

---

### Diapositiva 27: Diapositiva 27

Sin notas registradas.

---

### Diapositiva 28: Taller 2: Copia de memoria (memcpy)

Veamos ahora una optimización profesional para copiar memoria equivalente a la función memcpy.

[click] En lugar de copiar byte por byte con MOVSB, dividimos ECX entre cuatro con shr ecx, 2 y transferimos de cuatro en cuatro bytes usando rep movsd.

[click] Luego recuperamos el residuo con and ecx, 3 y copiamos los bytes sobrantes con rep movsb.

Esta técnica maximiza el ancho de banda del bus de datos de la máquina.

---

### Diapositiva 29: Diapositiva 29

Sin notas registradas.

---

### Diapositiva 30: Taller 3: Inicialización (memset)

Examinemos cómo inicializar memoria de forma ultrarrápida con REP STOSB.

[click] Con solo configurar EDI con el puntero al buffer, AL con el byte deseado y ECX con la longitud, la instrucción rep stosb escribe en memoria en cada ciclo de reloj.

[click] Apreciemos en el gráfico cómo cada celda se llena uniformemente con ceros mientras EDI avanza hacia el final del bloque.

Esta es la rutina que utilizan los sistemas operativos para limpiar buffers de memoria antes de entregarlos a un proceso de usuario.

---

### Diapositiva 31: Diapositiva 31

Sin notas registradas.

---

### Diapositiva 32: Taller 4: Comparación léxica (strcmp)

Analicemos la función strcmp con REPE CMPSB.

[click] Al ejecutar repe cmpsb, el procesador compara byte a byte ambas cadenas. Si son idénticas en todas sus posiciones, el bucle concluye con la bandera ZF en uno y saltamos a cadenas_iguales retornando cero.

[click] Si se detecta una diferencia, el prefijo se detiene inmediatamente. Un detalle crítico es que como los punteros ya avanzaron una posición, debemos leer en esi menos uno y edi menos uno para restar los caracteres y determinar cuál cadena es léxicamente mayor.

---

### Diapositiva 33: Diapositiva 33

Sin notas registradas.

---

### Diapositiva 34: Rendimiento: Bloques vs bucles

Comparemos el rendimiento entre ambas alternativas.

En la columna izquierda vemos el bucle tradicional: lectura, escritura, incrementos, decremento y salto condicional con riesgo de fallo de predicción.

[click] Con REP MOVSB eliminamos toda esa sobrecarga. La decodificación ocurre una sola vez y el procesador ejecuta la copia continua a velocidad de hardware.

[click] Además de ganar velocidad, el código binario es mucho más compacto y no satura la memoria caché del procesador.

---

### Diapositiva 35: Diapositiva 35

Sin notas registradas.

---

### Diapositiva 36: Mini-quiz formativo (Sesión 2)

Pongamos a prueba lo aprendido con este mini-quiz de cierre.

Pregunta uno: ¿Qué instrucción asegura que los punteros avancen hacia adelante?
[click] Correcto, la instrucción CLD.

Pregunta dos: ¿Cuándo se detiene el prefijo REPE CMPSB?
[click] Exacto, cuando ECX llega a cero o cuando se encuentra la primera diferencia con ZF en cero.

Pregunta tres: ¿Cuál es la forma más rápida de inicializar un arreglo de enteros con ceros?
[click] Muy bien, REP STOSD utilizando el registro EAX con valor cero.

---

### Diapositiva 37: Diapositiva 37

Sin notas registradas.

---

### Diapositiva 38: Diapositiva 38

Con esto concluimos la décima semana de tutorías.

Hemos dominado una de las facetas más potentes del ensamblador x86: las instrucciones de cadena y los prefijos de repetición condicional.

Estas técnicas les permitirán escribir código sumamente eficiente y elegante tanto para sus tareas como para el proyecto del curso.

¡Muchas gracias a todos por su participación y nos vemos en la próxima sesión!

---
