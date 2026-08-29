---
theme: default
layout: center
transition: slide-left | slide-right
addons:
  - slidev-component-zoom
---

<div class="text-center">
  <div class="text-3xl text-gray-400 mb-4 font-mono">Semana 10</div>
  <h1 class="text-5xl font-bold mb-6">Procesamiento de cadenas y manipulación de memoria</h1>
  <div class="text-2xl text-blue-400">IC3101: Arquitectura de computadores</div>
</div>
<!--
Hola a todos. Bienvenidos a la décima semana de tutorías de Arquitectura de Computadores.

En la semana anterior aprendimos a comunicarnos con el sistema operativo para realizar operaciones de entrada y salida mediante llamadas al sistema.

Hoy abordaremos uno de los mecanismos más potentes y optimizados de la arquitectura x86: las instrucciones especializadas para procesamiento de cadenas y transferencia de bloques de memoria, junto con los prefijos de repetición por hardware.
-->

---
transition: fade
---

# Objetivos de la primera sesión

<div class="mb-4 text-sm text-gray-300">
Dominar los mecanismos de bajo nivel para manipulación masiva de memoria:
</div>
<v-clicks>

- **Representación de datos contiguos:** Comprender esquemas de longitud fija y cadenas terminadas en nulo.
- **Banco de registros especializados:** Dominar el rol de los punteros <i>ESI</i> y <i>EDI</i>, el contador <i>ECX</i> y el acumulador.
- **Control de dirección de recorrido:** Analizar el impacto de la bandera de dirección y las instrucciones <i>CLD</i> y <i>STD</i>.
- **Instrucciones de bloque fundamentales:** Estudiar el funcionamiento de <i>MOVS</i>, <i>STOS</i>, <i>LODS</i>, <i>CMPS</i> y <i>SCAS</i>.
- **Prefijos de repetición por hardware:** Evaluar la repetición incondicional y las condiciones de parada con <i>REPZ</i> y <i>REPNZ</i>.

</v-clicks>
<!--
Revisemos los objetivos para esta primera sesión teórica:

[click] Primero, entenderemos cómo se representan las cadenas de caracteres y los arreglos en la memoria principal.

[click] Segundo, analizaremos los registros dedicados de la arquitectura x86 que soportan estas operaciones de manera automática.

[click] Tercero, estudiaremos la bandera de dirección para controlar si el procesamiento avanza hacia adelante o retrocede en memoria.

[click] Cuarto, examinaremos las cinco instrucciones de manipulación de bloques en sus diferentes tamaños de datos.

[click] Y quinto, dominaremos los prefijos de repetición que permiten ejecutar bucles completos a nivel de microcódigo en el procesador.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Representación de cadenas en memoria

<div class="text-[11px] text-gray-300 mb-1.5">
Esquemas de organización de secuencias de bytes continuas:
</div>
<div v-click="1" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg text-xs mb-1.5">
  <div class="text-amber-400 font-bold text-[11px] mb-0.5">Longitud fija</div>
  <p class="text-gray-300 text-[10px] leading-tight">
    Ocupa un tamaño predefinido constante, rellenando con espacios o ceros.
  </p>
</div>
<div v-click="2" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg text-xs">
  <div class="text-emerald-400 font-bold text-[11px] mb-0.5">Longitud variable (ASCIIZ)</div>
  <p class="text-gray-300 text-[10px] leading-tight">
    Finaliza con byte centinela <i>0x00</i> (nulo <i>\0</i>). Estándar en C y eficiente en RAM.
  </p>
</div>

::right::

<div v-click="3" class="bg-gray-900/90 border border-gray-800 rounded-xl p-2.5 text-xs text-center">
  <div class="text-blue-400 font-bold mb-1 text-[10.5px]">Estructura de cadena ASCIIZ ("ARQUI")</div>
  <div class="grid grid-cols-6 gap-1 font-mono text-[9px] my-1.5">
  <div class="bg-blue-950/40 border border-blue-600/50 p-1 rounded">
  <div class="text-[7.5px] text-gray-400">+0</div>
  <div class="text-blue-300 font-bold text-xs">A</div>
  <div class="text-[7.5px] text-gray-500">0x41</div>
  </div>
  <div class="bg-blue-950/40 border border-blue-600/50 p-1 rounded">
  <div class="text-[7.5px] text-gray-400">+1</div>
  <div class="text-blue-300 font-bold text-xs">R</div>
  <div class="text-[7.5px] text-gray-500">0x52</div>
  </div>
  <div class="bg-blue-950/40 border border-blue-600/50 p-1 rounded">
  <div class="text-[7.5px] text-gray-400">+2</div>
  <div class="text-blue-300 font-bold text-xs">Q</div>
  <div class="text-[7.5px] text-gray-500">0x51</div>
  </div>
  <div class="bg-blue-950/40 border border-blue-600/50 p-1 rounded">
  <div class="text-[7.5px] text-gray-400">+3</div>
  <div class="text-blue-300 font-bold text-xs">U</div>
  <div class="text-[7.5px] text-gray-500">0x55</div>
  </div>
  <div class="bg-blue-950/40 border border-blue-600/50 p-1 rounded">
  <div class="text-[7.5px] text-gray-400">+4</div>
  <div class="text-blue-300 font-bold text-xs">I</div>
  <div class="text-[7.5px] text-gray-500">0x49</div>
  </div>
  <div class="bg-emerald-950/50 border border-emerald-500 p-1 rounded">
  <div class="text-[7.5px] text-emerald-400">+5</div>
  <div class="text-emerald-300 font-bold text-xs">\0</div>
  <div class="text-[7.5px] text-emerald-400 font-bold">0x00</div>
  </div>
  </div>
  <div class="flex justify-between items-center bg-gray-950/80 p-1 rounded border border-gray-800 text-[9.5px]">
  <span class="text-gray-300">Longitud: <strong class="text-blue-400">5 caracteres</strong></span>
  <span class="text-emerald-400 font-bold">Byte centinela nulo</span>
  </div>
