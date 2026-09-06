---
theme: default
background: https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?q=80&w=1920&auto=format&fit=crop
title: Tutoría 11 - Manejo de archivos en disco, macros y modularización (C con NASM)
info: |
  ## Tutoría 11: Manejo de archivos en disco, macros y modularización (C con NASM)
  Arquitectura de Computadores (IC3101)
  Instituto Tecnológico de Costa Rica
class: text-center
drawings:
  persist: false
transition: slide-left | slide-right
mdc: true
fonts:
  sans: 'Inter'
  serif: 'Noto Serif'
  mono: 'JetBrains Mono'
css: unocss
---

<div class="flex flex-col items-center justify-center h-full text-center">
  <div class="text-xs font-semibold px-3 py-1 rounded-full bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/60 dark:text-blue-300 dark:border-blue-800/40 mb-3 tracking-wide uppercase font-mono">
    IC3101 &bull; Arquitectura de Computadores
  </div>

  # Manejo de archivos en disco, macros y modularización

  <div class="text-gray-600 dark:text-gray-400 text-sm max-w-2xl mx-auto mt-2 leading-relaxed">
    Persistencia en el sistema de archivos con llamadas al sistema, preprocesador de NASM y proyectos híbridos de lenguaje C con ensamblador
  </div>

  <div class="mt-8 flex gap-4 text-xs font-mono text-gray-500 dark:text-gray-400">
    <span>Semana 11</span>
    <span>&bull;</span>
    <span>Modalidad bi-sesional (2 sesiones &times; 1.5 horas)</span>
    <span>&bull;</span>
    <span>Linux x86 (IA-32)</span>
  </div>
</div>

<!--
Bienvenidos a la undécima semana de tutorías de Arquitectura de Computadores.

En las sesiones anteriores aprendimos a comunicarnos con el núcleo mediante interrupciones de software y a manipular cadenas de texto masivamente en memoria.

Hoy daremos un salto fundamental hacia la persistencia de datos: aprenderemos cómo crear, leer, escribir y posicionar punteros en archivos físicos en disco mediante llamadas al sistema operativo.

Asimismo, exploraremos el potente preprocesador de NASM con macros multiparámetro y comprenderemos cómo construir proyectos híbridos modulares que conectan código en lenguaje C con rutinas de alto rendimiento en ensamblador.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Hoja de ruta de la semana

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Estructura bi-sesional planificada para el dominio integral de persistencia y modularidad:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-1 font-mono">Sesión 01: Fundamentos teóricos y modelos</div>
    <ul class="space-y-1 text-gray-600 dark:text-gray-300">
      <li>&bull; Abstracción del sistema de archivos en Linux y tabla de descriptores en el PCB.</li>
      <li>&bull; Llamadas al sistema: <i>sys_creat</i>, <i>sys_open</i>, <i>sys_read</i>, <i>sys_write</i>, <i>sys_close</i> y <i>sys_lseek</i>.</li>
      <li>&bull; Banderas de acceso, modos de creación y permisos octales Unix (0644, 0755).</li>
      <li>&bull; Tratamiento riguroso de errores del núcleo y códigos negativos en EAX.</li>
      <li>&bull; Preprocesador de NASM: constantes <i>%define</i>, inclusiones <i>%include</i> y macros <i>%macro</i>.</li>
      <li>&bull; Interfaz binaria y convención de llamadas estándar <i>cdecl</i> para interoperar C y NASM.</li>
    </ul>
  </div>
</div>

::right::

<div class="space-y-2 font-sans text-[9.5px] mt-8">
  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold text-[10.5px] mb-1 font-mono">Sesión 02: Talleres prácticos y consolidación</div>
    <ul class="space-y-1 text-gray-600 dark:text-gray-300">
      <li>&bull; <strong>Práctica 1 (3 diapositivas):</strong> Creación y apertura con descriptor de archivo, escritura de datos y diagnóstico de fallos en consola.</li>
      <li>&bull; <strong>Práctica 2 (3 diapositivas):</strong> Lectura secuencial por bloques, detección de fin de archivo (EOF) y posicionamiento con <i>sys_lseek</i>.</li>
      <li>&bull; <strong>Práctica 3 (2 diapositivas):</strong> Abstracción de llamadas al sistema con macros y construcción de cabecera modular <i>.inc</i>.</li>
      <li>&bull; <strong>Práctica 4 (3 diapositivas):</strong> Interfaz binaria C+NASM, subrutina de conteo y programa anfitrión enlazado con GCC.</li>
      <li>&bull; <strong>Desafíos de consolidación (2 diapositivas):</strong> Evaluación formativa de 6 reactivos con opciones alineadas y análisis paso a paso.</li>
    </ul>
  </div>
</div>

<!--
Esta diapositiva resume el itinerario completo de la semana.

En la primera sesión abordaremos la teoría de archivos físicos en Linux, el ciclo de vida de los descriptores de archivo, las banderas de apertura, los permisos de Unix en formato octal, la arquitectura del preprocesador de macros y la convención binaria de llamadas cdecl.

[click] Para la segunda sesión, hemos preparado cuatro talleres técnicos extensivos de múltiples diapositivas cada uno. No veremos ejemplos superficiales de una sola lámina, sino el desglose minucioso de cada fase: diseño en memoria, implementación del código en ensamblador y verificación práctica en consola.

Concluiremos con seis ejercicios de consolidación diseñados para fijar cada concepto crítico.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Persistencia y descriptores de archivo

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Abstracción de flujos persistentes en el bloque de control del proceso (PCB):
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-0.5">Filosofía Unix: todo es un archivo</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Linux unifica periféricos, canales de comunicación y almacenamiento masivo bajo una secuencia continua de bytes identificada por un número entero positivo.
    </p>
  </div>
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold text-[10.5px] mb-0.5">Descriptores reservados frente a descriptores en disco</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Los valores 0 (stdin), 1 (stdout) y 2 (stderr) se abren automáticamente al nacer el proceso. Cualquier archivo físico abierto por el usuario recibe el descriptor entero más bajo disponible a partir de 3.
    </p>
  </div>
  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-purple-600 dark:text-purple-400 font-bold text-[10.5px] mb-0.5">Ciclo de vida del recurso persistente</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Todo acceso a disco sigue una secuencia estricta: Apertura/Creación &rarr; Transferencia (Lectura/Escritura) &rarr; Posicionamiento opcional &rarr; Cierre obligatorio para descargar buffers del núcleo.
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] text-center font-sans">
  Tabla de descriptores en memoria del proceso
</div>

<div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl space-y-1.5 font-sans">
  <div class="flex items-center justify-between p-1.5 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded-md font-mono text-[9px] opacity-75">
    <span class="px-1.5 py-0.5 rounded bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 font-bold">FD 0</span>
    <span class="text-gray-700 dark:text-gray-300">stdin</span>
    <span class="text-gray-500 font-sans text-[8.5px]">Teclado (/dev/tty)</span>
  </div>
  <div class="flex items-center justify-between p-1.5 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded-md font-mono text-[9px] opacity-75">
    <span class="px-1.5 py-0.5 rounded bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 font-bold">FD 1</span>
    <span class="text-gray-700 dark:text-gray-300">stdout</span>
    <span class="text-gray-500 font-sans text-[8.5px]">Pantalla (/dev/pts/X)</span>
  </div>
  <div class="flex items-center justify-between p-1.5 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded-md font-mono text-[9px] opacity-75">
    <span class="px-1.5 py-0.5 rounded bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 font-bold">FD 2</span>
    <span class="text-gray-700 dark:text-gray-300">stderr</span>
    <span class="text-gray-500 font-sans text-[8.5px]">Pantalla sin buffer</span>
  </div>
  <div v-click="3" class="flex items-center justify-between p-1.5 bg-emerald-50 dark:bg-emerald-950/40 border border-emerald-300 dark:border-emerald-700/60 rounded-md font-mono text-[9.5px]">
    <span class="px-1.5 py-0.5 rounded bg-emerald-600 text-white font-bold">FD 3</span>
    <span class="font-bold text-emerald-800 dark:text-emerald-300">/tmp/datos.txt</span>
    <span class="text-emerald-700 dark:text-emerald-400 font-sans text-[8.5px]">Archivo regular (disco)</span>
  </div>
  <div v-click="4" class="flex items-center justify-between p-1.5 bg-blue-50 dark:bg-blue-950/40 border border-blue-300 dark:border-blue-700/60 rounded-md font-mono text-[9.5px]">
    <span class="px-1.5 py-0.5 rounded bg-blue-600 text-white font-bold">FD 4</span>
    <span class="font-bold text-blue-800 dark:text-blue-300">/var/log/app.log</span>
    <span class="text-blue-700 dark:text-blue-400 font-sans text-[8.5px]">Archivo en modo append</span>
  </div>
</div>

<div v-click="4" class="mt-2 p-1.5 bg-amber-50 border border-amber-200 dark:bg-amber-950/40 dark:border-amber-800/40 rounded text-[9px] text-amber-900 dark:text-amber-200 font-sans leading-snug">
  <strong>Principio de reutilización:</strong> Cuando un descriptor se cierra con <i>sys_close</i>, el kernel libera la entrada en la tabla para asignarla en la próxima apertura exitosa.
</div>

<!--
Recordemos el principio cardinal de los sistemas tipo Unix: todo recurso de entrada y salida se modela conceptualmente como un archivo.

En la semana 9 estudiamos los tres canales estándar: cero para teclado, uno para pantalla y dos para errores.

[click] Cuando solicitamos al sistema operativo abrir un archivo almacenado físicamente en disco, el subsistema de archivos busca la primera casilla vacía en la tabla de descriptores del bloque de control del proceso, asignando típicamente el descriptor 3.

[click] La comunicación con almacenamiento persistente exige respetar un ciclo riguroso: abrir, transferir datos y cerrar. Si un programa olvida cerrar sus descriptores, provoca una fuga de recursos que satura la tabla del núcleo.

[click] Observemos a la derecha cómo el archivo /tmp/datos.txt obtiene el descriptor 3 y un segundo archivo recibe el descriptor 4.

[click] Al invocar sys_close sobre el descriptor 3, esa ranura queda disponible de inmediato para futuras operaciones.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Llamadas al sistema para archivos en Linux

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Conjunto de servicios del vector de interrupción <i>int 0x80</i> en Linux de 32 bits:
</div>

