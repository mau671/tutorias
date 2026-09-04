---
theme: default
layout: center
transition: slide-left | slide-right
addons:
  - slidev-component-zoom
---

<div class="text-center">
  <div class="text-3xl text-gray-500 dark:text-gray-400 mb-4 font-mono">Semana 09</div>
  <h1 class="text-5xl font-bold mb-6 text-gray-900 dark:text-white">Llamadas al sistema e interacción con el sistema operativo</h1>
  <div class="text-2xl text-blue-600 dark:text-blue-400">IC3101: Arquitectura de computadores</div>
</div>
<!--
Hola a todos. Bienvenidos a la novena semana de tutorías de Arquitectura de Computadores.

Hasta este momento hemos trabajado con instrucciones que operan internamente sobre registros y memoria, como sumas, comparaciones, saltos condicionales y marcos de pila.

Hoy daremos un paso trascendental al conectar nuestros programas con el mundo exterior mediante las llamadas al sistema. Comprenderemos la separación de privilegios del procesador, el mecanismo de interrupciones por software y las operaciones fundamentales de entrada y salida por consola en Linux.
-->

---
transition: fade
---

# Objetivos de la primera sesión

<div class="mb-4 text-sm text-gray-600 dark:text-gray-300">
Comprender la frontera entre el espacio de usuario y el núcleo mediante llamadas al sistema:
</div>
<v-clicks>

- **Modelo de protección y modo dual:** Distinguir el aislamiento entre el nivel de usuario y el nivel de núcleo en la arquitectura del procesador.
- **Mecanismo de interrupciones por software:** Analizar la instrucción <i>int 0x80</i>, la tabla de descriptores de interrupción y la conmutación de contexto.
- **Convención de llamadas al sistema en Linux:** Dominar la asignación de registros para el identificador del servicio y la transferencia de argumentos.
- **Comparativa x86 frente a x86-64:** Contrastar la instrucción <i>int 0x80</i> de 32 bits con la instrucción rápida <i>syscall</i> de 64 bits.
- **Descriptores de archivo estándar POSIX:** Manejar los canales de entrada estándar, salida estándar y error estándar desde bajo nivel.
- **Secciones de memoria y directivas:** Analizar la estructura de código, datos inicializados y la alta eficiencia de la sección <i>.bss</i> en memoria virtual.

</v-clicks>
<!--
Antes de comenzar con el desarrollo teórico, repasemos los objetivos de esta primera sesión:

[click] Primero, entenderemos cómo el hardware garantiza la estabilidad y seguridad del sistema mediante el modo dual y los anillos de protección.

[click] Segundo, analizaremos el mecanismo de interrupción por software que permite solicitar servicios al núcleo de forma ordenada y controlada.

[click] Tercero, aprenderemos la convención de registros para invocar llamadas al sistema bajo la arquitectura IA-32 en Linux.

[click] Cuarto, contrastaremos este mecanismo clásico con la instrucción syscall propia de la arquitectura moderna de 64 bits.

[click] Quinto, estudiaremos los descriptores de archivo estándar para gestionar entradas y salidas.

[click] Y sexto, examinaremos la organización del binario en memoria, comprendiendo por qué la sección BSS optimiza el uso del almacenamiento en disco.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Jerarquía de privilegios x86

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Aislamiento por hardware mediante niveles concéntricos de ejecución:
</div>

<div class="relative pl-3.5 space-y-2.5 text-xs border-l-2 border-gray-200 dark:border-gray-800 ml-1.5 mt-2 font-sans">
  <div v-click="1" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-rose-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/80 dark:border-rose-500/30 dark:text-rose-300 text-[9.5px] font-semibold">
        Anillo 0 &bull; Modo núcleo
      </span>
      <span class="text-[12px] font-bold text-gray-900 dark:text-gray-100">Espacio de kernel</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-snug">
      Control total del hardware, tablas de páginas, memoria física, registros de control (<i>CR0</i>, <i>CR3</i>) e interrupciones.
    </p>
  </div>

  <div v-click="2" class="relative">
    <div class="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-blue-500 ring-4 ring-white dark:ring-gray-950"></div>
    <div class="flex items-center gap-2 mb-0.5">
      <span class="px-2 py-0.5 rounded-full bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/80 dark:border-blue-500/30 dark:text-blue-300 text-[9.5px] font-semibold">
        Anillo 3 &bull; Modo usuario
      </span>
      <span class="text-[12px] font-bold text-gray-900 dark:text-gray-100">Espacio de usuario</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-snug">
      Ejecución de programas de usuario con memoria virtual restringida. Intentar acceder al hardware directamente detona una excepción <i>#GP</i>.
    </p>
  </div>
</div>

::right::

<div v-click="3" class="flex flex-col items-center justify-center">
  <div class="text-blue-600 dark:text-blue-400 font-bold text-center mb-1.5 font-sans text-[11px]">
    Anillos de protección en arquitectura x86
  </div>
  <div class="relative w-48 h-48 mx-auto my-1 flex items-center justify-center font-sans">
    <!-- Ring 3: User Space -->
    <div class="absolute inset-0 rounded-full border-2 border-blue-400 bg-blue-50/50 dark:bg-blue-950/30 dark:border-blue-500 flex items-start justify-center pt-1.5 shadow-2xs">
      <span class="text-[9px] text-blue-700 dark:text-blue-300 font-bold tracking-wide">Anillo 3: Aplicaciones</span>
    </div>
    <!-- Ring 1 & 2: Device Drivers (historical/unused in Linux) -->
    <div class="absolute inset-6 rounded-full border-2 border-dashed border-amber-400 bg-amber-50/40 dark:bg-amber-950/20 dark:border-amber-500/60 flex items-start justify-center pt-1">
      <span class="text-[8px] text-amber-700 dark:text-amber-300 font-medium">Anillos 1 y 2</span>
    </div>
    <!-- Ring 0: Kernel Space -->
    <div class="absolute inset-13 rounded-full border-2 border-rose-500 bg-rose-100 dark:bg-rose-950/80 flex flex-col items-center justify-center shadow-md">
      <span class="text-[11px] text-rose-700 dark:text-rose-200 font-bold leading-none">Anillo 0</span>
      <span class="text-[8px] text-rose-600 dark:text-rose-300 font-mono mt-0.5">Núcleo Linux</span>
    </div>
  </div>
  <div class="text-[9.5px] text-gray-500 dark:text-gray-400 font-sans mt-2 text-center">
    Mayor nivel de privilegio hacia el centro &bull; Transición estrictamente controlada
  </div>
</div>
<!--
Comencemos analizando la división de privilegios en el hardware de la CPU.

En la arquitectura x86 existen cuatro anillos de protección numerados de cero a tres. Los sistemas operativos modernos como Linux implementan el modelo dual utilizando principalmente dos niveles: el anillo cero y el anillo tres.

[click] En el anillo cero, correspondiente al modo núcleo, reside el sistema operativo. Este nivel posee facultades irrestrictas para administrar la memoria física, configurar tablas de páginas y controlar periféricos mediante registros especiales.

[click] En el anillo tres, correspondiente al modo usuario, se ejecutan nuestras aplicaciones habituales. Cualquier intento de ejecutar una instrucción privilegiada provoca de inmediato una excepción de fallo de protección general.

[click] Observemos este diagrama concéntrico. Para que una aplicación en el anillo tres solicite un servicio al núcleo, debe atravesar la frontera mediante una puerta de enlace segura provista por las interrupciones por software.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Mecanismo de interrupciones por software

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Transición controlada entre el espacio de usuario y el núcleo del sistema:
</div>

