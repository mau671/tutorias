---
theme: default
layout: center
transition: slide-left | slide-right
addons:
  - slidev-component-zoom
---

<div class="text-center">
  <div class="text-3xl text-gray-500 dark:text-gray-400 mb-4 font-mono">Semana 11</div>
  <h1 class="text-5xl font-bold mb-6 text-gray-900 dark:text-white">Manejo de archivos en disco, macros y modularización</h1>
  <div class="text-2xl text-blue-600 dark:text-blue-400">IC3101: Arquitectura de computadores</div>
</div>

<!--
Bienvenidos a la undécima semana de tutorías de Arquitectura de Computadores.

En las sesiones anteriores aprendimos a comunicarnos con el núcleo mediante interrupciones de software y a manipular cadenas de texto masivamente en memoria.

Hoy daremos un salto fundamental hacia la persistencia de datos: aprenderemos cómo crear, leer, escribir y posicionar punteros en archivos físicos en disco mediante llamadas al sistema operativo.

Asimismo, exploraremos el potente preprocesador de NASM con macros multiparámetro y comprenderemos cómo construir proyectos híbridos modulares que conectan código en lenguaje C con rutinas de alto rendimiento en ensamblador.
-->

---
transition: fade
---

# Objetivos de la primera sesión

<div class="mb-4 text-sm text-gray-600 dark:text-gray-300">
Comprender los fundamentos de persistencia en disco, llamadas al sistema y preprocesamiento en ensamblador:
</div>
<v-clicks>

- **Abstracción de archivos y tabla de descriptores:** Analizar la filosofía Unix y el ciclo de vida de los descriptores de archivo en el PCB.
- **Llamadas al sistema para almacenamiento en disco:** Dominar los servicios <i>sys_creat</i>, <i>sys_open</i>, <i>sys_read</i>, <i>sys_write</i>, <i>sys_close</i> y <i>sys_lseek</i>.
- **Banderas de apertura y permisos octales:** Configurar modos de acceso (<i>O_RDONLY</i>, <i>O_CREAT</i>, <i>O_TRUNC</i>) y máscaras de protección estándar (0644o, 0755o).
- **Tratamiento de anomalías y convención errno:** Interpretar los códigos de error negativos devueltos por el kernel en EAX (-1 a -4095).
- **Preprocesador de NASM y modularidad:** Utilizar constantes <i>%define</i>, inclusión de archivos <i>%include</i> y macros con parámetros y etiquetas locales (%%).
- **Interfaz binaria de llamadas cdecl:** Comprender el paso de argumentos por pila, registros preservados y enlace con GCC.

</v-clicks>
<!--
Antes de entrar en materia teórica, repasemos los objetivos de esta primera sesión:

[click] Primero, comprenderemos la filosofía Unix donde todo es un archivo y cómo el núcleo gestiona los descriptores en el bloque de control del proceso.

[click] Segundo, estudiaremos las llamadas al sistema fundamentales para crear, abrir, leer, escribir, cerrar y reposicionar punteros en archivos físicos en disco.

[click] Tercero, aprenderemos a combinar banderas de acceso mediante operaciones a nivel de bits y a configurar permisos en formato octal.

[click] Cuarto, analizaremos el manejo profesional de fallos del kernel interpretando los códigos negativos de retorno en EAX.

[click] Quinto, exploraremos las herramientas del preprocesador de NASM para definir constantes simbólicas, incluir cabeceras y construir macros seguras con etiquetas locales.

[click] Y sexto, dominaremos el estándar binario de llamadas cdecl para transferir parámetros por la pila y enlazar módulos de C con subrutinas en ensamblador.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Persistencia y descriptores de archivo

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Abstracción de flujos persistentes en el bloque de control del proceso (PCB):
</div>

<div class="relative pl-3.5 space-y-3 text-xs border-l-2 border-gray-200 dark:border-gray-800 ml-1.5 mt-2.5 font-sans">
  <div class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-blue-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/80 dark:border-blue-500/30 dark:text-blue-300 text-[9.5px] font-semibold">
        Filosofía Unix
      </span>
      <span class="text-[11.5px] font-bold text-gray-900 dark:text-gray-100">Todo es un archivo</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug">
      Linux modela periféricos, terminales y almacenamiento como flujos continuos de bytes identificados por un descriptor entero positivo.
    </p>
  </div>

  <div v-click="1" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-emerald-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/80 dark:border-emerald-500/30 dark:text-emerald-300 text-[9.5px] font-semibold">
        Descriptores
      </span>
      <span class="text-[11.5px] font-bold text-gray-900 dark:text-gray-100">Estándar y persistentes</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug">
      0 (stdin), 1 (stdout) y 2 (stderr) se inicializan con el proceso. Los archivos físicos en disco reciben el descriptor libre más bajo a partir de 3.
    </p>
  </div>

  <div v-click="2" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-purple-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-purple-50 text-purple-700 border border-purple-200 dark:bg-purple-950/80 dark:border-purple-500/30 dark:text-purple-300 text-[9.5px] font-semibold">
        Ciclo de vida
      </span>
      <span class="text-[11.5px] font-bold text-gray-900 dark:text-gray-100">Gestión de recursos</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug">
      Apertura &rarr; Transferencia (Lectura/Escritura) &rarr; Posicionamiento &rarr; Cierre obligatorio con <i>sys_close</i> para vaciar buffers del núcleo.
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] text-center font-sans">
  Tabla de descriptores en memoria del proceso
</div>