<div class="space-y-1.5 font-sans text-[9px]">
  <div class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="font-mono font-bold text-blue-600 dark:text-blue-400 text-[10px] flex justify-between">
      <span>sys_creat (Servicio 8)</span>
      <span class="text-gray-500 font-sans text-[8.5px]">Crear y truncar archivo</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 mt-0.5 leading-tight">
      EBX = puntero a ruta ASCIIZ &bull; ECX = permisos octales (ej. 0644o). Devuelve FD en EAX.
    </p>
  </div>
  <div v-click="1" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="font-mono font-bold text-emerald-600 dark:text-emerald-400 text-[10px] flex justify-between">
      <span>sys_open (Servicio 5)</span>
      <span class="text-gray-500 font-sans text-[8.5px]">Apertura con banderas</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 mt-0.5 leading-tight">
      EBX = ruta ASCIIZ &bull; ECX = banderas de acceso (O_RDONLY, etc.) &bull; EDX = permisos si se crea.
    </p>
  </div>
  <div v-click="2" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="font-mono font-bold text-amber-600 dark:text-amber-400 text-[10px] flex justify-between">
      <span>sys_read (Servicio 3) y sys_write (Servicio 4)</span>
      <span class="text-gray-500 font-sans text-[8.5px]">Transferencia</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 mt-0.5 leading-tight">
      EBX = descriptor de archivo &bull; ECX = dirección del buffer &bull; EDX = número máximo de bytes.
    </p>
  </div>
  <div v-click="3" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="font-mono font-bold text-purple-600 dark:text-purple-400 text-[10px] flex justify-between">
      <span>sys_close (Servicio 6)</span>
      <span class="text-gray-500 font-sans text-[8.5px]">Liberar descriptor</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 mt-0.5 leading-tight">
      EBX = descriptor a cerrar. Fuerza la descarga de buffers pendientes al medio físico.
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] text-center font-sans">
  Mapeo de registros según el servicio solicitado
</div>

<div class="border border-gray-200 dark:border-gray-800 rounded-lg overflow-hidden font-sans text-[9px]">
  <table class="w-full text-left">
    <thead class="bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-200 border-b border-gray-200 dark:border-gray-700">
      <tr>
        <th class="p-1 font-mono">Syscall</th>
        <th class="p-1 font-mono">EAX</th>
        <th class="p-1 font-mono">EBX</th>
        <th class="p-1 font-mono">ECX</th>
        <th class="p-1 font-mono">EDX</th>
      </tr>
    </thead>
    <tbody class="divide-y divide-gray-200 dark:divide-gray-800 text-gray-700 dark:text-gray-300">
      <tr>
        <td class="p-1 font-mono font-bold text-blue-600">sys_creat</td>
        <td class="p-1 font-mono">8</td>
        <td class="p-1">pathname</td>
        <td class="p-1">mode</td>
        <td class="p-1 text-gray-400">no usado</td>
      </tr>
      <tr>
        <td class="p-1 font-mono font-bold text-emerald-600">sys_open</td>
        <td class="p-1 font-mono">5</td>
        <td class="p-1">pathname</td>
        <td class="p-1">flags</td>
        <td class="p-1">mode</td>
      </tr>
      <tr>
        <td class="p-1 font-mono font-bold text-amber-600">sys_read</td>
        <td class="p-1 font-mono">3</td>
        <td class="p-1 font-bold">fd</td>
        <td class="p-1">buf</td>
        <td class="p-1">count</td>
      </tr>
      <tr>
        <td class="p-1 font-mono font-bold text-amber-600">sys_write</td>
        <td class="p-1 font-mono">4</td>
        <td class="p-1 font-bold">fd</td>
        <td class="p-1">buf</td>
        <td class="p-1">count</td>
      </tr>
      <tr>
        <td class="p-1 font-mono font-bold text-purple-600">sys_close</td>
        <td class="p-1 font-mono">6</td>
        <td class="p-1 font-bold">fd</td>
        <td class="p-1 text-gray-400">no usado</td>
        <td class="p-1 text-gray-400">no usado</td>
      </tr>
      <tr>
        <td class="p-1 font-mono font-bold text-rose-600">sys_lseek</td>
        <td class="p-1 font-mono">19</td>
        <td class="p-1 font-bold">fd</td>
        <td class="p-1">offset</td>
        <td class="p-1">whence</td>
      </tr>
    </tbody>
  </table>
</div>

<div v-click="4" class="mt-2 p-1.5 bg-blue-50 border border-blue-200 dark:bg-blue-950/40 dark:border-blue-800/40 rounded text-[9px] text-blue-900 dark:text-blue-200 font-sans leading-snug">
  <strong>Retorno en EAX:</strong> Tanto <i>sys_creat</i> como <i>sys_open</i> retornan el descriptor recién creado en el registro EAX si la operación tuvo éxito.
</div>

<!--
En Linux de 32 bits, la invocación de llamadas al sistema se realiza cargando el número del servicio en EAX y sus parámetros en EBX, ECX y EDX antes de disparar int 0x80.

La llamada más elemental para crear un archivo nuevo es sys_creat, correspondiente al servicio 8.

[click] Sin embargo, la función más versátil es sys_open con el servicio 5, la cual permite abrir archivos existentes en solo lectura, lectura y escritura, o crearlos si no existen mediante banderas.

[click] Notemos que las llamadas sys_read y sys_write que usamos en la semana 9 para consola son exactamente las mismas para archivos en disco. La única diferencia radica en que EBX recibe el descriptor devuelto por el archivo en lugar de los números fijos 0 o 1.

[click] Finalmente, sys_close en el servicio 6 se encarga de vaciar los buffers del sistema y desenlazar el descriptor.

[click] En la tabla derecha apreciamos la correspondencia simétrica y exacta de registros para cada una de estas operaciones fundamentales.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Banderas de acceso y permisos octales

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Configuración de modo de apertura en ECX y máscara de permisos en EDX:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-1 font-mono">Banderas de acceso (O_FLAGS en Linux x86)</div>
    <div class="grid grid-cols-2 gap-1 font-mono text-[9px]">
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-blue-600">O_RDONLY:</span> 0 (Lectura)
      </div>
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-blue-600">O_WRONLY:</span> 1 (Escritura)
      </div>
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-blue-600">O_RDWR:</span> 2 (Lectura/Escritura)
      </div>
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-emerald-600">O_CREAT:</span> 64 (0x40)
      </div>
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-amber-600">O_TRUNC:</span> 512 (0x200)
      </div>
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-purple-600">O_APPEND:</span> 1024 (0x400)
      </div>
    </div>
    <p class="text-gray-600 dark:text-gray-300 mt-1 leading-snug">
      Se combinan con la operación OR a nivel de bits: <i>O_WRONLY | O_CREAT | O_TRUNC = 577</i> (0x241).
    </p>
  </div>
  <div v-click="1" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg text-[9px] text-emerald-900 dark:text-emerald-200 leading-snug">
    <strong>Creación idempotente:</strong> Usar <i>O_CREAT | O_TRUNC</i> asegura que si el archivo existe se limpia su contenido a cero bytes, y si no existe se crea en el directorio destino.
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Estructura de permisos Unix en formato octal
</div>

<div class="space-y-1.5 font-sans text-[9px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-gray-700 dark:text-gray-200 font-bold mb-1">Tres ternas binarias de protección (rwx):</div>
    <div class="grid grid-cols-3 gap-1 text-center font-mono">
      <div class="p-1 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded">
        <div class="text-blue-600 font-bold">Usuario (u)</div>
        <div class="text-[10px]">6 = 110<sub>2</sub> (rw-)</div>
      </div>
      <div class="p-1 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded">
        <div class="text-emerald-600 font-bold">Grupo (g)</div>
        <div class="text-[10px]">4 = 100<sub>2</sub> (r--)</div>
      </div>
      <div class="p-1 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded">
        <div class="text-purple-600 font-bold">Otros (o)</div>
        <div class="text-[10px]">4 = 100<sub>2</sub> (r--)</div>
      </div>
    </div>
  </div>
  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-gray-700 dark:text-gray-200 font-bold mb-0.5">Permisos típicos en proyectos:</div>
    <div class="space-y-1 font-mono text-[8.5px]">
      <div class="flex justify-between p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-blue-600">0644o (rw-r--r--):</span>
        <span>Lectura/escritura dueño, lectura el resto</span>
      </div>
      <div class="flex justify-between p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-emerald-600">0600o (rw-------):</span>
        <span>Acceso exclusivo privado para el usuario</span>
      </div>
      <div class="flex justify-between p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-purple-600">0755o (rwxr-xr-x):</span>
        <span>Permiso de ejecución para binarios y scripts</span>
      </div>
    </div>
  </div>
  <div v-click="3" class="p-1.5 bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded font-mono text-[8.5px] text-gray-700 dark:text-gray-300">
    En NASM, el sufijo <i>q</i> u <i>o</i> denota números en base octal: <span class="font-bold text-blue-600">mov edx, 0644o</span>.
  </div>
</div>

<!--
Para abrir un archivo con sys_open debemos suministrar dos parámetros clave: las banderas de acceso en ECX y los permisos en EDX.

Las tres banderas de acceso mutuamente excluyentes son O_RDONLY con valor cero, O_WRONLY con valor uno y O_RDWR con valor dos.

[click] Si deseamos que el archivo sea creado en caso de no existir, agregamos la bandera O_CREAT sumando 64. Y si queremos limpiar el archivo existente a cero bytes, agregamos O_TRUNC con valor 512. La suma binaria 1 + 64 + 512 arroja el valor 577 en decimal.

[click] Los permisos de archivo en Linux se expresan mediante el sistema octal tradicional. Nueve bits representan los permisos de lectura, escritura y ejecución para el dueño, el grupo y el resto de los usuarios del sistema.

[click] La máscara más habitual para archivos de texto es 0644 en octal, que confiere permisos de lectura y escritura al usuario creador y solo lectura a los demás. En NASM podemos escribirlo directamente con el sufijo 'o' o 'q'.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Tratamiento riguroso de errores del núcleo

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Detección e interpretación de códigos de error devueltos en EAX:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-rose-600 dark:text-rose-400 font-bold text-[10.5px] mb-0.5">La convención de retorno del núcleo Linux</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Cuando una llamada al sistema falla, el kernel no aborta el proceso: retorna un valor negativo en EAX comprendido en el intervalo entre <i>-1</i> y <i>-4095</i>.
    </p>
  </div>
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-1">Códigos de error estándar (errno):</div>
    <div class="space-y-1 font-mono text-[9px]">
      <div class="flex justify-between p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-rose-600">EPERM (-1):</span>
        <span class="font-sans text-[8.5px]">Operación no permitida</span>
      </div>
      <div class="flex justify-between p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-rose-600">ENOENT (-2):</span>
        <span class="font-sans text-[8.5px]">Archivo o directorio inexistente</span>
      </div>
      <div class="flex justify-between p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-rose-600">EBADF (-9):</span>
        <span class="font-sans text-[8.5px]">Descriptor de archivo inválido o cerrado</span>
      </div>
      <div class="flex justify-between p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-rose-600">EACCES (-13):</span>
        <span class="font-sans text-[8.5px]">Permiso denegado en el sistema de archivos</span>
      </div>
    </div>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Patrón de comprobación en lenguaje ensamblador