<div class="space-y-2 text-xs font-sans mt-1">
  <div v-click="1" class="flex items-start gap-2.5">
    <span class="w-5 h-5 rounded-full bg-blue-100 text-blue-700 dark:bg-blue-950/80 dark:text-blue-300 border border-blue-300 dark:border-blue-700 text-[10px] font-bold flex items-center justify-center shrink-0">1</span>
    <div>
      <div class="text-blue-600 dark:text-blue-400 font-bold text-[11px]">Disparo con int 0x80</div>
      <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-snug">
        El programa de usuario genera una interrupción por software sincrónica solicitando un servicio del sistema.
      </p>
    </div>
  </div>

  <div v-click="2" class="flex items-start gap-2.5">
    <span class="w-5 h-5 rounded-full bg-amber-100 text-amber-800 dark:bg-amber-950/80 dark:text-amber-300 border border-amber-300 dark:border-amber-700 text-[10px] font-bold flex items-center justify-center shrink-0">2</span>
    <div>
      <div class="text-amber-700 dark:text-amber-400 font-bold text-[11px]">Conmutación a modo núcleo</div>
      <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-snug">
        La CPU consulta el vector <i>0x80</i> en la IDT, conmuta a la pila del núcleo y apila <i>SS:ESP</i>, <i>EFLAGS</i> y <i>CS:EIP</i>.
      </p>
    </div>
  </div>

  <div v-click="3" class="flex items-start gap-2.5">
    <span class="w-5 h-5 rounded-full bg-emerald-100 text-emerald-800 dark:bg-emerald-950/80 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-700 text-[10px] font-bold flex items-center justify-center shrink-0">3</span>
    <div>
      <div class="text-emerald-600 dark:text-emerald-400 font-bold text-[11px]">Despacho y retorno con iret</div>
      <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-snug">
        El despachador consulta <i>sys_call_table[EAX]</i>, ejecuta la rutina, deposita el resultado en <i>EAX</i> y restaura el contexto con <i>iret</i>.
      </p>
    </div>
  </div>
</div>

::right::

<div v-click="4" class="flex flex-col items-center justify-center font-sans text-xs">
  <div class="text-blue-600 dark:text-blue-400 font-bold text-center mb-2 text-[11px]">
    Flujo de control durante una llamada al sistema
  </div>

  <!-- Paso 1: Usuario -->
  <div class="w-full max-w-[340px] p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg text-center">
    <div class="text-[9.5px] font-bold text-blue-600 dark:text-blue-400 mb-0.5">Espacio de usuario (Anillo 3)</div>
    <div class="font-mono text-[9px] text-gray-700 dark:text-gray-300">
      mov eax, 4 &bull; mov ebx, 1 &bull; int 0x80
    </div>
  </div>

  <!-- Conector hacia abajo -->
  <div class="flex flex-col items-center my-1">
    <div class="w-[1.5px] h-2 bg-gray-300 dark:bg-gray-600"></div>
    <div class="text-[8px] font-mono px-1.5 py-0.5 bg-amber-50 text-amber-800 border border-amber-200 dark:bg-amber-950/60 dark:text-amber-300 dark:border-amber-800/40 rounded">
      Vector 0x80 &bull; Conmutación de contexto
    </div>
    <div class="w-0 h-0 border-l-[3.5px] border-l-transparent border-r-[3.5px] border-r-transparent border-t-[4.5px] border-t-amber-500"></div>
  </div>

  <!-- Paso 2: Hardware / Kernel -->
  <div class="w-full max-w-[340px] p-2 bg-rose-50/60 border border-rose-200 dark:bg-rose-950/30 dark:border-rose-800/50 rounded-lg text-center">
    <div class="text-[9.5px] font-bold text-rose-700 dark:text-rose-300 mb-0.5">Espacio de núcleo (Anillo 0)</div>
    <div class="font-mono text-[8.5px] text-gray-700 dark:text-gray-300 space-y-0.5">
      <div>IDT[0x80] &rarr; system_call()</div>
      <div>call sys_call_table[EAX * 4]</div>
    </div>
  </div>

  <!-- Conector de retorno -->
  <div class="flex flex-col items-center my-1">
    <div class="w-0 h-0 border-l-[3.5px] border-l-transparent border-r-[3.5px] border-r-transparent border-b-[4.5px] border-b-emerald-500"></div>
    <div class="text-[8px] font-mono px-1.5 py-0.5 bg-emerald-50 text-emerald-800 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40 rounded">
      iret &bull; Retorno con resultado en EAX
    </div>
    <div class="w-[1.5px] h-2 bg-gray-300 dark:bg-gray-600"></div>
  </div>

  <!-- Retorno a usuario -->
  <div class="w-full max-w-[340px] p-1.5 bg-emerald-50/50 border border-emerald-200 dark:bg-emerald-950/20 dark:border-emerald-800/40 rounded-lg text-center">
    <div class="text-[9px] font-semibold text-emerald-700 dark:text-emerald-300">
      Continúa ejecución en la instrucción siguiente a <i>int 0x80</i>
    </div>
  </div>
</div>
<!--
Analicemos en detalle la secuencia que se desencadena al invocar una llamada al sistema.

[click] Primero, el programa configura los registros con los parámetros requeridos y ejecuta la instrucción int 0x80.

[click] Segundo, la CPU detiene la ejecución secuencial, consulta la tabla de descriptores de interrupción en la entrada 0x80, cambia el puntero de pila hacia la pila del núcleo y salva el estado del usuario.

[click] Tercero, el núcleo recibe el control mediante el despachador de llamadas, busca la rutina correspondiente en la tabla interna indexada por EAX y la ejecuta. Al finalizar, deposita el resultado en EAX y ejecuta la instrucción iret para volver al espacio de usuario.

[click] En el esquema de la derecha podemos apreciar con total claridad este viaje de ida y vuelta a través de la frontera de privilegios.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Convención de llamadas en IA-32

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Asignación canónica de registros en Linux x86 para transferir parámetros:
</div>

<div class="space-y-1.5 text-xs font-sans">
  <div v-click="1" class="flex items-center gap-2 p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="px-2 py-0.5 rounded font-mono font-bold text-[10.5px] bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/60 dark:text-blue-300 dark:border-blue-800/40">EAX</span>
    <span class="text-gray-700 dark:text-gray-300 text-[10px]">Identificador numérico del servicio solicitado al núcleo</span>
  </div>

  <div v-click="2" class="flex items-center gap-2 p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="px-2 py-0.5 rounded font-mono font-bold text-[10.5px] bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40">EBX</span>
    <span class="text-gray-700 dark:text-gray-300 text-[10px]">Primer parámetro (Descriptor de archivo o código de salida)</span>
  </div>

  <div v-click="3" class="flex items-center gap-2 p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="px-2 py-0.5 rounded font-mono font-bold text-[10.5px] bg-amber-50 text-amber-800 border border-amber-200 dark:bg-amber-950/60 dark:text-amber-300 dark:border-amber-800/40">ECX</span>
    <span class="text-gray-700 dark:text-gray-300 text-[10px]">Segundo parámetro (Dirección base del buffer en memoria)</span>
  </div>

  <div v-click="4" class="flex items-center gap-2 p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="px-2 py-0.5 rounded font-mono font-bold text-[10.5px] bg-purple-50 text-purple-700 border border-purple-200 dark:bg-purple-950/60 dark:text-purple-300 dark:border-purple-800/40">EDX</span>
    <span class="text-gray-700 dark:text-gray-300 text-[10px]">Tercer parámetro (Cantidad de bytes a transferir)</span>
  </div>
</div>

::right::

<div class="space-y-2 text-xs">
  <div v-click="5">
    <div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] font-sans text-center">
      Llamadas al sistema fundamentales en IA-32
    </div>
    <table class="w-full text-left text-[9.5px] border-collapse font-mono">
      <thead>
        <tr class="text-gray-500 dark:text-gray-400 border-b border-gray-300 dark:border-gray-700 font-sans">
          <th class="py-1 px-1.5">Servicio</th>
          <th class="py-1 px-1.5 text-center">EAX</th>
          <th class="py-1 px-1.5 text-center">EBX</th>
          <th class="py-1 px-1.5 text-center">ECX</th>
          <th class="py-1 px-1.5 text-center">EDX</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-200 dark:divide-gray-800 text-gray-700 dark:text-gray-300">
        <tr>
          <td class="py-1 px-1.5 text-blue-600 dark:text-blue-400 font-bold">sys_exit</td>
          <td class="py-1 px-1.5 text-center font-bold">1</td>
          <td class="py-1 px-1.5 text-center">código</td>
          <td class="py-1 px-1.5 text-center text-gray-400">&mdash;</td>
          <td class="py-1 px-1.5 text-center text-gray-400">&mdash;</td>
        </tr>
        <tr>
          <td class="py-1 px-1.5 text-emerald-600 dark:text-emerald-400 font-bold">sys_read</td>
          <td class="py-1 px-1.5 text-center font-bold">3</td>
          <td class="py-1 px-1.5 text-center">fd</td>
          <td class="py-1 px-1.5 text-center">buffer</td>
          <td class="py-1 px-1.5 text-center">conteo</td>
        </tr>
        <tr>
          <td class="py-1 px-1.5 text-amber-700 dark:text-amber-400 font-bold">sys_write</td>
          <td class="py-1 px-1.5 text-center font-bold">4</td>
          <td class="py-1 px-1.5 text-center">fd</td>
          <td class="py-1 px-1.5 text-center">buffer</td>
          <td class="py-1 px-1.5 text-center">conteo</td>
        </tr>
      </tbody>
    </table>
  </div>

  <div v-click="6" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg text-[9.5px] font-sans">
    <span class="text-emerald-700 dark:text-emerald-300 font-bold block mb-0.5">Diagnóstico del retorno en EAX:</span>
    <p class="text-gray-600 dark:text-gray-300 leading-snug">
      Si <i>EAX &ge; 0</i>, representa el éxito (bytes transferidos). Si <i>EAX &lt; 0</i>, el kernel indica un código de error con signo invertido (<i>-errno</i>).
    </p>
  </div>