</div>
<!--
Comencemos revisando la forma en que representamos cadenas en bajo nivel.

[click] La primera alternativa son las cadenas de longitud fija, donde reservamos un espacio constante y rellenamos los sobrantes.

[click] La segunda alternativa, y la más extendida, son las cadenas de longitud variable terminadas en nulo, también conocidas como cadenas ASCIIZ.

[click] Observemos en este mapa de memoria cómo cada letra ocupa exactamente un byte y la secuencia finaliza con el valor hexadecimal cero.

[click] Un aspecto vital es que las instrucciones de cadenas no se limitan a texto, sino que funcionan para manipular cualquier bloque continuo de memoria como arreglos numéricos o estructuras de datos.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Registros dedicados en cadenas

<div class="text-[11px] text-gray-300 mb-1.5">
La arquitectura IA-32 asigna roles específicos para operaciones de bloque:
</div>
<div class="space-y-1 text-xs font-mono">
<div v-click="1" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg flex justify-between items-center">
  <span class="text-cyan-400 font-bold text-[11px]">ESI</span>
  <span class="text-gray-300 font-sans text-[10px]">Índice origen (memoria fuente)</span>
</div>
<div v-click="2" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg flex justify-between items-center">
  <span class="text-emerald-400 font-bold text-[11px]">EDI</span>
  <span class="text-gray-300 font-sans text-[10px]">Índice destino (memoria diana)</span>
</div>
<div v-click="3" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg flex justify-between items-center">
  <span class="text-amber-400 font-bold text-[11px]">ECX</span>
  <span class="text-gray-300 font-sans text-[10px]">Contador de repeticiones</span>
</div>
<div v-click="4" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg flex justify-between items-center">
  <span class="text-rose-400 font-bold text-[11px]">AL / EAX</span>
  <span class="text-gray-300 font-sans text-[10px]">Acumulador de datos</span>
</div>
</div>

::right::

<div class="space-y-1.5 text-xs">
<div v-click="5" class="p-2 bg-gray-900/80 border border-gray-800 rounded-xl font-mono">
  <div class="text-blue-400 font-bold mb-1 text-center font-sans text-[10.5px]">Sufijos por tamaño de operando</div>
  <table class="w-full text-left border-collapse text-[10px]">
  <thead>
  <tr class="text-gray-400 border-b border-gray-700">
  <th class="p-0.5">Sufijo</th>
  <th class="p-0.5 font-sans">Tamaño</th>
  <th class="p-0.5">Acumulador</th>
  <th class="p-0.5">Avance</th>
  </tr>
  </thead>
  <tbody class="text-gray-300 text-[9.5px]">
  <tr class="border-b border-gray-800">
  <td class="p-0.5 text-cyan-300 font-bold">B</td>
  <td class="p-0.5 font-sans">Byte (8 bits)</td>
  <td class="p-0.5">AL</td>
  <td class="p-0.5">&plusmn;1 byte</td>
  </tr>
  <tr class="border-b border-gray-800">
  <td class="p-0.5 text-emerald-300 font-bold">W</td>
  <td class="p-0.5 font-sans">Word (16 bits)</td>
  <td class="p-0.5">AX</td>
  <td class="p-0.5">&plusmn;2 bytes</td>
  </tr>
  <tr>
  <td class="p-0.5 text-amber-300 font-bold">D</td>
  <td class="p-0.5 font-sans">DWord (32 bits)</td>
  <td class="p-0.5">EAX</td>
  <td class="p-0.5">&plusmn;4 bytes</td>
  </tr>
  </tbody>
  </table>
</div>
<div v-click="6" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg text-gray-400 font-sans text-[10px]">
  <span class="text-emerald-400 font-bold block">Autoincremento implícito:</span>
  La CPU actualiza automáticamente <i>ESI</i> y <i>EDI</i> según el tamaño y la bandera <i>DF</i>.
</div>
</div>
<!--
Analicemos los registros dedicados en IA-32 para el manejo de cadenas.

[click] El registro ESI actúa como puntero al bloque fuente u origen de los datos.

[click] El registro EDI actúa como puntero al bloque de destino donde escribiremos o compararemos.

[click] El registro ECX sirve de contador automático de repeticiones en las instrucciones iterativas.

[click] Y el registro acumulador, ya sea AL, AX o EAX, almacena el valor transferido o el patrón buscado.

[click] Cada instrucción de cadena posee tres variantes según el tamaño: sufijo B para bytes con avance de un paso, sufijo W para palabras de dos bytes y sufijo D para palabras dobles de cuatro bytes.

[click] Notemos que el hardware se encarga de modificar los punteros en cada iteración de manera automática.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Control de dirección (Bandera DF)

<div class="text-[11px] text-gray-300 mb-1.5">
Determina el sentido de desplazamiento de <i>ESI</i> y <i>EDI</i> en cada ciclo:
</div>
<div class="space-y-1.5 text-xs">
<div v-click="1" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg">
  <div class="flex justify-between font-mono text-emerald-400 font-bold text-[10.5px]">
  <span>CLD (DF = 0)</span>
  <span>Hacia adelante (&rarr;)</span>
  </div>
  <p class="text-gray-400 font-sans text-[9.5px]">
    Incrementa punteros hacia direcciones crecientes (+1, +2, +4).
  </p>
</div>
<div v-click="2" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg">
  <div class="flex justify-between font-mono text-rose-400 font-bold text-[10.5px]">
  <span>STD (DF = 1)</span>
  <span>Hacia atrás (&larr;)</span>
  </div>
  <p class="text-gray-400 font-sans text-[9.5px]">
    Decrementa punteros hacia direcciones menores (-1, -2, -4).
  </p>