<div class="space-y-1.5 font-sans">
  <div class="flex items-center justify-between px-2 py-1 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded font-mono text-[9px] opacity-75">
    <span class="px-1.5 py-0.5 rounded bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 font-bold">FD 0</span>
    <span class="text-gray-700 dark:text-gray-300">stdin</span>
    <span class="text-gray-500 font-sans text-[8.5px]">Teclado (/dev/tty)</span>
  </div>
  <div class="flex items-center justify-between px-2 py-1 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded font-mono text-[9px] opacity-75">
    <span class="px-1.5 py-0.5 rounded bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 font-bold">FD 1</span>
    <span class="text-gray-700 dark:text-gray-300">stdout</span>
    <span class="text-gray-500 font-sans text-[8.5px]">Pantalla (/dev/pts/X)</span>
  </div>
  <div class="flex items-center justify-between px-2 py-1 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded font-mono text-[9px] opacity-75">
    <span class="px-1.5 py-0.5 rounded bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 font-bold">FD 2</span>
    <span class="text-gray-700 dark:text-gray-300">stderr</span>
    <span class="text-gray-500 font-sans text-[8.5px]">Pantalla sin buffer</span>
  </div>
  <div v-click="3" class="flex items-center justify-between px-2 py-1 bg-emerald-50 dark:bg-emerald-950/40 border border-emerald-300 dark:border-emerald-700/60 rounded font-mono text-[9.5px]">
    <span class="px-1.5 py-0.5 rounded bg-emerald-600 text-white font-bold">FD 3</span>
    <span class="font-bold text-emerald-800 dark:text-emerald-300">/tmp/datos.txt</span>
    <span class="text-emerald-700 dark:text-emerald-400 font-sans text-[8.5px]">Archivo regular (disco)</span>
  </div>
  <div v-click="4" class="flex items-center justify-between px-2 py-1 bg-blue-50 dark:bg-blue-950/40 border border-blue-300 dark:border-blue-700/60 rounded font-mono text-[9.5px]">
    <span class="px-1.5 py-0.5 rounded bg-blue-600 text-white font-bold">FD 4</span>
    <span class="font-bold text-blue-800 dark:text-blue-300">/var/log/app.log</span>
    <span class="text-blue-700 dark:text-blue-400 font-sans text-[8.5px]">Archivo en modo append</span>
  </div>
</div>

<div v-click="4" class="mt-2 text-[9px] text-gray-500 dark:text-gray-400 font-sans pl-1">
  &bull; Al cerrar con <i>sys_close</i>, el kernel libera la entrada para la próxima apertura exitosa.
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

<div class="space-y-3 mt-2 text-xs font-sans">
  <div class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">sys_creat</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">EAX = 8</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Crea o trunca un archivo. Recibe ruta en EBX y permisos octales en ECX. Retorna FD en EAX.
    </p>
  </div>

  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">sys_open</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">EAX = 5</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Apertura flexible con banderas en ECX (O_RDONLY, O_WRONLY, O_CREAT) y permisos en EDX.
    </p>
  </div>

  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-600 dark:text-amber-400 text-[11px]">sys_read / sys_write</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-amber-700 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">EAX = 3 / 4</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Transfieren datos entre memoria (ECX) y archivo (EBX = FD) con longitud en EDX.
    </p>
  </div>

  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-purple-600 dark:text-purple-400 text-[11px]">sys_close</span>
      <span class="text-purple-400 dark:text-purple-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-purple-700 bg-purple-50 border border-purple-200 dark:text-purple-300 dark:bg-purple-950/60 dark:border-purple-800/40 px-1.5 py-0.5 rounded">EAX = 6</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Vence buffers pendientes al medio físico y libera la casilla del descriptor en EBX.
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

<div v-click="4" class="mt-2 text-[9px] text-gray-500 dark:text-gray-400 font-sans pl-1">
  &bull; Tanto <i>sys_creat</i> como <i>sys_open</i> retornan el nuevo descriptor en EAX tras ejecutar <i>int 0x80</i>.
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

<div class="space-y-2 mt-1 font-sans text-xs">
  <div class="text-blue-600 dark:text-blue-400 font-bold text-[11px] mb-1 font-mono">Banderas de acceso (O_FLAGS en Linux x86)</div>
  <div class="grid grid-cols-2 gap-1.5 font-mono text-[9px]">
    <div class="px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
      <span class="font-bold text-blue-600 dark:text-blue-400">O_RDONLY:</span> 0 (Lectura)
    </div>
    <div class="px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
      <span class="font-bold text-blue-600 dark:text-blue-400">O_WRONLY:</span> 1 (Escritura)
    </div>
    <div class="px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
      <span class="font-bold text-blue-600 dark:text-blue-400">O_RDWR:</span> 2 (Lectura/Escritura)
    </div>
    <div class="px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
      <span class="font-bold text-emerald-600 dark:text-emerald-400">O_CREAT:</span> 64 (0x40)
    </div>
    <div class="px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
      <span class="font-bold text-amber-600 dark:text-amber-400">O_TRUNC:</span> 512 (0x200)
    </div>
    <div class="px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
      <span class="font-bold text-purple-600 dark:text-purple-400">O_APPEND:</span> 1024 (0x400)
    </div>
  </div>
  <p class="text-gray-600 dark:text-gray-400 text-[9px] leading-snug pl-1">
    &bull; Se combinan mediante OR a nivel de bits: <i>O_WRONLY | O_CREAT | O_TRUNC = 577</i> (0x241).
  </p>
  <div v-click="1" class="text-[9px] text-emerald-700 dark:text-emerald-300 font-sans pl-1">
    &bull; <strong>Creación idempotente:</strong> <i>O_CREAT | O_TRUNC</i> vacía el archivo previo o lo crea en disco si no existe.
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Estructura de permisos Unix en formato octal
</div>

<div class="space-y-2 mt-1 font-sans text-xs">
  <div class="grid grid-cols-3 gap-1.5 text-center font-mono text-[9px]">
    <div class="px-1.5 py-1 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded">
      <div class="text-blue-600 dark:text-blue-400 font-bold">Usuario (u)</div>
      <div class="text-[9.5px]">6 = 110<sub>2</sub> (rw-)</div>
    </div>
    <div class="px-1.5 py-1 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded">
      <div class="text-emerald-600 dark:text-emerald-400 font-bold">Grupo (g)</div>
      <div class="text-[9.5px]">4 = 100<sub>2</sub> (r--)</div>
    </div>
    <div class="px-1.5 py-1 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded">
      <div class="text-purple-600 dark:text-purple-400 font-bold">Otros (o)</div>
      <div class="text-[9.5px]">4 = 100<sub>2</sub> (r--)</div>
    </div>
  </div>

  <div v-click="2" class="space-y-1 font-mono text-[8.5px]">
    <div class="flex justify-between px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
      <span class="font-bold text-blue-600 dark:text-blue-400">0644o:</span>
      <span class="text-gray-600 dark:text-gray-300">rw-r--r-- (estándar datos)</span>
    </div>
    <div class="flex justify-between px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
      <span class="font-bold text-emerald-600 dark:text-emerald-400">0600o:</span>
      <span class="text-gray-600 dark:text-gray-300">rw------- (privado dueño)</span>
    </div>
    <div class="flex justify-between px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
      <span class="font-bold text-purple-600 dark:text-purple-400">0755o:</span>
      <span class="text-gray-600 dark:text-gray-300">rwxr-xr-x (binarios/scripts)</span>
    </div>
  </div>

  <div v-click="3" class="text-[9px] text-gray-500 dark:text-gray-400 font-sans pl-1">
    &bull; En NASM, el sufijo <i>q</i> u <i>o</i> denota números en base octal: <code class="font-mono text-blue-600 dark:text-blue-400">mov edx, 0644o</code>.
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