</div>
<!--
Estudiemos la convención formal de registros para invocar llamadas al sistema bajo Linux IA-32.

[click] El registro EAX es el selector central: almacena el número que identifica qué servicio del núcleo estamos solicitando.

[click] El registro EBX recibe el primer argumento de la llamada, como el descriptor de archivo o el código de retorno.

[click] El registro ECX recibe el segundo parámetro, casi siempre una dirección de memoria donde se ubica la información.

[click] Y el registro EDX contiene el tercer parámetro, indicando el límite de bytes a procesar.

[click] En esta tabla resumimos las tres llamadas elementales que utilizaremos en esta sesión: sys_exit identificada con el número uno, sys_read con el número tres y sys_write con el número cuatro.

[click] Prestemos especial atención al retorno: tras ejecutar la interrupción, el núcleo devuelve el resultado directamente en EAX. Un valor positivo indica la cantidad real de bytes operados, mientras que un valor negativo denota un error del sistema.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Comparativa arquitectónica: x86 frente a x86-64

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Evolución del mecanismo de invocación al núcleo entre generaciones:
</div>

<div class="space-y-2 text-xs font-sans">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px] mb-0.5">Arquitectura x86 (32 bits &bull; IA-32)</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Emplea la interrupción de software clásica <i>int 0x80</i>. Requiere lectura de la IDT en memoria y guardado completo del marco en la pila del kernel.
    </p>
  </div>

  <div v-click="2" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold text-[10.5px] mb-0.5">Arquitectura x86-64 (64 bits &bull; AMD64)</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Utiliza la instrucción especializada <i>syscall</i>. Salta de forma ultrarrápida usando registros de modelo específico (<i>MSR</i>) sin consultar la IDT.
    </p>
  </div>
</div>

::right::

<div v-click="3" class="text-xs">
  <div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] font-sans text-center">
    Matriz de correspondencia de registros
  </div>
  <table class="w-full text-left text-[9px] border-collapse font-mono">
    <thead>
      <tr class="text-gray-500 dark:text-gray-400 border-b border-gray-300 dark:border-gray-700 font-sans">
        <th class="py-1 px-1">Rol en llamada</th>
        <th class="py-1 px-1 text-blue-600 dark:text-blue-400 font-bold">x86 (int 0x80)</th>
        <th class="py-1 px-1 text-emerald-600 dark:text-emerald-400 font-bold">x86-64 (syscall)</th>
      </tr>
    </thead>
    <tbody class="divide-y divide-gray-200 dark:divide-gray-800 text-gray-700 dark:text-gray-300">
      <tr>
        <td class="py-1 px-1 font-sans">Número de llamada</td>
        <td class="py-1 px-1 font-bold">EAX</td>
        <td class="py-1 px-1 font-bold">RAX</td>
      </tr>
      <tr>
        <td class="py-1 px-1 font-sans">Primer argumento</td>
        <td class="py-1 px-1">EBX</td>
        <td class="py-1 px-1">RDI</td>
      </tr>
      <tr>
        <td class="py-1 px-1 font-sans">Segundo argumento</td>
        <td class="py-1 px-1">ECX</td>
        <td class="py-1 px-1">RSI</td>
      </tr>
      <tr>
        <td class="py-1 px-1 font-sans">Tercer argumento</td>
        <td class="py-1 px-1">EDX</td>
        <td class="py-1 px-1">RDX</td>
      </tr>
      <tr>
        <td class="py-1 px-1 font-sans">Cuarto argumento</td>
        <td class="py-1 px-1">ESI</td>
        <td class="py-1 px-1">R10</td>
      </tr>
      <tr>
        <td class="py-1 px-1 font-sans">Quinto argumento</td>
        <td class="py-1 px-1">EDI</td>
        <td class="py-1 px-1">R8</td>
      </tr>
    </tbody>
  </table>

  <div v-click="4" class="mt-2 p-1.5 bg-amber-50 border border-amber-200 dark:bg-amber-950/40 dark:border-amber-800/40 rounded text-[9px] text-amber-900 dark:text-amber-200 font-sans leading-snug">
    <strong>Diferencia crítica:</strong> En 64 bits los números de servicio difieren (ej. <i>sys_write</i> es 1 en 64 bits y 4 en 32 bits). En este curso empleamos la convención estándar IA-32.
  </div>
</div>
<!--
Es crucial comparar el mecanismo clásico de 32 bits contra la arquitectura x86-64 moderna.

[click] En sistemas de 32 bits, la invocación se realiza mediante la interrupción de software int 0x80. Este mecanismo implica consultar la tabla IDT en memoria y salvar registros en la pila, con un costo apreciable de ciclos de procesador.

[click] En contraste, en x86-64 los procesadores incorporan la instrucción dedicada syscall, la cual conmuta al modo núcleo casi instantáneamente mediante registros internos MSR preconfigurados por el sistema operativo.

[click] A la derecha observamos cómo cambia la convención de registros: mientras que en 32 bits usamos EAX, EBX, ECX y EDX, en 64 bits se utilizan RAX, RDI, RSI y RDX.

[click] Tengamos presente que los números de servicio también cambian entre ambas arquitecturas. En nuestras prácticas utilizaremos estrictamente el estándar IA-32 de 32 bits.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Descriptores de archivo en POSIX

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Abstracción unificada de flujos de entrada y salida mediante identificadores enteros:
</div>

<div class="space-y-2 text-xs font-sans mt-1">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="flex items-center justify-between font-mono mb-0.5">
      <span class="text-emerald-600 dark:text-emerald-400 font-bold text-[10.5px]">stdin (FD 0)</span>
      <span class="text-[9px] px-1.5 py-0.5 rounded bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40 font-sans">Entrada estándar</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Canal predeterminado para capturar texto del usuario desde el teclado.
    </p>
  </div>

  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="flex items-center justify-between font-mono mb-0.5">
      <span class="text-blue-600 dark:text-blue-400 font-bold text-[10.5px]">stdout (FD 1)</span>
      <span class="text-[9px] px-1.5 py-0.5 rounded bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/60 dark:text-blue-300 dark:border-blue-800/40 font-sans">Salida estándar</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Canal para desplegar mensajes y respuestas en el emulador de terminal.
    </p>
  </div>

  <div v-click="3" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="flex items-center justify-between font-mono mb-0.5">
      <span class="text-rose-600 dark:text-rose-400 font-bold text-[10.5px]">stderr (FD 2)</span>
      <span class="text-[9px] px-1.5 py-0.5 rounded bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/60 dark:text-rose-300 dark:border-rose-800/40 font-sans">Error estándar</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Canal independiente para diagnósticos y advertencias críticas.
    </p>
  </div>
</div>

::right::

