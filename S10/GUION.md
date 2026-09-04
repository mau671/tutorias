# Guión de exposición oral: Semana 10
## Procesamiento de cadenas y manipulación masiva de memoria
### IC3101: Arquitectura de computadores

Este documento compila el guión oral del tutor para las dos sesiones de 90 minutos de la Semana 10, sincronizado con cada diapositiva y marcador de animación `[click]`.

---

### Diapositiva 01: Portada de la tutoría

Hola a todos. Bienvenidos a la décima semana de tutorías de Arquitectura de Computadores.

En la sesión anterior dominamos las llamadas al sistema operativo y la entrada y salida por consola.

Hoy nos adentraremos en una de las características más potentes y optimizadas de la arquitectura x86: las instrucciones especializadas de bloque y procesamiento de cadenas. Estudiaremos los registros dedicados ESI y EDI, la bandera de dirección, los prefijos de repetición por microcódigo y la implementación de rutinas fundamentales como strlen, memcpy, memset y strcmp.

---

### Diapositiva 02: Objetivos de la primera sesión

Antes de comenzar con los fundamentos teóricos, repasemos los objetivos de esta primera jornada:

[click] Primero, comprenderemos cómo se representan las cadenas en la memoria, contrastando el esquema de longitud fija con el formato ASCIIZ estándar.

[click] Segundo, analizaremos los registros especializados que el procesador dedica exclusivamente para operaciones de cadenas y bloques de memoria.

[click] Tercero, estudiaremos el control del sentido de recorrido en la memoria a través de la bandera de dirección en el registro EFLAGS.

[click] Cuarto, analizaremos las cinco instrucciones elementales de transferencia, almacenamiento, comparación y búsqueda en memoria.

[click] Y quinto, dominaremos los prefijos de repetición que permiten ejecutar bucles completos directamente a nivel de microcódigo en el chip.

---

### Diapositiva 03: Representación de cadenas en memoria

Comencemos revisando cómo se representan las secuencias de texto en memoria.

[click] En las cadenas de longitud fija se reserva un tamaño constante y los espacios sobrantes se rellenan con caracteres nulos o blancos, lo cual resulta ineficiente cuando los textos varían en longitud.

[click] Por otro lado, el estándar predominante en la arquitectura x86 y los sistemas UNIX son las cadenas de longitud variable terminadas en nulo, comúnmente llamadas ASCIIZ.

[click] Observemos el esquema a la derecha: cada carácter ocupa un byte en direcciones consecutivas de memoria, y el final de la cadena queda marcado de forma inequívoca por el byte cero hexadecimal.

[click] Las instrucciones de cadenas no solo operan sobre texto legible, sino sobre cualquier bloque contiguo de bytes o enteros en memoria RAM.

---

### Diapositiva 04: Registros dedicados en cadenas

Analicemos los registros dedicados por hardware en la arquitectura x86.

[click] El registro ESI actúa como el puntero de origen de datos, indexando la memoria fuente con el segmento DS.

[click] El registro EDI actúa como el puntero de destino, indexando la memoria receptora con el segmento ES.

[click] El registro ECX sirve de contador automático para las instrucciones repetitivas.

[click] Y el acumulador, ya sea AL, AX o EAX, almacena el valor leído, transferido o el patrón buscado.

[click] Cada instrucción de cadena dispone de tres variantes según el sufijo: B para un byte con avance de un paso, W para palabras de dos bytes y D para palabras dobles de cuatro bytes.

[click] Notemos que el hardware se encarga de modificar los punteros en cada ciclo de reloj sin necesidad de instrucciones de incremento manual.

---

### Diapositiva 05: Control de dirección (Bandera DF)

Estudiemos la bandera de dirección y su influencia en el registro EFLAGS.

[click] La instrucción CLD pone a cero la bandera DF. Con ello, tanto ESI como EDI avanzan hacia adelante incrementando sus direcciones de memoria.

[click] Por el contrario, la instrucción STD fija la bandera en uno, provocando que los punteros retrocedan hacia direcciones inferiores. Esto resulta sumamente útil cuando se mueven bloques contiguos de memoria que se solapan entre sí.

[click] En el gráfico de la derecha podemos apreciar la dirección del flujo de datos en ambos casos.

[click] Una regla de oro de la arquitectura x86 es anteponer siempre la instrucción CLD antes de operar con cadenas para evitar que una función anterior haya dejado la bandera DF activada.

---

### Diapositiva 06: Transferencia: LODS, STOS y MOVS

Examinemos las tres instrucciones fundamentales de movimiento de información.

[click] LODSB carga en el acumulador el byte apuntado por ESI y actualiza dicho puntero al siguiente elemento.

[click] STOSB deposita el valor del acumulador en la posición apuntada por EDI y avanza el puntero de destino.

[click] MOVSB combina ambas operaciones en una sola instrucción atómica de procesador: transfiere el dato desde la dirección ESI a la dirección EDI y actualiza ambos punteros a la vez.

