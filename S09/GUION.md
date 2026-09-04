# Guión de exposición oral: Semana 09
## Llamadas al sistema e interacción con el sistema operativo
### IC3101: Arquitectura de computadores

Este documento compila el guión oral del tutor para las dos sesiones de 90 minutos de la Semana 09, sincronizado con cada diapositiva y marcador de animación `[click]`.

---

### Diapositiva 01: Portada de la tutoría

Hola a todos. Bienvenidos a la novena semana de tutorías de Arquitectura de Computadores.

Hasta este momento hemos trabajado con instrucciones que operan internamente sobre registros y memoria, como sumas, comparaciones, saltos condicionales y marcos de pila.

Hoy daremos un paso trascendental al conectar nuestros programas con el mundo exterior mediante las llamadas al sistema. Comprenderemos la separación de privilegios del procesador, el mecanismo de interrupciones por software y las operaciones fundamentales de entrada y salida por consola en Linux.

---

### Diapositiva 02: Objetivos de la primera sesión

Antes de comenzar con el desarrollo teórico, repasemos los objetivos de esta primera sesión:

[click] Primero, entenderemos cómo el hardware garantiza la estabilidad y seguridad del sistema mediante el modo dual y los anillos de protección.

[click] Segundo, analizaremos el mecanismo de interrupción por software que permite solicitar servicios al núcleo de forma ordenada y controlada.

[click] Tercero, aprenderemos la convención de registros para invocar llamadas al sistema bajo la arquitectura IA-32 en Linux.

[click] Cuarto, contrastaremos este mecanismo clásico con la instrucción syscall propia de la arquitectura moderna de 64 bits.

[click] Quinto, estudiaremos los descriptores de archivo estándar para gestionar entradas y salidas.

[click] Y sexto, examinaremos la organización del binario en memoria, comprendiendo por qué la sección BSS optimiza el uso del almacenamiento en disco.

---

### Diapositiva 03: Jerarquía de privilegios x86

Comencemos analizando la división de privilegios en el hardware de la CPU.

En la arquitectura x86 existen cuatro anillos de protección numerados de cero a tres. Los sistemas operativos modernos como Linux implementan el modelo dual utilizando principalmente dos niveles: el anillo cero y el anillo tres.

[click] En el anillo cero, correspondiente al modo núcleo, reside el sistema operativo. Este nivel posee facultades irrestrictas para administrar la memoria física, configurar tablas de páginas y controlar periféricos mediante registros especiales.

[click] En el anillo tres, correspondiente al modo usuario, se ejecutan nuestras aplicaciones habituales. Cualquier intento de ejecutar una instrucción privilegiada provoca de inmediato una excepción de fallo de protección general.

[click] Observemos este diagrama concéntrico. Para que una aplicación en el anillo tres solicite un servicio al núcleo, debe atravesar la frontera mediante una puerta de enlace segura provista por las interrupciones por software.

---

### Diapositiva 04: Mecanismo de interrupciones por software

Analicemos en detalle la secuencia que se desencadena al invocar una llamada al sistema.

[click] Primero, el programa configura los registros con los parámetros requeridos y ejecuta la instrucción int 0x80.

[click] Segundo, la CPU detiene la ejecución secuencial, consulta la tabla de descriptores de interrupción en la entrada 0x80, cambia el puntero de pila hacia la pila del núcleo y salva el estado del usuario.

[click] Tercero, el núcleo recibe el control mediante el despachador de llamadas, busca la rutina correspondiente en la tabla interna indexada por EAX y la ejecuta. Al finalizar, deposita el resultado en EAX y ejecuta la instrucción iret para volver al espacio de usuario.

[click] En el esquema de la derecha podemos apreciar con total claridad este viaje de ida y vuelta a través de la frontera de privilegios.

---

### Diapositiva 05: Convención de llamadas en IA-32

Estudiemos la convención formal de registros para invocar llamadas al sistema bajo Linux IA-32.

[click] El registro EAX es el selector central: almacena el número que identifica qué servicio del núcleo estamos solicitando.

[click] El registro EBX recibe el primer argumento de la llamada, como el descriptor de archivo o el código de retorno.

[click] El registro ECX recibe el segundo parámetro, casi siempre una dirección de memoria donde se ubica la información.