<div v-click="4" class="text-xs font-sans">
  <div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] text-center">
    Tabla de descriptores en el bloque de control del proceso (PCB)
  </div>

  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl space-y-1.5">
    <div class="flex items-center justify-between p-1.5 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded-md font-mono text-[9.5px]">
      <span class="px-1.5 py-0.5 rounded bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300 font-bold">FD 0</span>
      <span class="font-bold text-gray-800 dark:text-gray-200">stdin</span>
      <span class="text-gray-500 dark:text-gray-400 font-sans text-[9px]">/dev/tty (teclado)</span>
    </div>

    <div class="flex items-center justify-between p-1.5 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded-md font-mono text-[9.5px]">
      <span class="px-1.5 py-0.5 rounded bg-blue-100 text-blue-800 dark:bg-blue-950 dark:text-blue-300 font-bold">FD 1</span>
      <span class="font-bold text-gray-800 dark:text-gray-200">stdout</span>
      <span class="text-gray-500 dark:text-gray-400 font-sans text-[9px]">/dev/pts/X (pantalla)</span>
    </div>

    <div class="flex items-center justify-between p-1.5 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded-md font-mono text-[9.5px]">
      <span class="px-1.5 py-0.5 rounded bg-rose-100 text-rose-800 dark:bg-rose-950 dark:text-rose-300 font-bold">FD 2</span>
      <span class="font-bold text-gray-800 dark:text-gray-200">stderr</span>
      <span class="text-gray-500 dark:text-gray-400 font-sans text-[9px]">/dev/pts/X (sin buffer)</span>
    </div>

    <div class="flex items-center justify-between p-1.5 bg-white/50 dark:bg-gray-800/40 border border-gray-200/60 dark:border-gray-700/40 rounded-md font-mono text-[9.5px] opacity-75">
      <span class="px-1.5 py-0.5 rounded bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-300 font-bold">FD 3+</span>
      <span class="text-gray-600 dark:text-gray-300">Archivos / Sockets</span>
      <span class="text-gray-500 dark:text-gray-400 font-sans text-[9px]">Disco / Red (Semana 11)</span>
    </div>
  </div>

  <div v-click="5" class="mt-2 p-1.5 bg-blue-50 border border-blue-200 dark:bg-blue-950/40 dark:border-blue-800/40 rounded text-[9.5px] text-blue-900 dark:text-blue-200 leading-snug">
    <strong>Carga en EBX:</strong> Pasamos <i>EBX = 1</i> para emitir hacia la pantalla con <i>sys_write</i> y <i>EBX = 0</i> para capturar desde el teclado con <i>sys_read</i>.
  </div>
</div>
<!--
En los sistemas UNIX y Linux rige el principio de que los canales de comunicación se gestionan como flujos homogéneos de bytes mediante descriptores de archivo.

Al crearse cualquier proceso, el sistema operativo abre automáticamente tres descriptores universales:

[click] El descriptor cero corresponde a la entrada estándar, conectado inicialmente al teclado.

[click] El descriptor uno corresponde a la salida estándar, conectado a la pantalla de la terminal.

[click] Y el descriptor dos es el canal de error estándar, destinado a emitir diagnósticos sin interferir con la salida de datos normal.

[click] Observemos a la derecha la tabla de descriptores que mantiene el núcleo en el bloque de control del proceso. Los números tres en adelante quedan disponibles para archivos físicos en disco.

[click] En ensamblador simplemente cargamos el número correspondiente en EBX antes de solicitar la llamada al sistema.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Secciones de memoria en NASM

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Estructura y segmentación del espacio de memoria de un programa:
</div>

<div class="space-y-2 text-xs font-sans mt-1">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold font-mono text-[10.5px] mb-0.5">section .text</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Contiene el código ejecutable de máquina. Tiene permisos de lectura y ejecución (<i>R-X</i>) para evitar que el programa se modifique a sí mismo.
    </p>
  </div>

  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold font-mono text-[10.5px] mb-0.5">section .data</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Alberga variables globales y constantes con valores iniciales conocidos en compilación. Permisos de lectura y escritura (<i>RW-</i>).
    </p>
  </div>

  <div v-click="3" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-amber-700 dark:text-amber-400 font-bold font-mono text-[10.5px] mb-0.5">section .bss</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Reserva buffers y variables no inicializadas. No almacena datos en el archivo ELF, ahorrando espacio en disco.
    </p>
  </div>
</div>

::right::

<div class="font-mono text-xs">
  <div v-click="4" class="text-blue-600 dark:text-blue-400 font-bold mb-1 text-[11px] font-sans text-center">
    Estructura modular del archivo fuente
  </div>

```asm
section .data
  mensaje db "Arquitectura x86", 0x0A
  longitud equ $ - mensaje

section .bss
  buffer_entrada resb 64

section .text
  global _start

_start:
  ; Código de instrucciones ejecutables
```

  <div v-click="5" class="mt-2 p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg text-[9.5px] font-sans text-gray-700 dark:text-gray-300">
    <span class="text-emerald-700 dark:text-emerald-400 font-bold block mb-0.5">Eficiencia arquitectónica de .bss:</span>
    Un buffer de 64 KB en <i>.bss</i> no suma un solo byte al archivo ejecutable en disco. El cargador del sistema asigna las páginas de memoria física y las limpia con ceros en RAM al iniciar.
  </div>
</div>
<!--
Revisemos cómo organizamos las secciones de un archivo fuente en NASM.

[click] La sección punto text alberga las instrucciones que ejecutará la CPU. El sistema operativo le asigna atributos de sólo lectura y ejecución para prevenir corrupciones o modificaciones accidentales del código.

[click] La sección punto data almacena cadenas de caracteres y variables globales con contenido inicial conocido desde el momento de compilar.

[click] La sección punto bss se utiliza para reservar memoria de trabajo y buffers que recibirán datos durante la ejecución, como la entrada del usuario.

[click] En el bloque de código de la derecha apreciamos cómo delimitamos de forma limpia cada sección dentro de un archivo de ensamblador.

[click] Notemos la enorme ventaja de la sección BSS: reservar un buffer de sesenta y cuatro kilobytes no incrementa el peso del binario en el disco, ya que el cargador de Linux asigna y limpia la memoria en RAM en tiempo de carga.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Directivas de definición y reserva

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Diferenciación estricta entre datos inicializados y reservas vacías de memoria:
</div>

<div class="space-y-2 text-xs font-mono mt-1">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold font-sans text-[10.5px] mb-1">Definición en .data (con valor)</div>
    <ul class="space-y-1 text-gray-700 dark:text-gray-300 text-[9.5px]">
      <li><span class="text-blue-600 dark:text-blue-400 font-bold">db:</span> Byte (8 bits) &nbsp;|&nbsp; <span class="text-blue-600 dark:text-blue-400 font-bold">dw:</span> Word (16 bits)</li>
      <li><span class="text-blue-600 dark:text-blue-400 font-bold">dd:</span> DWord (32 bits) &nbsp;|&nbsp; <span class="text-blue-600 dark:text-blue-400 font-bold">dq:</span> QWord (64 bits)</li>
    </ul>
  </div>

  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-amber-700 dark:text-amber-400 font-bold font-sans text-[10.5px] mb-1">Reserva en .bss (sin valor inicial)</div>
    <ul class="space-y-1 text-gray-700 dark:text-gray-300 text-[9.5px]">
      <li><span class="text-amber-700 dark:text-amber-400 font-bold">resb N:</span> Reserva N bytes continuos</li>
      <li><span class="text-amber-700 dark:text-amber-400 font-bold">resw N:</span> Reserva N palabras (2N bytes)</li>
      <li><span class="text-amber-700 dark:text-amber-400 font-bold">resd N:</span> Reserva N palabras dobles (4N bytes)</li>
    </ul>
  </div>
</div>

::right::

<div class="space-y-2 text-xs font-mono">
  <div v-click="3">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold mb-1 text-[11px] font-sans text-center">
      Cálculo automático de longitud con equ
    </div>

```asm
section .data
  saludo db "Bienvenido a la tutoría", 0x0A
  longitud equ $ - saludo
```

    <p class="mt-1 text-gray-600 dark:text-gray-300 font-sans text-[9.5px] leading-snug">
      El símbolo especial <i>$</i> representa la dirección de memoria actual. Al restarle la dirección inicial <i>saludo</i>, NASM calcula en tiempo de ensamblado los bytes exactos.
    </p>
  </div>

  <div v-click="4" class="p-2 bg-purple-50 border border-purple-200 dark:bg-purple-950/40 dark:border-purple-800/40 rounded-lg text-[9.5px] font-sans text-gray-700 dark:text-gray-300">
    <span class="text-purple-700 dark:text-purple-300 font-bold block mb-0.5">Propiedad de equ:</span>
    <i>equ</i> define una constante simbólica del preprocesador. No asigna memoria física en RAM ni en disco, actuando como un alias estático similar a <i>#define</i> en C.
  </div>
</div>
<!--
Veamos en detalle las directivas para definir y reservar datos.

