# Guión de exposición oral: Semana 11
## Manejo de archivos en disco, macros y modularización (C con NASM)
### IC3101: Arquitectura de computadores

Este documento compila el guión oral del tutor para las dos sesiones de 90 minutos de la Semana 11, sincronizado con cada diapositiva y marcador de animación `[click]`.

---

### Diapositiva 01: Diapositiva 1

(Sin notas del presentador)

---

### Diapositiva 02: Manejo de archivos en disco, macros y modularización

Bienvenidos a la undécima semana de tutorías de Arquitectura de Computadores.

En las sesiones anteriores aprendimos a comunicarnos con el núcleo mediante interrupciones de software y a manipular cadenas de texto masivamente en memoria.

Hoy daremos un salto fundamental hacia la persistencia de datos: aprenderemos cómo crear, leer, escribir y posicionar punteros en archivos físicos en disco mediante llamadas al sistema operativo.

Asimismo, exploraremos el potente preprocesador de NASM con macros multiparámetro y comprenderemos cómo construir proyectos híbridos modulares que conectan código en lenguaje C con rutinas de alto rendimiento en ensamblador.

---

### Diapositiva 03: Objetivos de la primera sesión

Antes de entrar en materia teórica, repasemos los objetivos de esta primera sesión:

[click] Primero, comprenderemos la filosofía Unix donde todo es un archivo y cómo el núcleo gestiona los descriptores en el bloque de control del proceso.

[click] Segundo, estudiaremos las llamadas al sistema fundamentales para crear, abrir, leer, escribir, cerrar y reposicionar punteros en archivos físicos en disco.

[click] Tercero, aprenderemos a combinar banderas de acceso mediante operaciones a nivel de bits y a configurar permisos en formato octal.

[click] Cuarto, analizaremos el manejo profesional de fallos del kernel interpretando los códigos negativos de retorno en EAX.

[click] Quinto, exploraremos las herramientas del preprocesador de NASM para definir constantes simbólicas, incluir cabeceras y construir macros seguras con etiquetas locales.

[click] Y sexto, dominaremos el estándar binario de llamadas cdecl para transferir parámetros por la pila y enlazar módulos de C con subrutinas en ensamblador.

---

### Diapositiva 04: Persistencia y descriptores de archivo

Recordemos el principio cardinal de los sistemas tipo Unix: todo recurso de entrada y salida se modela conceptualmente como un archivo.

En la semana 9 estudiamos los tres canales estándar: cero para teclado, uno para pantalla y dos para errores.

[click] Cuando solicitamos al sistema operativo abrir un archivo almacenado físicamente en disco, el subsistema de archivos busca la primera casilla vacía en la tabla de descriptores del bloque de control del proceso, asignando típicamente el descriptor 3.

[click] La comunicación con almacenamiento persistente exige respetar un ciclo riguroso: abrir, transferir datos y cerrar. Si un programa olvida cerrar sus descriptores, provoca una fuga de recursos que satura la tabla del núcleo.

[click] Observemos a la derecha cómo el archivo /tmp/datos.txt obtiene el descriptor 3 y un segundo archivo recibe el descriptor 4.

[click] Al invocar sys_close sobre el descriptor 3, esa ranura queda disponible de inmediato para futuras operaciones.

---

### Diapositiva 05: Llamadas al sistema para archivos en Linux

En Linux de 32 bits, la invocación de llamadas al sistema se realiza cargando el número del servicio en EAX y sus parámetros en EBX, ECX y EDX antes de disparar int 0x80.

La llamada más elemental para crear un archivo nuevo es sys_creat, correspondiente al servicio 8.

[click] Sin embargo, la función más versátil es sys_open con el servicio 5, la cual permite abrir archivos existentes en solo lectura, lectura y escritura, o crearlos si no existen mediante banderas.

[click] Notemos que las llamadas sys_read y sys_write que usamos en la semana 9 para consola son exactamente las mismas para archivos en disco. La única diferencia radica en que EBX recibe el descriptor devuelto por el archivo en lugar de los números fijos 0 o 1.

[click] Finalmente, sys_close en el servicio 6 se encarga de vaciar los buffers del sistema y desenlazar el descriptor.

[click] En la tabla derecha apreciamos la correspondencia simétrica y exacta de registros para cada una de estas operaciones fundamentales.

---

### Diapositiva 06: Banderas de acceso y permisos octales

Para abrir un archivo con sys_open debemos suministrar dos parámetros clave: las banderas de acceso en ECX y los permisos en EDX.

Las tres banderas de acceso mutuamente excluyentes son O_RDONLY con valor cero, O_WRONLY con valor uno y O_RDWR con valor dos.