</div>

<div class="font-mono text-[8.5px]">

```asm {all|1-5|7-9|11-13|15-18}
; Intentar abrir archivo para lectura
mov eax, 5           ; sys_open
mov ebx, ruta        ; puntero a cadena con ruta
mov ecx, 0           ; O_RDONLY
int 0x80             ; llamada al kernel

; Comprobación obligatoria de resultado
cmp eax, 0           ; ¿EAX es menor a cero?
jl .error_apertura   ; bifurcar si ocurrió error

; Si EAX >= 0, el descriptor es válido
mov [fd_archivo], eax ; guardar descriptor seguro
jmp .continuar

.error_apertura:
; EAX contiene el código negativo del error
neg eax              ; convertir a código positivo
; Desplegar diagnóstico y salir ordenadamente
```

</div>

<div v-click="3" class="mt-1.5 p-1.5 bg-rose-50 border border-rose-200 dark:bg-rose-950/40 dark:border-rose-800/40 rounded text-[9px] text-rose-900 dark:text-rose-200 font-sans leading-snug">
  <strong>Trampa común:</strong> No comprobar el resultado y usar directamente EAX como descriptor para <i>sys_read</i> causará fallos en cascada con error <i>EBADF</i>.
</div>

<!--
Un programador profesional de sistemas nunca asume que una llamada al sistema tuvo éxito. En almacenamiento masivo, los errores son cotidianos: el archivo puede no existir, el usuario puede carecer de permisos o el disco puede estar lleno.

Cuando una syscall falla, el kernel Linux coloca en el registro EAX un entero negativo entre -1 y -4095.

[click] Este valor negativo se corresponde exactamente con los códigos estándar de la biblioteca errno de C. Por ejemplo, -2 significa que el archivo no existe y -13 indica que se denegó el permiso de acceso.

[click] En la columna derecha observamos el patrón idiomático en NASM. Tras invocar int 0x80, comparamos EAX con cero mediante cmp eax, 0 y bifurcamos con jl o comprobamos con test eax, eax seguido de js.

[click] Si el descriptor es válido, lo preservamos en memoria antes de que cualquier otra operación altere el registro EAX.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Desplazamiento y acceso con sys_lseek

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Manipulación del puntero de posición interno de lectura y escritura:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-0.5">El puntero de posición del archivo (file offset)</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      El kernel mantiene un cursor interno que indica el byte exacto donde ocurrirá la próxima lectura o escritura. Cada transferencia avanza este puntero automáticamente.
    </p>
  </div>
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold text-[10.5px] mb-1">Constantes de referencia (EDX):</div>
    <div class="space-y-1 font-mono text-[9px]">
      <div class="flex justify-between p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-blue-600">SEEK_SET (0):</span>
        <span class="font-sans text-[8.5px]">Relativo al inicio del archivo</span>
      </div>
      <div class="flex justify-between p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-emerald-600">SEEK_CUR (1):</span>
        <span class="font-sans text-[8.5px]">Relativo a la posición actual del cursor</span>
      </div>
      <div class="flex justify-between p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-purple-600">SEEK_END (2):</span>
        <span class="font-sans text-[8.5px]">Relativo al byte final del archivo</span>
      </div>
    </div>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Técnica de obtención del tamaño de un archivo
</div>

<div class="font-mono text-[8.5px]">

```asm {all|1-5|7-9|11-15}
; Mover el puntero al final del archivo
mov eax, 19          ; sys_lseek
mov ebx, [fd_archivo]; descriptor de archivo
mov ecx, 0           ; desplazamiento de 0 bytes
mov edx, 2           ; SEEK_END
int 0x80             ; llamada al kernel

; EAX contiene la posición absoluta resultante:
; ¡el tamaño total del archivo en bytes!
mov [tamano_archivo], eax

; Rebobinar el puntero al inicio para leerlo
mov eax, 19          ; sys_lseek
mov ebx, [fd_archivo]; descriptor
mov ecx, 0           ; desplazamiento 0
mov edx, 0           ; SEEK_SET
int 0x80
```

</div>

<div v-click="2" class="mt-1.5 p-1.5 bg-purple-50 border border-purple-200 dark:bg-purple-950/40 dark:border-purple-800/40 rounded text-[9px] text-purple-900 dark:text-purple-200 font-sans leading-snug">
  <strong>Valor de retorno:</strong> La llamada <i>sys_lseek</i> siempre devuelve en EAX la posición resultante en bytes medida desde el byte cero del archivo.
</div>

<!--
Por defecto, las operaciones de entrada y salida son estrictamente secuenciales. Sin embargo, en bases de datos y estructuras complejas necesitamos acceder a cualquier registro arbitrario sin tener que leer todo el archivo previo.

Para esto existe sys_lseek, correspondiente a la llamada al sistema 19.

[click] El registro EDX determina el origen de la referencia: SEEK_SET con valor 0 mide desde el inicio, SEEK_CUR con valor 1 desde la posición actual del cursor y SEEK_END con valor 2 desde el byte final.

[click] En el código de la derecha apreciamos un algoritmo clásico en desarrollo de sistemas: si solicitamos un desplazamiento de 0 bytes relativo a SEEK_END, el cursor se sitúa al final del archivo y el kernel devuelve en EAX el tamaño exacto del archivo en bytes.

[click] Posteriormente, basta con invocar sys_lseek con desplazamiento 0 respecto a SEEK_SET para rebobinar el archivo y comenzar a leer sus datos desde el inicio.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Preprocesador de NASM: constantes y macros

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Transformación del texto fuente antes de la generación de código de máquina:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-0.5">Constantes con %define frente a equ</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      La directiva <i>%define</i> opera a nivel de preprocesador reemplazando identificadores textualmente, mientras que <i>equ</i> es evaluado por el motor de expresiones en tiempo de ensamblado.
    </p>
  </div>
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold text-[10.5px] mb-0.5">Inclusión de cabeceras con %include</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Permite insertar el contenido íntegro de archivos auxiliares (típicamente con extensión <i>.inc</i>), compartiendo constantes, definiciones de llamadas al sistema y macros entre múltiples módulos.
    </p>
  </div>
  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-purple-600 dark:text-purple-400 font-bold text-[10.5px] mb-0.5">Macros frente a subrutinas (call / ret)</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Las macros se expanden *en línea* en cada invocación: no usan la pila, no pagan penalización de llamada pero incrementan el tamaño del ejecutable si se usan repetidamente.
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Declaración de constantes y modularidad
</div>

<div class="font-mono text-[8.5px]">

```asm {all|1-4|6-9|11-14}
; Definición de constantes del sistema
%define SYS_EXIT   1
%define SYS_READ   3
%define SYS_WRITE  4
%define SYS_OPEN   5
%define SYS_CLOSE  6

; Banderas del sistema de archivos
%define O_RDONLY   0
%define O_WRONLY   1
%define O_CREAT    64
%define O_TRUNC    512

; Inclusión modular de cabeceras externas
%include "constantes.inc"
%include "macros_io.inc"
```

</div>

<div v-click="3" class="mt-1.5 p-1.5 bg-blue-50 border border-blue-200 dark:bg-blue-950/40 dark:border-blue-800/40 rounded text-[9px] text-blue-900 dark:text-blue-200 font-sans leading-snug">
  <strong>Buenas prácticas:</strong> Centralizar los números mágicos del kernel en un archivo <i>.inc</i> previene errores tipográficos y facilita la migración del código.
</div>

<!--
A medida que nuestros programas de bajo nivel crecen, escribir números mágicos como 5, 3 o 4 directamente en el código oscurece la lectura y propicia errores difíciles de depurar.

NASM incorpora un procesador de macros de una potencia extraordinaria que actúa sobre el código fuente antes de que se genere una sola instrucción de máquina.

[click] Mediante %define creamos constantes simbólicas que sustituyen texto de forma limpia.

[click] La directiva %include nos permite dividir un proyecto grande en módulos lógicos, ubicando las definiciones del sistema operativo en archivos .inc reutilizables.

[click] A diferencia de una función llamada con call y ret, una macro copia su bloque de instrucciones directamente en el punto del código donde se invoca. No hay penalización de salto ni de pila, pero cada invocación incrementa el tamaño del ejecutable.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Macros con parámetros y etiquetas locales

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Sintaxis avanzada y prevención de colisión de símbolos:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-0.5">Sintaxis %macro nombre número_parámetros</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Los argumentos se referencian dentro del cuerpo de la macro mediante <i>%1</i>, <i>%2</i>, ..., <i>%n</i> en el orden estricto de su invocación.
    </p>
  </div>
  <div v-click="1" class="p-2 bg-rose-50 border border-rose-200 dark:bg-rose-950/40 dark:border-rose-800/40 rounded-lg text-rose-900 dark:text-rose-200">
    <div class="font-bold text-[10px] mb-0.5">El problema de las etiquetas duplicadas</div>
    <p class="text-[9px] leading-tight">
      Si una macro incluye una etiqueta convencional (ej. <i>.fin:</i>) y se invoca dos veces en el mismo programa, el enlazador emitirá un error de símbolo duplicado.
    </p>
  </div>
  <div v-click="2" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg text-emerald-900 dark:text-emerald-200">
    <div class="font-bold text-[10px] mb-0.5">Solución: etiquetas locales con doble porcentaje (%%)</div>
    <p class="text-[9px] leading-tight">
      Al escribir <i>%%etiqueta</i>, NASM genera automáticamente un identificador alfanumérico único para cada expansión (ej. <i>..@1.etiqueta</i>).
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Macro segura con etiquetas locales únicas
</div>

<div class="font-mono text-[8.5px]">