[click] Para inicializar variables en la sección data utilizamos db para bytes de 8 bits, dw para palabras de 16 bits y dd para palabras dobles de 32 bits.

[click] En cambio, dentro de la sección BSS empleamos las directivas resb, resw o resd seguidas de la cantidad de elementos a reservar.

[click] Para no contar letras manualmente al emitir mensajes, usamos la fórmula dólar menos la etiqueta inicial. El símbolo de dólar indica la dirección de ensamblado actual, de modo que la resta produce exactamente la cantidad de bytes del texto.

[click] La directiva equ crea una constante simbólica en tiempo de ensamblado sin gastar memoria física, logrando un código mantenible y seguro.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Ejemplo guiado: Salida en consola

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1">
Programa completo para imprimir una cadena en terminal y finalizar de forma limpia:
</div>

<div class="font-mono text-[9px]">

```asm {all|1-4|6-13|15-18}
section .data
  msg db "Arquitectura de Computadores", 0x0A
  len equ $ - msg

section .text
  global _start

_start:
  ; 1. Escribir mensaje en stdout
  mov eax, 4          ; sys_write
  mov ebx, 1          ; descriptor stdout
  mov ecx, msg        ; puntero al buffer
  mov edx, len        ; longitud en bytes
  int 0x80            ; invocar al núcleo

  ; 2. Terminar proceso
  mov eax, 1          ; sys_exit
  mov ebx, 0          ; código de retorno 0
  int 0x80            ; invocar al núcleo
```

</div>

::right::

<div class="space-y-1.5 text-xs font-sans">
  <div v-click="1" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg">
    <div class="font-mono text-emerald-700 dark:text-emerald-300 font-bold text-[10.5px]">sys_write (EAX = 4):</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Carga <i>EBX = 1</i> (stdout), <i>ECX = msg</i> (dirección en memoria) y <i>EDX = len</i>. Transfiere el bloque a la terminal.
    </p>
  </div>

  <div v-click="2" class="p-2 bg-blue-50 border border-blue-200 dark:bg-blue-950/40 dark:border-blue-800/40 rounded-lg">
    <div class="font-mono text-blue-700 dark:text-blue-300 font-bold text-[10.5px]">sys_exit (EAX = 1):</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Cierra el proceso y entrega el código 0 en <i>EBX</i> al sistema operativo, evitando fallos de segmentación.
    </p>
  </div>

  <div v-click="3" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg font-mono text-[9px]">
    <div class="text-amber-700 dark:text-amber-400 font-bold font-sans text-[10px] mb-1">Flujo de comandos en terminal:</div>
    <div class="text-gray-700 dark:text-gray-300">nasm -f elf32 hola.asm -o hola.o</div>
    <div class="text-gray-700 dark:text-gray-300">ld -m elf_i386 hola.o -o hola</div>
    <div class="text-emerald-600 dark:text-emerald-400 font-bold">./hola</div>
  </div>
</div>
<!--
Analicemos este primer programa completo en ensamblador con llamadas al sistema.

[click] En la sección de datos declaramos el mensaje terminando en el salto de línea hexadecimal 0x0A y calculamos su longitud automática.

[click] Para emitir el texto por pantalla preparamos sys_write con EAX en cuatro, la salida estándar en EBX con uno, el puntero del mensaje en ECX y la longitud en EDX antes de invocar la interrupción 0x80.

[click] Seguidamente preparamos sys_exit con EAX en uno y código de terminación exitosa cero en EBX, entregando el control de vuelta al sistema operativo.

[click] Para compilar y ejecutar en Linux de 32 bits generamos el objeto ELF con nasm y enlazamos con ld usando la emulación elf_i386.
-->

---
transition: fade
---

# Síntesis de la primera sesión

<div class="max-w-xl mx-auto text-left space-y-2.5 text-xs font-sans">
  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <strong class="text-rose-600 dark:text-rose-400 font-bold text-[11px]">1. Aislamiento por hardware y modo dual:</strong>
    <p class="text-gray-600 dark:text-gray-300 mt-0.5 text-[10px] leading-snug">
      El procesador distingue entre el anillo 3 (usuario) y el anillo 0 (núcleo), garantizando que las operaciones sobre hardware se gestionen exclusivamente por el sistema operativo mediante la instrucción <i>int 0x80</i>.
    </p>
  </div>

  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <strong class="text-blue-600 dark:text-blue-400 font-bold text-[11px]">2. Convención estandarizada en IA-32:</strong>
    <p class="text-gray-600 dark:text-gray-300 mt-0.5 text-[10px] leading-snug">
      El registro <i>EAX</i> especifica el servicio, mientras que <i>EBX</i>, <i>ECX</i> y <i>EDX</i> transfieren los tres primeros parámetros. Al retornar, <i>EAX</i> almacena el resultado o un código de error.
    </p>
  </div>

  <div v-click="1" class="p-2.5 bg-amber-50 border border-amber-200 dark:bg-amber-950/40 dark:border-amber-800/40 rounded-lg">
    <strong class="text-amber-800 dark:text-amber-300 font-bold text-[11px]">3. Pregunta detonante para el taller práctico:</strong>
    <p class="text-amber-900 dark:text-amber-200 mt-0.5 text-[10px] italic leading-snug">
      Al capturar texto desde el teclado con <i>sys_read</i>, la tecla Enter genera el carácter de salto de línea <i>0x0A</i> dentro del buffer. ¿Cómo podemos detectar y reemplazar dicho byte por el terminador nulo <i>0x00</i> para que sea compatible con cadenas estándar?
    </p>
  </div>
</div>
<!--
Con esto concluimos la primera sesión teórica. Hemos cubierto los fundamentos del modo dual, el funcionamiento de la interrupción 0x80, la convención de llamadas y las secciones de memoria.

[click] Les dejo esta pregunta detonante para reflexionar antes de pasar al taller práctico: cuando el usuario presiona Enter, la entrada almacena el byte 0x0A. ¿Cómo manipulamos la memoria para convertirlo en una cadena terminada en nulo?
-->

---
layout: center
transition: slide-up | slide-down
---

<div class="text-center">
  <div class="text-3xl text-gray-500 dark:text-gray-400 mb-4 font-mono">Semana 09</div>
  <h1 class="text-6xl font-bold mb-8 text-gray-900 dark:text-white">Sesión 02: Práctica guiada</h1>
  <div class="text-2xl text-blue-600 dark:text-blue-400 mt-4">IC3101: Arquitectura de computadores</div>
</div>
<!--
¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de la separación de privilegios, la tabla de descriptores y la convención de llamadas al sistema, dedicaremos esta jornada completa a la programación práctica interactiva, depuración en vivo con GDB y consolidación analítica.
-->

---
transition: fade
---

# Objetivos de la segunda sesión

<div class="mb-4 text-sm text-gray-600 dark:text-gray-300">
Desarrollar destrezas prácticas de entrada y salida interactiva, sanitización de cadenas y depuración:
</div>
<v-clicks>

- **Captura interactiva con sys_read:** Configurar buffers de recepción en <i>.bss</i> y procesar entradas del usuario desde teclado.
- **Tratamiento del carácter de fin de línea:** Detectar y sustituir el byte <i>0x0A</i> por el terminador centinela <i>0x00</i> (ASCIIZ).
- **Control de desbordamiento de buffer:** Limitar con rigor el tamaño máximo de lectura en <i>EDX</i> para proteger la memoria.
- **Depuración interactiva con GDB:** Inspeccionar registros de entrada y salida de llamadas al sistema y examinar buffers con <i>x/s</i>.
- **Diagnóstico y prevención de trampas:** Analizar errores recurrentes como omisión de <i>sys_exit</i> y sobreescritura accidental de <i>EAX</i>.

</v-clicks>
<!--
Antes de comenzar con los ejercicios prácticos, repasemos los objetivos de esta segunda sesión:

[click] Primero, implementaremos la lectura interactiva desde el teclado utilizando sys_read hacia buffers en la sección BSS.

[click] Segundo, aprenderemos a sanitizar la entrada reemplazando el salto de línea por el byte nulo terminador.

[click] Tercero, aplicaremos buenas prácticas de seguridad acotando el tamaño máximo de captura para evitar desbordamientos de buffer.

[click] Cuarto, utilizaremos el depurador GDB para inspeccionar en vivo los registros antes y después de cada llamada al sistema.