[click] Si deseamos que el archivo sea creado en caso de no existir, agregamos la bandera O_CREAT sumando 64. Y si queremos limpiar el archivo existente a cero bytes, agregamos O_TRUNC con valor 512. La suma binaria 1 + 64 + 512 arroja el valor 577 en decimal.

[click] Los permisos de archivo en Linux se expresan mediante el sistema octal tradicional. Nueve bits representan los permisos de lectura, escritura y ejecución para el dueño, el grupo y el resto de los usuarios del sistema.

[click] La máscara más habitual para archivos de texto es 0644 en octal, que confiere permisos de lectura y escritura al usuario creador y solo lectura a los demás. En NASM podemos escribirlo directamente con el sufijo 'o' o 'q'.

---

### Diapositiva 07: Tratamiento riguroso de errores del núcleo

Un programador profesional de sistemas nunca asume que una llamada al sistema tuvo éxito. En almacenamiento masivo, los errores son cotidianos: el archivo puede no existir, el usuario puede carecer de permisos o el disco puede estar lleno.

Cuando una syscall falla, el kernel Linux coloca en el registro EAX un entero negativo entre -1 y -4095.

[click] Este valor negativo se corresponde exactamente con los códigos estándar de la biblioteca errno de C. Por ejemplo, -2 significa que el archivo no existe y -13 indica que se denegó el permiso de acceso.

[click] En la columna derecha observamos el patrón idiomático en NASM. Tras invocar int 0x80, comparamos EAX con cero mediante cmp eax, 0 y bifurcamos con jl o comprobamos con test eax, eax seguido de js.

[click] Si el descriptor es válido, lo preservamos en memoria antes de que cualquier otra operación altere el registro EAX.

---

### Diapositiva 08: Desplazamiento y acceso con sys_lseek

Por defecto, las operaciones de entrada y salida son estrictamente secuenciales. Sin embargo, en bases de datos y estructuras complejas necesitamos acceder a cualquier registro arbitrario sin tener que leer todo el archivo previo.

Para esto existe sys_lseek, correspondiente a la llamada al sistema 19.

[click] El registro EDX determina el origen de la referencia: SEEK_SET con valor 0 mide desde el inicio, SEEK_CUR con valor 1 desde la posición actual del cursor y SEEK_END con valor 2 desde el byte final.

[click] En el código de la derecha apreciamos un algoritmo clásico en desarrollo de sistemas: si solicitamos un desplazamiento de 0 bytes relativo a SEEK_END, el cursor se sitúa al final del archivo y el kernel devuelve en EAX el tamaño exacto del archivo en bytes.

[click] Posteriormente, basta con invocar sys_lseek con desplazamiento 0 respecto a SEEK_SET para rebobinar el archivo y comenzar a leer sus datos desde el inicio.

---

### Diapositiva 09: Preprocesador de NASM: constantes y macros

A medida que nuestros programas de bajo nivel crecen, escribir números mágicos como 5, 3 o 4 directamente en el código oscurece la lectura y propicia errores difíciles de depurar.

NASM incorpora un procesador de macros de una potencia extraordinaria que actúa sobre el código fuente antes de que se genere una sola instrucción de máquina.

[click] Mediante %define creamos constantes simbólicas que sustituyen texto de forma limpia.

[click] La directiva %include nos permite dividir un proyecto grande en módulos lógicos, ubicando las definiciones del sistema operativo en archivos .inc reutilizables.

[click] A diferencia de una función llamada con call y ret, una macro copia su bloque de instrucciones directamente en el punto del código donde se invoca. No hay penalización de salto ni de pila, pero cada invocación incrementa el tamaño del ejecutable.

---

### Diapositiva 10: Macros con parámetros y etiquetas locales

El verdadero poder de las macros de NASM radica en su capacidad de recibir parámetros.

Definimos una macro indicando su nombre y la cantidad de argumentos que espera, accediendo a ellos mediante %1, %2, etc.

[click] Pero atención a una de las trampas más frecuentes: si nuestra macro contiene saltos condicionales y etiquetas ordinarias, al invocarla dos veces en el mismo programa NASM intentará definir el mismo símbolo dos veces, produciendo un error fatal de ensamblado.

[click] La solución que nos ofrece NASM es anteponer dos signos de porcentaje: %%error_escritura. Cada vez que la macro se expande, NASM reemplaza %% por un prefijo interno numérico irrepetible.

[click] En el ejemplo de la derecha podemos llamar a escribir_seguro diez veces seguidas sin el menor riesgo de colisión de símbolos.