<div class="space-y-2.5 mt-1 font-sans text-xs">
  <div class="space-y-0.5">
    <div class="font-bold text-rose-600 dark:text-rose-400 text-[11px]">Convención de retorno del kernel</div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      El kernel no aborta el proceso: retorna un entero negativo en EAX entre <i>-1</i> y <i>-4095</i> correspondiente al código <i>errno</i> negado.
    </p>
  </div>

  <div v-click="1" class="space-y-1">
    <div class="font-bold text-blue-600 dark:text-blue-400 text-[11px] mb-0.5">Códigos de error estándar (errno)</div>
    <div class="space-y-1 font-mono text-[9px]">
      <div class="flex justify-between px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-rose-600 dark:text-rose-400">EPERM (-1):</span>
        <span class="font-sans text-gray-600 dark:text-gray-300 text-[8.5px]">Operación no permitida</span>
      </div>
      <div class="flex justify-between px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-rose-600 dark:text-rose-400">ENOENT (-2):</span>
        <span class="font-sans text-gray-600 dark:text-gray-300 text-[8.5px]">Archivo inexistente</span>
      </div>
      <div class="flex justify-between px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-rose-600 dark:text-rose-400">EBADF (-9):</span>
        <span class="font-sans text-gray-600 dark:text-gray-300 text-[8.5px]">Descriptor inválido o cerrado</span>
      </div>
      <div class="flex justify-between px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-rose-600 dark:text-rose-400">EACCES (-13):</span>
        <span class="font-sans text-gray-600 dark:text-gray-300 text-[8.5px]">Permiso denegado</span>
      </div>
    </div>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Patrón de comprobación en lenguaje ensamblador
</div>

<div class="font-mono text-[8.5px]">

```asm {all|1-5|7-9|11-13|15-18}{maxHeight:'320px'}
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

<div v-click="3" class="mt-2 text-[9px] text-gray-500 dark:text-gray-400 font-sans pl-1">
  &bull; No comprobar el retorno y usar EAX directamente provocará errores en cascada <i>EBADF</i>.
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

<div class="space-y-3 mt-2 text-xs font-sans">
  <div class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">Puntero de posición</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <span class="text-gray-700 dark:text-gray-300 font-mono text-[10px]">file offset</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      El kernel rastrea el byte donde ocurrirá la próxima transferencia y avanza el cursor automáticamente.
    </p>
  </div>

  <div v-click="1" class="space-y-1.5">
    <div class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">Constantes de referencia (EDX)</div>
    <div class="space-y-1 font-mono text-[9px]">
      <div class="flex justify-between px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-blue-600 dark:text-blue-400">SEEK_SET (0):</span>
        <span class="font-sans text-gray-600 dark:text-gray-300 text-[8.5px]">Relativo al inicio del archivo</span>
      </div>
      <div class="flex justify-between px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-emerald-600 dark:text-emerald-400">SEEK_CUR (1):</span>
        <span class="font-sans text-gray-600 dark:text-gray-300 text-[8.5px]">Relativo a la posición actual</span>
      </div>
      <div class="flex justify-between px-2 py-1 bg-white dark:bg-gray-800/80 rounded border border-gray-200 dark:border-gray-700">
        <span class="font-bold text-purple-600 dark:text-purple-400">SEEK_END (2):</span>
        <span class="font-sans text-gray-600 dark:text-gray-300 text-[8.5px]">Relativo al byte final</span>
      </div>
    </div>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Técnica de obtención del tamaño de un archivo
</div>

<div class="font-mono text-[8.5px]">

```asm {all|1-5|7-9|11-15}{maxHeight:'320px'}
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

<div v-click="2" class="mt-2 text-[9px] text-gray-500 dark:text-gray-400 font-sans pl-1">
  &bull; <i>sys_lseek</i> siempre retorna en EAX la posición resultante en bytes desde el byte cero.
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

<div class="relative pl-3.5 space-y-3 text-xs border-l-2 border-gray-200 dark:border-gray-800 ml-1.5 mt-2.5 font-sans">
  <div class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-blue-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/80 dark:border-blue-500/30 dark:text-blue-300 text-[9.5px] font-semibold">
        %define vs equ
      </span>
      <span class="text-[11.5px] font-bold text-gray-900 dark:text-gray-100">Constantes</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug">
      <i>%define</i> opera a nivel de texto en el preprocesador; <i>equ</i> se resuelve en el árbol de expresiones del ensamblador.
    </p>
  </div>

  <div v-click="1" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-emerald-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/80 dark:border-emerald-500/30 dark:text-emerald-300 text-[9.5px] font-semibold">
        %include
      </span>
      <span class="text-[11.5px] font-bold text-gray-900 dark:text-gray-100">Modularidad</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug">
      Inserta cabeceras auxiliares (<i>.inc</i>) compartiendo constantes, números mágicos y definiciones entre módulos.
    </p>
  </div>

  <div v-click="2" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-purple-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-purple-50 text-purple-700 border border-purple-200 dark:bg-purple-950/80 dark:border-purple-500/30 dark:text-purple-300 text-[9.5px] font-semibold">
        Expansión
      </span>
      <span class="text-[11.5px] font-bold text-gray-900 dark:text-gray-100">Macros vs Call</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug">
      Las macros se sustituyen en línea sin coste de pila, aunque incrementan el peso binario si se invocan muchas veces.
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Declaración de constantes y modularidad
</div>