```asm {all|1-3|5-10|12-14|16-19}
; Macro para escribir buffer en descriptor con validación
%macro escribir_seguro 3
  ; %1 = fd, %2 = buffer, %3 = longitud
  mov eax, 4          ; sys_write
  mov ebx, %1         ; descriptor
  mov ecx, %2         ; buffer
  mov edx, %3         ; longitud
  int 0x80

  cmp eax, 0          ; verificar retorno
  jl %%error_escritura; etiqueta local segura
  jmp %%exito

%%error_escritura:
  ; tratamiento interno de fallo
%%exito:
%endmacro

; Invocaciones sucesivas sin colisión:
escribir_seguro 1, msg1, len1
escribir_seguro 3, buf, 64
```

</div>

<!--
El verdadero poder de las macros de NASM radica en su capacidad de recibir parámetros.

Definimos una macro indicando su nombre y la cantidad de argumentos que espera, accediendo a ellos mediante %1, %2, etc.

[click] Pero atención a una de las trampas más frecuentes: si nuestra macro contiene saltos condicionales y etiquetas ordinarias, al invocarla dos veces en el mismo programa NASM intentará definir el mismo símbolo dos veces, produciendo un error fatal de ensamblado.

[click] La solución que nos ofrece NASM es anteponer dos signos de porcentaje: %%error_escritura. Cada vez que la macro se expande, NASM reemplaza %% por un prefijo interno numérico irrepetible.

[click] En el ejemplo de la derecha podemos llamar a escribir_seguro diez veces seguidas sin el menor riesgo de colisión de símbolos.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Enlace separado y proyectos híbridos C + NASM

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Conexión de módulos compilados de forma independiente:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-0.5">El rol de global y extern</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      La directiva <i>global</i> exporta un símbolo a la tabla de símbolos del archivo objeto ELF, haciéndolo visible al enlazador. La directiva <i>extern</i> declara que un símbolo reside en otro archivo.
    </p>
  </div>
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold text-[10.5px] mb-0.5">¿Por qué construir proyectos híbridos?</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Permite combinar lo mejor de ambos mundos: la expresividad de C para la interfaz y lógica de alto nivel, y ensamblador para rutinas críticas donde se requiere control exacto de registros y microcódigo.
    </p>
  </div>
  <div v-click="2" class="p-2 bg-purple-50 border border-purple-200 dark:bg-purple-950/40 dark:border-purple-800/40 rounded-lg text-purple-900 dark:text-purple-200 leading-snug">
    <strong>Cadena de construcción con GCC de 32 bits:</strong>
    <div class="font-mono text-[8.5px] mt-1 space-y-0.5 text-gray-800 dark:text-gray-200">
      <div>nasm -f elf32 rutina.asm -o rutina.o</div>
      <div>gcc -m32 -c main.c -o main.o</div>
      <div>gcc -m32 main.o rutina.o -o ejecutable</div>
    </div>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] text-center font-sans">
  Cadena de enlazado de módulos independientes
</div>

<div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl space-y-2 font-sans">
  <div class="flex items-center justify-between p-1.5 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700 text-[9px]">
    <span class="font-mono font-bold text-blue-600">rutina.asm</span>
    <span class="text-gray-500 font-mono">&rarr; nasm -f elf32 &rarr;</span>
    <span class="font-mono font-bold text-emerald-600">rutina.o</span>
  </div>
  <div class="flex items-center justify-between p-1.5 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700 text-[9px]">
    <span class="font-mono font-bold text-blue-600">main.c</span>
    <span class="text-gray-500 font-mono">&rarr; gcc -m32 -c &rarr;</span>
    <span class="font-mono font-bold text-emerald-600">main.o</span>
  </div>
  <div v-click="3" class="text-center font-mono text-[9px] font-bold text-gray-500">
    &darr; Enlazador (ld invocado por gcc -m32) &darr;
  </div>
  <div v-click="3" class="p-2 bg-emerald-100/60 dark:bg-emerald-950/60 border border-emerald-300 dark:border-emerald-700 rounded-lg text-center font-mono text-[9.5px] font-bold text-emerald-800 dark:text-emerald-300">
    Archivo ejecutable final (formato ELF32)
  </div>
</div>

<!--
En la práctica profesional de sistemas, rara vez se programa una aplicación de miles de líneas en un único archivo de código.

Para que un archivo en C pueda invocar una rutina escrita en NASM, debemos declarar el nombre de la función como global en ensamblador. De lo contrario, el símbolo será privado y el enlazador rechazará el enlace por referencia indefinida.

[click] Esta arquitectura híbrida nos brinda una ventaja colosal: redactamos el menú, el análisis de argumentos y las estructuras en C, y delegamos la operación intensiva de archivos o algoritmos de hashing al módulo en NASM.

[click] La compilación se divide en dos pasos claros: NASM produce el archivo objeto ELF32 de la rutina y GCC genera el objeto de C, enlazándolos con el flag -m32.

[click] El enlazador unifica las tablas de símbolos y genera el ejecutable final sin fricciones.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Convención de llamadas cdecl en Linux x86

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Contrato binario entre código compilado en C y subrutinas en ensamblador:
</div>

<div class="space-y-1.5 font-sans text-[9px]">
  <div class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10px] mb-0.5">Paso de argumentos por la pila</div>
    <p class="text-gray-600 dark:text-gray-300 leading-tight">
      Los argumentos se apilan de derecha a izquierda. El primer argumento queda en el tope de la pila al ingresar a la subrutina.
    </p>
  </div>
  <div v-click="1" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold text-[10px] mb-0.5">Valor de retorno</div>
    <p class="text-gray-600 dark:text-gray-300 leading-tight">
      Los valores enteros y punteros devueltos por la función deben quedar depositados obligatoriamente en el registro <i>EAX</i>.
    </p>
  </div>
  <div v-click="2" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-purple-600 dark:text-purple-400 font-bold text-[10px] mb-0.5">Limpieza de la pila (caller clean-up)</div>
    <p class="text-gray-600 dark:text-gray-300 leading-tight">
      El llamador (C) es responsable de retirar los argumentos tras el retorno ejecutando <i>add esp, N_bytes</i>.
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Clasificación de registros según la convención
</div>

<div class="space-y-1.5 font-sans text-[9px]">
  <div class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg text-emerald-900 dark:text-emerald-200">
    <div class="font-bold text-[10px] mb-1 font-mono">Registros preservados (callee-saved)</div>
    <div class="grid grid-cols-4 gap-1 text-center font-mono font-bold text-[10px]">
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-emerald-300">EBX</div>
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-emerald-300">ESI</div>
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-emerald-300">EDI</div>
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-emerald-300">EBP</div>
    </div>
    <p class="mt-1 text-[8.5px] leading-tight">
      Si la rutina en NASM modifica cualquiera de estos registros, DEBE respaldarlos con <i>push</i> al inicio y restaurarlos con <i>pop</i> antes de <i>ret</i>.
    </p>
  </div>
  <div v-click="3" class="p-2 bg-amber-50 border border-amber-200 dark:bg-amber-950/40 dark:border-amber-800/40 rounded-lg text-amber-900 dark:text-amber-200">
    <div class="font-bold text-[10px] mb-1 font-mono">Registros volátiles (caller-saved)</div>
    <div class="grid grid-cols-3 gap-1 text-center font-mono font-bold text-[10px]">
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-amber-300">EAX</div>
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-amber-300">ECX</div>
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-amber-300">EDX</div>
    </div>
    <p class="mt-1 text-[8.5px] leading-tight">
      La subrutina puede alterarlos libremente sin necesidad de preservarlos.
    </p>
  </div>
</div>

<!--
Para que un binario compilado por GCC pueda ejecutar código ensamblado por NASM sin corromper la memoria, ambos deben respetar rigurosamente un contrato: la convención de llamadas cdecl.

En cdecl de 32 bits, los argumentos se pasan a través de la pila en orden inverso.

[click] El valor de retorno debe quedar estrictamente en EAX. Si la función devuelve un int o un puntero, C buscará el resultado exclusivamente en EAX.

[click] La responsabilidad de limpiar la pila corresponde al llamador, no a la función que retorna.

[click] Y la regla de oro que previene errores fatales de segmentación: los registros EBX, ESI, EDI y EBP pertenecen al llamador. Si en nuestro código NASM necesitamos usarlos, es obligatorio guardarlos en la pila con push al inicio y recuperarlos con pop antes de ejecutar ret.
-->

---
layout: center
transition: slide-up | slide-down
---

<div class="text-center space-y-4">
  <div class="text-xs font-semibold px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40 tracking-wide uppercase font-mono inline-block">
    IC3101 &bull; Sesión 02 de 02
  </div>

  # Sesión 02: Práctica guiada

  <div class="text-gray-600 dark:text-gray-400 text-sm max-w-xl mx-auto leading-relaxed">
    Talleres paso a paso de persistencia en disco, desarrollo modular con macros y proyectos híbridos C con NASM
  </div>

  <div class="pt-2 text-xs font-mono text-gray-500 dark:text-gray-400">
    Duración estimada: 90 minutos &bull; 4 Prácticas extendidas &bull; Retos de consolidación
  </div>
</div>

<!--
Con esto damos inicio formal a la segunda sesión de la semana 11.

Habiendo comprendido la teoría de descriptores de archivo, banderas de acceso, permisos octales, macros de preprocesador y la convención binaria cdecl, pasaremos a implementar soluciones prácticas completas en la terminal de Linux.
-->

---
transition: fade
---

# Objetivos de la segunda sesión

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-4">
Metas de aprendizaje técnico y aplicación en bajo nivel para la jornada de hoy:
</div>