---

### Diapositiva 11: Enlace separado y proyectos híbridos C + NASM

En la práctica profesional de sistemas, rara vez se programa una aplicación de miles de líneas en un único archivo de código.

Para que un archivo en C pueda invocar una rutina escrita en NASM, debemos declarar el nombre de la función como global en ensamblador. De lo contrario, el símbolo será privado y el enlazador rechazará el enlace por referencia indefinida.

[click] Esta arquitectura híbrida nos brinda una ventaja colosal: redactamos el menú, el análisis de argumentos y las estructuras en C, y delegamos la operación intensiva de archivos o algoritmos de hashing al módulo en NASM.

[click] La compilación se divide en dos pasos claros: NASM produce el archivo objeto ELF32 de la rutina y GCC genera el objeto de C, enlazándolos con el flag -m32.

[click] El enlazador unifica las tablas de símbolos y genera el ejecutable final sin fricciones.

---

### Diapositiva 12: Convención de llamadas cdecl en Linux x86

Para que un binario compilado por GCC pueda ejecutar código ensamblado por NASM sin corromper la memoria, ambos deben respetar rigurosamente un contrato: la convención de llamadas cdecl.

En cdecl de 32 bits, los argumentos se pasan a través de la pila en orden inverso.

[click] El valor de retorno debe quedar estrictamente en EAX. Si la función devuelve un int o un puntero, C buscará el resultado exclusivamente en EAX.

[click] La responsabilidad de limpiar la pila corresponde al llamador, no a la función que retorna.

[click] Y la regla de oro que previene errores fatales de segmentación: los registros EBX, ESI, EDI y EBP pertenecen al llamador. Si en nuestro código NASM necesitamos usarlos, es obligatorio guardarlos en la pila con push al inicio y recuperarlos con pop antes de ejecutar ret.

---

### Diapositiva 13: Sesión 02: Práctica guiada

¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de persistencia, llamadas al sistema, preprocesador de macros y convención cdecl, dedicaremos esta jornada completa a la programación práctica en consola, implementando rutinas de archivo paso a paso y construyendo un proyecto modular híbrido con C y NASM.

---

### Diapositiva 14: Objetivos de la segunda sesión

Antes de iniciar los ejercicios prácticos, repasemos los cuatro objetivos de esta segunda jornada:

[click] Primero, aprenderemos a crear archivos en disco físico aplicando permisos octales, escribiendo registros en memoria y cerrando el descriptor con seguridad.

[click] Segundo, diseñaremos un bucle robusto de lectura por bloques que detecta con precisión el fin de archivo cuando EAX es cero, complementado con cálculo de tamaño mediante sys_lseek.

[click] Tercero, construiremos una librería de macros reutilizable en un archivo .inc aplicando etiquetas locales seguras.

[click] Y cuarto, unificaremos C y NASM en un proyecto ejecutable enlazado con GCC de 32 bits, verificando la convención cdecl.

---

### Diapositiva 15: Creación y apertura con descriptor de archivo

Comenzamos analizando la especificación técnica del problema.

Queremos crear el archivo /tmp/registro.txt con permisos estándar de lectura y escritura para el usuario y lectura para los demás (0644 en octal).

[click] En la sección de datos declaramos la ruta como cadena ASCIIZ terminada en cero nulo y el texto que deseamos almacenar. En la sección no inicializada .bss reservamos cuatro bytes con resd 1 para almacenar el descriptor devuelto.

[click] Para invocar sys_creat preparamos EAX con 8, EBX con la dirección de la ruta y ECX con 0644o. Al ejecutarse int 0x80, el kernel creará el archivo y nos entregará su descriptor en EAX.

---

### Diapositiva 16: Escritura de datos y cierre seguro del descriptor

En esta diapositiva implementamos el flujo completo de escritura en ensamblador.

Notemos las cuatro fases claramente delimitadas. Primero preparamos sys_creat.

[click] Al recibir la respuesta del kernel, comparamos inmediatamente EAX con 0. Si es negativo, saltamos a la rutina de tratamiento de error. Si es positivo, almacenamos el descriptor en memoria.

[click] Para escribir el mensaje en el archivo, preparamos sys_write con EAX en 4, pasando el descriptor almacenado en EBX, la dirección del texto en ECX y la longitud en EDX.

[click] Finalmente, cerramos el archivo con sys_close en EAX = 6. Este paso es imperativo: si el proceso termina sin cerrar el descriptor, se corre el riesgo de perder datos almacenados en los buffers del kernel.

---

### Diapositiva 17: Diagnóstico de errores y verificación de archivo