<div class="font-mono text-[8.5px]">

```asm {all|1-4|6-9|11-14}{maxHeight:'320px'}
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

<div v-click="3" class="mt-2 text-[9px] text-gray-500 dark:text-gray-400 font-sans pl-1">
  &bull; Centralizar números mágicos en un archivo <i>.inc</i> previene errores y simplifica el mantenimiento.
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

<div class="relative pl-3.5 space-y-3 text-xs border-l-2 border-gray-200 dark:border-gray-800 ml-1.5 mt-2.5 font-sans">
  <div class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-blue-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/80 dark:border-blue-500/30 dark:text-blue-300 text-[9.5px] font-semibold">
        %macro / %endmacro
      </span>
      <span class="text-[11.5px] font-bold text-gray-900 dark:text-gray-100">Parámetros</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug">
      Los parámetros posicionales se referencian como <i>%1</i>, <i>%2</i>, ..., <i>%n</i> en el orden de llamada.
    </p>
  </div>

  <div v-click="1" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-rose-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/80 dark:border-rose-500/30 dark:text-rose-300 text-[9.5px] font-semibold">
        Símbolo duplicado
      </span>
      <span class="text-[11.5px] font-bold text-gray-900 dark:text-gray-100">Riesgo</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug">
      Si una macro usa etiquetas ordinarias (ej. <i>.fin:</i>), invocarla dos veces genera un error fatal de símbolo duplicado.
    </p>
  </div>

  <div v-click="2" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-emerald-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/80 dark:border-emerald-500/30 dark:text-emerald-300 text-[9.5px] font-semibold">
        %%etiqueta
      </span>
      <span class="text-[11.5px] font-bold text-gray-900 dark:text-gray-100">Solución segura</span>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug">
      Al anteponer <i>%%</i>, NASM genera identificadores irrepetibles (ej. <i>..@1.etiqueta</i>) en cada expansión.
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] text-center font-sans">
  Macro segura con etiquetas locales únicas
</div>

<div class="font-mono text-[8.5px]">

```asm {all|1-3|5-10|12-14|16-19}{maxHeight:'330px'}
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

<div class="space-y-3 mt-1.5 text-xs font-sans">
  <div class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">1. Visibilidad de símbolos</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">global / extern</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      <code>global</code> exporta un símbolo a la tabla ELF haciéndolo visible al enlazador; <code>extern</code> declara que el símbolo reside en otro archivo objeto.
    </p>
  </div>

  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">2. Arquitectura modular</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">C + Ensamblador</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Combina la expresividad de C para la interfaz y lógica de control con la eficiencia de NASM para rutinas críticas donde se requiere control exacto de registros.
    </p>
  </div>

  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-purple-600 dark:text-purple-400 text-[11px]">3. Compilación independiente</span>
      <span class="text-purple-400 dark:text-purple-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-purple-700 bg-purple-50 border border-purple-200 dark:text-purple-300 dark:bg-purple-950/60 dark:border-purple-800/40 px-1.5 py-0.5 rounded">gcc -m32</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Cada fuente se genera por separado a objeto <code>.o</code> de 32 bits, delegando a GCC la invocación de <code>ld</code> para la resolución final de enlaces sin colisiones.
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-2.5 text-[11px] text-center font-sans">
  Cadena de enlazado de módulos independientes
</div>

<div class="space-y-2 text-xs font-sans">
  <div class="flex items-center justify-between px-3 py-2 bg-gray-50 dark:bg-gray-800/70 rounded-lg border border-gray-200 dark:border-gray-700 text-[9.5px]">
    <span class="font-mono font-bold text-blue-600 dark:text-blue-400">rutina.asm</span>
    <span class="text-gray-400 dark:text-gray-500 font-mono text-xs">&rarr; nasm -f elf32 &rarr;</span>
    <span class="font-mono font-bold text-emerald-600 dark:text-emerald-400">rutina.o</span>
  </div>

  <div class="flex items-center justify-between px-3 py-2 bg-gray-50 dark:bg-gray-800/70 rounded-lg border border-gray-200 dark:border-gray-700 text-[9.5px]">
    <span class="font-mono font-bold text-blue-600 dark:text-blue-400">main.c</span>
    <span class="text-gray-400 dark:text-gray-500 font-mono text-xs">&rarr; gcc -m32 -c &rarr;</span>
    <span class="font-mono font-bold text-emerald-600 dark:text-emerald-400">main.o</span>
  </div>

  <div v-click="3" class="flex items-center justify-center gap-2 py-1 text-gray-400 dark:text-gray-500 font-mono text-[9px] font-bold">
    <span>&darr;</span>
    <span>Enlazador (ld invocado por gcc -m32)</span>
    <span>&darr;</span>
  </div>

  <div v-click="3" class="px-3 py-2 bg-emerald-50 dark:bg-emerald-950/50 border border-emerald-300 dark:border-emerald-700/60 rounded-lg text-center font-mono text-[10px] font-bold text-emerald-700 dark:text-emerald-300">
    Archivo ejecutable final (formato ELF32)
  </div>

  <div v-click="3" class="mt-2 text-[9px] text-gray-500 dark:text-gray-400 text-center font-sans">
    &bull; GCC unifica las tablas de símbolos y genera el binario ejecutable sin colisiones.
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

<div class="space-y-3 mt-2 text-xs font-sans">
  <div class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">Paso por pila</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">push argN..arg1</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Los parámetros se apilan de derecha a izquierda quedando el primero en el tope.
    </p>
  </div>

  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">Valor de retorno</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">EAX</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Los valores escalares y punteros devueltos a C deben quedar estrictamente en EAX.
    </p>
  </div>

  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-purple-600 dark:text-purple-400 text-[11px]">Limpieza de pila</span>
      <span class="text-purple-400 dark:text-purple-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-purple-700 bg-purple-50 border border-purple-200 dark:text-purple-300 dark:bg-purple-950/60 dark:border-purple-800/40 px-1.5 py-0.5 rounded">add esp, N</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      El llamador (C) retira los argumentos apilados tras la ejecución de <i>ret</i>.
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

