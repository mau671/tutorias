# Guión de exposición oral: Semana 09
## Llamadas al sistema e interacción con el sistema operativo
### IC3101: Arquitectura de computadores

Este documento compila el discurso oral del tutor para las dos sesiones de 90 minutos de la Semana 09.

---

### Diapositiva 01: Diapositiva 1

Sin notas registradas.

---

### Diapositiva 02: Diapositiva 2

Hola a todos. Bienvenidos a la novena semana de tutorías de Arquitectura de Computadores.

Hasta este momento hemos trabajado con instrucciones que operan internamente sobre registros y memoria, como sumas, comparaciones, saltos condicionales y marcos de pila.

Hoy daremos un paso fundamental para conectar nuestros programas con el mundo exterior mediante las llamadas al sistema, comprendiendo la separación de privilegios del procesador y los mecanismos de entrada y salida en Linux.

---

### Diapositiva 03: Diapositiva 3

Sin notas registradas.

---

### Diapositiva 04: Objetivos de la primera sesión

Antes de comenzar con la teoría, repasemos los objetivos de esta primera sesión:

[click] Primero, entenderemos cómo el procesador garantiza la estabilidad del sistema mediante el modo dual y los anillos de protección.

[click] Segundo, analizaremos el mecanismo de interrupción por software que permite solicitar servicios al sistema operativo de manera controlada.

[click] Tercero, aprenderemos la convención de registros para invocar llamadas al sistema bajo la arquitectura IA-32 en Linux.

[click] Cuarto, estudiaremos los descriptores de archivo estándar para entrada y salida.

[click] Y quinto, examinaremos la organización de la memoria del programa en secciones de datos, código y reserva.

---

### Diapositiva 05: Diapositiva 5

Sin notas registradas.

---

### Diapositiva 06: Jerarquía de privilegios x86

Comencemos analizando por qué existe la división de privilegios en el hardware.

En la arquitectura x86 existen cuatro anillos de protección numerados del 0 al 3. Los sistemas operativos como Linux utilizan principalmente dos: el anillo 0 y el anillo 3.

[click] En el espacio de núcleo reside el sistema operativo. Tiene control absoluto sobre la memoria física, la tabla de páginas y los controladores de dispositivos.

[click] Por otro lado, en el espacio de usuario se ejecutan nuestras aplicaciones habituales. Si una aplicación intenta ejecutar una instrucción privilegiada, la CPU detiene la ejecución inmediatamente.

[click] Observemos este diagrama. La capa exterior contiene las aplicaciones comunes, mientras que el núcleo reside en el centro con el nivel máximo de autoridad y protección del procesador.

---

### Diapositiva 07: Diapositiva 7

Sin notas registradas.

---

### Diapositiva 08: Mecanismo de interrupciones por software

Veamos ahora qué ocurre internamente cuando invocamos una llamada al sistema.

[click] El primer paso ocurre en el programa de usuario, el cual configura los registros necesarios y ejecuta la instrucción int 0x80.

[click] Al recibir esta instrucción, la unidad central de procesamiento consulta la tabla de descriptores de interrupción en la posición 0x80, guarda el estado actual en la pila del núcleo y conmuta al nivel privilegiado.

[click] Una vez en el núcleo, el despachador general utiliza el valor de EAX como índice en la tabla de llamadas al sistema para ubicar la función requerida.

[click] Al finalizar el servicio, el núcleo deposita el resultado en el registro EAX y ejecuta la instrucción iret para restaurar el contexto original y regresar al espacio de usuario de forma transparente.

---

### Diapositiva 09: Diapositiva 9

Sin notas registradas.

---

### Diapositiva 10: Convención de llamadas en IA-32

Analicemos la convención de registros para invocar servicios en IA-32.

[click] El registro EAX es el más importante, pues contiene el número de servicio que identifica la llamada solicitada al sistema operativo.

[click] El registro EBX recibe el primer argumento de la llamada.

[click] El registro ECX recibe el segundo parámetro, típicamente la dirección de memoria donde se ubican los datos.

[click] Y el registro EDX contiene el tercer argumento, usualmente la cantidad máxima de bytes a transferir.

[click] En esta tabla resumimos las tres llamadas elementales con las que trabajaremos: sys_exit identificada con el número 1, sys_read con el número 3 y sys_write con el número 4.

[click] Tengamos presente que al volver de la interrupción, el resultado de la operación queda registrado en EAX.

---

### Diapositiva 11: Diapositiva 11

Sin notas registradas.

---

### Diapositiva 12: Descriptores de archivo en POSIX

Hablemos ahora de la abstracción de entrada y salida mediante descriptores de archivo.

En Linux todo se trata como un archivo o un flujo de bytes. Al iniciar cualquier proceso, el sistema operativo abre automáticamente tres canales fundamentales:

[click] El descriptor 0 corresponde a la entrada estándar, usualmente vinculada al teclado de la computadora.

[click] El descriptor 1 corresponde a la salida estándar, conectada a nuestra consola o emulador de terminal.

[click] Y el descriptor 2 es la salida de error estándar, diseñada para emitir diagnósticos.

[click] Observemos cómo la tabla interna del proceso asigna estos identificadores numéricos a los dispositivos físicos o archivos correspondientes.

[click] En ensamblador simplemente cargamos el número del descriptor en el registro EBX para indicar hacia dónde dirigir la lectura o la escritura.

---

### Diapositiva 13: Diapositiva 13

Sin notas registradas.

---

### Diapositiva 14: Secciones de memoria en NASM

Revisemos cómo organizamos el código fuente en NASM.

[click] La sección punto text contiene la secuencia de instrucciones que ejecutará el procesador. Tiene permisos de sólo lectura y ejecución para impedir que el programa se modifique a sí mismo accidentalmente.

[click] La sección punto data alberga las variables y cadenas de caracteres con valores iniciales conocidos desde el momento de compilar.

[click] La sección punto bss se utiliza para reservar memoria para variables y buffers que recibirán datos durante la ejecución, como la entrada del usuario.

[click] Aquí apreciamos la estructura típica de un archivo en ensamblador con sus tres secciones bien delimitadas.

[click] Notemos que la sección BSS es sumamente eficiente, puesto que reservar un buffer de sesenta y cuatro bytes no agrega ningún peso al archivo binario generado en disco.

---

### Diapositiva 15: Diapositiva 15

Sin notas registradas.

---

### Diapositiva 16: Directivas de definición y reserva

Veamos en detalle las directivas de datos que utilizaremos en nuestras prácticas.

[click] Para inicializar variables en la sección de datos usamos db para bytes individuales, dw para palabras de dieciséis bits y dd para palabras dobles de treinta y dos bits.

[click] En contraste, dentro de la sección BSS usamos resb, resw o resd acompañados de un número entero que indica la cantidad de elementos vacíos a reservar.

[click] Una técnica muy elegante para no contar caracteres manualmente es usar el operador signo de dólar menos la etiqueta de inicio. Esto calcula la longitud exacta en bytes de forma automática.

[click] La directiva equ crea una constante simbólica en tiempo de ensamblado, facilitando un código limpio y mantenible.

---

### Diapositiva 17: Diapositiva 17

Sin notas registradas.

---

### Diapositiva 18: Ejemplo guiado: Salida en consola

Analicemos este primer programa completo.

[click] Para emitir el mensaje por pantalla, configuramos EAX con el número cuatro correspondiente a sys_write, EBX con uno para la salida estándar, ECX con la dirección de la cadena y EDX con la longitud.

[click] Luego ejecutamos int 0x80 para que el sistema operativo realice la escritura. Inmediatamente después preparamos la llamada sys_exit con código cero para cerrar el proceso de forma limpia.

[click] Para ensamblar y enlazar este código en Linux de 32 bits utilizamos nasm con formato elf32 y ld con emulación elf_i386.

---

### Diapositiva 19: Diapositiva 19

Sin notas registradas.

---

### Diapositiva 20: Síntesis de la primera sesión

Con esto concluimos la primera sesión teórica. Hemos cubierto los principios de protección por hardware, la tabla de llamadas al sistema y la segmentación en ensamblador.

[click] Les dejo esta pregunta detonante para reflexionar antes del taller práctico: cuando el usuario escribe en consola y presiona Enter, ¿cómo limpiamos el carácter de salto de línea en memoria?

---

### Diapositiva 21: Diapositiva 21

Sin notas registradas.

---

### Diapositiva 22: Diapositiva 22

¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de la separación de privilegios y la interfaz de llamadas al sistema, dedicaremos esta jornada completa al taller práctico y la resolución de ejercicios paso a paso.

---

### Diapositiva 23: Diapositiva 23

Sin notas registradas.

---

### Diapositiva 24: Objetivos de la segunda sesión

Antes de iniciar los ejercicios, repasemos los objetivos de esta segunda sesión práctica:

[click] Primero, implementaremos la lectura interactiva desde teclado con sys_read.

[click] Segundo, gestionaremos la memoria de trabajo en la sección BSS para almacenar la información recibida.

[click] Tercero, aprenderemos a sanitizar cadenas suprimiendo el byte de salto de línea.

[click] Cuarto, utilizaremos el depurador GDB para inspeccionar registros y memoria en vivo.

[click] Y quinto, analizaremos los errores más comunes al interactuar con el sistema operativo para evitar comportamientos anómalos.

---

### Diapositiva 25: Diapositiva 25

Sin notas registradas.

---

### Diapositiva 26: Captura con sys_read

Entremos al taller práctico revisando cómo funciona sys_read.