Para cerrar esta primera etapa, analizamos cómo responder ante situaciones anómalas.

Si el archivo no se puede crear, la bifurcación jl nos envía a la etiqueta .error_creat.

[click] Notemos que emitimos el mensaje de diagnóstico hacia el descriptor 2 (stderr) y terminamos el proceso con código de salida 1, indicando fallo al entorno de ejecución.

[click] En la terminal verificamos el resultado mediante los comandos estándar de Linux: ls -l corrobora los permisos octales 0644 asignados, mientras que cat y hexdump demuestran que el texto se escribió con fidelidad absoluta en el disco.

---

### Diapositiva 18: Lectura secuencial por bloques y detección de EOF

Pasamos ahora a la lectura secuencial de archivos en disco.

En aplicaciones reales nunca debemos asumir que un archivo cabe en un buffer fijo. Por ello, empleamos la técnica de ventanas de lectura en bloques de tamaño constante, como 64 o 256 bytes.

[click] La clave para controlar el ciclo de lectura radica en evaluar rigurosamente el valor devuelto por sys_read en EAX: un número positivo representa los bytes leídos en esa iteración, cero señala que alcanzamos el final del archivo y un número negativo denota un error de hardware.

[click] En el diagrama de la derecha vemos el flujo cíclico: leemos un bloque, emitimos sus bytes a la pantalla, y repetimos hasta que el kernel retorne cero en EAX.

---

### Diapositiva 19: Implementación del bucle de lectura y emisión

Analicemos la implementación técnica del bucle de lectura.

Abrimos el archivo con modo O_RDONLY (cero) y validamos el descriptor devuelto.

[click] Dentro de .bucle_lectura, solicitamos hasta 64 bytes con sys_read.

[click] Inmediatamente comparamos EAX con 0. Si es menor o igual a cero, saltamos a .fin_archivo. Si EAX es cero, alcanzamos el final del archivo sin errores; si es negativo, se presentó una falla.

[click] Si se leyeron datos positivos, pasamos ese mismo valor de EAX a EDX y llamamos a sys_write sobre el descriptor 1 (la pantalla de la terminal), reutilizando el buffer de inmediato para la siguiente iteración.

---

### Diapositiva 20: Posicionamiento en archivos con sys_lseek

Para culminar esta fase, examinemos la llamada sys_lseek.

Cuando terminamos de leer o escribir un archivo, el cursor queda posicionado al final. Si quisiéramos leerlo de nuevo sin cerrarlo y reabrirlo, la única manera es mediante sys_lseek.

[click] En el código observamos el procedimiento de dos pasos: primero situamos el cursor en el extremo final con SEEK_END para capturar el tamaño exacto en EAX, y de inmediato lo rebobinamos al byte cero con SEEK_SET.

[click] Este patrón es el que emplean los enlazadores y cargadores de programas para inspeccionar encabezados de archivos ejecutables antes de transferirlos a memoria.

---

### Diapositiva 21: Abstracción de llamadas al sistema con macros

Abordamos a continuación la ingeniería de macros para construir bibliotecas de código reutilizable.

En lugar de reescribir una y otra vez la carga de registros para int 0x80, diseñamos macros limpias y expresivas.

[click] Observemos cómo la macro abrir_archivo recibe la ruta y las banderas, ejecuta la llamada y valida el retorno.

[click] Al utilizar %%error_abrir y %%exito_abrir, NASM se asegura de que cada vez que utilicemos la macro en cualquier parte de nuestro proyecto, las etiquetas internas tengan nombres absolutamente únicos, erradicando los molestos errores de símbolo duplicado.

---

### Diapositiva 22: Construcción de cabecera modular para llamadas

Aquí vemos el resultado final de aplicar modularidad mediante macros.

Creamos una cabecera llamada archivos.inc con todas nuestras macros y constantes.

[click] Al incluirla con %include en el programa principal, miremos lo limpio y elegante que resulta el código en _start.

[click] Abrimos el archivo, escribimos el buffer, cerramos el descriptor y finalizamos el programa en apenas cuatro líneas declarativas de ensamblador, conservando la velocidad pura del código de máquina.

---

### Diapositiva 23: Interfaz binaria de llamadas entre C y NASM

Llegamos ahora a la integración donde uniremos el lenguaje C con NASM en una solución híbrida.

En el archivo de C declaramos la función contar_bytes como extern int, indicando que su implementación reside en un módulo binario externo.

[click] En 32 bits bajo cdecl, el llamador apila el argumento antes del call. Al entrar a la subrutina y construir el marco de pila con push ebp y mov ebp, esp, el argumento de la ruta se ubica ineludiblemente en la dirección [ebp + 8].