[click] Y quinto, analizaremos las trampas más frecuentes al interactuar con el núcleo para blindar nuestro código contra fallos de segmentación.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Captura con sys_read

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
La llamada <i>sys_read</i> suspende el proceso hasta recibir la entrada del usuario:
</div>

<div class="space-y-2 text-xs font-sans mt-1">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold font-sans text-[10.5px] mb-1">Configuración de registros:</div>
    <ul class="space-y-0.5 font-mono text-gray-700 dark:text-gray-300 text-[9.5px]">
      <li><i>mov eax, 3</i> &bull; Servicio sys_read</li>
      <li><i>mov ebx, 0</i> &bull; Descriptor 0 (stdin / teclado)</li>
      <li><i>mov ecx, buffer</i> &bull; Puntero al buffer en .bss</li>
      <li><i>mov edx, 64</i> &bull; Capacidad máxima de captura</li>
    </ul>
  </div>

  <div v-click="2" class="p-2 bg-amber-50 border border-amber-200 dark:bg-amber-950/40 dark:border-amber-800/40 rounded-lg text-xs font-sans">
    <span class="text-amber-800 dark:text-amber-300 font-bold text-[10.5px] block mb-0.5">Retorno dinámico en EAX:</span>
    <p class="text-gray-700 dark:text-gray-300 text-[9.5px] leading-snug">
      Al retornar, <i>EAX</i> almacena la cantidad exacta de bytes leídos, incluyendo el byte <i>0x0A</i> (<i>\n</i>) introducido al presionar Enter.
    </p>
  </div>
</div>

::right::

<div v-click="3" class="flex flex-col items-center justify-center font-sans">
  <div class="text-blue-600 dark:text-blue-400 font-bold text-center mb-1.5 text-[11px]">
    Estado del buffer en memoria (.bss) tras escribir "Juan" + Enter
  </div>

  <div class="grid grid-cols-5 gap-1.5 text-center font-mono text-[10px] w-full max-w-[340px] mb-2">
    <div class="border border-blue-300 bg-blue-50 dark:border-blue-700 dark:bg-blue-950/40 rounded-lg p-1.5 shadow-2xs">
      <div class="text-[8px] text-gray-500 dark:text-gray-400">+0</div>
      <div class="font-bold text-blue-700 dark:text-blue-300 text-sm">J</div>
      <div class="text-[7.5px] text-gray-500">0x4A</div>
    </div>
    <div class="border border-blue-300 bg-blue-50 dark:border-blue-700 dark:bg-blue-950/40 rounded-lg p-1.5 shadow-2xs">
      <div class="text-[8px] text-gray-500 dark:text-gray-400">+1</div>
      <div class="font-bold text-blue-700 dark:text-blue-300 text-sm">u</div>
      <div class="text-[7.5px] text-gray-500">0x75</div>
    </div>
    <div class="border border-blue-300 bg-blue-50 dark:border-blue-700 dark:bg-blue-950/40 rounded-lg p-1.5 shadow-2xs">
      <div class="text-[8px] text-gray-500 dark:text-gray-400">+2</div>
      <div class="font-bold text-blue-700 dark:text-blue-300 text-sm">a</div>
      <div class="text-[7.5px] text-gray-500">0x61</div>
    </div>
    <div class="border border-blue-300 bg-blue-50 dark:border-blue-700 dark:bg-blue-950/40 rounded-lg p-1.5 shadow-2xs">
      <div class="text-[8px] text-gray-500 dark:text-gray-400">+3</div>
      <div class="font-bold text-blue-700 dark:text-blue-300 text-sm">n</div>
      <div class="text-[7.5px] text-gray-500">0x6E</div>
    </div>
    <div class="border border-amber-400 bg-amber-50 dark:border-amber-600 dark:bg-amber-950/40 rounded-lg p-1.5 shadow-2xs">
      <div class="text-[8px] text-amber-600 dark:text-amber-400 font-bold">+4</div>
      <div class="font-bold text-amber-700 dark:text-amber-300 text-sm">\n</div>
      <div class="text-[7.5px] text-amber-600 dark:text-amber-400 font-bold">0x0A</div>
    </div>
  </div>

  <div class="w-full max-w-[340px] flex justify-between items-center bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 p-2 rounded-lg text-[10px] font-mono">
    <span class="text-gray-600 dark:text-gray-300 font-sans">Retorno en EAX:</span>
    <span class="text-emerald-600 dark:text-emerald-400 font-bold">5 bytes leídos</span>
  </div>
</div>
<!--
Iniciemos la parte práctica analizando el funcionamiento de la llamada sys_read.

[click] Para capturar texto, configuramos EAX con tres, EBX con cero correspondiente a stdin, ECX con la dirección de nuestro buffer y EDX con la capacidad máxima que estamos dispuestos a admitir.

[click] Cuando el usuario termina de escribir y presiona la tecla Enter, el sistema operativo reactiva el proceso y coloca en EAX la cantidad exacta de bytes leídos.

[click] Observemos detenidamente el mapa de memoria del buffer a la derecha. Si el usuario escribe Juan y presiona Enter, el buffer almacena las cuatro letras más el carácter de salto de línea 0x0A, totalizando cinco bytes en EAX.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Saludo interactivo en consola

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1">
Programa interactivo para solicitar nombre y emitir saludo personalizado:
</div>

<div class="font-mono text-[8.5px]">

```asm
section .data
  preg db "Ingrese su nombre: "
  l_preg equ $ - preg
  sal db "Hola, "
  l_sal equ $ - sal

section .bss
  nom resb 32
  bytes_leidos resd 1

section .text
  global _start

_start:
  ; 1. Desplegar solicitud
  mov eax, 4
  mov ebx, 1
  mov ecx, preg
  mov edx, l_preg
  int 0x80

  ; 2. Leer entrada desde teclado
  mov eax, 3
  mov ebx, 0
  mov ecx, nom
  mov edx, 32
  int 0x80
  mov [bytes_leidos], eax ; Guardar conteo
```

</div>

::right::

<div class="font-mono text-[8.5px]">

```asm
  ; 3. Imprimir 'Hola, '
  mov eax, 4
  mov ebx, 1
  mov ecx, sal
  mov edx, l_sal
  int 0x80

  ; 4. Imprimir nombre capturado
  mov eax, 4
  mov ebx, 1
  mov ecx, nom
  mov edx, [bytes_leidos] ; Longitud dinámica
  int 0x80

  ; 5. Salir limpiamente
  mov eax, 1
  mov ebx, 0
  int 0x80
```

  <div v-click="1" class="mt-2 p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg text-gray-700 dark:text-gray-300 font-sans text-[9.5px]">
    <span class="text-emerald-700 dark:text-emerald-300 font-bold block mb-0.5">Preservación crítica de EAX:</span>
    El valor de retorno de <i>sys_read</i> se almacena inmediatamente en <i>[bytes_leidos]</i> para usarlo como límite exacto al emitir el nombre.
  </div>
</div>
<!--
Construyamos este programa interactivo paso a paso.

En la columna izquierda vemos la primera etapa: solicitamos el nombre emitiendo una pregunta con sys_write y luego invocamos sys_read pasando nuestro buffer nom de treinta y dos bytes.

[click] Notemos que guardamos inmediatamente el retorno de EAX en la variable bytes_leidos. Esto es indispensable porque la siguiente llamada al sistema sobreescribirá EAX con su propio valor.

Finalmente, en la columna derecha imprimimos el prefijo Hola seguido del nombre del usuario empleando exactamente los bytes que fueron leídos, terminando con sys_exit.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Supresión del salto de línea

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Sustitución del byte <i>0x0A</i> por el terminador nulo <i>0x00</i> (formato ASCIIZ):
</div>

<div class="font-mono text-[9px] space-y-2">

```asm
  ; EAX contiene la cantidad de bytes leídos (ej. 5)
  ; nom es la dirección base del buffer

  dec eax                      ; EAX = 4 (índice base 0)
  mov byte [nom + eax], 0x00   ; Sustituir por NULL
```

  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg text-gray-700 dark:text-gray-300 font-sans text-[9.5px]">
    <span class="text-blue-600 dark:text-blue-400 font-bold block mb-0.5">Indexación base más índice:</span>
    <i>[nom + eax]</i> calcula la dirección física exacta del byte de salto de línea para sobreescribirlo de forma atómica.
  </div>
