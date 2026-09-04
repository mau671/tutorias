---
theme: default
layout: center
transition: slide-left | slide-right
addons:
  - slidev-component-zoom
---

<div class="text-center">
  <div class="text-3xl text-gray-500 dark:text-gray-400 mb-4 font-mono">Semana 10</div>
  <h1 class="text-5xl font-bold mb-6 text-gray-900 dark:text-white">Procesamiento de cadenas y manipulación masiva de memoria</h1>
  <div class="text-2xl text-blue-600 dark:text-blue-400">IC3101: Arquitectura de computadores</div>
</div>
<!--
Hola a todos. Bienvenidos a la décima semana de tutorías de Arquitectura de Computadores.

En la sesión anterior dominamos las llamadas al sistema operativo y la entrada y salida por consola.

Hoy nos adentraremos en una de las características más potentes y optimizadas de la arquitectura x86: las instrucciones especializadas de bloque y procesamiento de cadenas. Estudiaremos los registros dedicados ESI y EDI, la bandera de dirección, los prefijos de repetición por microcódigo y la implementación de rutinas fundamentales como strlen, memcpy, memset y strcmp.
-->

---
transition: fade
---

# Objetivos de la primera sesión

<div class="mb-4 text-sm text-gray-600 dark:text-gray-300">
Dominar las instrucciones de microcódigo por hardware para manipulación masiva de memoria:
</div>
<v-clicks>

- **Formatos de representación de cadenas:** Contrastar cadenas de longitud fija con cadenas terminadas en nulo (formato ASCIIZ estándar en C).
- **Banco de registros dedicados en cadenas:** Identificar el rol especializado de <i>ESI</i>, <i>EDI</i>, <i>ECX</i> y el acumulador <i>EAX</i>.
- **Control del sentido de avance (Bandera DF):** Dominar la bandera de dirección y las instrucciones <i>CLD</i> (adelante) y <i>STD</i> (atrás).
- **Instrucciones elementales de bloque:** Analizar el funcionamiento de <i>LODS</i>, <i>STOS</i>, <i>MOVS</i>, <i>CMPS</i> y <i>SCAS</i> en tamaños byte, word y dword.
- **Prefijos de repetición por hardware:** Comprender la ejecución iterativa incondicional (<i>REP</i>) y condicional (<i>REPE/REPZ</i> y <i>REPNE/REPNZ</i>).

</v-clicks>
<!--
Antes de comenzar con los fundamentos teóricos, repasemos los objetivos de esta primera jornada:

[click] Primero, comprenderemos cómo se representan las cadenas en la memoria, contrastando el esquema de longitud fija con el formato ASCIIZ estándar.

[click] Segundo, analizaremos los registros especializados que el procesador dedica exclusivamente para operaciones de cadenas y bloques de memoria.

[click] Tercero, estudiaremos el control del sentido de recorrido en la memoria a través de la bandera de dirección en el registro EFLAGS.

[click] Cuarto, analizaremos las cinco instrucciones elementales de transferencia, almacenamiento, comparación y búsqueda en memoria.

[click] Y quinto, dominaremos los prefijos de repetición que permiten ejecutar bucles completos directamente a nivel de microcódigo en el chip.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Representación de cadenas en memoria

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Esquemas de organización de secuencias de bytes contiguas en memoria:
</div>

<div class="space-y-2 text-xs font-sans mt-1">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-amber-700 dark:text-amber-400 font-bold font-sans text-[10.5px] mb-0.5">Longitud fija</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Ocupa un tamaño prefijado constante. Si el texto es más corto, se rellena con espacios o ceros, desperdiciando espacio en memoria.
    </p>
  </div>

  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold font-sans text-[10.5px] mb-0.5">Longitud variable (ASCIIZ)</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Finaliza con el byte centinela <i>0x00</i> (carácter nulo <i>\0</i>). Es el estándar adoptado por UNIX, Linux y lenguaje C.
    </p>
  </div>
</div>

::right::

<div v-click="3" class="flex flex-col items-center justify-center font-sans">
  <div class="text-blue-600 dark:text-blue-400 font-bold text-center mb-1 text-[11px]">
    Estructura en memoria de la cadena ASCIIZ "ARQUI"
  </div>

  <div class="grid grid-cols-6 gap-1.5 font-mono text-[9.5px] w-full max-w-[340px] mb-2">
    <div class="bg-blue-50 border border-blue-300 dark:bg-blue-950/40 dark:border-blue-700 p-1.5 rounded-lg text-center shadow-2xs">
      <div class="text-[7.5px] text-gray-500 dark:text-gray-400">+0</div>
      <div class="text-blue-700 dark:text-blue-300 font-bold text-sm">A</div>
      <div class="text-[7.5px] text-gray-500">0x41</div>
    </div>
    <div class="bg-blue-50 border border-blue-300 dark:bg-blue-950/40 dark:border-blue-700 p-1.5 rounded-lg text-center shadow-2xs">
      <div class="text-[7.5px] text-gray-500 dark:text-gray-400">+1</div>
      <div class="text-blue-700 dark:text-blue-300 font-bold text-sm">R</div>
      <div class="text-[7.5px] text-gray-500">0x52</div>
    </div>
    <div class="bg-blue-50 border border-blue-300 dark:bg-blue-950/40 dark:border-blue-700 p-1.5 rounded-lg text-center shadow-2xs">
      <div class="text-[7.5px] text-gray-500 dark:text-gray-400">+2</div>
      <div class="text-blue-700 dark:text-blue-300 font-bold text-sm">Q</div>
      <div class="text-[7.5px] text-gray-500">0x51</div>
    </div>
    <div class="bg-blue-50 border border-blue-300 dark:bg-blue-950/40 dark:border-blue-700 p-1.5 rounded-lg text-center shadow-2xs">
      <div class="text-[7.5px] text-gray-500 dark:text-gray-400">+3</div>
      <div class="text-blue-700 dark:text-blue-300 font-bold text-sm">U</div>
      <div class="text-[7.5px] text-gray-500">0x55</div>
    </div>
    <div class="bg-blue-50 border border-blue-300 dark:bg-blue-950/40 dark:border-blue-700 p-1.5 rounded-lg text-center shadow-2xs">
      <div class="text-[7.5px] text-gray-500 dark:text-gray-400">+4</div>
      <div class="text-blue-700 dark:text-blue-300 font-bold text-sm">I</div>
      <div class="text-[7.5px] text-gray-500">0x49</div>
    </div>
    <div class="bg-emerald-50 border border-emerald-400 dark:bg-emerald-950/60 dark:border-emerald-600 p-1.5 rounded-lg text-center shadow-2xs">
      <div class="text-[7.5px] text-emerald-600 dark:text-emerald-400 font-bold">+5</div>
      <div class="text-emerald-700 dark:text-emerald-300 font-bold text-sm">\0</div>
      <div class="text-[7.5px] text-emerald-600 dark:text-emerald-400 font-bold">0x00</div>
    </div>
  </div>

  <div class="w-full max-w-[340px] flex justify-between items-center bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 p-1.5 rounded-lg text-[9.5px]">
    <span class="text-gray-700 dark:text-gray-300">Longitud del texto: <strong class="text-blue-600 dark:text-blue-400">5 caracteres</strong></span>
    <span class="text-emerald-700 dark:text-emerald-400 font-bold">Byte centinela nulo</span>
  </div>
</div>
<!--
Comencemos revisando cómo se representan las secuencias de texto en memoria.

[click] En las cadenas de longitud fija se reserva un tamaño constante y los espacios sobrantes se rellenan con caracteres nulos o blancos, lo cual resulta ineficiente cuando los textos varían en longitud.