[click] Y el registro EDX contiene el tercer parámetro, indicando el límite de bytes a procesar.

[click] En esta tabla resumimos las tres llamadas elementales que utilizaremos en esta sesión: sys_exit identificada con el número uno, sys_read con el número tres y sys_write con el número cuatro.

[click] Prestemos especial atención al retorno: tras ejecutar la interrupción, el núcleo devuelve el resultado directamente en EAX. Un valor positivo indica la cantidad real de bytes operados, mientras que un valor negativo denota un error del sistema.

---

### Diapositiva 06: Comparativa arquitectónica: x86 frente a x86-64

Es crucial comparar el mecanismo clásico de 32 bits contra la arquitectura x86-64 moderna.

[click] En sistemas de 32 bits, la invocación se realiza mediante la interrupción de software int 0x80. Este mecanismo implica consultar la tabla IDT en memoria y salvar registros en la pila, con un costo apreciable de ciclos de procesador.

[click] En contraste, en x86-64 los procesadores incorporan la instrucción dedicada syscall, la cual conmuta al modo núcleo casi instantáneamente mediante registros internos MSR preconfigurados por el sistema operativo.

[click] A la derecha observamos cómo cambia la convención de registros: mientras que en 32 bits usamos EAX, EBX, ECX y EDX, en 64 bits se utilizan RAX, RDI, RSI y RDX.

[click] Tengamos presente que los números de servicio también cambian entre ambas arquitecturas. En nuestras prácticas utilizaremos estrictamente el estándar IA-32 de 32 bits.

---

### Diapositiva 07: Descriptores de archivo en POSIX

En los sistemas UNIX y Linux rige el principio de que los canales de comunicación se gestionan como flujos homogéneos de bytes mediante descriptores de archivo.

Al crearse cualquier proceso, el sistema operativo abre automáticamente tres descriptores universales:

[click] El descriptor cero corresponde a la entrada estándar, conectado inicialmente al teclado.

[click] El descriptor uno corresponde a la salida estándar, conectado a la pantalla de la terminal.

[click] Y el descriptor dos es el canal de error estándar, destinado a emitir diagnósticos sin interferir con la salida de datos normal.

[click] Observemos a la derecha la tabla de descriptores que mantiene el núcleo en el bloque de control del proceso. Los números tres en adelante quedan disponibles para archivos físicos en disco.

[click] En ensamblador simplemente cargamos el número correspondiente en EBX antes de solicitar la llamada al sistema.

---

### Diapositiva 08: Secciones de memoria en NASM

Revisemos cómo organizamos las secciones de un archivo fuente en NASM.

[click] La sección punto text alberga las instrucciones que ejecutará la CPU. El sistema operativo le asigna atributos de sólo lectura y ejecución para prevenir corrupciones o modificaciones accidentales del código.

[click] La sección punto data almacena cadenas de caracteres y variables globales con contenido inicial conocido desde el momento de compilar.

[click] La sección punto bss se utiliza para reservar memoria de trabajo y buffers que recibirán datos durante la ejecución, como la entrada del usuario.

[click] En el bloque de código de la derecha apreciamos cómo delimitamos de forma limpia cada sección dentro de un archivo de ensamblador.

[click] Notemos la enorme ventaja de la sección BSS: reservar un buffer de sesenta y cuatro kilobytes no incrementa el peso del binario en el disco, ya que el cargador de Linux asigna y limpia la memoria en RAM en tiempo de carga.

---

### Diapositiva 09: Directivas de definición y reserva

Veamos en detalle las directivas para definir y reservar datos.

[click] Para inicializar variables en la sección data utilizamos db para bytes de 8 bits, dw para palabras de 16 bits y dd para palabras dobles de 32 bits.

[click] En cambio, dentro de la sección BSS empleamos las directivas resb, resw o resd seguidas de la cantidad de elementos a reservar.

[click] Para no contar letras manualmente al emitir mensajes, usamos la fórmula dólar menos la etiqueta inicial. El símbolo de dólar indica la dirección de ensamblado actual, de modo que la resta produce exactamente la cantidad de bytes del texto.

[click] La directiva equ crea una constante simbólica en tiempo de ensamblado sin gastar memoria física, logrando un código mantenible y seguro.