</div>
</div>

::right::

<div v-click="3" class="bg-gray-900/90 border border-gray-800 rounded-xl p-2 text-xs text-center">
  <div class="text-amber-400 font-bold mb-1 text-[10.5px]">Dirección de recorrido en memoria</div>
  <div class="grid grid-cols-4 gap-1 font-mono text-[9px] my-1">
  <div class="bg-gray-800 p-0.5 rounded text-gray-300">0x100</div>
  <div class="bg-gray-800 p-0.5 rounded text-gray-300">0x101</div>
  <div class="bg-gray-800 p-0.5 rounded text-gray-300">0x102</div>
  <div class="bg-gray-800 p-0.5 rounded text-gray-300">0x103</div>
  </div>
  <div class="space-y-1 mt-1 font-sans text-[9.5px]">
  <div class="p-1 bg-emerald-950/40 border border-emerald-800 rounded flex justify-between items-center text-emerald-300">
  <span><strong>CLD:</strong> Avance a la derecha</span>
  <span class="font-bold">&rarr; (+1)</span>
  </div>
  <div class="p-1 bg-rose-950/40 border border-rose-800 rounded flex justify-between items-center text-rose-300">
  <span><strong>STD:</strong> Retroceso a la izquierda</span>
  <span class="font-bold">&larr; (-1)</span>
  </div>
  </div>
</div>
<!--
Estudiemos la bandera de dirección y su control en ensamblador.

[click] La instrucción cld limpia la bandera estableciendo DF en cero. Esto provoca que ESI y EDI avancen hacia adelante incrementando sus direcciones de memoria.

[click] La instrucción std establece la bandera en uno. Esto hace que los punteros retrocedan hacia direcciones de memoria inferiores.

[click] En el diagrama observamos con claridad la dirección del flujo de datos en ambos escenarios.

[click] Una regla indispensable de buena práctica es ejecutar siempre la instrucción cld antes de cualquier rutina de cadenas para evitar comportamientos imprevistos.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Transferencia: LODS, STOS y MOVS

<div class="text-[11px] text-gray-300 mb-1.5">
Operaciones de movimiento entre memoria y registros:
</div>
<div class="space-y-1 text-xs font-mono">
<div v-click="1" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg">
  <span class="text-cyan-400 font-bold font-sans text-[10.5px]">LODS (Load):</span>
  <p class="text-gray-300 font-sans text-[9.5px]">Carga <i>[ESI]</i> en <i>AL/EAX</i> y actualiza <i>ESI</i>.</p>
</div>
<div v-click="2" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg">
  <span class="text-emerald-400 font-bold font-sans text-[10.5px]">STOS (Store):</span>
  <p class="text-gray-300 font-sans text-[9.5px]">Escribe <i>AL/EAX</i> en <i>[EDI]</i> y actualiza <i>EDI</i>.</p>
</div>
<div v-click="3" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg">
  <span class="text-amber-400 font-bold font-sans text-[10.5px]">MOVS (Move):</span>
  <p class="text-gray-300 font-sans text-[9.5px]">Copia <i>[ESI] &rarr; [EDI]</i> directamente.</p>
</div>
</div>

::right::

<div v-click="4" class="bg-gray-900/90 border border-gray-800 rounded-xl p-2.5 text-xs font-mono">
  <div class="text-blue-400 font-bold mb-1 text-center font-sans text-[10.5px]">Rutas de transferencia</div>
  <div class="space-y-1.5 text-[9.5px]">
  <div class="p-1.5 bg-cyan-950/30 border border-cyan-800 rounded flex justify-between items-center">
  <span class="text-cyan-300 font-bold font-sans">LODSB:</span>
  <span>[ESI] &rarr; AL</span>
  <span class="text-gray-400 font-sans text-[8.5px]">ESI &plusmn;1</span>
  </div>
  <div class="p-1.5 bg-emerald-950/30 border border-emerald-800 rounded flex justify-between items-center">
  <span class="text-emerald-300 font-bold font-sans">STOSB:</span>
  <span>AL &rarr; [EDI]</span>
  <span class="text-gray-400 font-sans text-[8.5px]">EDI &plusmn;1</span>
  </div>
  <div class="p-1.5 bg-amber-950/30 border border-amber-800 rounded flex justify-between items-center">
  <span class="text-amber-300 font-bold font-sans">MOVSB:</span>
  <span>[ESI] &rarr; [EDI]</span>
  <span class="text-gray-400 font-sans text-[8.5px]">Ambos &plusmn;1</span>
  </div>
  </div>
</div>
<!--
Veamos las tres instrucciones fundamentales para mover información en memoria.

[click] LODSB carga en el acumulador el byte apuntado por ESI y desplaza dicho puntero al siguiente byte.

[click] STOSB toma el valor actual del acumulador y lo deposita en la dirección apuntada por EDI, avanzando este último.

[click] MOVSB combina ambas tareas transfiriendo el byte directamente desde la dirección origen ESI hacia la dirección destino EDI en un solo paso y actualizando ambos punteros a la vez.

[click] Notemos en este resumen cómo actúa cada instrucción sobre los registros y la memoria.

[click] La instrucción MOVSB es sumamente rápida porque realiza la transferencia de memoria a memoria de forma optimizada por microcódigo.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Inspección: CMPS y SCAS

<div class="text-[11px] text-gray-300 mb-1.5">
Comparación de bloques y búsqueda de patrones actualizando banderas:
</div>
<div class="space-y-1.5 text-xs font-mono">
<div v-click="1" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
  <div class="text-purple-400 font-bold font-sans text-[10.5px]">CMPS (Compare String)</div>
  <p class="text-gray-300 font-sans text-[10px]">
    Resta <i>[ESI] - [EDI]</i> y actualiza <i>ZF</i>, <i>CF</i> sin alterar la memoria.
  </p>