[click] En el diagrama observamos cómo fluyen los datos en el bus interno del microprocesador.

[click] MOVSB es de altísima velocidad porque delega la copia completa al microcódigo interno de la CPU.

---

### Diapositiva 07: Inspección: CMPS y SCAS

Analicemos ahora las instrucciones para comparar y buscar patrones en memoria.

[click] CMPSB compara el byte apuntado por ESI contra el apuntado por EDI realizando una resta aritmética sin guardar la diferencia, actualizando banderas como ZF y CF.

[click] SCASB compara el contenido del acumulador AL contra el byte apuntado por EDI. Es la instrucción ideal para buscar caracteres específicos como el terminador nulo.

[click] Observemos cómo la bandera ZF se pone en uno cuando hay coincidencia exacta y en cero cuando los elementos difieren.

[click] Este comportamiento de la bandera de cero es el núcleo que aprovechan los prefijos de repetición condicional.

---

### Diapositiva 08: Prefijo incondicional: REP

Veamos el prefijo de repetición incondicional REP.

[click] Al anteponer REP a MOVSB o MOVSD, el procesador transfiere tantos elementos como indique el registro ECX, decrementándolo en cada ciclo.

[click] Al combinarlo con STOSB o STOSD, inicializamos bloques masivos de memoria con un valor predeterminado, equivalente a la función memset de C.

[click] Apreciemos en la columna derecha el ciclo de microcódigo: la CPU evalúa si ECX es mayor a cero, ejecuta la instrucción, resta una unidad a ECX y repite hasta llegar a cero.

[click] Esto ahorra ciclos de decodificación y elimina paradas de salto condicional en el cauce de la CPU.

---

### Diapositiva 09: Prefijos condicionales: REPE y REPNE

Llegamos a los prefijos condicionales, un tema de alta relevancia analítica.

[click] REPE o REPZ repite la operación mientras los elementos comparados sean idénticos, es decir mientras la bandera ZF sea uno. En cuanto detecta una diferencia, la repetición finaliza de inmediato.

[click] En cambio, REPNE o REPNZ repite la instrucción mientras no haya coincidencia, o sea mientras ZF sea cero. Se detiene tan pronto encuentra el carácter buscado.

[click] A la derecha resumimos los dos grandes casos canónicos: comparar dos cadenas completas con REPE CMPSB y calcular la longitud escaneando el byte nulo con REPNE SCASB.

[click] Tengamos presente que los mnemónicos REPE y REPZ son alias sinónimos del mismo código de máquina.

---

### Diapositiva 10: Síntesis de la primera sesión

Con esto concluimos la primera sesión teórica de la semana. Hemos analizado los registros dedicados, el control de dirección con DF y la lógica de los prefijos de repetición.

[click] Les dejo esta pregunta detonante para reflexionar antes de pasar al taller práctico: si ECX empieza en menos uno y se decrementa en cada byte, ¿cómo deducimos la longitud exacta aplicando operadores a nivel de bits?

---

### Diapositiva 11: Portada de la segunda sesión

¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de las instrucciones de bloque y los prefijos de repetición, dedicaremos esta jornada completa a implementar de forma práctica funciones esenciales de memoria como strlen, memcpy, memset y strcmp, evaluando su rendimiento real frente a bucles tradicionales.

---

### Diapositiva 12: Objetivos de la segunda sesión

Antes de iniciar los ejercicios prácticos, repasemos los objetivos de esta segunda sesión:

[click] Primero, implementaremos la función strlen utilizando el prefijo REPNE SCASB para buscar el fin de cadena en memoria.

[click] Segundo, construiremos una rutina de copia masiva de memoria optimizada por palabras dobles de 32 bits.

[click] Tercero, aprenderemos a inicializar buffers de forma instantánea con REP STOSB.

[click] Cuarto, implementaremos la comparación de textos con REPE CMPSB determinando cuál cadena es mayor.

[click] Y quinto, analizaremos cuantitativamente por qué estas instrucciones en microcódigo superan ampliamente a los bucles manuales de software.

---

### Diapositiva 13: Longitud de cadena con strlen

Analicemos la implementación clásica de strlen con instrucciones de bloque.

[click] Primero aseguramos la dirección de avance con cld, colocamos ECX en menos uno y limpiamos AL con xor al, al para buscar el byte cero.

[click] Al ejecutar repne scasb, el procesador inspecciona byte a byte en microcódigo hasta toparse con el terminador nulo, activando la bandera ZF.

[click] Notemos este elegante truco matemático: al aplicar NOT sobre ECX y restar una unidad con dec ecx, obtenemos con precisión matemática el número exacto de caracteres de la cadena.

---

### Diapositiva 14: Copia de memoria optimizada con memcpy

Veamos una optimización profesional para duplicar bloques de memoria equivalente a memcpy en C.

[click] En vez de copiar byte a byte con MOVSB, dividimos el total de bytes entre cuatro mediante shr ecx, 2 y transferimos de cuatro en cuatro bytes usando rep movsd.