<div class="text-center">
  <div class="text-3xl text-gray-500 dark:text-gray-400 mb-4 font-mono">Semana 11</div>
  <h1 class="text-6xl font-bold mb-8">Sesión 02: Práctica guiada</h1>
  <div class="text-2xl text-blue-600 dark:text-blue-500 mt-4">IC3101: Arquitectura de computadores</div>
</div>
<!--
¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de persistencia, llamadas al sistema, preprocesador de macros y convención cdecl, dedicaremos esta jornada completa a la programación práctica en consola, implementando rutinas de archivo paso a paso y construyendo un proyecto modular híbrido con C y NASM.
-->

---
transition: fade
---

# Objetivos de la segunda sesión

<div class="mb-4 text-sm text-gray-600 dark:text-gray-300">
Desarrollar destrezas prácticas en manejo de archivos, modularidad con macros e integración C con NASM:
</div>
<v-clicks>

- **Creación y persistencia de archivos en disco:** Implementar rutinas con <i>sys_creat</i> y <i>sys_open</i> configurando permisos octales 0644, verificando fallos del kernel y liberando descriptores con <i>sys_close</i>.
- **Lectura en bloques y detección de EOF:** Construir bucles de lectura por ventanas en memoria con <i>sys_read</i>, detectando fin de archivo (EAX = 0) y manipulando el cursor con <i>sys_lseek</i>.
- **Modularidad con macros en NASM:** Diseñar una cabecera modular <i>.inc</i> con macros multiparámetro utilizando etiquetas locales con doble porcentaje (%%) para evitar colisiones.
- **Integración de aplicaciones híbridas C + NASM:** Programar y enlazar una subrutina en ensamblador invocada desde C respetando el estándar <i>cdecl</i> y la preservación de registros en la pila.

</v-clicks>
<!--
Antes de iniciar los ejercicios prácticos, repasemos los cuatro objetivos de esta segunda jornada:

[click] Primero, aprenderemos a crear archivos en disco físico aplicando permisos octales, escribiendo registros en memoria y cerrando el descriptor con seguridad.

[click] Segundo, diseñaremos un bucle robusto de lectura por bloques que detecta con precisión el fin de archivo cuando EAX es cero, complementado con cálculo de tamaño mediante sys_lseek.

[click] Tercero, construiremos una librería de macros reutilizable en un archivo .inc aplicando etiquetas locales seguras.

[click] Y cuarto, unificaremos C y NASM en un proyecto ejecutable enlazado con GCC de 32 bits, verificando la convención cdecl.
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
Especificación técnica y estructura de datos en memoria:
</div>

<div class="space-y-3 mt-1.5 text-xs font-sans">
  <div class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">1. Especificación técnica</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">0644o (rw-r--r--)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Crear en disco el archivo <code>/tmp/registro.txt</code> con permisos estándar de persistencia, escribir el mensaje estructurado y cerrar el descriptor asegurando la integridad física.
    </p>
  </div>

  <div v-click="1" class="space-y-1">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">2. Secciones en memoria</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">.data / .bss</code>
    </div>
    <div class="space-y-1 font-mono text-[9px] pl-1">
      <div class="flex items-center gap-2 px-2 py-1 bg-gray-50 dark:bg-gray-800/70 rounded border border-gray-200 dark:border-gray-700">
        <span class="text-blue-600 dark:text-blue-400 font-bold shrink-0">.data:</span>
        <span class="text-gray-700 dark:text-gray-300"><code>ruta db "/tmp/registro.txt", 0</code></span>
      </div>
      <div class="flex items-center gap-2 px-2 py-1 bg-gray-50 dark:bg-gray-800/70 rounded border border-gray-200 dark:border-gray-700">
        <span class="text-emerald-600 dark:text-emerald-400 font-bold shrink-0">.data:</span>
        <span class="text-gray-700 dark:text-gray-300"><code>texto db "Registro persistente...", 0x0A</code></span>
      </div>
      <div class="flex items-center gap-2 px-2 py-1 bg-gray-50 dark:bg-gray-800/70 rounded border border-gray-200 dark:border-gray-700">
        <span class="text-purple-600 dark:text-purple-400 font-bold shrink-0">.bss:</span>
        <span class="text-gray-700 dark:text-gray-300"><code>fd_archivo resd 1</code> (descriptor de 4 bytes)</span>
      </div>
    </div>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-2.5 text-[11px] text-center font-sans">
  Preparación de registros para sys_creat (Servicio 8)
</div>

<div class="space-y-2 text-xs font-sans">
  <div class="flex justify-between items-center px-3 py-2 bg-gray-50 dark:bg-gray-800/70 rounded-lg border border-gray-200 dark:border-gray-700 font-mono text-[9.5px]">
    <span class="font-bold text-blue-600 dark:text-blue-400">EAX = 8</span>
    <span class="text-gray-600 dark:text-gray-300 font-sans text-[9px]">Número de servicio sys_creat</span>
  </div>
  <div class="flex justify-between items-center px-3 py-2 bg-gray-50 dark:bg-gray-800/70 rounded-lg border border-gray-200 dark:border-gray-700 font-mono text-[9.5px]">
    <span class="font-bold text-emerald-600 dark:text-emerald-400">EBX = ruta</span>
    <span class="text-gray-600 dark:text-gray-300 font-sans text-[9px]">Puntero a cadena terminada en 0x00</span>
  </div>
  <div class="flex justify-between items-center px-3 py-2 bg-gray-50 dark:bg-gray-800/70 rounded-lg border border-gray-200 dark:border-gray-700 font-mono text-[9.5px]">
    <span class="font-bold text-amber-600 dark:text-amber-400">ECX = 0644o</span>
    <span class="text-gray-600 dark:text-gray-300 font-sans text-[9px]">Permisos rw-r--r-- (420 decimal)</span>
  </div>

  <div v-click="2" class="mt-2 text-[9px] text-gray-500 dark:text-gray-400 text-center font-sans">
    &bull; Al retornar de <i>int 0x80</i>, el kernel entrega en EAX el nuevo descriptor. Si EAX es menor a cero, ocurrió una anomalía.
  </div>
</div>

<!--
Comenzamos analizando la especificación técnica del problema.

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
Implementación paso a paso del ciclo de creación y escritura:
</div>