</div>

::right::

<div v-click="2" class="flex flex-col items-center justify-center font-sans">
  <div class="text-blue-600 dark:text-blue-400 font-bold text-center mb-1 text-[11px]">
    Transformación del buffer en memoria
  </div>

  <div class="w-full max-w-[340px] space-y-2">
    <!-- Antes -->
    <div>
      <div class="text-[9px] text-gray-500 dark:text-gray-400 mb-1">Tras sys_read (EAX = 5):</div>
      <div class="grid grid-cols-5 gap-1 text-center font-mono text-[9.5px]">
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1 rounded">J</div>
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1 rounded">u</div>
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1 rounded">a</div>
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1 rounded">n</div>
        <div class="bg-rose-100 dark:bg-rose-950/60 border border-rose-300 dark:border-rose-700 p-1 rounded font-bold text-rose-700 dark:text-rose-300">0x0A</div>
      </div>
    </div>

    <div class="text-center font-mono text-[9.5px] font-bold text-amber-700 dark:text-amber-400">
      &darr; dec eax &bull; mov byte [nom + eax], 0x00 &darr;
    </div>

    <!-- Después -->
    <div>
      <div class="text-[9px] text-gray-500 dark:text-gray-400 mb-1">Cadena terminada en nulo (ASCIIZ):</div>
      <div class="grid grid-cols-5 gap-1 text-center font-mono text-[9.5px]">
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1 rounded">J</div>
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1 rounded">u</div>
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1 rounded">a</div>
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1 rounded">n</div>
        <div class="bg-emerald-100 dark:bg-emerald-950/60 border border-emerald-300 dark:border-emerald-700 p-1 rounded font-bold text-emerald-700 dark:text-emerald-300">0x00</div>
      </div>
    </div>
  </div>
</div>
<!--
Un problema recurrente en las aplicaciones de consola es que el salto de línea queda incrustado dentro del texto recibido.

Si el usuario escribió cuatro letras y presionó Enter, leímos cinco bytes. Dado que los arreglos inician en el índice cero, las letras ocupan las posiciones cero a tres, y el salto de línea 0x0A se sitúa en la posición cuatro.

[click] Con la instrucción dec eax reducimos el conteo a cuatro, apuntando exactamente al índice donde yace el carácter 0x0A. Luego almacenamos un byte cero mediante direccionamiento base más índice.

[click] Observemos la transición en la columna derecha: el carácter de salto de línea desaparece y la cadena se convierte en una cadena ASCIIZ estándar, lista para interactuar con funciones de C o bibliotecas externas.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Depuración de llamadas con GDB

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Inspección de registros y memoria en tiempo de ejecución:
</div>

<div class="space-y-2 text-xs font-sans mt-1">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold font-sans text-[10.5px] mb-0.5">Símbolos de depuración:</div>
    <div class="font-mono text-[9px] text-gray-700 dark:text-gray-300">
      nasm -f elf32 -g -F dwarf prog.asm<br>
      ld -m elf_i386 prog.o -o prog
    </div>
  </div>

  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold font-sans text-[10.5px] mb-0.5">Control de ejecución:</div>
    <div class="font-mono text-[9px] text-gray-700 dark:text-gray-300">
      (gdb) break _start<br>
      (gdb) run &nbsp;|&nbsp; nexti &nbsp;|&nbsp; stepi
    </div>
  </div>
</div>

::right::

<div class="space-y-2 text-xs font-mono">
  <div v-click="3">
    <div class="text-amber-700 dark:text-amber-400 font-bold mb-1 text-[11px] font-sans text-center">
      Inspección de registros y buffers en consola GDB
    </div>

```text
(gdb) info registers eax ebx ecx edx
eax  0x4        4
ebx  0x1        1
ecx  0x8049000  134516736
edx  0x1c       28

(gdb) x/s 0x8049000
"Arquitectura de Computadores\n"
```

  </div>

  <div v-click="4" class="p-2 bg-purple-50 border border-purple-200 dark:bg-purple-950/40 dark:border-purple-800/40 rounded-lg text-gray-700 dark:text-gray-300 font-sans text-[9.5px]">
    <span class="text-purple-700 dark:text-purple-300 font-bold block mb-0.5">Modos del comando examine (x):</span>
    <i>x/s</i> (cadena de texto), <i>x/4xb</i> (cuatro bytes en hexadecimal) y <i>x/xw</i> (palabra doble de 32 bits).
  </div>
</div>
<!--
Veamos cómo emplear el depurador GDB para inspeccionar nuestras llamadas al sistema.

[click] Al compilar con NASM es fundamental incluir los modificadores menos g y menos F dwarf para generar información simbólica completa para el depurador.

[click] Dentro de GDB colocamos un punto de interrupción en la etiqueta start y avanzamos con stepi o nexti para posicionarnos justo antes de la instrucción int 0x80.

[click] Con info registers verificamos que los cuatro registros clave tengan los valores previstos: EAX con el número de llamada, EBX con el descriptor, ECX con el puntero al buffer y EDX con la longitud.

[click] Con el comando examine x/s comprobamos el texto apuntado por ECX en memoria, verificando la integridad de los datos antes de solicitar la operación al núcleo.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Trampas comunes en llamadas

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Errores frecuentes al interactuar con el sistema operativo y su corrección:
</div>

<div class="space-y-2.5 mt-2 text-xs font-sans">
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-rose-600 dark:text-rose-400 text-[11px]">1. Omisión de sys_exit</span>
      <span class="text-rose-400 dark:text-rose-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-rose-700 bg-rose-50 border border-rose-200 dark:text-rose-300 dark:bg-rose-950/60 dark:border-rose-800/40 px-1.5 py-0.5 rounded">Falta int 0x80 (EAX=1)</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      El procesador sigue ejecutando memoria no mapeada al final de <i>.text</i> detonando un fallo de segmentación.
    </p>
  </div>

  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-700 dark:text-amber-400 text-[11px]">2. Puntero vs contenido</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-amber-800 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">mov ecx, [msg]</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Pasar el contenido de los primeros 4 bytes en lugar de la dirección física del buffer en memoria.
    </p>
  </div>

  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">3. Sobreescritura de EAX</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">EAX destruido tras kernel</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Olvidar que el núcleo deposita el resultado en <i>EAX</i>, perdiendo el valor de servicio previo o el conteo de bytes.
    </p>
  </div>
</div>

::right::

<div v-click="4" class="text-xs">
  <div class="text-emerald-600 dark:text-emerald-400 font-bold mb-2 text-[11px] font-sans">
    Corrección formal de patrones
  </div>
  <table class="w-full text-left text-[9.5px] border-collapse font-mono">
    <thead>
      <tr class="text-gray-500 dark:text-gray-400 border-b border-gray-300 dark:border-gray-700 font-sans">
        <th class="py-1.5 px-2">Patrón erróneo</th>
        <th class="py-1.5 px-2">Patrón correcto</th>
      </tr>
    </thead>
    <tbody class="divide-y divide-gray-200 dark:divide-gray-800">
      <tr>
        <td class="py-1.5 px-2 text-rose-600 dark:text-rose-300">Fin sin sys_exit</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-300">mov eax, 1<br/>mov ebx, 0<br/>int 0x80</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-rose-600 dark:text-rose-300">mov ecx, [msg]</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-300">mov ecx, msg</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-rose-600 dark:text-rose-300">Uso de EAX sin guardar</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-300">mov [leidos], eax<br/>mov eax, 4</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-rose-600 dark:text-rose-300">mov edx, 100 (en buffer de 32)</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-300">mov edx, 32 (acotado)</td>
      </tr>
    </tbody>
  </table>
</div>
<!--
Revisemos las trampas más recurrentes al trabajar con llamadas al sistema operativo.

[click] La primera es omitir sys_exit. En ensamblador la ejecución no se detiene al terminar el archivo: si no invocamos sys_exit explícitamente, la CPU continuará ejecutando bytes basura de memoria hasta provocar un fallo de segmentación.

[click] La segunda trampa es confundir la dirección con el contenido. En ECX debemos pasar la etiqueta msg sin corchetes, de lo contrario pasaremos el valor numérico de las letras como si fuera un puntero a memoria.

[click] La tercera es olvidar que tras int 0x80 el registro EAX queda completamente sobreescrito con la respuesta del núcleo.