[click] Asimismo, dado que utilizaremos EBX para invocar llamadas al sistema, es obligatorio respaldar EBX con push ebx para cumplir con la convención callee-saved.

---

### Diapositiva 24: Subrutina NASM invocada desde lenguaje C

En esta diapositiva apreciamos el código completo de la subrutina contar_bytes en NASM.

Observen el prólogo: push ebp, mov ebp, esp y push ebx.

[click] Extraemos la ruta directamente desde la pila con [ebp + 8] y abrimos el archivo con sys_open.

[click] Con el descriptor en EBX, ejecutamos sys_lseek hacia SEEK_END. El tamaño del archivo queda en EAX. Lo guardamos momentáneamente en la pila con push eax mientras cerramos el archivo con sys_close, y lo recuperamos con pop eax.

[click] El epílogo restaura fielmente EBX y EBP, ejecutando ret. El programa en C recibirá exactamente el valor que dejamos en EAX.

---

### Diapositiva 25: Programa anfitrión en C y cadena de enlazado

Para completar la solución híbrida, redactamos el programa principal en C.

Observen qué sencillo resulta: main.c valida que el usuario proporcione un archivo en la línea de comandos e invoca contar_bytes exactamente como si fuera una función de la biblioteca estándar de C.

[click] En la consola ejecutamos los dos pasos de compilación: nasm -f elf32 genera el objeto de la subrutina, y gcc -m32 compila main.c enlazándolo con contar_bytes.o en un binario ejecutable único.

[click] Al ejecutar la aplicación contra nuestro archivo generado previamente, obtenemos la medición precisa de 30 bytes, integrando armónicamente ambos lenguajes.

---

### Diapositiva 26: Ejercicios de práctica

Iniciamos la primera ronda de ejercicios formativos.

Pregunta 1: Recordemos que el kernel de Linux nunca devuelve cero para indicar error de apertura. Cero es el descriptor legítimo de stdin. La respuesta correcta es la B: el kernel coloca en EAX el valor negativo -2, que corresponde al código de error estándar ENOENT de archivo inexistente.

Pregunta 2: Una macro se expande textualmente en la etapa de preensamblado. Si llamamos a la macro 5 veces, el bloque de instrucciones se copia 5 veces en la sección de texto, elevando el peso del archivo ejecutable. En cambio, call salta a una única dirección compartida. La opción correcta es la A.

Pregunta 3: La bandera O_TRUNC tiene como propósito expreso truncar la longitud del archivo existente a cero bytes. Por tanto, la opción correcta es la C: el archivo preexistente queda vacío y listo para recibir los nuevos datos sin generar ningún error de colisión.

---

### Diapositiva 27: Ejercicios de práctica

Continuamos con la siguiente ronda de reactivos formativos.

Pregunta 4: A diferencia de la lectura en consola donde el usuario puede ingresar líneas vacías, en archivos físicos en disco la condición universal de fin de archivo ocurre cuando sys_read retorna cero en EAX, indicando que el cursor alcanzó el último byte. La respuesta correcta es la B.

Pregunta 5: De acuerdo con la especificación cdecl de IA-32, EBX, ESI, EDI y EBP pertenecen a la categoría callee-saved. Si la rutina los modifica, está estrictamente obligada a restaurar los valores exactos que tenían antes de la llamada. La respuesta correcta es la C.

Pregunta 6: Cada proceso en Linux tiene un límite en la cantidad máxima de descriptores abiertos simultáneamente (típicamente 1024). Si olvidamos cerrarlos, la tabla se satura y las subsecuentes llamadas a sys_open fallarán con el código de error EMFILE (-24). La opción correcta es la A.

---

### Diapositiva 28: Diapositiva 28

Llegamos al final de la semana 11 habiendo dominado tres pilares esenciales de los sistemas de cómputo.

Primero, la persistencia en disco: sabemos cómo crear, inspeccionar, leer y escribir archivos físicos manejando descriptores y evaluando códigos de error del kernel.

Segundo, las macros de NASM: ahora disponemos de herramientas de preprocesado para diseñar bibliotecas modulares legibles y seguras sin colisión de etiquetas.

Y tercero, la interoperabilidad híbrida: comprendemos a nivel de bits la convención cdecl para construir proyectos reales donde C y ensamblador trabajan en perfecta sincronía.

Con estas competencias estamos plenamente equipados para abordar los temas de microarquitectura y segmentación de instrucciones que nos esperan la próxima semana. ¡Muchas gracias a todos por su participación y excelente trabajo!