<div class="space-y-3 mt-2 text-xs font-sans">
  <div class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">1. Crear archivo</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">sys_creat (8)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Invoca la creación con permisos 0644 y devuelve el descriptor nuevo en EAX.
    </p>
  </div>

  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">2. Comprobación</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">cmp eax, 0 / jl</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Si EAX es negativo bifurca al manejador de fallos; si es positivo guarda el descriptor.
    </p>
  </div>

  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-600 dark:text-amber-400 text-[11px]">3. Escribir datos</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-amber-700 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">sys_write (4)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Transfiere los bytes del buffer hacia el descriptor asignado en EBX.
    </p>
  </div>

  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-purple-600 dark:text-purple-400 text-[11px]">4. Cierre obligatorio</span>
      <span class="text-purple-400 dark:text-purple-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-purple-700 bg-purple-50 border border-purple-200 dark:text-purple-300 dark:bg-purple-950/60 dark:border-purple-800/40 px-1.5 py-0.5 rounded">sys_close (6)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Descarga los buffers a disco físico y libera la entrada de la tabla del proceso.
    </p>
  </div>
</div>

::right::

<div class="font-mono text-[8px]">

```asm {all|1-7|9-15|17-23|25-29}{maxHeight:'340px'}
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
Manejo de errores del kernel y validación en consola:
</div>

<div class="space-y-2 font-sans text-xs">
  <div class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-rose-600 dark:text-rose-400 text-[11px]">Tratamiento de excepción</span>
      <span class="text-rose-400 dark:text-rose-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-rose-700 bg-rose-50 border border-rose-200 dark:text-rose-300 dark:bg-rose-950/60 dark:border-rose-800/40 px-1.5 py-0.5 rounded">stderr (FD 2)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Si la creación falla, emite el diagnóstico hacia FD 2 y finaliza con código no nulo.
    </p>
  </div>

  <div v-click="1" class="font-mono text-[8px]">

```asm {*}{maxHeight:'260px'}
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

<div class="text-blue-600 dark:text-blue-400 font-bold mb-2 text-[11px] text-center font-sans">
  Verificación en consola del archivo creado
</div>

<div v-click="2" class="flex flex-col items-center">
  <img src="/images/verificacion_archivo.png" class="rounded-xl shadow-lg border border-gray-200 dark:border-gray-800 max-h-[300px] w-auto object-contain" />
  <div class="mt-2 text-[9px] text-gray-500 dark:text-gray-400 text-center font-sans">
    Inspección real de permisos 0644, tamaño exacto (30 bytes) y volcado con hexdump.
  </div>
</div>

<!--
Para cerrar esta primera etapa, analizamos cómo responder ante situaciones anómalas.

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
Técnica de ventanas en memoria y control de flujo con sys_read:
</div>

<div class="space-y-3 mt-1.5 text-xs font-sans">
  <div class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">1. Técnica de ventanas fijas</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">sys_read en bucle</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Un archivo físico puede medir kilobytes o gigabytes. La arquitectura robusta procesa la información leyendo bloques secuenciales de tamaño constante (ej. 64 bytes).
    </p>
  </div>

  <div v-click="1" class="space-y-1">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">2. Estados de retorno en EAX</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">Condición de corte</code>
    </div>
    <div class="space-y-1 text-[9.5px] pl-1 font-sans">
      <div class="flex items-center gap-2">
        <span class="font-bold text-emerald-600 font-mono shrink-0">EAX &gt; 0:</span>
        <span class="text-gray-600 dark:text-gray-300">Lectura exitosa de <i>N</i> bytes transferidos al buffer.</span>
      </div>
      <div class="flex items-center gap-2">
        <span class="font-bold text-blue-600 font-mono shrink-0">EAX == 0:</span>
        <span class="text-gray-600 dark:text-gray-300">Fin de archivo (EOF). No restan más bytes en disco.</span>
      </div>
      <div class="flex items-center gap-2">
        <span class="font-bold text-rose-600 font-mono shrink-0">EAX &lt; 0:</span>
        <span class="text-gray-600 dark:text-gray-300">Fallo de lectura en hardware o descriptor inválido.</span>
      </div>
    </div>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-2.5 text-[11px] text-center font-sans">
  Máquina de estados del bucle de lectura
</div>

<div class="space-y-2 text-xs font-sans">
  <div class="p-2 bg-blue-50 dark:bg-blue-950/60 border border-blue-200 dark:border-blue-800 rounded-lg text-center font-mono text-[9.5px] font-bold text-blue-800 dark:text-blue-200">
    sys_open("/tmp/datos.txt", O_RDONLY)
  </div>

  <div class="text-center font-mono font-bold text-[9px] text-gray-400 dark:text-gray-500">
    &darr; Descriptor válido (EAX &ge; 3) &darr;
  </div>

  <div class="p-2 bg-gray-50 dark:bg-gray-800/70 border border-gray-200 dark:border-gray-700 rounded-lg text-center font-mono text-[9.5px]">
    <div class="font-bold text-emerald-600 dark:text-emerald-400">.bucle_lectura:</div>
    <div class="text-gray-600 dark:text-gray-300 text-[9px] mt-0.5">sys_read(fd, buffer, 64)</div>
  </div>

  <div v-click="2" class="grid grid-cols-2 gap-2 text-center font-mono text-[8.5px]">
    <div class="p-2 bg-emerald-50 dark:bg-emerald-950/50 rounded-lg border border-emerald-300 dark:border-emerald-700 text-emerald-800 dark:text-emerald-200">
      <div class="font-bold">EAX &gt; 0</div>
      <div class="text-[8px] text-gray-600 dark:text-gray-300 mt-0.5">sys_write(stdout) &rarr; loop</div>
    </div>
    <div class="p-2 bg-gray-100 dark:bg-gray-800/90 rounded-lg border border-gray-300 dark:border-gray-700 text-gray-800 dark:text-gray-200">
      <div class="font-bold">EAX == 0 (EOF)</div>
      <div class="text-[8px] text-gray-600 dark:text-gray-300 mt-0.5">sys_close(fd) &rarr; exit</div>
    </div>
  </div>

  <div v-click="2" class="mt-2 text-[9px] text-gray-500 dark:text-gray-400 text-center font-sans">
    &bull; El valor devuelto por <i>sys_read</i> en EAX sirve simultáneamente como bandera de control y longitud de bytes a imprimir.
  </div>