[click] Por otro lado, el estándar predominante en la arquitectura x86 y los sistemas UNIX son las cadenas de longitud variable terminadas en nulo, comúnmente llamadas ASCIIZ.

[click] Observemos el esquema a la derecha: cada carácter ocupa un byte en direcciones consecutivas de memoria, y el final de la cadena queda marcado de forma inequívoca por el byte cero hexadecimal.

[click] Las instrucciones de cadenas no solo operan sobre texto legible, sino sobre cualquier bloque contiguo de bytes o enteros en memoria RAM.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Registros dedicados en cadenas

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
La arquitectura IA-32 asigna roles específicos para operaciones de bloque:
</div>

<div class="space-y-1.5 text-xs font-mono mt-1">
  <div v-click="1" class="flex items-center gap-2 p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="px-2 py-0.5 rounded font-bold text-[10.5px] bg-cyan-50 text-cyan-800 border border-cyan-200 dark:bg-cyan-950/60 dark:text-cyan-300 dark:border-cyan-800/40">ESI</span>
    <span class="text-gray-700 dark:text-gray-300 font-sans text-[10px]">Puntero origen (Extended Source Index &bull; segmentado con DS)</span>
  </div>

  <div v-click="2" class="flex items-center gap-2 p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="px-2 py-0.5 rounded font-bold text-[10.5px] bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40">EDI</span>
    <span class="text-gray-700 dark:text-gray-300 font-sans text-[10px]">Puntero destino (Extended Destination Index &bull; segmentado con ES)</span>
  </div>

  <div v-click="3" class="flex items-center gap-2 p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="px-2 py-0.5 rounded font-bold text-[10.5px] bg-amber-50 text-amber-800 border border-amber-200 dark:bg-amber-950/60 dark:text-amber-300 dark:border-amber-800/40">ECX</span>
    <span class="text-gray-700 dark:text-gray-300 font-sans text-[10px]">Contador de repeticiones decrecido automáticamente por ciclo</span>
  </div>

  <div v-click="4" class="flex items-center gap-2 p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <span class="px-2 py-0.5 rounded font-bold text-[10.5px] bg-purple-50 text-purple-700 border border-purple-200 dark:bg-purple-950/60 dark:text-purple-300 dark:border-purple-800/40">EAX</span>
    <span class="text-gray-700 dark:text-gray-300 font-sans text-[10px]">Acumulador de datos (AL para bytes, AX para words, EAX para dwords)</span>
  </div>
</div>

::right::

<div class="space-y-2 text-xs">
  <div v-click="5">
    <div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] font-sans text-center">
      Variantes por tamaño de operando y avance
    </div>
    <table class="w-full text-left text-[9.5px] border-collapse font-mono">
      <thead>
        <tr class="text-gray-500 dark:text-gray-400 border-b border-gray-300 dark:border-gray-700 font-sans">
          <th class="py-1 px-1.5">Sufijo</th>
          <th class="py-1 px-1.5 font-sans">Tamaño</th>
          <th class="py-1 px-1.5 text-center">Acumulador</th>
          <th class="py-1 px-1.5 text-center">Desplazamiento</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-200 dark:divide-gray-800 text-gray-700 dark:text-gray-300">
        <tr>
          <td class="py-1 px-1.5 text-cyan-600 dark:text-cyan-400 font-bold">B</td>
          <td class="py-1 px-1.5 font-sans">Byte (8 bits)</td>
          <td class="py-1 px-1.5 text-center">AL</td>
          <td class="py-1 px-1.5 text-center font-bold">&plusmn;1 byte</td>
        </tr>
        <tr>
          <td class="py-1 px-1.5 text-emerald-600 dark:text-emerald-400 font-bold">W</td>
          <td class="py-1 px-1.5 font-sans">Word (16 bits)</td>
          <td class="py-1 px-1.5 text-center">AX</td>
          <td class="py-1 px-1.5 text-center font-bold">&plusmn;2 bytes</td>
        </tr>
        <tr>
          <td class="py-1 px-1.5 text-amber-700 dark:text-amber-400 font-bold">D</td>
          <td class="py-1 px-1.5 font-sans">DWord (32 bits)</td>
          <td class="py-1 px-1.5 text-center">EAX</td>
          <td class="py-1 px-1.5 text-center font-bold">&plusmn;4 bytes</td>
        </tr>
      </tbody>
    </table>
  </div>

  <div v-click="6" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg text-[9.5px] font-sans text-gray-700 dark:text-gray-300">
    <span class="text-emerald-700 dark:text-emerald-300 font-bold block mb-0.5">Autoincremento por hardware:</span>
    El procesador actualiza automáticamente los registros <i>ESI</i> y <i>EDI</i> en cada iteración según el tamaño del sufijo y el estado de la bandera <i>DF</i>.
  </div>
</div>
<!--
Analicemos los registros dedicados por hardware en la arquitectura x86.

[click] El registro ESI actúa como el puntero de origen de datos, indexando la memoria fuente con el segmento DS.

[click] El registro EDI actúa como el puntero de destino, indexando la memoria receptora con el segmento ES.

[click] El registro ECX sirve de contador automático para las instrucciones repetitivas.

[click] Y el acumulador, ya sea AL, AX o EAX, almacena el valor leído, transferido o el patrón buscado.

[click] Cada instrucción de cadena dispone de tres variantes según el sufijo: B para un byte con avance de un paso, W para palabras de dos bytes y D para palabras dobles de cuatro bytes.

[click] Notemos que el hardware se encarga de modificar los punteros en cada ciclo de reloj sin necesidad de instrucciones de incremento manual.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Control de dirección (Bandera DF)

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
La bandera de dirección en <i>EFLAGS</i> determina el sentido de avance en memoria:
</div>

<div class="space-y-2 text-xs font-sans mt-1">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="flex justify-between font-mono text-emerald-600 dark:text-emerald-400 font-bold text-[10.5px]">
      <span>CLD (Clear Direction Flag)</span>
      <span>DF = 0 &bull; Hacia adelante (&rarr;)</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug mt-0.5 font-sans">
      Incrementa los punteros <i>ESI</i> y <i>EDI</i> hacia direcciones crecientes de memoria (+1, +2, +4). Es la configuración estándar.
    </p>
  </div>

  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="flex justify-between font-mono text-rose-600 dark:text-rose-400 font-bold text-[10.5px]">
      <span>STD (Set Direction Flag)</span>
      <span>DF = 1 &bull; Hacia atrás (&larr;)</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug mt-0.5 font-sans">
      Decrementa los punteros <i>ESI</i> y <i>EDI</i> hacia direcciones menores (-1, -2, -4). Usado para copiar bloques solapados hacia atrás.
    </p>
  </div>
</div>

::right::

<div v-click="3" class="flex flex-col items-center justify-center font-sans">
  <div class="text-blue-600 dark:text-blue-400 font-bold text-center mb-1 text-[11px]">
    Sentido del recorrido en el mapa de memoria
  </div>

  <div class="w-full max-w-[340px] space-y-2">
    <div class="grid grid-cols-4 gap-1 font-mono text-[9.5px] text-center">
      <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1.5 rounded text-gray-700 dark:text-gray-300">0x100</div>
      <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1.5 rounded text-gray-700 dark:text-gray-300">0x101</div>
      <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1.5 rounded text-gray-700 dark:text-gray-300">0x102</div>
      <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1.5 rounded text-gray-700 dark:text-gray-300">0x103</div>
    </div>
    <div class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg flex justify-between items-center text-[10px] text-emerald-800 dark:text-emerald-300">
      <span class="font-bold font-mono">CLD (DF = 0):</span>
      <span>Avance ascendente &rarr; (+1 byte)</span>
    </div>
    <div class="p-2 bg-rose-50 border border-rose-200 dark:bg-rose-950/40 dark:border-rose-800/40 rounded-lg flex justify-between items-center text-[10px] text-rose-800 dark:text-rose-300">
      <span class="font-bold font-mono">STD (DF = 1):</span>
      <span>Avance descendente &larr; (-1 byte)</span>
    </div>
  </div>

  <div v-click="4" class="mt-2 text-[9px] text-gray-500 dark:text-gray-400 text-center font-sans">
    Regla de oro: Ejecutar siempre <i>CLD</i> antes de cualquier rutina de cadenas.
  </div>