</div>
<div v-click="2" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
  <div class="text-emerald-400 font-bold font-sans text-[10.5px]">SCAS (Scan String)</div>
  <p class="text-gray-300 font-sans text-[10px]">
    Resta <i>AL - [EDI]</i> y actualiza banderas para hallar un carácter diana.
  </p>
</div>
</div>

::right::

<div v-click="3" class="bg-gray-900/90 border border-gray-800 rounded-xl p-2.5 text-xs">
  <div class="text-cyan-400 font-bold mb-1 text-center font-sans text-[10.5px]">Resultado en bandera ZF</div>
  <div class="space-y-1.5 text-[9.5px]">
  <div class="p-1.5 bg-purple-950/30 border border-purple-800 rounded">
  <div class="text-purple-300 font-bold font-mono mb-0.5">CMPSB: [ESI] vs [EDI]</div>
  <div class="flex justify-around font-mono text-[8.5px]">
  <span class="text-emerald-300">Iguales: <i>ZF = 1</i></span>
  <span class="text-rose-300">Distintos: <i>ZF = 0</i></span>
  </div>
  </div>
  <div class="p-1.5 bg-emerald-950/30 border border-emerald-800 rounded">
  <div class="text-emerald-300 font-bold font-mono mb-0.5">SCASB: AL vs [EDI]</div>
  <div class="flex justify-around font-mono text-[8.5px]">
  <span class="text-emerald-300">Encontrado: <i>ZF = 1</i></span>
  <span class="text-gray-400">No hallado: <i>ZF = 0</i></span>
  </div>
  </div>
  </div>
</div>
<!--
Analicemos ahora las instrucciones para comparar y buscar en memoria.

[click] CMPSB compara el byte de la fuente apuntado por ESI contra el byte del destino apuntado por EDI mediante una resta interna, actualizando las banderas como ZF y CF antes de desplazar ambos punteros.

[click] SCASB compara el valor que tenemos en el acumulador AL contra el byte en la dirección EDI. Es la instrucción predilecta para buscar caracteres en una cadena.

[click] Observemos cómo la bandera ZF se pone en uno cuando los elementos son iguales y en cero cuando difieren.

[click] Esta bandera de cero será evaluada en cada iteración cuando combinemos estas instrucciones con los prefijos de repetición condicional.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Prefijo incondicional: REP

<div class="text-[11px] text-gray-300 mb-1.5">
Repite la instrucción iterativamente mientras <i>ECX &gt; 0</i>:
</div>
<div class="space-y-1.5 text-xs">
<div v-click="1" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
  <span class="text-blue-400 font-bold font-mono text-[10.5px]">REP MOVSB:</span>
  <p class="text-gray-300 font-sans text-[10px]">Copia <i>ECX</i> bytes desde <i>ESI</i> a <i>EDI</i> en hardware.</p>
</div>
<div v-click="2" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
  <span class="text-emerald-400 font-bold font-mono text-[10.5px]">REP STOSB:</span>
  <p class="text-gray-300 font-sans text-[10px]">Rellena <i>ECX</i> bytes en <i>EDI</i> con el valor en <i>AL</i>.</p>
</div>
</div>

::right::

<div v-click="3" class="bg-gray-900/90 border border-gray-800 rounded-xl p-2.5 text-xs">
  <div class="text-amber-400 font-bold mb-1 text-center font-sans text-[10.5px]">Lógica del microcódigo REP</div>
  <div class="space-y-1 text-[9.5px] font-sans">
  <div class="p-1 bg-gray-950/80 border border-gray-800 rounded flex justify-between font-mono">
  <span class="text-amber-300">Condición:</span>
  <span>¿ECX &gt; 0?</span>
  </div>
  <div class="p-1 bg-blue-950/30 border border-blue-800 rounded flex justify-between font-mono">
  <span class="text-blue-300">Operación:</span>
  <span>Ejecutar instrucción</span>
  </div>
  <div class="p-1 bg-purple-950/30 border border-purple-800 rounded flex justify-between font-mono">
  <span class="text-purple-300">Paso:</span>
  <span><i>ECX = ECX - 1</i></span>
  </div>
  <div class="p-1 bg-emerald-950/30 border border-emerald-800 rounded flex justify-between font-mono">
  <span class="text-emerald-300">Salida:</span>
  <span>Al llegar a <i>ECX = 0</i></span>
  </div>
  </div>
</div>
<!--
Veamos el prefijo de repetición incondicional REP.

[click] Al anteponer REP a MOVSB, el procesador transfiere tantos bytes como indique el registro ECX, decrementando dicho contador hasta llegar a cero.

[click] Si lo usamos con STOSB, rellenamos rápidamente un área de memoria con un valor fijo, equivalente a la función memset de C.

[click] Apreciemos el flujo interno ejecutado por la unidad de control en este diagrama de estados.

[click] Este mecanismo es órdenes de magnitud más veloz que escribir un bucle manual con saltos, ya que la iteración ocurre directamente en el microcódigo del chip.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Prefijos condicionales: REPE y REPNE

<div class="text-[11px] text-gray-300 mb-1.5">
Evalúan simultáneamente el contador <i>ECX</i> y la bandera <i>ZF</i>:
</div>
<div class="space-y-1.5 text-xs">
<div v-click="1" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
  <div class="flex justify-between font-mono text-emerald-400 font-bold text-[10.5px]">
  <span>REPE / REPZ</span>
  <span>Mientras sea igual (<i>ZF = 1</i>)</span>
  </div>
  <p class="text-gray-300 font-sans text-[10px]">Para si <i>ECX = 0</i> o al detectar la primera diferencia (<i>ZF = 0</i>).</p>