<div class="max-w-2xl space-y-2.5 font-sans text-xs">
  <v-clicks>
    <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg flex items-start gap-3">
      <span class="w-5 h-5 rounded-full bg-blue-100 text-blue-700 dark:bg-blue-950 dark:text-blue-300 flex items-center justify-center font-mono font-bold text-[10px] shrink-0">1</span>
      <div>
        <strong class="text-gray-800 dark:text-gray-200">Creación y persistencia de archivos en disco:</strong>
        <p class="text-[10px] text-gray-600 dark:text-gray-400 mt-0.5">Implementar rutinas con <i>sys_creat</i> y <i>sys_open</i> configurando permisos octales 0644, verificando fallos del kernel y liberando descriptores con <i>sys_close</i>.</p>
      </div>
    </div>
    <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg flex items-start gap-3">
      <span class="w-5 h-5 rounded-full bg-emerald-100 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300 flex items-center justify-center font-mono font-bold text-[10px] shrink-0">2</span>
      <div>
        <strong class="text-gray-800 dark:text-gray-200">Lectura en bloques y detección de EOF:</strong>
        <p class="text-[10px] text-gray-600 dark:text-gray-400 mt-0.5">Construir bucles de lectura por ventanas en memoria con <i>sys_read</i>, detectando fin de archivo (EAX = 0) y manipulando el cursor con <i>sys_lseek</i>.</p>
      </div>
    </div>
    <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg flex items-start gap-3">
      <span class="w-5 h-5 rounded-full bg-amber-100 text-amber-700 dark:bg-amber-950 dark:text-amber-300 flex items-center justify-center font-mono font-bold text-[10px] shrink-0">3</span>
      <div>
        <strong class="text-gray-800 dark:text-gray-200">Modularidad con macros en NASM:</strong>
        <p class="text-[10px] text-gray-600 dark:text-gray-400 mt-0.5">Diseñar una cabecera modular <i>.inc</i> con macros multiparámetro utilizando etiquetas locales con doble porcentaje (%%) para evitar colisiones.</p>
      </div>
    </div>
    <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg flex items-start gap-3">
      <span class="w-5 h-5 rounded-full bg-purple-100 text-purple-700 dark:bg-purple-950 dark:text-purple-300 flex items-center justify-center font-mono font-bold text-[10px] shrink-0">4</span>
      <div>
        <strong class="text-gray-800 dark:text-gray-200">Integración de aplicaciones híbridas C + NASM:</strong>
        <p class="text-[10px] text-gray-600 dark:text-gray-400 mt-0.5">Programar y enlazar una subrutina en ensamblador invocada desde C respetando el estándar <i>cdecl</i> y la preservación de registros en la pila.</p>
      </div>
    </div>
  </v-clicks>
</div>

<!--
Repasemos los cuatro objetivos de esta segunda sesión.

[click] Primero, aprenderemos a crear archivos en disco físico aplicando permisos octales, escribiendo registros en memoria y cerrando el descriptor con seguridad.

[click] Segundo, diseñaremos un bucle robusto de lectura por bloques que detecta con precisión el fin de archivo cuando EAX es cero, complementado con cálculo de tamaño mediante sys_lseek.

[click] Tercero, construiremos una librería de macros reutilizable en un archivo .inc aplicando etiquetas locales seguras.

[click] Cuarto, unificaremos C y NASM en un proyecto ejecutable enlazado con GCC de 32 bits, verificando la convención cdecl.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Creación y apertura con descriptor de archivo

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Taller 1 &bull; Paso 1 de 3: Especificación del problema y mapa de memoria:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-0.5">Enunciado de la práctica</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Crear un archivo en disco llamado <i>/tmp/registro.txt</i> con permisos <i>0644o</i>, escribir un mensaje estructurado de texto y cerrar el descriptor garantizando la integridad de los datos.
    </p>
  </div>
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold text-[10.5px] mb-1">Estructura de datos requerida</div>
    <div class="space-y-1 font-mono text-[9px]">
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="text-blue-600 font-bold">.data:</span> ruta db "/tmp/registro.txt", 0
      </div>
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="text-emerald-600 font-bold">.data:</span> texto db "Registro persistente en disco", 0x0A
      </div>
      <div class="p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
        <span class="text-purple-600 font-bold">.bss:</span> fd_archivo resd 1 (reserva de 4 bytes para el descriptor)
      </div>
    </div>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] text-center font-sans">
  Preparación de registros para sys_creat (Servicio 8)
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl space-y-1.5 font-mono text-[9.5px]">
    <div class="flex justify-between items-center p-1.5 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
      <span class="font-bold text-blue-600">EAX = 8</span>
      <span class="text-gray-600 dark:text-gray-300 font-sans text-[9px]">Número de servicio sys_creat</span>
    </div>
    <div class="flex justify-between items-center p-1.5 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
      <span class="font-bold text-emerald-600">EBX = ruta</span>
      <span class="text-gray-600 dark:text-gray-300 font-sans text-[9px]">Puntero a cadena terminada en 0x00</span>
    </div>
    <div class="flex justify-between items-center p-1.5 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
      <span class="font-bold text-amber-600">ECX = 0644o</span>
      <span class="text-gray-600 dark:text-gray-300 font-sans text-[9px]">Permisos rw-r--r-- (420 decimal)</span>
    </div>
  </div>
  <div v-click="2" class="p-2 bg-blue-50 border border-blue-200 dark:bg-blue-950/40 dark:border-blue-800/40 rounded-lg text-[9px] text-blue-900 dark:text-blue-200 leading-snug">
    <strong>Validación del resultado:</strong> Al retornar de <i>int 0x80</i>, el kernel entrega en EAX el nuevo descriptor (ej. 3). Si EAX es negativo, el archivo no pudo ser creado (ej. ruta inexistente o falta de permisos).
  </div>
</div>

<!--
Comenzamos el Taller 1 analizando la especificación del problema.

Queremos crear el archivo /tmp/registro.txt con permisos estándar de lectura y escritura para el usuario y lectura para los demás (0644 en octal).

[click] En la sección de datos declaramos la ruta como cadena ASCIIZ terminada en cero nulo y el texto que deseamos almacenar. En la sección no inicializada .bss reservamos cuatro bytes con resd 1 para almacenar el descriptor devuelto.

[click] Para invocar sys_creat preparamos EAX con 8, EBX con la dirección de la ruta y ECX con 0644o. Al ejecutarse int 0x80, el kernel creará el archivo y nos entregará su descriptor en EAX.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Escritura de datos y cierre seguro del descriptor

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Taller 1 &bull; Paso 2 de 3: Implementación completa del ciclo de escritura:
</div>

<div class="space-y-1.5 font-sans text-[9px]">
  <div class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="font-bold text-blue-600 dark:text-blue-400 font-mono">1. Crear archivo:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-tight">Invocamos <i>sys_creat</i> y respaldamos el descriptor en <i>fd_archivo</i>.</p>
  </div>
  <div v-click="1" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="font-bold text-emerald-600 dark:text-emerald-400 font-mono">2. Comprobación de fallo:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-tight">Verificamos con <i>cmp eax, 0</i> &bull; <i>jl error_creat</i>.</p>
  </div>
  <div v-click="2" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="font-bold text-amber-600 dark:text-amber-400 font-mono">3. Escribir datos:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-tight"><i>sys_write (EAX = 4)</i> con <i>EBX = [fd_archivo]</i>, <i>ECX = texto</i> y <i>EDX = len</i>.</p>
  </div>
  <div v-click="3" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="font-bold text-purple-600 dark:text-purple-400 font-mono">4. Cierre obligatorio:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-tight"><i>sys_close (EAX = 6)</i> con <i>EBX = [fd_archivo]</i> para forzar vaciado a disco.</p>
  </div>
</div>

::right::

<div class="font-mono text-[8px]">

```asm {all|1-7|9-15|17-23|25-29}
; Paso 1: Crear archivo con permisos 0644
mov eax, 8            ; sys_creat
mov ebx, ruta         ; "/tmp/registro.txt"
mov ecx, 0644o        ; permisos octales
int 0x80

; Paso 2: Verificar si EAX contiene error
cmp eax, 0
jl .error_creat
mov [fd_archivo], eax ; guardar descriptor seguro

; Paso 3: Escribir contenido en el archivo
mov eax, 4            ; sys_write
mov ebx, [fd_archivo] ; descriptor retornado
mov ecx, texto        ; dirección del buffer
mov edx, texto_len    ; número exacto de bytes
int 0x80

; Paso 4: Cerrar el archivo
mov eax, 6            ; sys_close
mov ebx, [fd_archivo] ; descriptor a cerrar
int 0x80

; Salir exitosamente
mov eax, 1            ; sys_exit
mov ebx, 0
int 0x80
```

</div>

<!--
En esta diapositiva implementamos el flujo completo de escritura en ensamblador.

Notemos las cuatro fases claramente delimitadas. Primero preparamos sys_creat.

[click] Al recibir la respuesta del kernel, comparamos inmediatamente EAX con 0. Si es negativo, saltamos a la rutina de tratamiento de error. Si es positivo, almacenamos el descriptor en memoria.

[click] Para escribir el mensaje en el archivo, preparamos sys_write con EAX en 4, pasando el descriptor almacenado en EBX, la dirección del texto en ECX y la longitud en EDX.

[click] Finalmente, cerramos el archivo con sys_close en EAX = 6. Este paso es imperativo: si el proceso termina sin cerrar el descriptor, se corre el riesgo de perder datos almacenados en los buffers del kernel.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Diagnóstico de errores y verificación de archivo

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Taller 1 &bull; Paso 3 de 3: Manejo de anomalías y validación en la terminal:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-rose-50 border border-rose-200 dark:bg-rose-950/40 dark:border-rose-800/40 rounded-lg text-rose-900 dark:text-rose-200">
    <div class="font-bold text-[10px] mb-0.5">Manejo de errores del kernel</div>
    <p class="text-[9px] leading-snug">
      Si la creación falla (ej. por intentar escribir en un directorio protegido como <i>/root/</i>), el programa debe emitir un mensaje de diagnóstico al canal de error estándar (FD 2) y salir con código no nulo.
    </p>
  </div>
  <div v-click="1" class="font-mono text-[8px]">

```asm
.error_creat:
  mov eax, 4          ; sys_write
  mov ebx, 2          ; stderr (FD 2)
  mov ecx, msg_error
  mov edx, len_error
  int 0x80

  mov eax, 1          ; sys_exit
  mov ebx, 1          ; código de salida de error
  int 0x80
```

  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] text-center font-sans">
  Verificación en consola del archivo creado
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-gray-700 dark:text-gray-200 font-bold mb-1">Comprobación de permisos y tamaño:</div>
    <div class="p-1.5 bg-gray-900 text-gray-100 rounded font-mono text-[8.5px]">
      $ ls -l /tmp/registro.txt<br>
      <span class="text-emerald-400">-rw-r--r-- 1 mau mau 30 sep 6 12:00 /tmp/registro.txt</span>
    </div>
    <p class="text-gray-500 dark:text-gray-400 text-[8.5px] mt-1">
      Confirmamos los permisos exactos <i>-rw-r--r--</i> (0644 octal) y los 30 bytes generados.
    </p>
  </div>
  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-gray-700 dark:text-gray-200 font-bold mb-1">Examen del contenido persistente:</div>
    <div class="p-1.5 bg-gray-900 text-gray-100 rounded font-mono text-[8.5px]">
      $ cat /tmp/registro.txt<br>
      Registro persistente en disco<br>
      $ hexdump -C /tmp/registro.txt<br>
      <span class="text-blue-400">00000000 52 65 67 69 73 74 72 6f ... 0a</span>
    </div>
  </div>