</div>
<!--
Estudiemos la bandera de dirección y su influencia en el registro EFLAGS.

[click] La instrucción CLD pone a cero la bandera DF. Con ello, tanto ESI como EDI avanzan hacia adelante incrementando sus direcciones de memoria.

[click] Por el contrario, la instrucción STD fija la bandera en uno, provocando que los punteros retrocedan hacia direcciones inferiores. Esto resulta sumamente útil cuando se mueven bloques contiguos de memoria que se solapan entre sí.

[click] En el gráfico de la derecha podemos apreciar la dirección del flujo de datos en ambos casos.

[click] Una regla de oro de la arquitectura x86 es anteponer siempre la instrucción CLD antes de operar con cadenas para evitar que una función anterior haya dejado la bandera DF activada.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Transferencia: LODS, STOS y MOVS

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Instrucciones básicas para transferir y almacenar bloques de memoria:
</div>

<div class="space-y-2 text-xs font-mono mt-1">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg font-sans">
    <div class="text-cyan-600 dark:text-cyan-400 font-bold font-mono text-[10.5px]">LODS (Load String)</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Carga en <i>AL</i>, <i>AX</i> o <i>EAX</i> el dato apuntado por <i>[ESI]</i> y actualiza <i>ESI</i> según <i>DF</i>.
    </p>
  </div>

  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg font-sans">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold font-mono text-[10.5px]">STOS (Store String)</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Almacena el valor de <i>AL</i>, <i>AX</i> o <i>EAX</i> en <i>[EDI]</i> y actualiza <i>EDI</i> según <i>DF</i>.
    </p>
  </div>

  <div v-click="3" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg font-sans">
    <div class="text-amber-700 dark:text-amber-400 font-bold font-mono text-[10.5px]">MOVS (Move String)</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Transfiere directamente desde <i>[ESI]</i> hacia <i>[EDI]</i> en un solo ciclo y actualiza ambos punteros.
    </p>
  </div>
</div>

::right::

<div v-click="4" class="text-xs font-mono">
  <div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] font-sans text-center">
    Rutas de datos de las instrucciones de transferencia
  </div>

  <div class="space-y-2 text-[9.5px]">
    <div class="p-2 bg-cyan-50 border border-cyan-200 dark:bg-cyan-950/40 dark:border-cyan-800/40 rounded-lg flex justify-between items-center text-gray-800 dark:text-gray-200">
      <span class="font-bold text-cyan-700 dark:text-cyan-300 font-sans">LODSB:</span>
      <span>[ESI] &rarr; AL</span>
      <span class="text-gray-500 font-sans text-[8.5px]">ESI &plusmn; 1</span>
    </div>
    <div class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg flex justify-between items-center text-gray-800 dark:text-gray-200">
      <span class="font-bold text-emerald-700 dark:text-emerald-300 font-sans">STOSB:</span>
      <span>AL &rarr; [EDI]</span>
      <span class="text-gray-500 font-sans text-[8.5px]">EDI &plusmn; 1</span>
    </div>
    <div class="p-2 bg-amber-50 border border-amber-200 dark:bg-amber-950/40 dark:border-amber-800/40 rounded-lg flex justify-between items-center text-gray-800 dark:text-gray-200">
      <span class="font-bold text-amber-800 dark:text-amber-300 font-sans">MOVSB:</span>
      <span>[ESI] &rarr; [EDI]</span>
      <span class="text-gray-500 font-sans text-[8.5px]">Ambos &plusmn; 1</span>
    </div>
  </div>

  <div v-click="5" class="mt-2 p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg font-sans text-[9.5px] text-gray-600 dark:text-gray-300">
    <strong>Eficiencia de MOVS:</strong> Realiza una copia memoria a memoria sin necesidad de explicitar un registro intermediario en el código ensamblador.
  </div>
</div>
<!--
Examinemos las tres instrucciones fundamentales de movimiento de información.

[click] LODSB carga en el acumulador el byte apuntado por ESI y actualiza dicho puntero al siguiente elemento.

[click] STOSB deposita el valor del acumulador en la posición apuntada por EDI y avanza el puntero de destino.

[click] MOVSB combina ambas operaciones en una sola instrucción atómica de procesador: transfiere el dato desde la dirección ESI a la dirección EDI y actualiza ambos punteros a la vez.

[click] En el diagrama observamos cómo fluyen los datos en el bus interno del microprocesador.

[click] MOVSB es de altísima velocidad porque delega la copia completa al microcódigo interno de la CPU.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Inspección: CMPS y SCAS

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Comparación de bloques y búsqueda de caracteres actualizando banderas:
</div>

<div class="space-y-2 text-xs font-sans mt-1">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-purple-600 dark:text-purple-400 font-bold font-mono text-[10.5px]">CMPS (Compare String)</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Resta internamente <i>[ESI] - [EDI]</i> y actualiza las banderas <i>ZF</i>, <i>CF</i> y <i>SF</i> sin alterar la memoria. Avanza ambos punteros.
    </p>
  </div>

  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold font-mono text-[10.5px]">SCAS (Scan String)</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Resta internamente <i>AL - [EDI]</i> y actualiza banderas para comprobar coincidencia con un carácter diana. Avanza <i>EDI</i>.
    </p>
  </div>
</div>

::right::

<div v-click="3" class="text-xs font-sans">
  <div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] text-center">
    Evaluación de la bandera de cero (ZF)
  </div>

  <div class="space-y-2">
    <div class="p-2 bg-purple-50 border border-purple-200 dark:bg-purple-950/40 dark:border-purple-800/40 rounded-lg">
      <div class="font-bold text-purple-700 dark:text-purple-300 font-mono mb-1 text-[10px]">CMPSB: [ESI] vs [EDI]</div>
      <div class="flex justify-around font-mono text-[9px]">
        <span class="text-emerald-600 dark:text-emerald-400 font-bold">Iguales: ZF = 1</span>
        <span class="text-rose-600 dark:text-rose-400 font-bold">Distintos: ZF = 0</span>
      </div>
    </div>
    <div class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg">
      <div class="font-bold text-emerald-700 dark:text-emerald-300 font-mono mb-1 text-[10px]">SCASB: AL vs [EDI]</div>
      <div class="flex justify-around font-mono text-[9px]">
        <span class="text-emerald-600 dark:text-emerald-400 font-bold">Encontrado: ZF = 1</span>
        <span class="text-gray-500 dark:text-gray-400 font-bold">No hallado: ZF = 0</span>
      </div>
    </div>
  </div>

  <div v-click="4" class="mt-2 p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg text-[9.5px] text-gray-600 dark:text-gray-300 leading-snug">
    <strong>Integración con prefijos:</strong> El estado de <i>ZF</i> es evaluado por el procesador en cada paso para determinar si la repetición condicional debe continuar o detenerse.
  </div>