---

### Diapositiva 10: Ejemplo guiado: Salida en consola

Analicemos este primer programa completo en ensamblador con llamadas al sistema.

[click] En la sección de datos declaramos el mensaje terminando en el salto de línea hexadecimal 0x0A y calculamos su longitud automática.

[click] Para emitir el texto por pantalla preparamos sys_write con EAX en cuatro, la salida estándar en EBX con uno, el puntero del mensaje en ECX y la longitud en EDX antes de invocar la interrupción 0x80.

[click] Seguidamente preparamos sys_exit con EAX en uno y código de terminación exitosa cero en EBX, entregando el control de vuelta al sistema operativo.

[click] Para compilar y ejecutar en Linux de 32 bits generamos el objeto ELF con nasm y enlazamos con ld usando la emulación elf_i386.

---

### Diapositiva 11: Síntesis de la primera sesión

Con esto concluimos la primera sesión teórica. Hemos cubierto los fundamentos del modo dual, el funcionamiento de la interrupción 0x80, la convención de llamadas y las secciones de memoria.

[click] Les dejo esta pregunta detonante para reflexionar antes de pasar al taller práctico: cuando el usuario presiona Enter, la entrada almacena el byte 0x0A. ¿Cómo manipulamos la memoria para convertirlo en una cadena terminada en nulo?

---

### Diapositiva 12: Portada de la segunda sesión

¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de la separación de privilegios, la tabla de descriptores y la convención de llamadas al sistema, dedicaremos esta jornada completa a la programación práctica interactiva, depuración en vivo con GDB y consolidación analítica.

---

### Diapositiva 13: Objetivos de la segunda sesión

Antes de comenzar con los ejercicios prácticos, repasemos los objetivos de esta segunda sesión:

[click] Primero, implementaremos la lectura interactiva desde el teclado utilizando sys_read hacia buffers en la sección BSS.

[click] Segundo, aprenderemos a sanitizar la entrada reemplazando el salto de línea por el byte nulo terminador.

[click] Tercero, aplicaremos buenas prácticas de seguridad acotando el tamaño máximo de captura para evitar desbordamientos de buffer.

[click] Cuarto, utilizaremos el depurador GDB para inspeccionar en vivo los registros antes y después de cada llamada al sistema.

[click] Y quinto, analizaremos las trampas más frecuentes al interactuar con el núcleo para blindar nuestro código contra fallos de segmentación.

---

### Diapositiva 14: Captura con sys_read

Iniciemos la parte práctica analizando el funcionamiento de la llamada sys_read.

[click] Para capturar texto, configuramos EAX con tres, EBX con cero correspondiente a stdin, ECX con la dirección de nuestro buffer y EDX con la capacidad máxima que estamos dispuestos a admitir.

[click] Cuando el usuario termina de escribir y presiona la tecla Enter, el sistema operativo reactiva el proceso y coloca en EAX la cantidad exacta de bytes leídos.

[click] Observemos detenidamente el mapa de memoria del buffer a la derecha. Si el usuario escribe Juan y presiona Enter, el buffer almacena las cuatro letras más el carácter de salto de línea 0x0A, totalizando cinco bytes en EAX.

---

### Diapositiva 15: Saludo interactivo en consola

Construyamos este programa interactivo paso a paso.

En la columna izquierda vemos la primera etapa: solicitamos el nombre emitiendo una pregunta con sys_write y luego invocamos sys_read pasando nuestro buffer nom de treinta y dos bytes.

[click] Notemos que guardamos inmediatamente el retorno de EAX en la variable bytes_leidos. Esto es indispensable porque la siguiente llamada al sistema sobreescribirá EAX con su propio valor.

Finalmente, en la columna derecha imprimimos el prefijo Hola seguido del nombre del usuario empleando exactamente los bytes que fueron leídos, terminando con sys_exit.

---

### Diapositiva 16: Supresión del salto de línea

Un problema recurrente en las aplicaciones de consola es que el salto de línea queda incrustado dentro del texto recibido.

Si el usuario escribió cuatro letras y presionó Enter, leímos cinco bytes. Dado que los arreglos inician en el índice cero, las letras ocupan las posiciones cero a tres, y el salto de línea 0x0A se sitúa en la posición cuatro.