</div>

<!--
Pasamos ahora a la lectura secuencial de archivos en disco.

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
Implementación del bucle de lectura por bloques y salida a stdout:
</div>

<div class="space-y-3 mt-2 text-xs font-sans">
  <div class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">1. Apertura</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">sys_open (5)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Abre el archivo en solo lectura (ECX = 0) y respalda el descriptor retornado.
    </p>
  </div>

  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">2. Lectura en bloque</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">sys_read (3)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Pide hasta 64 bytes al kernel colocando los datos en el buffer de memoria.
    </p>
  </div>

  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-600 dark:text-amber-400 text-[11px]">3. Comprobación EOF</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-amber-700 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">cmp eax, 0 / jle</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Si EAX es 0 se llegó a fin de archivo; si es negativo ocurrió un error en disco.
    </p>
  </div>

  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-purple-600 dark:text-purple-400 text-[11px]">4. Emisión a stdout</span>
      <span class="text-purple-400 dark:text-purple-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-purple-700 bg-purple-50 border border-purple-200 dark:text-purple-300 dark:bg-purple-950/60 dark:border-purple-800/40 px-1.5 py-0.5 rounded">sys_write (4)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Escribe en la pantalla (FD 1) exactamente la cantidad de bytes transferidos.
    </p>
  </div>
</div>

::right::

<div class="font-mono text-[8px]">

```asm {all|1-7|9-16|18-24|26-31}{maxHeight:'340px'}
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
Manipulación del cursor y cálculo de tamaño con sys_lseek:
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

```asm {all|1-6|8-11|13-18}{maxHeight:'270px'}
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
Para culminar esta fase, examinemos la llamada sys_lseek.

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
Encapsulación declarativa y prevención de colisión de símbolos:
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

```asm {all|1-3|5-12|14-20}{maxHeight:'330px'}
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
Abordamos a continuación la ingeniería de macros para construir bibliotecas de código reutilizable.

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
Cabecera modular archivos.inc y simplificación del código fuente:
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

```asm {all|1-3|5-9|11-16|18-20}{maxHeight:'330px'}
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
Firma de subrutina externa y disposición del marco de pila:
</div>

<div class="space-y-3 mt-1.5 text-xs font-sans">
  <div class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">1. Declaración externa en C</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">extern int contar_bytes(...)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      El anfitrión en C delega a ensamblador la apertura del archivo y la medición con <code>sys_lseek</code>, esperando el retorno entero en <code>EAX</code>.
    </p>
  </div>

  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">2. Convención cdecl en 32 bits</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">[ebp + 8]</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Al montar el marco con <code>push ebp</code> y <code>mov ebp, esp</code>, el puntero al primer parámetro de la ruta reside exactamente en <code>[ebp + 8]</code>.
    </p>
  </div>
</div>

::right::

<div class="text-blue-600 dark:text-blue-400 font-bold mb-2.5 text-[11px] text-center font-sans">
  Mapa de la pila de memoria (cdecl)
</div>

<div class="space-y-2 text-xs font-sans">
  <div class="flex justify-between items-center px-3 py-2 bg-gray-50 dark:bg-gray-800/70 rounded-lg border border-gray-200 dark:border-gray-700 font-mono text-[9.5px]">
    <span class="font-bold text-blue-600 dark:text-blue-400">[ebp + 8]</span>
    <span class="text-gray-700 dark:text-gray-300 font-sans text-[9px]">Puntero a ruta (const char *)</span>
  </div>

  <div class="flex justify-between items-center px-3 py-2 bg-gray-50 dark:bg-gray-800/70 rounded-lg border border-gray-200 dark:border-gray-700 font-mono text-[9.5px]">
    <span class="font-bold text-emerald-600 dark:text-emerald-400">[ebp + 4]</span>
    <span class="text-gray-700 dark:text-gray-300 font-sans text-[9px]">Dirección de retorno (EIP guardado)</span>
  </div>

  <div class="flex justify-between items-center px-3 py-2 bg-gray-50 dark:bg-gray-800/70 rounded-lg border border-gray-200 dark:border-gray-700 font-mono text-[9.5px]">
    <span class="font-bold text-amber-600 dark:text-amber-400">[ebp]</span>
    <span class="text-gray-700 dark:text-gray-300 font-sans text-[9px]">EBP anterior del llamador en C</span>
  </div>

  <div v-click="2" class="flex justify-between items-center px-3 py-2 bg-purple-50 dark:bg-purple-950/50 rounded-lg border border-purple-300 dark:border-purple-700/60 font-mono text-[9.5px] text-purple-900 dark:text-purple-200">
    <span class="font-bold">[esp]</span>
    <span class="font-sans text-[9px]">Registros preservados (push ebx)</span>
  </div>

  <div v-click="2" class="mt-2 text-[9px] text-gray-500 dark:text-gray-400 text-center font-sans">
    &bull; La subrutina debe preservar registros <i>callee-saved</i> (EBX, ESI, EDI) antes de retornar.
  </div>
</div>

<!--
Llegamos ahora a la integración donde uniremos el lenguaje C con NASM en una solución híbrida.

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
Subrutina contar_bytes en NASM con preservación de registros:
</div>

<div class="space-y-3 mt-2 text-xs font-sans">
  <div class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">1. Prólogo y exportación</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">global / push ebx</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Exporta el símbolo ELF y preserva EBX junto a EBP cumpliendo la convención cdecl.
    </p>
  </div>

  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-emerald-600 dark:text-emerald-400 text-[11px]">2. Abrir archivo</span>
      <span class="text-emerald-400 dark:text-emerald-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-emerald-700 bg-emerald-50 border border-emerald-200 dark:text-emerald-300 dark:bg-emerald-950/60 dark:border-emerald-800/40 px-1.5 py-0.5 rounded">sys_open [ebp+8]</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Recupera el puntero al archivo desde la pila y obtiene el descriptor del núcleo.
    </p>
  </div>

  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-600 dark:text-amber-400 text-[11px]">3. Medir tamaño</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-amber-700 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">sys_lseek (SEEK_END)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Mueve el cursor al final para capturar la cantidad total de bytes en EAX.
    </p>
  </div>

  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-purple-600 dark:text-purple-400 text-[11px]">4. Epílogo y retorno</span>
      <span class="text-purple-400 dark:text-purple-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-purple-700 bg-purple-50 border border-purple-200 dark:text-purple-300 dark:bg-purple-950/60 dark:border-purple-800/40 px-1.5 py-0.5 rounded">pop ebx / ret</code>
    </div>
    <p class="text-gray-600 dark:text-gray-400 text-[9.5px] leading-snug pl-1">
      Cierra el descriptor, restaura los registros callee-saved y devuelve el control a C.
    </p>
  </div>