</div>

<!--
Para cerrar el Taller 1, analizamos cómo responder ante situaciones anómalas.

Si el archivo no se puede crear, la bifurcación jl nos envía a la etiqueta .error_creat.

[click] Notemos que emitimos el mensaje de diagnóstico hacia el descriptor 2 (stderr) y terminamos el proceso con código de salida 1, indicando fallo al entorno de ejecución.

[click] En la terminal verificamos el resultado mediante los comandos estándar de Linux: ls -l corrobora los permisos octales 0644 asignados, mientras que cat y hexdump demuestran que el texto se escribió con fidelidad absoluta en el disco.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Lectura secuencial por bloques y detección de EOF

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Taller 2 &bull; Paso 1 de 3: Arquitectura del buffer y control de flujo:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-0.5">El desafío de la lectura en memoria acotada</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Un archivo en disco puede medir kilobytes o gigabytes. Es inviable reservar memoria infinita: la técnica profesional consiste en leer en *ventanas de bloques fijos* (ej. 64 bytes).
    </p>
  </div>
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold text-[10.5px] mb-1">Los tres estados de retorno de sys_read (EAX)</div>
    <div class="space-y-1 font-mono text-[9px]">
      <div class="p-1 bg-emerald-50 dark:bg-emerald-950/40 rounded border border-emerald-300 text-emerald-900 dark:text-emerald-200">
        <strong>EAX &gt; 0:</strong> Se leyeron <i>N</i> bytes con éxito. Procesar y pedir más.
      </div>
      <div class="p-1 bg-blue-50 dark:bg-blue-950/40 rounded border border-blue-300 text-blue-900 dark:text-blue-200">
        <strong>EAX == 0:</strong> Fin de archivo (EOF). No quedan más bytes en disco.
      </div>
      <div class="p-1 bg-rose-50 dark:bg-rose-950/40 rounded border border-rose-300 text-rose-900 dark:text-rose-200">
        <strong>EAX &lt; 0:</strong> Error de lectura en el hardware o descriptor corrupto.
      </div>
    </div>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] text-center font-sans">
  Máquina de estados del bucle de lectura
</div>

<div class="p-3 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl space-y-2 font-sans text-[9px]">
  <div class="p-1.5 bg-blue-50 dark:bg-blue-950/60 border border-blue-200 dark:border-blue-800 rounded text-center font-bold text-blue-800 dark:text-blue-200">
    sys_open("/tmp/datos.txt", O_RDONLY)
  </div>
  <div class="text-center font-mono font-bold text-gray-500">&darr; Descriptor válido (EAX &ge; 3) &darr;</div>
  <div class="p-2 bg-emerald-50 dark:bg-emerald-950/60 border border-emerald-200 dark:border-emerald-800 rounded">
    <div class="font-bold text-emerald-800 dark:text-emerald-200 text-center font-mono">bucle_lectura:</div>
    <div class="text-center text-gray-600 dark:text-gray-300 mt-0.5">sys_read(fd, buffer, 64)</div>
  </div>
  <div v-click="2" class="grid grid-cols-2 gap-2 text-center font-mono text-[8.5px]">
    <div class="p-1.5 bg-emerald-100 dark:bg-emerald-900/60 rounded border border-emerald-400 text-emerald-800 dark:text-emerald-200">
      EAX &gt; 0<br>
      Escribir en stdout &rarr; Volver al bucle
    </div>
    <div class="p-1.5 bg-gray-200 dark:bg-gray-700 rounded border border-gray-400 text-gray-800 dark:text-gray-200">
      EAX == 0 (EOF)<br>
      Salir &rarr; sys_close(fd)
    </div>
  </div>
</div>

<!--
Pasamos ahora al Taller 2: lectura secuencial de archivos en disco.

En aplicaciones reales nunca debemos asumir que un archivo cabe en un buffer fijo. Por ello, empleamos la técnica de ventanas de lectura en bloques de tamaño constante, como 64 o 256 bytes.

[click] La clave para controlar el ciclo de lectura radica en evaluar rigurosamente el valor devuelto por sys_read en EAX: un número positivo representa los bytes leídos en esa iteración, cero señala que alcanzamos el final del archivo y un número negativo denota un error de hardware.

[click] En el diagrama de la derecha vemos el flujo cíclico: leemos un bloque, emitimos sus bytes a la pantalla, y repetimos hasta que el kernel retorne cero en EAX.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Implementación del bucle de lectura y emisión

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Taller 2 &bull; Paso 2 de 3: Código fuente ensamblador NASM completo:
</div>

<div class="space-y-1.5 font-sans text-[9px]">
  <div class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="font-bold text-blue-600 dark:text-blue-400 font-mono">1. Apertura:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-tight"><i>sys_open (5)</i> con <i>ECX = 0 (O_RDONLY)</i>.</p>
  </div>
  <div v-click="1" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="font-bold text-emerald-600 dark:text-emerald-400 font-mono">2. Llamada de lectura:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-tight"><i>sys_read</i> pidiendo hasta 64 bytes.</p>
  </div>
  <div v-click="2" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="font-bold text-amber-600 dark:text-amber-400 font-mono">3. Comprobación EOF:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-tight"><i>cmp eax, 0</i> &bull; <i>jle .fin_archivo</i>.</p>
  </div>
  <div v-click="3" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="font-bold text-purple-600 dark:text-purple-400 font-mono">4. Emisión a stdout:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-tight"><i>sys_write</i> hacia <i>FD 1</i> enviando exactamente <i>EAX</i> bytes.</p>
  </div>
</div>

::right::

<div class="font-mono text-[8px]">

```asm {all|1-7|9-16|18-24|26-31}
; Abrir archivo en modo solo lectura
mov eax, 5            ; sys_open
mov ebx, ruta         ; ruta ASCIIZ
mov ecx, 0            ; O_RDONLY
int 0x80
cmp eax, 0
jl .error_apertura
mov [fd_archivo], eax ; guardar descriptor

.bucle_lectura:
; Leer bloque de hasta 64 bytes
mov eax, 3            ; sys_read
mov ebx, [fd_archivo] ; descriptor de archivo
mov ecx, buffer       ; dirección de buffer en .bss
mov edx, 64           ; capacidad del buffer
int 0x80

; Verificar condición de terminación
cmp eax, 0            ; ¿EAX <= 0?
jle .fin_archivo      ; si es 0 (EOF) o negativo, salir

; Emitir a stdout los bytes efectivamente leídos
mov edx, eax          ; longitud = bytes leídos en EAX
mov eax, 4            ; sys_write
mov ebx, 1            ; FD 1 (stdout)
mov ecx, buffer       ; datos
int 0x80
jmp .bucle_lectura    ; siguiente bloque

.fin_archivo:
; Cerrar descriptor de archivo
mov eax, 6            ; sys_close
mov ebx, [fd_archivo]
int 0x80
```

</div>

<!--
Analicemos la implementación técnica del bucle de lectura.

Abrimos el archivo con modo O_RDONLY (cero) y validamos el descriptor devuelto.

[click] Dentro de .bucle_lectura, solicitamos hasta 64 bytes con sys_read.

[click] Inmediatamente comparamos EAX con 0. Si es menor o igual a cero, saltamos a .fin_archivo. Si EAX es cero, alcanzamos el final del archivo sin errores; si es negativo, se presentó una falla.

[click] Si se leyeron datos positivos, pasamos ese mismo valor de EAX a EDX y llamamos a sys_write sobre el descriptor 1 (la pantalla de la terminal), reutilizando el buffer de inmediato para la siguiente iteración.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Posicionamiento en archivos con sys_lseek

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Taller 2 &bull; Paso 3 de 3: Acceso no secuencial y medición de tamaño:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-0.5">El cursor de lectura como estado del kernel</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Tras finalizar una lectura o escritura, el cursor se encuentra al final del archivo. Si intentáramos volver a leer con <i>sys_read</i> obtendríamos inmediatamente <i>EAX = 0</i>.
    </p>
  </div>
  <div v-click="1" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg text-emerald-900 dark:text-emerald-200">
    <div class="font-bold text-[10px] mb-0.5">Rebobinado y lectura aleatoria</div>
    <p class="text-[9px] leading-snug">
      Con <i>sys_lseek</i> podemos reposicionar el cursor al inicio para realizar una segunda pasada, o saltar a la posición de un registro específico sin leer datos intermedios.
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Medición de tamaño y rebobinado
</div>

<div class="font-mono text-[8.5px]">

```asm {all|1-6|8-11|13-18}
; 1. Averiguar tamaño total del archivo
mov eax, 19           ; sys_lseek
mov ebx, [fd_archivo] ; descriptor
mov ecx, 0            ; offset = 0
mov edx, 2            ; SEEK_END
int 0x80              ; EAX = tamaño en bytes

; Guardar tamaño para reserva de buffer dinámico
mov [tamano_total], eax

; 2. Rebobinar cursor al primer byte
mov eax, 19           ; sys_lseek
mov ebx, [fd_archivo]
mov ecx, 0            ; offset = 0
mov edx, 0            ; SEEK_SET
int 0x80              ; cursor vuelve a byte 0

; 3. Ahora sys_read comenzará desde el inicio
```

</div>

<div v-click="2" class="mt-1.5 p-1.5 bg-amber-50 border border-amber-200 dark:bg-amber-950/40 dark:border-amber-800/40 rounded text-[9px] text-amber-900 dark:text-amber-200 font-sans leading-snug">
  <strong>Precaución de diseño:</strong> Modificar el cursor con <i>sys_lseek</i> más allá del tamaño del archivo y escribir datos crea los denominados <i>archivos dispersos (sparse files)</i> con agujeros de ceros.
</div>

<!--
Para culminar el Taller 2, examinemos la llamada sys_lseek.

Cuando terminamos de leer o escribir un archivo, el cursor queda posicionado al final. Si quisiéramos leerlo de nuevo sin cerrarlo y reabrirlo, la única manera es mediante sys_lseek.

[click] En el código observamos el procedimiento de dos pasos: primero situamos el cursor en el extremo final con SEEK_END para capturar el tamaño exacto en EAX, y de inmediato lo rebobinamos al byte cero con SEEK_SET.