</div>
<div v-click="2" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
  <div class="flex justify-between font-mono text-rose-400 font-bold text-[10.5px]">
  <span>REPNE / REPNZ</span>
  <span>Mientras difiera (<i>ZF = 0</i>)</span>
  </div>
  <p class="text-gray-300 font-sans text-[10px]">Para si <i>ECX = 0</i> o al hallar coincidencia (<i>ZF = 1</i>).</p>
</div>
</div>

::right::

<div class="space-y-1.5 font-mono text-xs">
<div v-click="3" class="p-2 bg-gray-900/80 border border-gray-800 rounded-xl">
  <div class="text-blue-400 font-bold mb-1 font-sans text-center text-[10.5px]">Casos de uso canónicos</div>
  <table class="w-full text-left border-collapse text-[9.5px]">
  <thead>
  <tr class="text-gray-400 border-b border-gray-700">
  <th class="p-0.5">Instrucción</th>
  <th class="p-0.5 font-sans">Uso estándar</th>
  </tr>
  </thead>
  <tbody class="text-gray-300 text-[9px]">
  <tr class="border-b border-gray-800">
  <td class="p-0.5 text-emerald-300 font-bold">REPE CMPSB</td>
  <td class="p-0.5 font-sans">Comparar cadenas (<i>strcmp</i>)</td>
  </tr>
  <tr>
  <td class="p-0.5 text-rose-300 font-bold">REPNE SCASB</td>
  <td class="p-0.5 font-sans">Buscar nulo o carácter (<i>strlen</i>)</td>
  </tr>
  </tbody>
  </table>
</div>
<div v-click="4" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg text-gray-400 font-sans text-[10px]">
  <span class="text-amber-400 font-bold">Sinónimos:</span>
  <i>REPE</i> &equiv; <i>REPZ</i> y <i>REPNE</i> &equiv; <i>REPNZ</i> comparten el mismo código de máquina.
</div>
</div>
<!--
Llegamos a los prefijos condicionales, uno de los temas más evaluados en el curso.

[click] REPE o REPZ repite la operación mientras los datos comparados sean idénticos, es decir, mientras la bandera ZF permanezca en uno. En el instante en que detecta una diferencia, la instrucción finaliza de inmediato.

[click] Por el contrario, REPNE o REPNZ repite la operación mientras no haya coincidencia, o sea mientras ZF sea cero. Se detiene tan pronto encuentra el elemento buscado.

[click] En esta tabla resumimos los dos grandes casos de uso: comparar dos cadenas completas con REPE CMPSB y buscar el carácter de fin de cadena con REPNE SCASB.

[click] Tengamos en cuenta que REPE y REPZ generan exactamente el mismo byte de instrucción en la máquina.
-->

---
transition: fade
---

# Síntesis de la primera sesión

<div class="max-w-xl mx-auto text-left space-y-2.5 text-xs">
  <div class="p-2.5 bg-gray-900/80 border border-gray-800 rounded-lg">
  <strong class="text-emerald-400 font-mono">1. Punteros y dirección:</strong>
  <p class="text-gray-300 mt-0.5 text-[11px]">
  <i>ESI</i> y <i>EDI</i> apuntan a origen y destino. La instrucción <i>CLD</i> garantiza avance ascendente y <i>STD</i> retroceso.
  </p>
  </div>
  <div class="p-2.5 bg-gray-900/80 border border-gray-800 rounded-lg">
  <strong class="text-cyan-400 font-mono">2. Cinco nemónicos clave:</strong>
  <p class="text-gray-300 mt-0.5 text-[11px]">
  <i>LODS</i>, <i>STOS</i>, <i>MOVS</i>, <i>CMPS</i> y <i>SCAS</i> operan sobre bytes, palabras y dobles palabras de memoria.
  </p>
  </div>
  <div v-click="1" class="p-2.5 bg-gray-900/80 border border-gray-800 rounded-lg">
  <strong class="text-amber-400 font-mono">3. Pregunta detonante para el taller:</strong>
  <p class="text-gray-300 mt-0.5 text-[11px] italic">
      Si <i>REPNE SCASB</i> decrementa <i>ECX</i> en cada byte inspeccionado, ¿cómo calculamos con exactitud matemática la longitud de la cadena al hallar el byte nulo?
  </p>
  </div>
</div>
<!--
Con esto concluimos la primera sesión teórica. Hemos cubierto los registros especializados, el sentido de avance con la bandera DF y los prefijos de repetición.

[click] Les dejo esta pregunta detonante para reflexionar antes del taller práctico: ¿cómo convertimos el valor residual de ECX en la longitud exacta de la cadena usando operaciones lógicas?
-->

---
layout: center
transition: slide-up | slide-down
---

<div class="text-center">
  <div class="text-3xl text-gray-400 mb-4 font-mono">Semana 10</div>
  <h1 class="text-6xl font-bold mb-8">Sesión 02: Taller práctico</h1>
  <div class="text-2xl text-blue-500 mt-4">IC3101: Arquitectura de computadores</div>
</div>
<!--
¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de las instrucciones de cadena y los prefijos de repetición, dedicaremos esta jornada completa a la implementación práctica de rutinas de alto rendimiento.
-->

---
transition: fade
---

# Objetivos de la segunda sesión

<div class="mb-4 text-sm text-gray-300">
Implementar funciones estándar de memoria en lenguaje ensamblador de alto rendimiento:
</div>
<v-clicks>