[click] Para leer datos, configuramos EAX con el valor tres, EBX con cero correspondiente a stdin, ECX con la dirección del buffer donde se guardará la entrada y EDX con la capacidad máxima.

[click] Un detalle fundamental es que al retornar de la interrupción, EAX almacena la cantidad exacta de bytes que el usuario escribió.

[click] Observemos este diagrama en memoria. Si el usuario escribe el nombre Juan y presiona Enter, el buffer contendrá las cuatro letras más el byte 0x0A del salto de línea, totalizando cinco bytes en EAX.

[click] Notemos la importancia de pasar en EDX el tamaño real del buffer para evitar cualquier desbordamiento de memoria.

---

### Diapositiva 27: Diapositiva 27

Sin notas registradas.

---

### Diapositiva 28: Taller 1: Saludo interactivo

Construyamos este programa interactivo paso a paso.

Primero mostramos el mensaje de solicitud en consola con sys_write.

Luego invocamos sys_read pasando nuestro buffer nombre de treinta y dos bytes. Observemos cómo guardamos el conteo que retorna EAX en la variable bytes_leidos.

[click] Finalmente imprimimos la palabra Hola seguida directamente del contenido de nuestro buffer con la cantidad exacta de bytes leídos antes de invocar sys_exit.

---

### Diapositiva 29: Diapositiva 29

Sin notas registradas.

---

### Diapositiva 30: Supresión del salto de línea

Un problema muy común al leer texto del usuario es que el salto de línea queda guardado dentro del buffer.

Si leímos cinco bytes, los índices van del cero al cuatro, por lo que el salto de línea está en la posición cuatro.

[click] Restamos uno a EAX con dec eax y escribimos un byte cero en la posición calculada mediante direccionamiento indexado.

[click] Observemos la transformación gráfica en la columna derecha. El byte 0x0A se sustituye por 0x00.

[click] Esto transforma la entrada en una cadena terminada en nulo, compatible con las funciones del lenguaje C.

---

### Diapositiva 31: Diapositiva 31

Sin notas registradas.

---

### Diapositiva 32: Taller 2: Depuración con GDB

Veamos ahora cómo utilizar GDB para depurar nuestros programas en ensamblador.

[click] Al ensamblar con NASM debemos incluir los parámetros menos g y menos F dwarf para generar la tabla de símbolos de depuración.

[click] Dentro de GDB colocamos un punto de interrupción en _start con break y avanzamos instrucción por instrucción con nexti o stepi.

[click] Con info registers verificamos que los parámetros de la llamada al sistema estén correctamente colocados en EAX, EBX, ECX y EDX.

[click] El comando examine nos permite ver los caracteres exactos dentro de nuestro buffer para confirmar que los datos se leyeron adecuadamente.

---

### Diapositiva 33: Diapositiva 33

Sin notas registradas.

---

### Diapositiva 34: Errores comunes en llamadas

Analicemos los tres errores más comunes al trabajar con llamadas al sistema:

[click] Primero, olvidar invocar sys_exit. Si no detenemos el programa explícitamente, el procesador seguirá leyendo bytes basura en memoria y el sistema abortará con un fallo de segmentación.

[click] Segundo, confundir el puntero con el contenido. En ECX debemos pasar la dirección msg y no su valor entre corchetes.

[click] Y tercero, olvidar que EAX es sobreescrito por el núcleo al retornar de la interrupción.

[click] Por ello, siempre guardamos el valor retornado inmediatamente antes de configurar la siguiente instrucción.

---

### Diapositiva 35: Diapositiva 35

Sin notas registradas.

---

### Diapositiva 36: Mini-quiz formativo (Sesión 2)

Pongamos a prueba los conocimientos adquiridos con este breve cuestionario formativo.

Pregunta uno: ¿Qué registro define el código de la llamada al sistema?
[click] Correcto, el registro EAX.

Pregunta dos: ¿Por qué la sección BSS no incrementa el tamaño del archivo ejecutable?
[click] Exactamente, porque sólo define la cantidad de memoria que el sistema operativo debe reservar al cargar el programa.

Pregunta tres: Si ingresamos cuatro letras y presionamos Enter, ¿cuánto retorna sys_read en EAX?
[click] Muy bien, retorna cinco bytes debido al carácter de salto de línea.

---

### Diapositiva 37: Diapositiva 37

Sin notas registradas.

---

### Diapositiva 38: Diapositiva 38

Con esto concluimos la novena semana de tutorías.

Hemos cerrado la brecha entre las instrucciones puras de procesador y los servicios del sistema operativo, dominando la lectura, escritura y depuración de programas interactivos.

En la próxima semana daremos un salto hacia la manipulación eficiente de bloques de memoria con las instrucciones de cadenas y prefijos de repetición.

¡Excelente trabajo y nos vemos en la siguiente sesión!

---