</div>

::right::

<div class="font-mono text-[7.8px]">

```asm {all|1-7|9-16|18-26|28-34}{maxHeight:'340px'}
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
Programa anfitrión en C y flujo de construcción con GCC:
</div>

<div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-1 font-sans">
  Programa anfitrión (main.c)
</div>

<div class="font-mono text-[8.5px]">

```c {all|1-4|6-10|11-15|16-17}{maxHeight:'320px'}
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

<div class="text-blue-600 dark:text-blue-400 font-bold mb-2 text-[11px] text-center font-sans">
  Comandos de construcción y ejecución en consola
</div>

<div v-click="1" class="flex flex-col items-center">
  <img v-if="$clicks < 2" src="/images/compilacion_hibrida.png" class="rounded-xl shadow-lg border border-gray-200 dark:border-gray-800 max-h-[290px] w-auto object-contain" />
  <img v-else src="/images/ejecucion_hibrida.png" class="rounded-xl shadow-lg border border-gray-200 dark:border-gray-800 max-h-[290px] w-auto object-contain" />
  <div class="mt-2 text-[9px] text-gray-500 dark:text-gray-400 text-center font-sans">
    <span v-if="$clicks < 2">Pasos 1 y 2: Ensamblado con NASM (elf32) y compilación/enlazado con GCC (-m32).</span>
    <span v-else>Paso 3: Ejecución del auditor integrado comprobando el tamaño exacto de 30 bytes.</span>
  </div>
</div>

<!--
Para completar la solución híbrida, redactamos el programa principal en C.

Observen qué sencillo resulta: main.c valida que el usuario proporcione un archivo en la línea de comandos e invoca contar_bytes exactamente como si fuera una función de la biblioteca estándar de C.

[click] En la consola ejecutamos los dos pasos de compilación: nasm -f elf32 genera el objeto de la subrutina, y gcc -m32 compila main.c enlazándolo con contar_bytes.o en un binario ejecutable único.

[click] Al ejecutar la aplicación contra nuestro archivo generado previamente, obtenemos la medición precisa de 30 bytes, integrando armónicamente ambos lenguajes.
-->

---
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Ejercicios de práctica

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Llamadas al sistema, macros de preprocesador y banderas de acceso:
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

# Ejercicios de práctica

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Trazado de bucles de lectura, convención cdecl y cierre de descriptores:
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
Continuamos con la siguiente ronda de reactivos formativos.

Pregunta 4: A diferencia de la lectura en consola donde el usuario puede ingresar líneas vacías, en archivos físicos en disco la condición universal de fin de archivo ocurre cuando sys_read retorna cero en EAX, indicando que el cursor alcanzó el último byte. La respuesta correcta es la B.

Pregunta 5: De acuerdo con la especificación cdecl de IA-32, EBX, ESI, EDI y EBP pertenecen a la categoría callee-saved. Si la rutina los modifica, está estrictamente obligada a restaurar los valores exactos que tenían antes de la llamada. La respuesta correcta es la C.

Pregunta 6: Cada proceso en Linux tiene un límite en la cantidad máxima de descriptores abiertos simultáneamente (típicamente 1024). Si olvidamos cerrarlos, la tabla se satura y las subsecuentes llamadas a sys_open fallarán con el código de error EMFILE (-24). La opción correcta es la A.
-->

---
layout: center
transition: fade
---

<div class="text-center max-w-xl mx-auto font-sans">
  <h1 class="text-3xl font-bold mb-3 text-gray-900 dark:text-white">Conclusiones y siguiente paso</h1>
  <div class="p-3.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl text-left text-xs text-gray-700 dark:text-gray-300 space-y-1.5 mt-3">
    <p>
      &bull; Comprendimos la filosofía Unix de descriptores de archivo y el ciclo de vida estricto de apertura, transferencia por bloques y cierre obligatorio.
    </p>
    <p>
      &bull; Dominamos las llamadas al sistema <i>sys_creat</i>, <i>sys_open</i>, <i>sys_read</i>, <i>sys_write</i>, <i>sys_close</i> y <i>sys_lseek</i> junto con la interpretación de códigos <i>errno</i> negativos en EAX.
    </p>
    <p>
      &bull; Adquirimos destreza en el diseño de cabeceras modulares <i>.inc</i> y macros seguras con etiquetas locales con doble porcentaje (%%) para evitar colisiones.
    </p>
    <p>
      &bull; Integramos aplicaciones híbridas C + NASM respetando rigurosamente el contrato binario <i>cdecl</i> y la preservación de registros en la pila.
    </p>
    <p>
      &bull; En la <strong>Semana 12</strong> estudiaremos la <strong>arquitectura del procesador, segmentación de cauce (pipeline) y riesgos</strong> (estructurales, de datos y de control).
    </p>
  </div>
  <div class="text-blue-600 dark:text-blue-400 font-semibold mt-3 text-xs">
    ¡Muchas gracias por su atención y nos vemos en la Semana 12!
  </div>
</div>
<!--
Con esto concluimos la undécima semana de tutorías de Arquitectura de Computadores.

Hemos construido los cimientos indispensables para interactuar con almacenamiento persistente y estructurar aplicaciones modulares de bajo nivel, dominando la sincronía entre C y ensamblador.

En la próxima semana profundizaremos en la microarquitectura interna del procesador, analizando la segmentación de cauce y las técnicas para mitigar riesgos en hardware.

¡Excelente trabajo a todos y nos vemos en la siguiente sesión!
-->