[click] Con la instrucción dec eax reducimos el conteo a cuatro, apuntando exactamente al índice donde yace el carácter 0x0A. Luego almacenamos un byte cero mediante direccionamiento base más índice.

[click] Observemos la transición en la columna derecha: el carácter de salto de línea desaparece y la cadena se convierte en una cadena ASCIIZ estándar, lista para interactuar con funciones de C o bibliotecas externas.

---

### Diapositiva 17: Depuración de llamadas con GDB

Veamos cómo emplear el depurador GDB para inspeccionar nuestras llamadas al sistema.

[click] Al compilar con NASM es fundamental incluir los modificadores menos g y menos F dwarf para generar información simbólica completa para el depurador.

[click] Dentro de GDB colocamos un punto de interrupción en la etiqueta start y avanzamos con stepi o nexti para posicionarnos justo antes de la instrucción int 0x80.

[click] Con info registers verificamos que los cuatro registros clave tengan los valores previstos: EAX con el número de llamada, EBX con el descriptor, ECX con el puntero al buffer y EDX con la longitud.

[click] Con el comando examine x/s comprobamos el texto apuntado por ECX en memoria, verificando la integridad de los datos antes de solicitar la operación al núcleo.

---

### Diapositiva 18: Trampas comunes en llamadas

Revisemos las trampas más recurrentes al trabajar con llamadas al sistema operativo.

[click] La primera es omitir sys_exit. En ensamblador la ejecución no se detiene al terminar el archivo: si no invocamos sys_exit explícitamente, la CPU continuará ejecutando bytes basura de memoria hasta provocar un fallo de segmentación.

[click] La segunda trampa es confundir la dirección con el contenido. En ECX debemos pasar la etiqueta msg sin corchetes, de lo contrario pasaremos el valor numérico de las letras como si fuera un puntero a memoria.

[click] La tercera es olvidar que tras int 0x80 el registro EAX queda completamente sobreescrito con la respuesta del núcleo.

[click] A la derecha observamos las correcciones estándar para cada uno de estos escenarios.

---

### Diapositiva 19: Ejercicios de práctica (Parte 1)

Evaluemos lo aprendido con esta primera ronda de ejercicios de consolidación.

Pregunta uno: ¿Por qué un programa de usuario no puede manipular directamente el hardware?
[click] Exacto, opción B: el hardware impide ejecutar instrucciones privilegiadas fuera del anillo cero detonando un fallo general de protección.

Pregunta dos: ¿Qué registro contiene el código del servicio en Linux IA-32?
[click] Muy bien, el registro EAX.

Pregunta tres: Para enviar un mensaje de error por stderr, ¿cuál descriptor cargamos en EBX?
[click] Correcto, el descriptor numérico dos.

---

### Diapositiva 20: Ejercicios de práctica (Parte 2)

Continuemos con la segunda ronda de ejercicios prácticos.

Pregunta cuatro: ¿Cuánto espacio suma al ejecutable en disco una reserva en la sección BSS?
[click] Excelente, cero bytes, porque la memoria se asigna dinámicamente en RAM al cargar el programa.

Pregunta cinco: Al escribir TEC y presionar Enter, ¿cuántos bytes retorna sys_read?
[click] Muy bien, retorna cuatro bytes debido a la inclusión del carácter de fin de línea 0x0A.

Pregunta seis: ¿Por qué es un error usar corchetes al cargar la dirección del buffer en ECX?
[click] Exactamente, la opción B: los corchetes cargan los caracteres del texto como si fueran un puntero numérico, provocando que el kernel intente leer una dirección inválida.

---

### Diapositiva 21: Conclusiones y siguiente paso

Con esto concluimos la novena semana de tutorías de Arquitectura de Computadores.

Hemos construido un puente sólido entre el código puro de máquina y los servicios del sistema operativo, dominando la entrada, salida y depuración interactiva sin dependencias de alto nivel.

En la próxima semana daremos un salto decisivo hacia la manipulación eficiente de bloques masivos de memoria mediante las instrucciones de cadenas y los prefijos de repetición en hardware.

¡Muchas gracias a todos por su compromiso y nos vemos en la siguiente sesión!