</div>
<!--
Analicemos ahora las instrucciones para comparar y buscar patrones en memoria.

[click] CMPSB compara el byte apuntado por ESI contra el apuntado por EDI realizando una resta aritmética sin guardar la diferencia, actualizando banderas como ZF y CF.

[click] SCASB compara el contenido del acumulador AL contra el byte apuntado por EDI. Es la instrucción ideal para buscar caracteres específicos como el terminador nulo.

[click] Observemos cómo la bandera ZF se pone en uno cuando hay coincidencia exacta y en cero cuando los elementos difieren.

[click] Este comportamiento de la bandera de cero es el núcleo que aprovechan los prefijos de repetición condicional.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Prefijo incondicional: REP

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Repite la instrucción de forma iterativa por hardware mientras <i>ECX &gt; 0</i>:
</div>

<div class="space-y-2 text-xs font-sans mt-1">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-blue-600 dark:text-blue-400 font-bold font-mono text-[10.5px]">REP MOVSB / REP MOVSD</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Copia <i>ECX</i> elementos consecutivos desde <i>ESI</i> hacia <i>EDI</i> en ráfagas optimizadas de bus.
    </p>
  </div>

  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="text-emerald-600 dark:text-emerald-400 font-bold font-mono text-[10.5px]">REP STOSB / REP STOSD</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Rellena un bloque de <i>ECX</i> elementos en <i>EDI</i> con el valor almacenado en el acumulador.
    </p>
  </div>
</div>

::right::

<div v-click="3" class="text-xs font-sans">
  <div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] text-center">
    Lógica de ejecución en microcódigo del prefijo REP
  </div>

  <div class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl space-y-1.5">
    <div class="p-1.5 bg-white dark:bg-gray-800/80 border border-gray-200 dark:border-gray-700 rounded flex justify-between font-mono text-[9px]">
      <span class="text-amber-700 dark:text-amber-400 font-bold">Condición:</span>
      <span>¿ECX &gt; 0?</span>
    </div>
    <div class="p-1.5 bg-blue-50 border border-blue-200 dark:bg-blue-950/40 dark:border-blue-800/40 rounded flex justify-between font-mono text-[9px] text-blue-900 dark:text-blue-200">
      <span class="font-bold">Acción:</span>
      <span>Ejecutar instrucción de cadena</span>
    </div>
    <div class="p-1.5 bg-purple-50 border border-purple-200 dark:bg-purple-950/40 dark:border-purple-800/40 rounded flex justify-between font-mono text-[9px] text-purple-900 dark:text-purple-200">
      <span class="font-bold">Decremento:</span>
      <span>ECX = ECX - 1</span>
    </div>
    <div class="p-1.5 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded flex justify-between font-mono text-[9px] text-emerald-900 dark:text-emerald-200">
      <span class="font-bold">Terminación:</span>
      <span>Sale del bucle cuando ECX = 0</span>
    </div>
  </div>

  <div v-click="4" class="mt-2 p-1.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded text-[9px] text-gray-600 dark:text-gray-300">
    <strong>Ventaja:</strong> La iteración se procesa internamente en la unidad de control, sin penalización por saltos condicionales en el cauce (<i>pipeline</i>).
  </div>
</div>
<!--
Veamos el prefijo de repetición incondicional REP.

[click] Al anteponer REP a MOVSB o MOVSD, el procesador transfiere tantos elementos como indique el registro ECX, decrementándolo en cada ciclo.

[click] Al combinarlo con STOSB o STOSD, inicializamos bloques masivos de memoria con un valor predeterminado, equivalente a la función memset de C.

[click] Apreciemos en la columna derecha el ciclo de microcódigo: la CPU evalúa si ECX es mayor a cero, ejecuta la instrucción, resta una unidad a ECX y repite hasta llegar a cero.

[click] Esto ahorra ciclos de decodificación y elimina paradas de salto condicional en el cauce de la CPU.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Prefijos condicionales: REPE y REPNE

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Evalúan simultáneamente el contador <i>ECX</i> y la bandera <i>ZF</i>:
</div>

<div class="space-y-2 text-xs font-sans mt-1">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="flex justify-between font-mono text-emerald-600 dark:text-emerald-400 font-bold text-[10.5px]">
      <span>REPE / REPZ</span>
      <span>Repetir mientras sea igual (ZF = 1)</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug mt-0.5">
      Continúa mientras <i>ECX &gt; 0</i> y los datos coincidan. Se detiene de inmediato al detectar la primera diferencia (<i>ZF = 0</i>).
    </p>
  </div>

  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="flex justify-between font-mono text-rose-600 dark:text-rose-400 font-bold text-[10.5px]">
      <span>REPNE / REPNZ</span>
      <span>Repetir mientras difiera (ZF = 0)</span>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug mt-0.5">
      Continúa mientras <i>ECX &gt; 0</i> y los datos difieran. Se detiene tan pronto halla coincidencia con el carácter buscado (<i>ZF = 1</i>).
    </p>
  </div>
</div>

::right::

<div class="space-y-2 text-xs">
  <div v-click="3">
    <div class="text-blue-600 dark:text-blue-400 font-bold mb-1.5 text-[11px] font-sans text-center">
      Aplicaciones canónicas en rutinas estándar
    </div>
    <table class="w-full text-left text-[9.5px] border-collapse font-mono">
      <thead>
        <tr class="text-gray-500 dark:text-gray-400 border-b border-gray-300 dark:border-gray-700 font-sans">
          <th class="py-1 px-1.5">Instrucción</th>
          <th class="py-1 px-1.5 font-sans">Función estándar de C</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-200 dark:divide-gray-800 text-gray-700 dark:text-gray-300">
        <tr>
          <td class="py-1 px-1.5 text-emerald-600 dark:text-emerald-400 font-bold">REPE CMPSB</td>
          <td class="py-1 px-1.5 font-sans">Comparación léxica de cadenas (<i>strcmp</i>)</td>
        </tr>
        <tr>
          <td class="py-1 px-1.5 text-rose-600 dark:text-rose-400 font-bold">REPNE SCASB</td>
          <td class="py-1 px-1.5 font-sans">Cálculo de longitud de cadena (<i>strlen</i>)</td>
        </tr>
      </tbody>
    </table>
  </div>

  <div v-click="4" class="p-2 bg-amber-50 border border-amber-200 dark:bg-amber-950/40 dark:border-amber-800/40 rounded-lg text-[9.5px] font-sans text-gray-700 dark:text-gray-300">
    <span class="text-amber-800 dark:text-amber-300 font-bold block mb-0.5">Sinónimos en código máquina:</span>
    <i>REPE</i> y <i>REPZ</i> comparten el mismo código de operación (<i>0xF3</i>). Del mismo modo, <i>REPNE</i> y <i>REPNZ</i> son el opcode <i>0xF2</i>.
  </div>
</div>
<!--
Llegamos a los prefijos condicionales, un tema de alta relevancia analítica.

[click] REPE o REPZ repite la operación mientras los elementos comparados sean idénticos, es decir mientras la bandera ZF sea uno. En cuanto detecta una diferencia, la repetición finaliza de inmediato.

[click] En cambio, REPNE o REPNZ repite la instrucción mientras no haya coincidencia, o sea mientras ZF sea cero. Se detiene tan pronto encuentra el carácter buscado.

[click] A la derecha resumimos los dos grandes casos canónicos: comparar dos cadenas completas con REPE CMPSB y calcular la longitud escaneando el byte nulo con REPNE SCASB.

[click] Tengamos presente que los mnemónicos REPE y REPZ son alias sinónimos del mismo código de máquina.
-->