- **Cálculo de longitud de cadena (strlen):** Utilizar <i>REPNE SCASB</i> para escanear memoria hasta el byte centinela <i>0x00</i>.
- **Duplicación masiva de bloques (memcpy y strcpy):** Optimizar transferencias por palabras dobles con <i>REP MOVSD</i> y <i>MOVSB</i>.
- **Inicialización de memoria (memset):** Rellenar rápidamente buffers con patrones de bytes mediante <i>REP STOSB</i>.
- **Comparación léxica de textos (strcmp):** Evaluar igualdad y orden lexicográfico con <i>REPE CMPSB</i>.
- **Análisis de eficiencia y caché:** Comparar la densidad y velocidad de las instrucciones de bloque frente a bucles manuales.

</v-clicks>
<!--
Antes de iniciar los ejercicios, repasemos los objetivos de esta segunda sesión práctica:

[click] Primero, implementaremos la función strlen utilizando el prefijo REPNE SCASB para buscar el fin de cadena.

[click] Segundo, construiremos una rutina de copia de memoria optimizada por palabras dobles de 32 bits.

[click] Tercero, aprenderemos a inicializar buffers de forma instantánea con REP STOSB.

[click] Cuarto, implementaremos la comparación de textos con REPE CMPSB detectando discrepancias.

[click] Y quinto, analizaremos por qué estas instrucciones en microcódigo superan ampliamente a los bucles tradicionales con saltos.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Taller 1: Longitud de cadena (strlen)

<div class="text-[11px] text-gray-300 mb-1">
Búsqueda del byte nulo <i>0x00</i> con <i>REPNE SCASB</i>:
</div>
<div class="font-mono text-[9px]">

```asm {1-4|6|8-10|all}
; Entrada: EDI = inicio de cadena
; Salida:  EAX = longitud

strlen_opt:
  cld                 ; DF = 0 (adelante)
  mov ecx, -1         ; ECX = 0xFFFFFFFF
  xor al, al          ; AL = 0x00 (buscar)

  repne scasb         ; Escanear hasta 0x00

  not ecx             ; Invertir bits
  dec ecx             ; Descontar byte nulo
  mov eax, ecx        ; Retornar longitud
  ret
```

</div>

::right::

<div class="space-y-1.5 font-mono text-xs">
<div v-click="1" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg font-sans text-xs">
  <span class="text-cyan-400 font-bold block text-[10.5px]">Inicialización en -1:</span>
  <p class="text-gray-300 text-[10px]">Evita que <i>ECX</i> agote su cuenta antes de topar el nulo.</p>
</div>
<div v-click="2" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg font-sans text-xs">
  <span class="text-amber-400 font-bold block text-[10.5px]">Criterio de parada:</span>
  <p class="text-gray-300 text-[10px]">Al hallar <i>0x00</i>, <i>ZF = 1</i> y <i>REPNE</i> se detiene.</p>
</div>
<div v-click="3" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg font-sans text-xs">
  <span class="text-emerald-400 font-bold block text-[10.5px]">Cálculo matemático:</span>
  <p class="text-gray-300 text-[10px]"><span class="font-mono font-bold text-emerald-300">Longitud = NOT(ECX) - 1</span></p>
</div>
</div>
<!--
Analicemos la implementación clásica de strlen con instrucciones de bloque.

[click] Primero aseguramos la dirección con cld, colocamos ECX en menos uno y limpiamos AL con xor al, al.

[click] Al ejecutar repne scasb, el procesador escanea la memoria a máxima velocidad hasta hallar el byte cero.

[click] Notemos este truco matemático: al aplicar la instrucción NOT sobre ECX y decrementar una unidad, obtenemos con precisión matemática el número exacto de caracteres de la cadena.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Taller 2: Copia de memoria (memcpy)

<div class="text-[11px] text-gray-300 mb-1">
Transferencia por palabras dobles de 32 bits (4 bytes/ciclo):
</div>
<div class="font-mono text-[9px]">

```asm {1-4|6-7|9-11|all}
; Entrada: ESI = origen, EDI = destino, ECX = bytes

memcpy_opt:
  cld                 ; Dirección hacia adelante
  push ecx            ; Preservar total

  ; Copiar dwords (4 bytes por paso)
  shr ecx, 2          ; ECX = dwords
  rep movsd           ; Transferir dwords

  ; Copiar bytes remanentes
  pop ecx             ; Restaurar total
  and ecx, 3          ; ECX = residuo (0..3)
  rep movsb           ; Transferir sobrantes

  ret
```

</div>

::right::

<div class="space-y-1.5 text-xs">
<div v-click="1" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
  <span class="text-emerald-400 font-bold font-mono text-[10.5px] block">Transferencia por dwords:</span>
  <p class="text-gray-300 font-sans text-[10px]"><i>MOVSD</i> cuadruplica el ancho de banda transferido por ciclo de bus (4&times;).</p>
</div>
<div v-click="2" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
  <span class="text-blue-400 font-bold font-mono text-[10.5px] block">Manejo de remanentes:</span>
  <p class="text-gray-300 font-sans text-[10px]"><i>and ecx, 3</i> extrae los bytes finales (0 &le; r &le; 3) para copiarlos con <i>MOVSB</i>.</p>
</div>
</div>
<!--
Veamos ahora una optimización profesional para copiar memoria equivalente a la función memcpy.

[click] En lugar de copiar byte por byte con MOVSB, dividimos ECX entre cuatro con shr ecx, 2 y transferimos de cuatro en cuatro bytes usando rep movsd.

[click] Luego recuperamos el residuo con and ecx, 3 y copiamos los bytes sobrantes con rep movsb.

Esta técnica maximiza el ancho de banda del bus de datos de la máquina.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Taller 3: Inicialización (memset)

<div class="text-[11px] text-gray-300 mb-1">
Relleno masivo de memoria con valor uniforme mediante <i>REP STOSB</i>:
</div>
<div class="font-mono text-[9px]">