[click] Este patrón es el que emplean los enlazadores y cargadores de programas para inspeccionar encabezados de archivos ejecutables antes de transferirlos a memoria.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Abstracción de llamadas al sistema con macros

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Taller 3 &bull; Paso 1 de 2: Diseño de macros reutilizables y etiquetas locales:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-0.5">Objetivo de diseño</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Encapsular las llamadas del kernel en macros declarativas para que el código ensamblador resulte tan legible como un lenguaje de alto nivel, sin sacrificar rendimiento.
    </p>
  </div>
  <div v-click="1" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg text-emerald-900 dark:text-emerald-200">
    <div class="font-bold text-[10px] mb-0.5">Uso estricto de %% para saltos locales</div>
    <p class="text-[9px] leading-snug">
      Si una macro evalúa el resultado de una llamada y salta condicionalmente, sus etiquetas deben declararse con doble porcentaje (ej. <i>%%error</i> y <i>%%salir</i>).
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Definición de macros seguras de E/S
</div>

<div class="font-mono text-[8px]">

```asm {all|1-3|5-12|14-20}
; Macro para abrir archivo con comprobación
%macro abrir_archivo 2
  ; %1 = ruta, %2 = banderas
  mov eax, 5          ; sys_open
  mov ebx, %1         ; ruta
  mov ecx, %2         ; banderas
  int 0x80
  cmp eax, 0
  jl %%error_abrir
  jmp %%exito_abrir
%%error_abrir:
  mov eax, -1         ; código de error unificado
%%exito_abrir:
%endmacro

; Macro para cerrar descriptor
%macro cerrar_archivo 1
  ; %1 = fd
  mov eax, 6          ; sys_close
  mov ebx, %1         ; descriptor
  int 0x80
%endmacro
```

</div>

<!--
En el Taller 3 abordamos la ingeniería de macros para construir bibliotecas de código reutilizable.

En lugar de reescribir una y otra vez la carga de registros para int 0x80, diseñamos macros limpias y expresivas.

[click] Observemos cómo la macro abrir_archivo recibe la ruta y las banderas, ejecuta la llamada y valida el retorno.

[click] Al utilizar %%error_abrir y %%exito_abrir, NASM se asegura de que cada vez que utilicemos la macro en cualquier parte de nuestro proyecto, las etiquetas internas tengan nombres absolutamente únicos, erradicando los molestos errores de símbolo duplicado.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Construcción de cabecera modular para llamadas

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Taller 3 &bull; Paso 2 de 2: Estructura del archivo .inc y código cliente:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-0.5">Archivo de cabecera: archivos.inc</div>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Agrupa las definiciones de constantes del sistema de archivos, las macros de llamadas al sistema y los códigos de error en una sola unidad lógica.
    </p>
  </div>
  <div v-click="1" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg text-emerald-900 dark:text-emerald-200">
    <div class="font-bold text-[10px] mb-0.5">Legibilidad del código cliente</div>
    <p class="text-[9px] leading-snug">
      Al incluir <i>%include "archivos.inc"</i>, el programa principal se lee con una claridad asombrosa, reduciendo la complejidad del ensamblador sin perder control de bajo nivel.
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Programa principal simplificado mediante macros
</div>

<div class="font-mono text-[8px]">

```asm {all|1-3|5-9|11-16|18-20}
; Inclusión de la cabecera modular
%include "archivos.inc"

section .data
  ruta db "/tmp/prueba.txt", 0
  texto db "Escritura modular mediante macros", 0x0A
  texto_len equ $ - texto

section .bss
  fd_archivo resd 1

section .text
  global _start

_start:
  ; Uso transparente de las macros definidas
  abrir_archivo ruta, O_CREAT_WRONLY
  mov [fd_archivo], eax

  escribir_archivo [fd_archivo], texto, texto_len
  cerrar_archivo [fd_archivo]
  salir_exitoso
```

</div>

<!--
Aquí vemos el resultado final de aplicar modularidad mediante macros.

Creamos una cabecera llamada archivos.inc con todas nuestras macros y constantes.

[click] Al incluirla con %include en el programa principal, miremos lo limpio y elegante que resulta el código en _start.

[click] Abrimos el archivo, escribimos el buffer, cerramos el descriptor y finalizamos el programa en apenas cuatro líneas declarativas de ensamblador, conservando la velocidad pura del código de máquina.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Interfaz binaria de llamadas entre C y NASM

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Taller 4 &bull; Paso 1 de 3: Diseño del contrato de llamadas y marco de pila:
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-0.5">Firma de la función en lenguaje C</div>
    <div class="font-mono text-[9px] p-1 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700 text-blue-600 font-bold">
      extern int contar_bytes(const char *ruta);
    </div>
    <p class="text-gray-600 dark:text-gray-300 mt-1 leading-snug">
      El programa en C delega a ensamblador la tarea de abrir el archivo, calcular su tamaño total en bytes mediante <i>sys_lseek</i> y retornar el conteo.
    </p>
  </div>
  <div v-click="1" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg text-emerald-900 dark:text-emerald-200">
    <div class="font-bold text-[10px] mb-0.5">Acceso a argumentos en la pila</div>
    <p class="text-[9px] leading-snug">
      Al montar el marco con <i>push ebp</i> y <i>mov ebp, esp</i>, el puntero a la cadena con la ruta reside exactamente en <i>[ebp + 8]</i>.
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] text-center font-sans">
  Mapa de la pila de memoria (cdecl)
</div>

<div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl space-y-1.5 font-mono text-[9.5px]">
  <div class="flex justify-between items-center p-1.5 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
    <span class="font-bold text-blue-600">[ebp + 8]</span>
    <span class="text-gray-700 dark:text-gray-300">Puntero a ruta (const char *)</span>
  </div>
  <div class="flex justify-between items-center p-1.5 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
    <span class="font-bold text-emerald-600">[ebp + 4]</span>
    <span class="text-gray-700 dark:text-gray-300">Dirección de retorno (EIP guardado)</span>
  </div>
  <div class="flex justify-between items-center p-1.5 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
    <span class="font-bold text-amber-600">[ebp]</span>
    <span class="text-gray-700 dark:text-gray-300">EBP anterior del llamador en C</span>
  </div>
  <div v-click="2" class="flex justify-between items-center p-1.5 bg-purple-50 dark:bg-purple-950/40 rounded border border-purple-300 text-purple-900 dark:text-purple-200">
    <span class="font-bold">[esp]</span>
    <span>Registros preservados (push ebx)</span>
  </div>
</div>

<!--
Llegamos al Taller 4, donde uniremos el lenguaje C con NASM en una solución híbrida.

En el archivo de C declaramos la función contar_bytes como extern int, indicando que su implementación reside en un módulo binario externo.

[click] En 32 bits bajo cdecl, el llamador apila el argumento antes del call. Al entrar a la subrutina y construir el marco de pila con push ebp y mov ebp, esp, el argumento de la ruta se ubica ineludiblemente en la dirección [ebp + 8].

[click] Asimismo, dado que utilizaremos EBX para invocar llamadas al sistema, es obligatorio respaldar EBX con push ebx para cumplir con la convención callee-saved.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Subrutina NASM invocada desde lenguaje C

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Taller 4 &bull; Paso 2 de 3: Implementación de la función contar_bytes en NASM:
</div>

<div class="space-y-1.5 font-sans text-[9px]">
  <div class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="font-bold text-blue-600 dark:text-blue-400 font-mono">1. Prólogo y exportación:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-tight"><i>global contar_bytes</i> hace público el símbolo. Respaldamos <i>EBP</i> y <i>EBX</i>.</p>
  </div>
  <div v-click="1" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="font-bold text-emerald-600 dark:text-emerald-400 font-mono">2. Abrir archivo:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-tight">Cargamos la ruta desde <i>[ebp + 8]</i> en <i>EBX</i> y llamamos a <i>sys_open</i>.</p>
  </div>
  <div v-click="2" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="font-bold text-amber-600 dark:text-amber-400 font-mono">3. Calcular tamaño:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-tight">Invocamos <i>sys_lseek</i> con <i>SEEK_END</i> para capturar la longitud en <i>EAX</i>.</p>
  </div>
  <div v-click="3" class="p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="font-bold text-purple-600 dark:text-purple-400 font-mono">4. Epílogo y retorno:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-tight">Cerramos el archivo, restauramos <i>EBX</i>, <i>EBP</i> y retornamos con <i>ret</i>.</p>
  </div>
</div>

::right::

<div class="font-mono text-[7.8px]">

```asm {all|1-7|9-16|18-26|28-34}
global contar_bytes
section .text

contar_bytes:
  push ebp            ; guardar marco anterior
  mov ebp, esp
  push ebx            ; callee-saved: guardar EBX

  ; 1. Abrir archivo (ruta en [ebp + 8])
  mov eax, 5          ; sys_open
  mov ebx, [ebp + 8]  ; puntero a la ruta
  mov ecx, 0          ; O_RDONLY
  int 0x80
  cmp eax, 0
  jl .error_abrir
  mov ebx, eax        ; EBX = descriptor de archivo

  ; 2. Medir tamaño con sys_lseek
  mov eax, 19         ; sys_lseek
  mov ecx, 0          ; offset 0
  mov edx, 2          ; SEEK_END
  int 0x80
  push eax            ; respaldar tamaño devuelto en EAX

  ; 3. Cerrar archivo
  mov eax, 6          ; sys_close
  int 0x80
  pop eax             ; restaurar tamaño como retorno

  jmp .salir

.error_abrir:
  mov eax, -1         ; indicar error a C

.salir:
  pop ebx             ; restaurar EBX
  mov esp, ebp        ; desmontar marco
  pop ebp
  ret                 ; retorno a C con resultado en EAX
```

</div>

<!--
En esta diapositiva apreciamos el código completo de la subrutina contar_bytes en NASM.

Observen el prólogo: push ebp, mov ebp, esp y push ebx.

[click] Extraemos la ruta directamente desde la pila con [ebp + 8] y abrimos el archivo con sys_open.

[click] Con el descriptor en EBX, ejecutamos sys_lseek hacia SEEK_END. El tamaño del archivo queda en EAX. Lo guardamos momentáneamente en la pila con push eax mientras cerramos el archivo con sys_close, y lo recuperamos con pop eax.

[click] El epílogo restaura fielmente EBX y EBP, ejecutando ret. El programa en C recibirá exactamente el valor que dejamos en EAX.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Programa anfitrión en C y cadena de enlazado

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Taller 4 &bull; Paso 3 de 3: Código fuente main.c y compilación con GCC:
</div>

<div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-1 font-sans">
  Programa anfitrión (main.c)
</div>

<div class="font-mono text-[8.5px]">