---
transition: fade
---

# Síntesis de la primera sesión

<div class="max-w-xl mx-auto text-left space-y-2.5 text-xs font-sans">
  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <strong class="text-emerald-600 dark:text-emerald-400 font-bold text-[11px]">1. Punteros dedicados y control de dirección:</strong>
    <p class="text-gray-600 dark:text-gray-300 mt-0.5 text-[10px] leading-snug">
      <i>ESI</i> y <i>EDI</i> indexan origen y destino. La instrucción <i>CLD</i> garantiza incremento hacia adelante (<i>DF = 0</i>), mientras que <i>STD</i> fuerza avance hacia atrás (<i>DF = 1</i>).
    </p>
  </div>

  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <strong class="text-blue-600 dark:text-blue-400 font-bold text-[11px]">2. Bloques y prefijos de repetición:</strong>
    <p class="text-gray-600 dark:text-gray-300 mt-0.5 text-[10px] leading-snug">
      <i>LODS</i>, <i>STOS</i>, <i>MOVS</i>, <i>CMPS</i> y <i>SCAS</i> se combinan con <i>REP</i>, <i>REPE</i> y <i>REPNE</i> para operar ráfagas continuas de memoria a máxima velocidad de hardware.
    </p>
  </div>

  <div v-click="1" class="p-2.5 bg-amber-50 border border-amber-200 dark:bg-amber-950/40 dark:border-amber-800/40 rounded-lg">
    <strong class="text-amber-800 dark:text-amber-300 font-bold text-[11px]">3. Pregunta detonante para el taller práctico:</strong>
    <p class="text-amber-900 dark:text-amber-200 mt-0.5 text-[10px] italic leading-snug">
      Si inicializamos <i>ECX</i> en <i>-1</i> y ejecutamos <i>REPNE SCASB</i> buscando el byte nulo <i>0x00</i>, ¿qué operación matemática bit a bit nos permite calcular la longitud exacta de la cadena a partir del residuo en <i>ECX</i>?
    </p>
  </div>
</div>
<!--
Con esto concluimos la primera sesión teórica de la semana. Hemos analizado los registros dedicados, el control de dirección con DF y la lógica de los prefijos de repetición.

[click] Les dejo esta pregunta detonante para reflexionar antes de pasar al taller práctico: si ECX empieza en menos uno y se decrementa en cada byte, ¿cómo deducimos la longitud exacta aplicando operadores a nivel de bits?
-->

---
layout: center
transition: slide-up | slide-down
---

<div class="text-center">
  <div class="text-3xl text-gray-500 dark:text-gray-400 mb-4 font-mono">Semana 10</div>
  <h1 class="text-6xl font-bold mb-8 text-gray-900 dark:text-white">Sesión 02: Práctica guiada</h1>
  <div class="text-2xl text-blue-600 dark:text-blue-400 mt-4">IC3101: Arquitectura de computadores</div>
</div>
<!--
¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de las instrucciones de bloque y los prefijos de repetición, dedicaremos esta jornada completa a implementar de forma práctica funciones esenciales de memoria como strlen, memcpy, memset y strcmp, evaluando su rendimiento real frente a bucles tradicionales.
-->

---
transition: fade
---

# Objetivos de la segunda sesión

<div class="mb-4 text-sm text-gray-600 dark:text-gray-300">
Implementar funciones estándar de memoria en lenguaje ensamblador de alto rendimiento:
</div>
<v-clicks>

- **Cálculo de longitud de cadena con strlen:** Utilizar <i>REPNE SCASB</i> para buscar el byte centinela y calcular la longitud en <i>EAX</i>.
- **Copia masiva de memoria con memcpy:** Optimizar transferencias por palabras dobles con <i>REP MOVSD</i> y copiar residuos con <i>MOVSB</i>.
- **Inicialización de buffers con memset:** Rellenar eficientemente bloques de memoria con patrones continuos usando <i>REP STOSB</i>.
- **Comparación léxica de textos con strcmp:** Evaluar igualdad y orden lexicográfico con <i>REPE CMPSB</i> y saltos condicionales.
- **Análisis comparativo de rendimiento:** Medir ciclos de procesador y densidad de código frente a bucles manuales de software.

</v-clicks>
<!--
Antes de iniciar los ejercicios prácticos, repasemos los objetivos de esta segunda sesión:

[click] Primero, implementaremos la función strlen utilizando el prefijo REPNE SCASB para buscar el fin de cadena en memoria.

[click] Segundo, construiremos una rutina de copia masiva de memoria optimizada por palabras dobles de 32 bits.

[click] Tercero, aprenderemos a inicializar buffers de forma instantánea con REP STOSB.

[click] Cuarto, implementaremos la comparación de textos con REPE CMPSB determinando cuál cadena es mayor.

[click] Y quinto, analizaremos cuantitativamente por qué estas instrucciones en microcódigo superan ampliamente a los bucles manuales de software.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Longitud de cadena con strlen

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1">
Búsqueda del byte nulo <i>0x00</i> mediante <i>REPNE SCASB</i>:
</div>

<div class="font-mono text-[9px]">

```asm {all|1-4|6|8-11}
; Entrada: EDI = dirección inicial de cadena
; Salida:  EAX = longitud en caracteres

strlen_opt:
  cld                 ; DF = 0 (hacia adelante)
  mov ecx, -1         ; ECX = 0xFFFFFFFF
  xor al, al          ; AL = 0x00 (buscar nulo)

  repne scasb         ; Escanear mientras != 0

  not ecx             ; Invertir bits de ECX
  dec ecx             ; Descontar byte nulo
  mov eax, ecx        ; Retornar en EAX
  ret
```

</div>

::right::

<div class="space-y-1.5 text-xs font-sans">
  <div v-click="1" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="font-mono text-cyan-600 dark:text-cyan-400 font-bold text-[10.5px]">Inicialización en -1 (0xFFFFFFFF):</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Evita que el contador <i>ECX</i> se agote antes de encontrar el byte nulo en cadenas de cualquier longitud.
    </p>
  </div>

  <div v-click="2" class="p-2 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-lg">
    <div class="font-mono text-amber-700 dark:text-amber-400 font-bold text-[10.5px]">Criterio de parada (ZF = 1):</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Al hallar <i>0x00</i>, <i>AL - [EDI] = 0</i> activa <i>ZF = 1</i> y <i>REPNE</i> detiene la repetición.
    </p>
  </div>

  <div v-click="3" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg">
    <div class="font-mono text-emerald-700 dark:text-emerald-300 font-bold text-[10.5px]">Deducción matemática:</div>
    <p class="text-gray-700 dark:text-gray-300 text-[9.5px] font-mono leading-snug">
      Longitud = NOT(ECX_final) - 1
    </p>
    <p class="text-gray-600 dark:text-gray-400 text-[8.5px] font-sans mt-0.5">
      La inversión de bits restaura la cantidad de decrementos ocurridos en el escaneo.
    </p>
  </div>
</div>
<!--
Analicemos la implementación clásica de strlen con instrucciones de bloque.

[click] Primero aseguramos la dirección de avance con cld, colocamos ECX en menos uno y limpiamos AL con xor al, al para buscar el byte cero.

[click] Al ejecutar repne scasb, el procesador inspecciona byte a byte en microcódigo hasta toparse con el terminador nulo, activando la bandera ZF.

[click] Notemos este elegante truco matemático: al aplicar NOT sobre ECX y restar una unidad con dec ecx, obtenemos con precisión matemática el número exacto de caracteres de la cadena.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Copia de memoria optimizada con memcpy

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1">
Transferencia por palabras dobles de 32 bits (4 bytes por ciclo de bus):
</div>