```asm {1-4|6-10|all}
; Entrada: EDI = buffer, AL = valor, ECX = bytes

memset_opt:
  cld
  rep stosb           ; Escribir AL en [EDI]
  ret

; Ejemplo: limpiar 256 bytes con ceros
limpiar_tabla:
  mov edi, tabla
  xor al, al          ; AL = 0x00
  mov ecx, 256
  call memset_opt
```

</div>

::right::

<div v-click="1" class="bg-gray-900/90 border border-gray-800 rounded-xl p-2.5 text-xs text-center font-mono">
  <div class="text-emerald-400 font-bold mb-1 font-sans text-[10.5px]">Efecto en memoria (REP STOSB)</div>
  <div class="mb-1">
  <div class="text-[8.5px] text-gray-400 mb-0.5 font-sans">Datos previos:</div>
  <div class="grid grid-cols-4 gap-1 text-[9px]">
  <div class="bg-gray-800 p-1 rounded text-gray-400">0xA3</div>
  <div class="bg-gray-800 p-1 rounded text-gray-400">0x5F</div>
  <div class="bg-gray-800 p-1 rounded text-gray-400">0x12</div>
  <div class="bg-gray-800 p-1 rounded text-gray-400">0x8B</div>
  </div>
  </div>
  <div class="text-emerald-400 text-[9.5px] my-0.5 font-bold">&darr; Relleno con AL = 0x00 &darr;</div>
  <div>
  <div class="text-[8.5px] text-gray-400 mb-0.5 font-sans">Memoria limpia:</div>
  <div class="grid grid-cols-4 gap-1 text-[9px]">
  <div class="bg-emerald-950/60 border border-emerald-600 p-1 rounded text-emerald-300 font-bold">0x00</div>
  <div class="bg-emerald-950/60 border border-emerald-600 p-1 rounded text-emerald-300 font-bold">0x00</div>
  <div class="bg-emerald-950/60 border border-emerald-600 p-1 rounded text-emerald-300 font-bold">0x00</div>
  <div class="bg-emerald-950/60 border border-emerald-600 p-1 rounded text-emerald-300 font-bold">0x00</div>
  </div>
  </div>
</div>
<!--
Examinemos cómo inicializar memoria de forma ultrarrápida con REP STOSB.

[click] Con solo configurar EDI con el puntero al buffer, AL con el byte deseado y ECX con la longitud, la instrucción rep stosb escribe en memoria en cada ciclo de reloj.

[click] Apreciemos en el gráfico cómo cada celda se llena uniformemente con ceros mientras EDI avanza hacia el final del bloque.

Esta es la rutina que utilizan los sistemas operativos para limpiar buffers de memoria antes de entregarlos a un proceso de usuario.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Taller 4: Comparación léxica (strcmp)

<div class="text-[11px] text-gray-300 mb-1">
Comparación byte a byte hasta hallar discrepancia con <i>REPE CMPSB</i>:
</div>
<div class="font-mono text-[8.5px]">

```asm {1-4|6-7|9-11|14-16|all}
; Entrada: ESI = s1, EDI = s2, ECX = max
; Salida:  EAX = 0 (iguales), EAX != 0 (diferencia)

strcmp_opt:
  cld
  repe cmpsb          ; Comparar mientras iguales
  je cadenas_iguales  ; Si ZF = 1 -> son idénticas

  ; Si hubo diferencia:
  movzx eax, byte [esi - 1]
  movzx edx, byte [edi - 1]
  sub eax, edx        ; Retornar s1[k] - s2[k]
  ret

cadenas_iguales:
  xor eax, eax
  ret
```

</div>

::right::

<div class="space-y-1.5 text-xs">
<div v-click="1" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
  <span class="text-rose-400 font-bold font-mono text-[10.5px] block">Ajuste de puntero (-1):</span>
  <p class="text-gray-300 font-sans text-[10px]">
  <i>CMPSB</i> incrementa antes de parar. Por ello leemos en <i>[esi - 1]</i> y <i>[edi - 1]</i>.
  </p>
</div>
<div v-click="2" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
  <span class="text-emerald-400 font-bold font-mono text-[10.5px] block">Comprobación con je:</span>
  <p class="text-gray-300 font-sans text-[10px]">
    Si <i>ZF = 1</i>, el bucle concluyó sin discrepancias y retorna cero (<i>EAX = 0</i>).
  </p>
</div>
</div>
<!--
Analicemos la función strcmp con REPE CMPSB.

[click] Al ejecutar repe cmpsb, el procesador compara byte a byte ambas cadenas. Si son idénticas en todas sus posiciones, el bucle concluye con la bandera ZF en uno y saltamos a cadenas_iguales retornando cero.

[click] Si se detecta una diferencia, el prefijo se detiene inmediatamente. Un detalle crítico es que como los punteros ya avanzaron una posición, debemos leer en esi menos uno y edi menos uno para restar los caracteres y determinar cuál cadena es léxicamente mayor.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Rendimiento: Bloques vs bucles

<div class="text-[11px] text-gray-300 mb-1">
Comparativa de rendimiento y eficiencia en caché:
</div>
<div class="font-mono text-[8.5px]">

```asm
; Bucle manual con saltos:
bucle_copia:
  mov al, [esi]
  mov [edi], al
  inc esi
  inc edi
  dec ecx
  jnz bucle_copia     ; Penalización por salto

; Instrucción de bloque:
cld
rep movsb             ; En microcódigo de CPU
```

</div>

::right::

<div class="space-y-1.5 text-xs">
<div v-click="1" class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
  <div class="text-emerald-400 font-bold text-[10.5px] mb-0.5">Ventajas de instrucciones de bloque:</div>
  <ul class="space-y-0.5 text-gray-300 font-sans text-[10px]">
  <li>&bull; Decodificación única sin salto repetido</li>
  <li>&bull; Ráfagas continuas en bus de memoria</li>
  <li>&bull; Cero fallos de predicción de saltos</li>
  </ul>