```c {all|1-4|6-10|11-15|16-17}
#include <stdio.h>

// Declaración de función externa en NASM
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
```

</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] text-center font-sans">
  Comandos de construcción y ejecución en consola
</div>

<div class="space-y-2 font-sans text-[9.5px]">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-gray-700 dark:text-gray-200 font-bold mb-1 font-mono text-[9px]">Paso 1: Ensamblado del módulo NASM</div>
    <div class="p-1.5 bg-gray-900 text-gray-100 rounded font-mono text-[8.5px]">
      $ nasm -f elf32 contar_bytes.asm -o contar_bytes.o
    </div>
  </div>
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-gray-700 dark:text-gray-200 font-bold mb-1 font-mono text-[9px]">Paso 2: Compilación de C y enlazado con GCC</div>
    <div class="p-1.5 bg-gray-900 text-gray-100 rounded font-mono text-[8.5px]">
      $ gcc -m32 main.c contar_bytes.o -o auditor_archivos
    </div>
  </div>
  <div v-click="2" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg text-emerald-900 dark:text-emerald-200">
    <div class="text-gray-700 dark:text-gray-200 font-bold mb-1 font-mono text-[9px]">Paso 3: Prueba de ejecución</div>
    <div class="p-1.5 bg-gray-900 text-emerald-400 rounded font-mono text-[8.5px]">
      $ ./auditor_archivos /tmp/registro.txt<br>
      El archivo '/tmp/registro.txt' mide 30 bytes
    </div>
  </div>
</div>

<!--
Para completar la solución híbrida, redactamos el programa principal en C.

Observen qué sencillo resulta: main.c valida que el usuario proporcione un archivo en la línea de comandos e invoca contar_bytes exactamente como si fuera una función de la biblioteca estándar de C.

[click] En la consola ejecutamos los dos pasos de compilación: nasm -f elf32 genera el objeto de la subrutina, y gcc -m32 compila main.c enlazándolo con contar_bytes.o en un binario ejecutable único.

[click] Al ejecutar la aplicación contra nuestro archivo generado en el Taller 1, obtenemos la medición precisa de 30 bytes, integrando armónicamente ambos lenguajes.
-->

---
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Ejercicios de práctica

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-3">
Reactivos de consolidación técnica (Preguntas 1 a 3):
</div>

<div class="space-y-3 font-sans text-xs">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="font-bold text-gray-800 dark:text-gray-200 text-[10px]">
      1. Si invocamos sys_open sobre un archivo que no existe sin la bandera O_CREAT, ¿qué valor deposita el kernel en EAX?
    </div>
    <div class="grid grid-cols-3 gap-3 text-[9px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>El valor cero indicando que no se pudo abrir ningún archivo.</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>Un entero negativo (-2 correspondiente al código ENOENT).</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>El descriptor 3 pero configurado en modo nulo por el núcleo.</span>
      </div>
    </div>
  </div>

  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="font-bold text-gray-800 dark:text-gray-200 text-[10px]">
      2. ¿Cuál es la diferencia estructural en el binario entre invocar una macro 5 veces frente a llamar una función con call 5 veces?
    </div>
    <div class="grid grid-cols-3 gap-3 text-[9px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>La macro duplica sus instrucciones en cada punto incrementando el tamaño del código, mientras que call reutiliza un único cuerpo en memoria.</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>La macro siempre es más lenta porque el procesador debe desapilar argumentos en cada iteración.</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>No existe ninguna diferencia binaria ya que el enlazador convierte todas las macros en subrutinas.</span>
      </div>
    </div>
  </div>

  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="font-bold text-gray-800 dark:text-gray-200 text-[10px]">
      3. Al combinar banderas para sys_open con O_WRONLY | O_CREAT | O_TRUNC y permisos 0644o, ¿qué ocurre si el archivo ya existía?
    </div>
    <div class="grid grid-cols-3 gap-3 text-[9px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>La llamada falla arrojando error EEXIST porque el archivo ya fue creado con anterioridad.</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>El kernel abre el archivo preservando su longitud previa y añadiendo datos al final.</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>El kernel trunca su longitud a cero bytes y lo abre en modo solo escritura listo para sobrescribir.</span>
      </div>
    </div>
  </div>
</div>

<!--
Iniciamos la primera ronda de ejercicios formativos.

Pregunta 1: Recordemos que el kernel de Linux nunca devuelve cero para indicar error de apertura. Cero es el descriptor legítimo de stdin. La respuesta correcta es la B: el kernel coloca en EAX el valor negativo -2, que corresponde al código de error estándar ENOENT de archivo inexistente.

Pregunta 2: Una macro se expande textualmente en la etapa de preensamblado. Si llamamos a la macro 5 veces, el bloque de instrucciones se copia 5 veces en la sección de texto, elevando el peso del archivo ejecutable. En cambio, call salta a una única dirección compartida. La opción correcta es la A.

Pregunta 3: La bandera O_TRUNC tiene como propósito expreso truncar la longitud del archivo existente a cero bytes. Por tanto, la opción correcta es la C: el archivo preexistente queda vacío y listo para recibir los nuevos datos sin generar ningún error de colisión.
-->

---
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Ejercicios de práctica (Parte 2)

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-3">
Reactivos de consolidación técnica (Preguntas 4 a 6):
</div>

<div class="space-y-3 font-sans text-xs">
  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="font-bold text-gray-800 dark:text-gray-200 text-[10px]">
      4. En un bucle de lectura con sys_read, ¿cuál es la condición inequívoca de fin de archivo (EOF)?
    </div>
    <div class="grid grid-cols-3 gap-3 text-[9px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>Que el buffer de lectura contenga el carácter especial 0xFF.</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>Que el valor devuelto por el kernel en EAX sea exactamente cero.</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>Que la llamada genere una interrupción de desbordamiento en la CPU.</span>
      </div>
    </div>
  </div>

  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="font-bold text-gray-800 dark:text-gray-200 text-[10px]">
      5. Bajo la convención cdecl, si una subrutina en NASM altera los registros ESI y EBX, ¿cuál es su obligación antes de retornar?
    </div>
    <div class="grid grid-cols-3 gap-3 text-[9px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>Ninguna, porque ESI y EBX son registros volátiles que el llamador debe recargar.</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>Limpiar la pila con add esp, 8 antes de ejecutar la instrucción ret.</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>Respaldarlos con push al inicio y restaurar sus valores originales con pop antes de ret.</span>
      </div>
    </div>
  </div>

  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="font-bold text-gray-800 dark:text-gray-200 text-[10px]">
      6. ¿Qué consecuencia tiene olvidar invocar sys_close en un programa que abre archivos continuamente en un bucle?
    </div>
    <div class="grid grid-cols-3 gap-3 text-[9px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>Agotamiento de la tabla de descriptores de archivo del proceso arrojando error EMFILE.</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>El kernel bloquea automáticamente el bus de datos congelando el procesador.</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>Los datos del archivo se borran del disco duro al apagarse la computadora.</span>
      </div>
    </div>
  </div>
</div>

<!--
Segunda y última parte de reactivos formativos.

Pregunta 4: A diferencia de la lectura en consola donde el usuario puede ingresar líneas vacías, en archivos físicos en disco la condición universal de fin de archivo ocurre cuando sys_read retorna cero en EAX, indicando que el cursor alcanzó el último byte. La respuesta correcta es la B.

Pregunta 5: De acuerdo con la especificación cdecl de IA-32, EBX, ESI, EDI y EBP pertenecen a la categoría callee-saved. Si la rutina los modifica, está estrictamente obligada a restaurar los valores exactos que tenían antes de la llamada. La respuesta correcta es la C.

Pregunta 6: Cada proceso en Linux tiene un límite en la cantidad máxima de descriptores abiertos simultáneamente (típicamente 1024). Si olvidamos cerrarlos, la tabla se satura y las subsecuentes llamadas a sys_open fallarán con el código de error EMFILE (-24). La opción correcta es la A.
-->

---
layout: center
transition: fade
---

<div class="text-center space-y-4">
  <div class="text-xs font-semibold px-3 py-1 rounded-full bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/60 dark:text-blue-300 dark:border-blue-800/40 tracking-wide uppercase font-mono inline-block">
    IC3101 &bull; Semana 11
  </div>

  # Conclusiones y balance de la semana

  <div class="text-gray-600 dark:text-gray-400 text-sm max-w-xl mx-auto leading-relaxed">
    Persistencia en almacenamiento secundario, abstracción con macros y arquitectura de software modular híbrido
  </div>

  <div class="grid grid-cols-3 gap-3 max-w-2xl mx-auto pt-2 text-left font-sans text-[9.5px]">
    <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
      <div class="font-bold text-blue-600 dark:text-blue-400 mb-0.5">Persistencia en disco</div>
      <p class="text-gray-600 dark:text-gray-300 leading-snug">
        El ciclo estricto de apertura, lectura/escritura por bloques y cierre garantiza la integridad de los datos en el sistema de archivos.
      </p>
    </div>
    <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
      <div class="font-bold text-emerald-600 dark:text-emerald-400 mb-0.5">Macros de NASM</div>
      <p class="text-gray-600 dark:text-gray-300 leading-snug">
        Las macros con etiquetas locales (%%) ofrecen abstracción sin coste de pila, unificando llamadas al sistema en cabeceras <i>.inc</i>.
      </p>
    </div>
    <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
      <div class="font-bold text-purple-600 dark:text-purple-400 mb-0.5">Módulos C + NASM</div>
      <p class="text-gray-600 dark:text-gray-300 leading-snug">
        El respeto a la convención <i>cdecl</i> permite orquestar aplicaciones donde C gobierna el flujo y NASM optimiza la operación de bajo nivel.
      </p>
    </div>
  </div>
</div>

<!--
Llegamos al final de la semana 11 habiendo dominado tres pilares esenciales de los sistemas de cómputo.

Primero, la persistencia en disco: sabemos cómo crear, inspeccionar, leer y escribir archivos físicos manejando descriptores y evaluando códigos de error del kernel.

Segundo, las macros de NASM: ahora disponemos de herramientas de preprocesado para diseñar bibliotecas modulares legibles y seguras sin colisión de etiquetas.

Y tercero, la interoperabilidad híbrida: comprendemos a nivel de bits la convención cdecl para construir proyectos reales donde C y ensamblador trabajan en perfecta sincronía.

Con estas competencias estamos plenamente equipados para abordar los temas de microarquitectura y segmentación de instrucciones que nos esperan la próxima semana. ¡Muchas gracias a todos por su participación y excelente trabajo!
-->