<div class="font-mono text-[9px]">

```asm {all|1-4|6-7|9-11}
; Entrada: ESI = origen, EDI = destino, ECX = total bytes

memcpy_opt:
  cld                 ; DF = 0 (hacia adelante)
  push ecx            ; Preservar total original

  ; 1. Copiar bloques de 4 bytes (dwords)
  shr ecx, 2          ; ECX = total / 4
  rep movsd           ; Transferir dwords

  ; 2. Copiar residuos (0 a 3 bytes)
  pop ecx             ; Restaurar total original
  and ecx, 3          ; ECX = residuo (total % 4)
  rep movsb           ; Transferir sobrantes

  ret
```

</div>

::right::

<div class="space-y-2 text-xs font-sans">
  <div v-click="1" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg">
    <div class="font-mono text-emerald-700 dark:text-emerald-300 font-bold text-[10.5px]">Aceleración con MOVSD:</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Mueve 32 bits a la vez, cuadruplicando el ancho de banda efectivo respecto a transferencias individuales por byte (4&times;).
    </p>
  </div>

  <div v-click="2" class="p-2 bg-blue-50 border border-blue-200 dark:bg-blue-950/40 dark:border-blue-800/40 rounded-lg">
    <div class="font-mono text-blue-700 dark:text-blue-300 font-bold text-[10.5px]">Manejo de remanentes con and ecx, 3:</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      La máscara binaria <i>AND 3</i> extrae de forma instantánea el residuo de la división entre cuatro (0, 1, 2 o 3 bytes restantes).
    </p>
  </div>
</div>
<!--
Veamos una optimización profesional para duplicar bloques de memoria equivalente a memcpy en C.

[click] En vez de copiar byte a byte con MOVSB, dividimos el total de bytes entre cuatro mediante shr ecx, 2 y transferimos de cuatro en cuatro bytes usando rep movsd.

[click] Luego recuperamos el total original de la pila, extraemos el residuo con and ecx, 3 y copiamos los bytes finales con rep movsb.

Esta técnica explota al máximo el ancho de palabra del procesador.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Inicialización de memoria con memset

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1">
Relleno masivo de buffers con un valor uniforme mediante <i>REP STOSB</i>:
</div>

<div class="font-mono text-[9px]">

```asm {all|1-4|6-10}
; Entrada: EDI = buffer, AL = valor a escribir, ECX = bytes

memset_opt:
  cld                 ; DF = 0
  rep stosb           ; Escribir AL en [EDI] iterando
  ret

; Ejemplo de invocación: limpiar buffer de 256 bytes
limpiar_memoria:
  mov edi, mi_buffer  ; Puntero al buffer
  xor al, al          ; AL = 0x00
  mov ecx, 256        ; Cantidad de bytes
  call memset_opt
```

</div>

::right::

<div v-click="1" class="flex flex-col items-center justify-center font-sans">
  <div class="text-blue-600 dark:text-blue-400 font-bold text-center mb-1 text-[11px]">
    Efecto del relleno en memoria (REP STOSB)
  </div>
  <div class="w-full max-w-[340px] space-y-2">
    <div>
      <div class="text-[9px] text-gray-500 dark:text-gray-400 mb-1">Contenido previo (basura en memoria):</div>
      <div class="grid grid-cols-4 gap-1 text-center font-mono text-[9.5px]">
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1 rounded text-gray-500">0xA3</div>
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1 rounded text-gray-500">0x5F</div>
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1 rounded text-gray-500">0x12</div>
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 p-1 rounded text-gray-500">0x8B</div>
      </div>
    </div>
    <div class="text-center font-mono text-[9.5px] font-bold text-emerald-600 dark:text-emerald-400">
      &darr; Relleno en microcódigo con AL = 0x00 &darr;
    </div>
    <div>
      <div class="text-[9px] text-gray-500 dark:text-gray-400 mb-1">Buffer inicializado:</div>
      <div class="grid grid-cols-4 gap-1 text-center font-mono text-[9.5px]">
        <div class="bg-emerald-50 dark:bg-emerald-950/60 border border-emerald-300 dark:border-emerald-700 p-1 rounded font-bold text-emerald-700 dark:text-emerald-300">0x00</div>
        <div class="bg-emerald-50 dark:bg-emerald-950/60 border border-emerald-300 dark:border-emerald-700 p-1 rounded font-bold text-emerald-700 dark:text-emerald-300">0x00</div>
        <div class="bg-emerald-50 dark:bg-emerald-950/60 border border-emerald-300 dark:border-emerald-700 p-1 rounded font-bold text-emerald-700 dark:text-emerald-300">0x00</div>
        <div class="bg-emerald-50 dark:bg-emerald-950/60 border border-emerald-300 dark:border-emerald-700 p-1 rounded font-bold text-emerald-700 dark:text-emerald-300">0x00</div>
      </div>
    </div>
  </div>
</div>
<!--
Revisemos cómo inicializar memoria de forma ultrarrápida utilizando REP STOSB.

[click] Con solo cargar EDI con la dirección base del buffer, AL con el valor a escribir y ECX con la longitud, la instrucción rep stosb escribe en memoria en cada ciclo de procesador.

[click] Apreciemos en la ilustración gráfica cómo las celdas previamente sucias con datos residuales quedan completamente limpias con ceros.

Esta es exactamente la rutina que utilizan los sistemas operativos para inicializar páginas de memoria antes de entregarlas a los procesos de usuario.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Comparación léxica con strcmp

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1">
Comparación byte a byte hasta detectar discrepancia mediante <i>REPE CMPSB</i>:
</div>

<div class="font-mono text-[8.5px]">

```asm {all|1-4|6-7|9-12|14-16}
; Entrada: ESI = cadena1, EDI = cadena2, ECX = max_bytes
; Salida:  EAX = 0 (iguales), EAX != 0 (diferencia)

strcmp_opt:
  cld
  repe cmpsb          ; Comparar mientras [ESI] == [EDI]
  je cadenas_iguales  ; Si ZF = 1, son idénticas

  ; Si hubo discrepancia:
  movzx eax, byte [esi - 1] ; Carácter de cadena1
  movzx edx, byte [edi - 1] ; Carácter de cadena2
  sub eax, edx              ; Retornar s1[k] - s2[k]
  ret

cadenas_iguales:
  xor eax, eax        ; Retornar 0
  ret
```

</div>

::right::

<div class="space-y-2 text-xs font-sans">
  <div v-click="1" class="p-2 bg-rose-50 border border-rose-200 dark:bg-rose-950/40 dark:border-rose-800/40 rounded-lg">
    <div class="font-mono text-rose-700 dark:text-rose-300 font-bold text-[10.5px]">Ajuste de punteros [esi - 1] y [edi - 1]:</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      <i>CMPSB</i> incrementa los punteros antes de evaluar la parada. Por tanto, el byte discrepante se encuentra en la posición anterior (<i>-1</i>).
    </p>
  </div>

  <div v-click="2" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg">
    <div class="font-mono text-emerald-700 dark:text-emerald-300 font-bold text-[10.5px]">Salto con je:</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Si todas las letras fueron idénticas, <i>ZF = 1</i> se mantiene activo y la subrutina retorna 0 indicando igualdad perfecta.
    </p>
  </div>
</div>
<!--
Analicemos la función strcmp implementada con REPE CMPSB.

[click] Al ejecutar repe cmpsb, el procesador compara byte a byte ambas cadenas mientras sean iguales. Si no se detecta ninguna diferencia, el bucle finaliza con ZF en uno y retornamos cero.