[click] Luego recuperamos el total original de la pila, extraemos el residuo con and ecx, 3 y copiamos los bytes finales con rep movsb.

Esta técnica explota al máximo el ancho de palabra del procesador.

---

### Diapositiva 15: Inicialización de memoria con memset

Revisemos cómo inicializar memoria de forma ultrarrápida utilizando REP STOSB.

[click] Con solo cargar EDI con la dirección base del buffer, AL con el valor a escribir y ECX con la longitud, la instrucción rep stosb escribe en memoria en cada ciclo de procesador.

[click] Apreciemos en la ilustración gráfica cómo las celdas previamente sucias con datos residuales quedan completamente limpias con ceros.

Esta es exactamente la rutina que utilizan los sistemas operativos para inicializar páginas de memoria antes de entregarlas a los procesos de usuario.

---

### Diapositiva 16: Comparación léxica con strcmp

Analicemos la función strcmp implementada con REPE CMPSB.

[click] Al ejecutar repe cmpsb, el procesador compara byte a byte ambas cadenas mientras sean iguales. Si no se detecta ninguna diferencia, el bucle finaliza con ZF en uno y retornamos cero.

[click] Si se detecta una diferencia, el prefijo se detiene inmediatamente. Un detalle crítico de bajo nivel es que los punteros ya avanzaron una posición, por lo que leemos en esi menos uno y edi menos uno para restar los caracteres y determinar cuál cadena es mayor.

---

### Diapositiva 17: Rendimiento: Bloques frente a bucles

Comparemos el rendimiento entre ambas alternativas.

En la columna izquierda observamos el bucle manual tradicional: lectura, escritura, incrementos de punteros, decremento de contador y salto condicional con riesgo de fallos de predicción.

[click] Con REP MOVSD eliminamos toda esa sobrecarga. La decodificación ocurre una sola vez y el procesador transfiere datos en ráfagas directas a velocidad de hardware.

[click] Además de ganar velocidad, el binario resultante es mucho más compacto y no satura las líneas de la memoria caché L1 del procesador.

---

### Diapositiva 18: Trampas comunes en cadenas

Revisemos las trampas más frecuentes al programar con instrucciones de cadenas en x86.

[click] La primera es no limpiar la bandera DF con cld. Si una rutina previa ejecutó STD, nuestros punteros retrocederán y corromperán datos ajenos en la memoria.

[click] La segunda trampa es el desfase de punteros: al detenerse una búsqueda o comparación con CMPSB o SCASB, el hardware ya incrementó los punteros, por lo que el byte que causó la parada está en la posición menos uno.

[click] La tercera es confundir ESI con EDI, recordando que STOS escribe siempre en la dirección de EDI.

[click] En la tabla derecha resumimos las correcciones estandarizadas para asegurar la estabilidad de nuestras rutinas.

---

### Diapositiva 19: Ejercicios de práctica (Parte 1)

Evaluemos lo aprendido con esta primera ronda de ejercicios formativos.

Pregunta uno: ¿Qué instrucción asegura que los punteros avancen hacia adelante?
[click] Correcto, la instrucción CLD.

Pregunta dos: En STOSD, ¿cuál es el registro origen y cuál el destino?
[click] Exacto, opción B: el origen es EAX y el destino es la memoria apuntada por EDI.

Pregunta tres: ¿Cuál es la opción más veloz para inicializar un arreglo de enteros con ceros?
[click] Muy bien, REP STOSD con EAX en cero y ECX con la cantidad de palabras dobles.

---

### Diapositiva 20: Ejercicios de práctica (Parte 2)

Continuemos con la segunda ronda de ejercicios de práctica.

Pregunta cuatro: ¿Cuándo concluye el prefijo REPE CMPSB?
[click] Exactamente, opción A: al agotarse ECX o al hallar la primera diferencia con ZF en cero.

Pregunta cinco: ¿Por qué restamos uno tras aplicar NOT sobre ECX en strlen?
[click] Muy bien, opción B: para descontar el propio byte nulo que fue escaneado antes de que la CPU se detuviera.

Pregunta seis: Si REPE CMPSB detecta una discrepancia, ¿dónde se ubican los bytes?
[click] Excelente, en esi menos uno y edi menos uno, debido al autoincremento previo del hardware.

---

### Diapositiva 21: Conclusiones integradoras

Con esto concluimos la décima semana de tutorías de Arquitectura de Computadores.

Hemos dominado una de las facetas más eficientes del ensamblador x86: las instrucciones de cadena y los prefijos de repetición condicional por hardware.

Estas técnicas les dotan de destrezas indispensables para el desarrollo de rutinas de alto rendimiento y la manipulación de buffers en memoria.

En la próxima semana daremos el paso hacia la persistencia de datos en disco mediante llamadas al sistema de archivos, el preprocesador de macros y la integración híbrida de C con NASM.

¡Muchas gracias a todos por su compromiso y nos vemos en la siguiente sesión!