</div>
<div v-click="2" class="p-1.5 bg-gray-900/60 border border-gray-800 rounded-lg text-gray-300 font-sans text-[10px]">
  <span class="text-amber-400 font-bold block">Densidad de código:</span>
  Una sola instrucción de 2 bytes reemplaza 6 instrucciones ahorrando espacio en caché L1.
</div>
</div>
<!--
Comparemos el rendimiento entre ambas alternativas.

En la columna izquierda vemos el bucle tradicional: lectura, escritura, incrementos, decremento y salto condicional con riesgo de fallo de predicción.

[click] Con REP MOVSB eliminamos toda esa sobrecarga. La decodificación ocurre una sola vez y el procesador ejecuta la copia continua a velocidad de hardware.

[click] Además de ganar velocidad, el código binario es mucho más compacto y no satura la memoria caché del procesador.
-->

---
transition: fade
---

# Mini-quiz formativo (Sesión 2)

<div class="space-y-2 mt-3 text-xs">
<div class="p-2.5 bg-gray-900/60 border border-gray-800 rounded-xl">
  <strong class="text-blue-400 text-[11px]">1. ¿Qué instrucción asegura que ESI y EDI se incrementen hacia adelante?</strong>
  <p class="text-gray-300 mt-0.5 font-mono text-[10px]">
    A) STD &nbsp;&nbsp;&nbsp; B) CLD &nbsp;&nbsp;&nbsp; C) REP &nbsp;&nbsp;&nbsp; D) INC
  </p>
  <div v-click="1" class="text-emerald-400 mt-0.5 text-[10px] font-sans font-bold">
    &rarr; Respuesta correcta: B) CLD limpia la bandera de dirección (<i>DF = 0</i>) habilitando el incremento.
  </div>
</div>
<div class="p-2.5 bg-gray-900/60 border border-gray-800 rounded-xl">
  <strong class="text-amber-400 text-[11px]">2. ¿En qué condición se detiene la ejecución de REPE CMPSB?</strong>
  <p class="text-gray-300 mt-0.5 font-sans text-[10px]">
    A) Cuando <i>ECX</i> llega a cero o cuando <i>ZF</i> pasa a cero &nbsp;&nbsp;&nbsp; B) Solo cuando <i>ECX</i> es cero &nbsp;&nbsp;&nbsp; C) Cuando <i>ZF</i> es uno
  </p>
  <div v-click="2" class="text-emerald-400 mt-0.5 text-[10px] font-sans font-bold">
    &rarr; Respuesta correcta: A) Se detiene cuando se agota <i>ECX</i> o al hallar la primera diferencia (<i>ZF = 0</i>).
  </div>
</div>
<div class="p-2.5 bg-gray-900/60 border border-gray-800 rounded-xl">
  <strong class="text-purple-400 text-[11px]">3. ¿Cuál opción es más rápida para inicializar enteros de 32 bits con ceros?</strong>
  <p class="text-gray-300 mt-0.5 font-mono text-[10px]">
    A) REP MOVSB &nbsp;&nbsp;&nbsp; B) REPNE SCASB &nbsp;&nbsp;&nbsp; C) REP STOSD con EAX = 0
  </p>
  <div v-click="3" class="text-emerald-400 mt-0.5 text-[10px] font-sans font-bold">
    &rarr; Respuesta correcta: C) REP STOSD escribe 4 bytes por ciclo de bus a máxima velocidad.
  </div>
</div>
</div>
<!--
Pongamos a prueba lo aprendido con este mini-quiz de cierre.

Pregunta uno: ¿Qué instrucción asegura que los punteros avancen hacia adelante?
[click] Correcto, la instrucción CLD.

Pregunta dos: ¿Cuándo se detiene el prefijo REPE CMPSB?
[click] Exacto, cuando ECX llega a cero o cuando se encuentra la primera diferencia con ZF en cero.

Pregunta tres: ¿Cuál es la forma más rápida de inicializar un arreglo de enteros con ceros?
[click] Muy bien, REP STOSD utilizando el registro EAX con valor cero.
-->

---
layout: center
transition: fade
---

<div class="text-center max-w-xl mx-auto">
  <h1 class="text-3xl font-bold mb-3 text-white">Conclusiones integradoras</h1>
  <div class="p-3.5 bg-gray-900/60 border border-gray-800 rounded-xl text-left text-xs text-gray-300 space-y-1.5 mt-3">
  <p>
      &bull; Las instrucciones de manipulación de bloques de memoria aprovechan al máximo los registros <i>ESI</i>, <i>EDI</i> y <i>ECX</i> junto con la bandera <i>DF</i>.
  </p>
  <p>
      &bull; Los prefijos de repetición <i>REP</i>, <i>REPZ</i> y <i>REPNZ</i> permiten implementar algoritmos esenciales como <i>strlen</i>, <i>memcpy</i> y <i>strcmp</i> con rendimiento superior a cualquier bucle manual.
  </p>
  <p>
      &bull; Estos conocimientos son la base técnica imprescindible para el <strong>Proyecto de Ensamblador</strong> del curso.
  </p>
  </div>
  <div class="text-blue-400 font-semibold mt-3 text-xs">
    ¡Muchas gracias por su dedicación y éxito en sus prácticas!
  </div>
</div>
<!--
Con esto concluimos la décima semana de tutorías.

Hemos dominado una de las facetas más potentes del ensamblador x86: las instrucciones de cadena y los prefijos de repetición condicional.

Estas técnicas les permitirán escribir código sumamente eficiente y elegante tanto para sus tareas como para el proyecto del curso.

¡Muchas gracias a todos por su participación y nos vemos en la próxima sesión!
-->