[click] Si se detecta una diferencia, el prefijo se detiene inmediatamente. Un detalle crítico de bajo nivel es que los punteros ya avanzaron una posición, por lo que leemos en esi menos uno y edi menos uno para restar los caracteres y determinar cuál cadena es mayor.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

<div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
  Práctica
</div>

# Rendimiento: Bloques frente a bucles

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1">
Comparativa de ciclos de procesador y densidad en memoria caché:
</div>

<div class="font-mono text-[8.5px] space-y-2">

```asm
; Alternativa A: Bucle manual en software
bucle_copia:
  mov al, [esi]       ; Lectura
  mov [edi], al       ; Escritura
  inc esi             ; Avanzar origen
  inc edi             ; Avanzar destino
  dec ecx             ; Decrementar contador
  jnz bucle_copia     ; Salto condicional repetido
```

```asm
; Alternativa B: Instrucción de bloque por hardware
cld
rep movsd             ; Transferencia masiva 32 bits
```

</div>

::right::

<div class="space-y-2 text-xs font-sans">
  <div v-click="1" class="p-2 bg-emerald-50 border border-emerald-200 dark:bg-emerald-950/40 dark:border-emerald-800/40 rounded-lg">
    <div class="text-emerald-700 dark:text-emerald-300 font-bold text-[10.5px] mb-0.5">Ventajas de las instrucciones de bloque:</div>
    <ul class="space-y-1 text-gray-600 dark:text-gray-300 text-[9.5px]">
      <li>&bull; <strong>Decodificación única:</strong> La CPU decodifica la instrucción una sola vez.</li>
      <li>&bull; <strong>Ráfagas de bus:</strong> Emite transferencias continuas aprovechando el bus de memoria.</li>
      <li>&bull; <strong>Cero predicción de saltos:</strong> No satura la unidad branch target buffer.</li>
    </ul>
  </div>

  <div v-click="2" class="p-2 bg-blue-50 border border-blue-200 dark:bg-blue-950/40 dark:border-blue-800/40 rounded-lg">
    <div class="text-blue-700 dark:text-blue-300 font-bold text-[10.5px] mb-0.5">Densidad de código en caché L1:</div>
    <p class="text-gray-600 dark:text-gray-300 text-[9.5px] leading-snug">
      Una sola instrucción de 2 bytes sustituye un lazo de 6 instrucciones de máquina, liberando espacio en la caché de instrucciones L1.
    </p>
  </div>
</div>
<!--
Comparemos el rendimiento entre ambas alternativas.

En la columna izquierda observamos el bucle manual tradicional: lectura, escritura, incrementos de punteros, decremento de contador y salto condicional con riesgo de fallos de predicción.

[click] Con REP MOVSD eliminamos toda esa sobrecarga. La decodificación ocurre una sola vez y el procesador transfiere datos en ráfagas directas a velocidad de hardware.

[click] Además de ganar velocidad, el binario resultante es mucho más compacto y no satura las líneas de la memoria caché L1 del procesador.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Trampas comunes en cadenas

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-1.5">
Errores recurrentes en el manejo de instrucciones de bloque y su prevención:
</div>

<div class="space-y-2.5 mt-2 text-xs font-sans">
  <div v-click="1" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-rose-600 dark:text-rose-400 text-[11px]">1. Olvido de CLD</span>
      <span class="text-rose-400 dark:text-rose-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-rose-700 bg-rose-50 border border-rose-200 dark:text-rose-300 dark:bg-rose-950/60 dark:border-rose-800/40 px-1.5 py-0.5 rounded">DF desconocido</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Si una función previa activó <i>STD</i>, las instrucciones retrocederán corrompiendo memoria adyacente.
    </p>
  </div>

  <div v-click="2" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-amber-700 dark:text-amber-400 text-[11px]">2. Desfase de punteros</span>
      <span class="text-amber-400 dark:text-amber-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-amber-800 bg-amber-50 border border-amber-200 dark:text-amber-300 dark:bg-amber-950/60 dark:border-amber-800/40 px-1.5 py-0.5 rounded">[esi] en vez de [esi - 1]</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Olvidar que <i>CMPSB</i> y <i>SCASB</i> avanzan los punteros antes de comprobar la condición de parada.
    </p>
  </div>

  <div v-click="3" class="space-y-0.5">
    <div class="flex items-center gap-2">
      <span class="font-bold text-blue-600 dark:text-blue-400 text-[11px]">3. Inversión ESI / EDI</span>
      <span class="text-blue-400 dark:text-blue-500/60 font-mono text-xs">&mdash;&mdash;&gt;</span>
      <code class="text-[9.5px] font-mono text-blue-700 bg-blue-50 border border-blue-200 dark:text-blue-300 dark:bg-blue-950/60 dark:border-blue-800/40 px-1.5 py-0.5 rounded">Destino en ESI</code>
    </div>
    <p class="text-gray-600 dark:text-gray-300 text-[10px] leading-relaxed pl-1">
      Asumir que <i>STOS</i> escribe en <i>ESI</i> cuando por hardware siempre opera sobre <i>EDI</i>.
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
        <td class="py-1.5 px-2 text-rose-600 dark:text-rose-300">rep movsb directo</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-300">cld<br/>rep movsb</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-rose-600 dark:text-rose-300">mov al, [esi] tras cmpsb</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-300">mov al, [esi - 1]</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-rose-600 dark:text-rose-300">stosb con ESI</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-300">mov edi, destino<br/>stosb</td>
      </tr>
      <tr>
        <td class="py-1.5 px-2 text-rose-600 dark:text-rose-300">strlen sin dec ecx</td>
        <td class="py-1.5 px-2 text-emerald-600 dark:text-emerald-300">not ecx<br/>dec ecx</td>
      </tr>
    </tbody>
  </table>
</div>
<!--
Revisemos las trampas más frecuentes al programar con instrucciones de cadenas en x86.

[click] La primera es no limpiar la bandera DF con cld. Si una rutina previa ejecutó STD, nuestros punteros retrocederán y corromperán datos ajenos en la memoria.

[click] La segunda trampa es el desfase de punteros: al detenerse una búsqueda o comparación con CMPSB o SCASB, el hardware ya incrementó los punteros, por lo que el byte que causó la parada está en la posición menos uno.

[click] La tercera es confundir ESI con EDI, recordando que STOS escribe siempre en la dirección de EDI.

[click] En la tabla derecha resumimos las correcciones estandarizadas para asegurar la estabilidad de nuestras rutinas.
-->

---
transition: fade
---

# Ejercicios de práctica

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Banderas de control, registros dedicados e inicialización de memoria:
</div>