[click] A la derecha observamos las correcciones estándar para cada uno de estos escenarios.
-->

---
transition: fade
---

# Ejercicios de práctica

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Privilegios, convención de llamadas y descriptores estándar:
</div>

<div class="space-y-2 mt-3 text-xs font-sans">
  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
    <strong class="text-blue-600 dark:text-blue-400 text-[11px]">1. ¿Por qué una aplicación de usuario en el anillo 3 no puede emitir directamente bytes a la pantalla mediante instrucciones de hardware?</strong>
    <div class="grid grid-cols-3 gap-3 text-[9.5px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>Porque carece de memoria virtual asignada</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>Porque el procesador protege los puertos y registros de hardware detonando una excepción #GP si no está en anillo 0</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>Porque las tarjetas de video solo responden a lenguaje C</span>
      </div>
    </div>
    <div v-click="1" class="text-emerald-600 dark:text-emerald-400 mt-1 text-[10px] font-bold">
      &rarr; Respuesta correcta: B) El modo dual y los anillos de protección restringen las instrucciones privilegiadas de E/S exclusivamente al núcleo.
    </div>
  </div>

  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
    <strong class="text-amber-700 dark:text-amber-400 text-[11px]">2. En Linux x86 (IA-32), ¿cuál registro almacena el identificador numérico de la llamada al sistema solicitada?</strong>
    <div class="grid grid-cols-4 gap-3 text-[9.5px] font-mono text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>EBX</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>EAX</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>ECX</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">D)</span>
        <span>EDX</span>
      </div>
    </div>
    <div v-click="2" class="text-emerald-600 dark:text-emerald-400 mt-1 text-[10px] font-bold font-sans">
      &rarr; Respuesta correcta: B) EAX recibe el código del servicio (1 para sys_exit, 3 para sys_read, 4 para sys_write).
    </div>
  </div>

  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
    <strong class="text-purple-600 dark:text-purple-400 text-[11px]">3. Para emitir un mensaje de diagnóstico por el canal de error estándar (stderr), ¿qué valor debe colocarse en EBX?</strong>
    <div class="grid grid-cols-3 gap-3 text-[9.5px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>EBX = 0</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>EBX = 1</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>EBX = 2</span>
      </div>
    </div>
    <div v-click="3" class="text-emerald-600 dark:text-emerald-400 mt-1 text-[10px] font-bold">
      &rarr; Respuesta correcta: C) El descriptor POSIX 2 corresponde al canal de error estándar (stderr).
    </div>
  </div>
</div>
<!--
Evaluemos lo aprendido con esta primera ronda de ejercicios de consolidación.

Pregunta uno: ¿Por qué un programa de usuario no puede manipular directamente el hardware?
[click] Exacto, opción B: el hardware impide ejecutar instrucciones privilegiadas fuera del anillo cero detonando un fallo general de protección.

Pregunta dos: ¿Qué registro contiene el código del servicio en Linux IA-32?
[click] Muy bien, el registro EAX.

Pregunta tres: Para enviar un mensaje de error por stderr, ¿cuál descriptor cargamos en EBX?
[click] Correcto, el descriptor numérico dos.
-->

---
transition: fade
---

# Ejercicios de práctica

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Sección .bss, captura de cadenas y diagnóstico de errores en bajo nivel:
</div>

<div class="space-y-2 mt-3 text-xs font-sans">
  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
    <strong class="text-blue-600 dark:text-blue-400 text-[11px]">4. Si en la sección .bss declaramos buffer resb 1024, ¿cuántos bytes adicionales ocupa el archivo ejecutable generado en disco?</strong>
    <div class="grid grid-cols-3 gap-3 text-[9.5px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>1024 bytes</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>0 bytes</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>512 bytes</span>
      </div>
    </div>
    <div v-click="1" class="text-emerald-600 dark:text-emerald-400 mt-1 text-[10px] font-bold">
      &rarr; Respuesta correcta: B) 0 bytes. La sección .bss solo registra el tamaño requerido en la cabecera ELF, y el cargador asigna la memoria al ejecutar.
    </div>
  </div>

  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
    <strong class="text-amber-700 dark:text-amber-400 text-[11px]">5. Si un usuario introduce las letras "TEC" y presiona la tecla Enter, ¿qué valor exacto retorna el kernel en EAX tras sys_read?</strong>
    <div class="grid grid-cols-4 gap-3 text-[9.5px] font-mono text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>3</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>4</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>5</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">D)</span>
        <span>0</span>
      </div>
    </div>
    <div v-click="2" class="text-emerald-600 dark:text-emerald-400 mt-1 text-[10px] font-bold font-sans">
      &rarr; Respuesta correcta: B) 4 bytes (los 3 caracteres de texto más el byte 0x0A del salto de línea generado por la tecla Enter).
    </div>
  </div>

  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
    <strong class="text-purple-600 dark:text-purple-400 text-[11px]">6. ¿Por qué la instrucción mov ecx, [buffer] provoca un comportamiento anómalo al preparar sys_write?</strong>
    <div class="grid grid-cols-3 gap-3 text-[9.5px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>Porque ECX debe ser un número entero</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>Porque carga los 4 primeros bytes de texto como dirección en lugar del puntero al buffer</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>Porque la sección .bss no admite corchetes</span>
      </div>
    </div>
    <div v-click="3" class="text-emerald-600 dark:text-emerald-400 mt-1 text-[10px] font-bold">
      &rarr; Respuesta correcta: B) Los corchetes desreferencian la memoria; el kernel requiere la dirección física del buffer y no su contenido numérico.
    </div>
  </div>
</div>
<!--
Continuemos con la segunda ronda de ejercicios prácticos.

Pregunta cuatro: ¿Cuánto espacio suma al ejecutable en disco una reserva en la sección BSS?
[click] Excelente, cero bytes, porque la memoria se asigna dinámicamente en RAM al cargar el programa.

Pregunta cinco: Al escribir TEC y presionar Enter, ¿cuántos bytes retorna sys_read?
[click] Muy bien, retorna cuatro bytes debido a la inclusión del carácter de fin de línea 0x0A.

Pregunta seis: ¿Por qué es un error usar corchetes al cargar la dirección del buffer en ECX?
[click] Exactamente, la opción B: los corchetes cargan los caracteres del texto como si fueran un puntero numérico, provocando que el kernel intente leer una dirección inválida.
-->

---
layout: center
transition: fade
---

<div class="text-center max-w-xl mx-auto font-sans">
  <h1 class="text-3xl font-bold mb-3 text-gray-900 dark:text-white">Conclusiones y siguiente paso</h1>
  <div class="p-3.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl text-left text-xs text-gray-700 dark:text-gray-300 space-y-1.5 mt-3">
    <p>
      &bull; Comprendimos el aislamiento por hardware entre modo usuario y modo núcleo, y la función de la interrupción <i>int 0x80</i>.
    </p>
    <p>
      &bull; Dominamos la convención de registros para <i>sys_exit</i>, <i>sys_read</i> y <i>sys_write</i> y los descriptores estándar POSIX (0, 1, 2).
    </p>
    <p>
      &bull; Desarrollamos programas interactivos con reservas eficientes en <i>.bss</i> y sanitización del salto de línea <i>0x0A</i>.
    </p>
    <p>
      &bull; En la <strong>Semana 10</strong> estudiaremos el <strong>procesamiento de cadenas y manipulación masiva de memoria</strong> con instrucciones de microcódigo por hardware (<i>MOVS</i>, <i>STOS</i>, <i>LODS</i>, <i>CMPS</i>, <i>SCAS</i>) y prefijos de repetición (<i>REP</i>, <i>REPE</i>, <i>REPNE</i>).
    </p>
  </div>
  <div class="text-blue-600 dark:text-blue-400 font-semibold mt-3 text-xs">
    ¡Muchas gracias por su atención y nos vemos en la Semana 10!
  </div>
</div>
<!--
Con esto concluimos la novena semana de tutorías de Arquitectura de Computadores.

Hemos construido un puente sólido entre el código puro de máquina y los servicios del sistema operativo, dominando la entrada, salida y depuración interactiva sin dependencias de alto nivel.

En la próxima semana daremos un salto decisivo hacia la manipulación eficiente de bloques masivos de memoria mediante las instrucciones de cadenas y los prefijos de repetición en hardware.

¡Muchas gracias a todos por su compromiso y nos vemos en la siguiente sesión!
-->