<div class="space-y-2 mt-3 text-xs font-sans">
  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
    <strong class="text-blue-600 dark:text-blue-400 text-[11px]">1. ¿Cuál instrucción asegura que ESI y EDI avancen hacia direcciones ascendentes de memoria?</strong>
    <div class="grid grid-cols-4 gap-3 text-[9.5px] font-mono text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>STD</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>CLD</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>REP</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">D)</span>
        <span>INC</span>
      </div>
    </div>
    <div v-click="1" class="text-emerald-600 dark:text-emerald-400 mt-1 text-[10px] font-bold font-sans">
      &rarr; Respuesta correcta: B) CLD limpia la bandera de dirección (DF = 0), habilitando el incremento hacia adelante.
    </div>
  </div>

  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
    <strong class="text-amber-700 dark:text-amber-400 text-[11px]">2. En la instrucción STOSD, ¿cuál es el registro de origen y cuál es el puntero de destino en memoria?</strong>
    <div class="grid grid-cols-3 gap-3 text-[9.5px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>Origen ESI y destino EAX</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>Origen EAX y destino apuntado por EDI</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>Origen EDX y destino apuntado por ESI</span>
      </div>
    </div>
    <div v-click="2" class="text-emerald-600 dark:text-emerald-400 mt-1 text-[10px] font-bold">
      &rarr; Respuesta correcta: B) STOSD almacena el contenido del acumulador EAX en la dirección apuntada por EDI.
    </div>
  </div>

  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
    <strong class="text-purple-600 dark:text-purple-400 text-[11px]">3. ¿Cuál es el método más rápido para inicializar un arreglo de 100 enteros de 32 bits con ceros en x86?</strong>
    <div class="grid grid-cols-3 gap-3 text-[9.5px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug font-mono">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0 font-sans">A)</span>
        <span>REP MOVSB con ECX = 400</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0 font-sans">B)</span>
        <span>REP STOSD con EAX = 0 y ECX = 100</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0 font-sans">C)</span>
        <span>REPNE SCASB con ECX = 100</span>
      </div>
    </div>
    <div v-click="3" class="text-emerald-600 dark:text-emerald-400 mt-1 text-[10px] font-bold font-sans">
      &rarr; Respuesta correcta: B) REP STOSD escribe palabras dobles de 4 bytes por ciclo de bus a máxima velocidad.
    </div>
  </div>
</div>
<!--
Evaluemos lo aprendido con esta primera ronda de ejercicios formativos.

Pregunta uno: ¿Qué instrucción asegura que los punteros avancen hacia adelante?
[click] Correcto, la instrucción CLD.

Pregunta dos: En STOSD, ¿cuál es el registro origen y cuál el destino?
[click] Exacto, opción B: el origen es EAX y el destino es la memoria apuntada por EDI.

Pregunta tres: ¿Cuál es la opción más veloz para inicializar un arreglo de enteros con ceros?
[click] Muy bien, REP STOSD con EAX en cero y ECX con la cantidad de palabras dobles.
-->

---
transition: fade
---

# Ejercicios de práctica

<div class="text-[11px] text-gray-600 dark:text-gray-400 mb-2">
Prefijos condicionales, deducción matemática y diagnóstico de punteros:
</div>

<div class="space-y-2 mt-3 text-xs font-sans">
  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
    <strong class="text-blue-600 dark:text-blue-400 text-[11px]">4. ¿En qué condición se detiene la ejecución del prefijo condicional REPE CMPSB?</strong>
    <div class="grid grid-cols-3 gap-3 text-[9.5px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>Cuando ECX llega a cero o cuando ZF pasa a cero al detectar una diferencia</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>Únicamente cuando ECX llega a cero</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>Cuando la bandera de acarreo CF se activa</span>
      </div>
    </div>
    <div v-click="1" class="text-emerald-600 dark:text-emerald-400 mt-1 text-[10px] font-bold">
      &rarr; Respuesta correcta: A) REPE finaliza al agotarse el contador ECX o al hallar el primer byte dispar (ZF = 0).
    </div>
  </div>

  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
    <strong class="text-amber-700 dark:text-amber-400 text-[11px]">5. En la función strlen con REPNE SCASB y ECX = -1 inicial, ¿por qué es indispensable ejecutar dec ecx tras not ecx?</strong>
    <div class="grid grid-cols-3 gap-3 text-[9.5px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>Para convertir el número a positivo</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>Para descontar el byte nulo 0x00 que también fue contado en la última iteración</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>Para limpiar la bandera de dirección</span>
      </div>
    </div>
    <div v-click="2" class="text-emerald-600 dark:text-emerald-400 mt-1 text-[10px] font-bold">
      &rarr; Respuesta correcta: B) SCASB decrementa ECX al encontrar el byte nulo; dec ecx descuenta dicho centinela.
    </div>
  </div>

  <div class="p-2.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl">
    <strong class="text-purple-600 dark:text-purple-400 text-[11px]">6. Si REPE CMPSB se detiene por una discrepancia, ¿dónde se ubican los bytes que causaron la parada?</strong>
    <div class="grid grid-cols-3 gap-3 text-[9.5px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug font-mono">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0 font-sans">A)</span>
        <span>En [esi] y [edi]</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0 font-sans">B)</span>
        <span>En [esi - 1] y [edi - 1]</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0 font-sans">C)</span>
        <span>En [esi + 1] y [edi + 1]</span>
      </div>
    </div>
    <div v-click="3" class="text-emerald-600 dark:text-emerald-400 mt-1 text-[10px] font-bold font-sans">
      &rarr; Respuesta correcta: B) La instrucción incrementa los punteros antes de evaluar el salto de parada.
    </div>
  </div>
</div>
<!--
Continuemos con la segunda ronda de ejercicios de práctica.

Pregunta cuatro: ¿Cuándo concluye el prefijo REPE CMPSB?
[click] Exactamente, opción A: al agotarse ECX o al hallar la primera diferencia con ZF en cero.

Pregunta cinco: ¿Por qué restamos uno tras aplicar NOT sobre ECX en strlen?
[click] Muy bien, opción B: para descontar el propio byte nulo que fue escaneado antes de que la CPU se detuviera.

Pregunta seis: Si REPE CMPSB detecta una discrepancia, ¿dónde se ubican los bytes?
[click] Excelente, en esi menos uno y edi menos uno, debido al autoincremento previo del hardware.
-->

---
layout: center
transition: fade
---

<div class="text-center max-w-xl mx-auto font-sans">
  <h1 class="text-3xl font-bold mb-3 text-gray-900 dark:text-white">Conclusiones integradoras</h1>
  <div class="p-3.5 bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800 rounded-xl text-left text-xs text-gray-700 dark:text-gray-300 space-y-1.5 mt-3">
    <p>
      &bull; Las instrucciones de bloque de x86 aprovechan los registros dedicados <i>ESI</i>, <i>EDI</i> y <i>ECX</i> junto a la bandera <i>DF</i>.
    </p>
    <p>
      &bull; Los prefijos de repetición <i>REP</i>, <i>REPE</i> y <i>REPNE</i> permiten implementar <i>strlen</i>, <i>memcpy</i>, <i>memset</i> y <i>strcmp</i> con rendimiento superior a cualquier bucle manual en software.
    </p>
    <p>
      &bull; La copia por palabras dobles (<i>MOVSD</i>) y el manejo de remanentes (<i>AND 3</i>) maximizan el ancho de banda del bus de memoria.
    </p>
    <p>
      &bull; En la <strong>Semana 11</strong> estudiaremos el <strong>manejo de archivos en disco</strong> (<i>sys_open</i>, <i>sys_creat</i>, <i>sys_close</i>, <i>sys_lseek</i>), macros de preensamblado y modularización híbrida C con NASM.
    </p>
  </div>
  <div class="text-blue-600 dark:text-blue-400 font-semibold mt-3 text-xs">
    ¡Muchas gracias por su atención y nos vemos en la Semana 11!
  </div>
</div>
<!--
Con esto concluimos la décima semana de tutorías de Arquitectura de Computadores.

Hemos dominado una de las facetas más eficientes del ensamblador x86: las instrucciones de cadena y los prefijos de repetición condicional por hardware.

Estas técnicas les dotan de destrezas indispensables para el desarrollo de rutinas de alto rendimiento y la manipulación de buffers en memoria.

En la próxima semana daremos el paso hacia la persistencia de datos en disco mediante llamadas al sistema de archivos, el preprocesador de macros y la integración híbrida de C con NASM.

¡Muchas gracias a todos por su compromiso y nos vemos en la siguiente sesión!
-->
