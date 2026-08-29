---
theme: default
layout: center
transition: slide-left | slide-right
addons:
  - slidev-component-zoom
---

<div class="text-center">
  <div class="text-3xl text-gray-400 mb-4">Semana 04</div>
  <h1 class="text-6xl font-bold mb-8">Multiplicación, división y punto flotante</h1>
  <div class="text-2xl text-blue-500 mt-4">IC3101: Arquitectura de computadores</div>
</div>
<!--
¡Hola a todos! Bienvenidos a la cuarta semana de tutorías de Arquitectura de Computadores.

En las sesiones anteriores dominamos la representación de enteros en complemento a dos y el diseño básico de la ALU para sumas, restas y operaciones lógicas.

Hoy daremos un salto fundamental hacia operaciones más complejas, estudiando cómo el hardware realiza multiplicaciones y divisiones eficientes, y analizando en profundidad el estándar IEEE 754 para números en punto flotante.
-->

---
transition: fade
---

# Objetivos de la primera sesión

<div class="mb-4 text-sm text-gray-300">
Comprender los fundamentos y diseño de algoritmos de hardware para aritmética avanzada:
</div>
<v-clicks>

- **Multiplicación de enteros sin signo:** Comprender el mecanismo iterativo de sumas y desplazamientos y el rol de los registros combinados.
- **Algoritmo de Booth:** Dominar el tratamiento directo de enteros con signo en complemento a dos mediante recodificación de bits contiguos.
- **División no restauradora:** Analizar la reducción de ciclos frente al método restaurador al posponer correcciones del residuo.
- **Fundamentos de punto flotante:** Entender la motivación de la coma flotante y la descomposición del estándar IEEE 754.
- **Casos especiales y anomalías numéricas:** Identificar desbordamientos, subnormales, infinitos, NaN y errores de absorción y cancelación.

</v-clicks>
<!--
Antes de entrar en detalle, repasemos los objetivos de esta primera sesión teórica:

[click] Primero, entenderemos la multiplicación iterativa sin signo y cómo se gestionan los productos de tamaño doble.

[click] Segundo, analizaremos el algoritmo de Booth para operar directamente números con signo sin necesidad de convertirlos previamente a magnitud positiva.

[click] Tercero, estudiaremos la división en hardware y por qué el enfoque no restaurador optimiza el rendimiento.

[click] Cuarto, entraremos de lleno en la anatomía del estándar IEEE 754 para números en punto flotante de 32 y 64 bits.

[click] Y quinto, analizaremos los estados especiales como NaN e infinitos, y fenómenos críticos como la pérdida de significancia y errores por redondeo.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Multiplicación de enteros sin signo

<div>
La multiplicación binaria en hardware replica el principio de sumas y desplazamientos sucesivos del cálculo manual, operando bit a bit sobre el multiplicador.
</div>
<div v-click="1" class="mt-4 p-3 bg-gray-100 dark:bg-gray-800/80 rounded-lg text-xs font-mono">
<div class="text-blue-400 font-bold mb-1">Ejemplo en base 2:</div>

```text
      1 0 1 1   (11 decimal: Multiplicando)
    x 1 1 0 1   (13 decimal: Multiplicador)
    ---------
      1 0 1 1   (Bit 0 es 1: suma multiplicando)
    0 0 0 0 .   (Bit 1 es 0: solo desplazamiento)
  1 0 1 1 . .   (Bit 2 es 1: suma multiplicando)
1 0 1 1 . . .   (Bit 3 es 1: suma multiplicando)
-------------
1 0 0 0 1 1 1 1 (143 decimal: Producto de 2n bits)
```

</div>

::right::

<div class="mt-12 space-y-3 text-sm">
<div v-click="2" class="p-3 border border-emerald-500/40 bg-emerald-950/20 rounded-lg">
  <strong class="text-emerald-400">Regla de evaluación por ciclo:</strong>
  <p class="text-xs text-gray-300 mt-1">
    Si el bit menos significativo del multiplicador es 1, se suma el multiplicando al acumulador. Si el bit es 0, no se realiza suma alguna.
  </p>
</div>
<div v-click="3" class="p-3 border border-blue-500/40 bg-blue-950/20 rounded-lg">
  <strong class="text-blue-400">Desplazamiento a la derecha:</strong>
  <p class="text-xs text-gray-300 mt-1">
    El acumulador y el multiplicador se desplazan juntos un bit a la derecha tras cada ciclo, permitiendo evaluar el siguiente bit en la siguiente iteración.
  </p>
</div>
<div v-click="4" class="p-3 border border-amber-500/40 bg-amber-950/20 rounded-lg">
  <strong class="text-amber-400">Tamaño del producto:</strong>
  <p class="text-xs text-gray-300 mt-1">
    La multiplicación de dos operandos de <i>n</i> bits produce un resultado que requiere hasta 2<i>n</i> bits para garantizar que no exista desbordamiento.
  </p>
</div>
</div>
<!--
Comencemos revisando la multiplicación básica sin signo. En papel, cuando multiplicamos números binarios, realizamos exactamente la misma lógica que en el sistema decimal.

[click] Observemos el ejemplo en pantalla: si multiplicamos once por trece, examinamos cada bit del multiplicador de derecha a izquierda. Si el bit actual es uno, copiamos el multiplicando desplazado, mientras que si es cero, colocamos ceros, sumando al final los productos parciales.

[click] En hardware no podemos sumar todos los productos parciales al mismo tiempo sin un área enorme de compuertas. Por tanto, el procesador utiliza un acumulador y procesa un bit por ciclo de reloj según la regla que vemos a la derecha.

[click] Tras cada decisión de suma, el acumulador y el multiplicador se desplazan juntos a la derecha para evaluar el siguiente bit en la siguiente iteración.

[click] Noten un detalle clave de diseño: el producto de dos números de n bits ocupa hasta dos n bits. Por esta razón, en arquitecturas como x86, la multiplicación almacena el resultado combinado en dos registros, como EDX y EAX.
-->

---
transition: slide-left | slide-right
---

# Organización del hardware de multiplicación

<div class="grid grid-cols-3 gap-4 my-2 text-xs font-sans">
  <div class="border border-gray-800 bg-gray-900/60 rounded-lg p-3">
  <div class="text-blue-400 font-semibold mb-1">Registro M (Multiplicando)</div>
  <div class="text-gray-400 text-[11px] leading-relaxed">Contiene el multiplicando de <i>n</i> bits de forma constante durante todo el proceso.</div>
  </div>
  <div class="border border-gray-800 bg-gray-900/60 rounded-lg p-3">
  <div class="text-emerald-400 font-semibold mb-1">Registro A (Acumulador)</div>
  <div class="text-gray-400 text-[11px] leading-relaxed">Inicializado en 0. Almacena la parte alta del producto parcial y recibe el resultado del sumador.</div>
  </div>
  <div class="border border-gray-800 bg-gray-900/60 rounded-lg p-3">
  <div class="text-purple-400 font-semibold mb-1">Registro Q (Multiplicador)</div>
  <div class="text-gray-400 text-[11px] leading-relaxed">Almacena el multiplicador de <i>n</i> bits. Al desplazarse, la parte baja del producto entra en este registro.</div>
  </div>
</div>
<div class="border border-gray-800 bg-gray-900/60 rounded-xl p-3 my-3">
  <div class="flex justify-between items-center text-xs text-gray-300 mb-2 font-sans">
  <span class="font-medium">Estructura de registros combinados:</span>
  <span class="text-gray-400 text-[11px]">Registro C (1b) + Registro A (<i>n</i> bits) + Registro Q (<i>n</i> bits)</span>
  </div>
  <div class="grid grid-cols-12 gap-1.5 text-center text-xs font-sans">
  <div class="col-span-1 bg-amber-950/30 border border-amber-800/40 rounded p-2 text-amber-300 font-semibold">C</div>
  <div class="col-span-6 bg-emerald-950/30 border border-emerald-800/40 rounded p-2 text-emerald-200 font-semibold">Acumulador A (<i>n</i> bits)</div>
  <div class="col-span-5 bg-purple-950/30 border border-purple-800/40 rounded p-2 text-purple-200 font-semibold">Multiplicador Q (<i>n</i> bits)</div>
  </div>
  <div class="flex justify-between text-[11px] text-gray-500 mt-2 px-2 font-sans">
  <span>&larr; Acarreo del sumador</span>
  <span class="text-gray-400">&rarr; Desplazamiento lógico conjunto a la derecha &rarr;</span>
  <span>Inspección de <i>Q</i><sub>0</sub> &rarr;</span>
  </div>
</div>
<div v-click="1" class="text-xs text-gray-300 bg-gray-900/80 p-3 rounded-lg border border-gray-800 font-sans">
  <span class="text-gray-100 font-semibold">Ciclo de control:</span> En cada paso, la lógica de control inspecciona el bit <i>Q</i><sub>0</sub>. Si <i>Q</i><sub>0</sub> = 1, la ALU suma <i>A</i> + <i>M</i> y guarda el resultado en <i>C</i> y <i>A</i>. Seguidamente, toda la estructura [<i>C</i>, <i>A</i>, <i>Q</i>] se desplaza un bit a la derecha y el contador de ciclos disminuye en uno.
</div>
<!--
Analicemos la microarquitectura de este multiplicador. 

El hardware consta de tres registros principales: el registro M que retiene el multiplicando, el acumulador A que comienza en cero para almacenar la mitad superior del producto, y el registro Q que contiene inicialmente el multiplicador. Fíjense en cómo se conectan: el bit C retiene el acarreo que pueda generar la suma de n bits.

[click] Al activarse el ciclo de control, en cada iteración la unidad de control mira únicamente el bit menos significativo de Q. Si es uno, activa la ALU para sumar A con M; si es cero, no hace suma. Inmediatamente después, toda la cadena compuesta por C, A y Q se desplaza un bit a la derecha. Tras n ciclos, el producto exacto queda en A y Q.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Multiplicación con enteros con signo

<div>
Cuando los operandos están expresados en complemento a dos, el algoritmo sin signo ordinario falla debido al peso aritmético negativo del bit más significativo.
</div>
<div v-click="1" class="mt-4 p-3 bg-red-950/30 border border-red-800/60 rounded-lg text-xs">
<strong class="text-red-400">Por qué falla el algoritmo directo:</strong>
<p class="text-gray-300 mt-1">
En complemento a dos de 4 bits, el número 1101<sub>2</sub> representa el valor -3, dado que el bit superior tiene peso -2<sup>3</sup> = -8. Si el hardware lo trata como entero sin signo (13), el producto resultante será totalmente incorrecto.
</p>
</div>

::right::

<div class="mt-12 space-y-3 text-xs">
<div v-click="2" class="p-3 bg-gray-800/60 border border-gray-700 rounded-lg">
  <strong class="text-blue-400">Estrategia ingenua:</strong>
  <p class="text-gray-300 mt-1">
    Convertir ambos operandos a magnitudes positivas calculando su complemento a dos previo, multiplicar como enteros sin signo y luego aplicar el signo adecuado al resultado final.
  </p>
</div>
<div v-click="3" class="p-3 bg-amber-950/30 border border-amber-800/60 rounded-lg">
  <strong class="text-amber-400">Desventajas de la estrategia ingenua:</strong>
  <p class="text-gray-300 mt-1">
    Requiere etapas adicionales de comprobación de signo, cálculo de complemento a dos previo y posterior, aumentando la latencia y la complejidad del circuito de control.
  </p>
</div>
<div v-click="4" class="p-3 bg-emerald-950/30 border border-emerald-800/60 rounded-lg">
  <strong class="text-emerald-400">La solución óptima: Algoritmo de Booth</strong>
  <p class="text-gray-300 mt-1">
    Permite operar directamente con números positivos y negativos en complemento a dos sin conversiones preliminares, acelerando además la ejecución mediante recodificación de bits.
  </p>
</div>
</div>
<!--
¿Qué sucede cuando queremos multiplicar números enteros con signo? Si aplicamos el algoritmo anterior a números negativos en complemento a dos, obtendremos un resultado completamente erróneo.

[click] La razón matemática es que en complemento a dos, el bit más significativo no vale dos a la n menos uno positivo, sino menos dos a la n menos uno, teniendo un peso negativo.

[click] Una primera idea sería la estrategia ingenua: calcular el valor absoluto de ambos números, multiplicarlos como enteros sin signo, y luego aplicar el signo al resultado.

[click] Sin embargo, esto resulta costoso en hardware porque exige pasos adicionales de conversión antes y después de la multiplicación.

[click] Por ello, la solución óptima es el algoritmo de Booth, que opera directamente con números en complemento a dos sin conversiones y optimiza la cantidad de operaciones requeridas.
-->

---
transition: slide-up | slide-down
---

# Fundamento del algoritmo de Booth

<div class="text-sm mb-3">
El algoritmo de Booth se fundamenta en que una secuencia continua de unos binarios puede reemplazarse por una única resta en el inicio del bloque y una única suma al final del bloque.
</div>
<div class="grid grid-cols-2 gap-4 my-2 text-xs">
  <div class="border border-blue-500/50 bg-blue-950/30 rounded-lg p-3 font-mono">
  <div class="text-blue-400 font-bold mb-1">Identidad matemática:</div>
  <div class="text-gray-200">
      011110<sub>2</sub> = 2<sup>4</sup> + 2<sup>3</sup> + 2<sup>2</sup> + 2<sup>1</sup> = 30<sub>10</sub><br>
      011110<sub>2</sub> = 2<sup>5</sup> - 2<sup>1</sup> = 32 - 2 = 30<sub>10</sub>
  </div>
  <div class="text-gray-400 text-[11px] mt-2 font-sans">
      Cuatro sumas sucesivas se convierten en solo una resta y una suma.
  </div>
  </div>
  <div class="border border-emerald-500/50 bg-emerald-950/30 rounded-lg p-3">
  <div class="text-emerald-400 font-bold mb-1 font-mono">Recodificación de pares de bits:</div>
  <div class="text-gray-300 text-[11px]">
      Se inspecciona el bit actual del multiplicador (<i>Q</i><sub>0</sub>) y el bit previo inmediatamente descartado a la derecha (<i>Q</i><sub>-1</sub>).
  </div>
  </div>
</div>
<div v-click="1" class="overflow-x-auto my-2 text-xs">
  <table class="w-full text-center border-collapse border border-gray-700 font-mono">
  <thead>
  <tr class="bg-gray-800 text-gray-200">
  <th class="border border-gray-700 p-2" style="text-align: center;">Par [<i>Q</i><sub>0</sub>, <i>Q</i><sub>-1</sub>]</th>
  <th class="border border-gray-700 p-2" style="text-align: center;">Transición de bits</th>
  <th class="border border-gray-700 p-2" style="text-align: center;">Acción en la ALU</th>
  <th class="border border-gray-700 p-2 font-sans" style="text-align: left;">Explicación conceptual</th>
  </tr>
  </thead>
  <tbody>
  <tr class="bg-rose-950/30">
  <td class="border border-gray-700 p-2 font-bold text-rose-300">1 0</td>
  <td class="border border-gray-700 p-2">Inicio de bloque de unos</td>
  <td class="border border-gray-700 p-2 font-bold text-rose-400"><i>A</i> ← <i>A</i> - <i>M</i></td>
  <td class="border border-gray-700 p-2 text-left font-sans text-gray-300">Se resta el multiplicando del acumulador</td>
  </tr>
  <tr class="bg-emerald-950/30">
  <td class="border border-gray-700 p-2 font-bold text-emerald-300">0 1</td>
  <td class="border border-gray-700 p-2">Fin de bloque de unos</td>
  <td class="border border-gray-700 p-2 font-bold text-emerald-400"><i>A</i> ← <i>A</i> + <i>M</i></td>
  <td class="border border-gray-700 p-2 text-left font-sans text-gray-300">Se suma el multiplicando al acumulador</td>
  </tr>
  <tr class="bg-gray-900/40">
  <td class="border border-gray-700 p-2 font-bold text-gray-400">0 0</td>
  <td class="border border-gray-700 p-2">Cadena continua de ceros</td>
  <td class="border border-gray-700 p-2 text-gray-400">Ninguna</td>
  <td class="border border-gray-700 p-2 text-left font-sans text-gray-400">Solo desplazamiento aritmético</td>
  </tr>
  <tr class="bg-gray-900/40">
  <td class="border border-gray-700 p-2 font-bold text-gray-400">1 1</td>
  <td class="border border-gray-700 p-2">Interior de bloque de unos</td>
  <td class="border border-gray-700 p-2 text-gray-400">Ninguna</td>
  <td class="border border-gray-700 p-2 text-left font-sans text-gray-400">Solo desplazamiento aritmético</td>
  </tr>
  </tbody>
  </table>
</div>
<!--
Veamos cuál es la intuición detrás del algoritmo de Booth. 

Imaginen que tienen una cadena con muchos unos seguidos, como treinta en decimal. En lugar de sumar cuatro veces el multiplicando desplazado, podemos notar que treinta es igual a treinta y dos menos dos, es decir, dos a la cinco menos dos a la uno. Por tanto, podemos reemplazar cuatro sumas por solo una resta al inicio del bloque de unos y una suma al final del bloque.

[click] Para implementar esto, examinamos la tabla de transiciones: si vemos uno cero, entramos a un bloque de unos y restamos el multiplicando; si vemos cero uno, salimos del bloque y sumamos; y si vemos ceros o unos continuos, no realizamos operación aritmética y solo desplazamos.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Flujo operativo del algoritmo de Booth

<div class="text-xs space-y-2 font-mono">
<div class="border border-gray-700 bg-gray-800/70 p-2 rounded">
  <span class="text-blue-400 font-bold">1. Inicialización:</span>
  <p class="text-gray-300 font-sans text-[11px] mt-0.5">
  <i>A</i> = 0, <i>Q</i><sub>-1</sub> = 0, <i>M</i> = multiplicando, <i>Q</i> = multiplicador, Contador = <i>n</i>.
  </p>
</div>
<div class="border border-gray-700 bg-gray-800/70 p-2 rounded">
  <span class="text-emerald-400 font-bold">2. Decisión aritmética:</span>
  <p class="text-gray-300 font-sans text-[11px] mt-0.5">
    Evaluar [<i>Q</i><sub>0</sub>, <i>Q</i><sub>-1</sub>] y ejecutar <i>A</i> ← <i>A</i> - <i>M</i>, <i>A</i> ← <i>A</i> + <i>M</i> o mantener <i>A</i> intacto.
  </p>
</div>
<div class="border border-gray-700 bg-gray-800/70 p-2 rounded">
  <span class="text-amber-400 font-bold">3. Desplazamiento aritmético:</span>
  <p class="text-gray-300 font-sans text-[11px] mt-0.5">
    Desplazar a la derecha la cadena [<i>A</i>, <i>Q</i>, <i>Q</i><sub>-1</sub>] conservando el bit de signo de <i>A</i>.
  </p>
</div>
<div class="border border-gray-700 bg-gray-800/70 p-2 rounded">
  <span class="text-purple-400 font-bold">4. Condición de término:</span>
  <p class="text-gray-300 font-sans text-[11px] mt-0.5">
    Decrementar contador. Si Contador &gt; 0, repetir. Al terminar, el producto reside en [<i>A</i>, <i>Q</i>].
  </p>
</div>
</div>

::right::

<div v-click="1" class="mt-8 p-3 border border-cyan-500/40 bg-cyan-950/20 rounded-xl text-xs space-y-3">
  <div class="text-cyan-300 font-bold font-sans">Detalle crítico: Desplazamiento aritmético</div>
  <p class="text-gray-300 text-[11px] leading-relaxed">
    A diferencia del desplazamiento lógico donde entra un cero por la izquierda, el <strong class="text-cyan-400">desplazamiento aritmético a la derecha</strong> replica el bit de signo en la posición más significativa de <i>A</i>.
  </p>
  <div class="p-2 bg-gray-900 border border-gray-700 rounded text-center font-mono text-xs">
  <div class="text-gray-400 text-[10px] mb-1">Preservación del signo:</div>
  <span class="text-rose-400 font-bold"><i>A</i><sub><i>n</i>-1</sub></span> &rarr; <span class="text-rose-400 font-bold"><i>A</i><sub><i>n</i>-1</sub></span> <i>A</i><sub><i>n</i>-2</sub> … <i>A</i><sub>0</sub> &rarr; <i>Q</i><sub><i>n</i>-1</sub> … <i>Q</i><sub>0</sub> &rarr; <i>Q</i><sub>-1</sub>
  </div>
  <p class="text-gray-400 text-[10px]">
    Esto asegura que los valores negativos mantengan su representación matemática correcta en complemento a dos durante cada iteración.
  </p>
</div>
<!--
Revisemos el ciclo de ejecución completo del algoritmo de Booth.

El proceso arranca inicializando el acumulador A en cero y la bandera Q sub menos uno en cero. Cargamos los operandos de n bits y fijamos el contador en n. En cada iteración, evaluamos el par Q sub cero y Q sub menos uno, aplicamos la suma o resta según corresponda, y ejecutamos el desplazamiento.

[click] Noten con mucha atención la tarjeta de la derecha sobre el desplazamiento aritmético. A diferencia del desplazamiento lógico, aquí el bit más significativo de A se copia a sí mismo al desplazarse, garantizando que el signo se preserve de forma exacta a lo largo de todos los ciclos.
-->

---
transition: slide-up | slide-down
---

# Traza de cálculo con algoritmo de Booth

<div class="text-xs mb-2 text-gray-300">
Multiplicación de 7 × (-3) = -21 en 4 bits: Multiplicando <i>M</i> = 0111<sub>2</sub> (7), -<i>M</i> = 1001<sub>2</sub> (-7), Multiplicador <i>Q</i> = 1101<sub>2</sub> (-3).
</div>
<div class="overflow-x-auto text-[11px] font-mono">
  <table class="w-full text-center border-collapse border border-gray-700">
  <thead>
  <tr class="bg-gray-800 text-gray-200">
  <th class="border border-gray-700 p-1.5" style="text-align: center;">Paso / Ciclo</th>
  <th class="border border-gray-700 p-1.5 font-sans" style="text-align: left;">Operación realizada</th>
  <th class="border border-gray-700 p-1.5 text-emerald-400" style="text-align: center;">Acumulador A</th>
  <th class="border border-gray-700 p-1.5 text-purple-400" style="text-align: center;">Registro Q</th>
  <th class="border border-gray-700 p-1.5 text-amber-400" style="text-align: center;"><i>Q</i><sub>-1</sub></th>
  <th class="border border-gray-700 p-1.5" style="text-align: center;">Contador</th>
  </tr>
  </thead>
  <tbody>
  <tr>
  <td class="border border-gray-700 p-1 font-bold text-gray-400">Inicio</td>
  <td class="border border-gray-700 p-1 text-left font-sans text-gray-300">Valores iniciales</td>
  <td class="border border-gray-700 p-1 text-emerald-300 font-bold">0000</td>
  <td class="border border-gray-700 p-1 text-purple-300 font-bold">1101</td>
  <td class="border border-gray-700 p-1 text-amber-300 font-bold">0</td>
  <td class="border border-gray-700 p-1 font-bold">4</td>
  </tr>
  <tr class="bg-rose-950/20">
  <td class="border border-gray-700 p-1 font-bold text-rose-300">Ciclo 1</td>
  <td class="border border-gray-700 p-1 text-left"><i>Q</i><sub>0</sub><i>Q</i><sub>-1</sub> = 10 → <i>A</i> ← <i>A</i> - <i>M</i>, Desp. aritmético</td>
  <td class="border border-gray-700 p-1 text-emerald-300">1100</td>
  <td class="border border-gray-700 p-1 text-purple-300">1110</td>
  <td class="border border-gray-700 p-1 text-amber-300">1</td>
  <td class="border border-gray-700 p-1">3</td>
  </tr>
  <tr class="bg-emerald-950/20">
  <td class="border border-gray-700 p-1 font-bold text-emerald-300">Ciclo 2</td>
  <td class="border border-gray-700 p-1 text-left"><i>Q</i><sub>0</sub><i>Q</i><sub>-1</sub> = 01 → <i>A</i> ← <i>A</i> + <i>M</i>, Desp. aritmético</td>
  <td class="border border-gray-700 p-1 text-emerald-300">0001</td>
  <td class="border border-gray-700 p-1 text-purple-300">1111</td>
  <td class="border border-gray-700 p-1 text-amber-300">0</td>
  <td class="border border-gray-700 p-1">2</td>
  </tr>
  <tr class="bg-rose-950/20">
  <td class="border border-gray-700 p-1 font-bold text-rose-300">Ciclo 3</td>
  <td class="border border-gray-700 p-1 text-left"><i>Q</i><sub>0</sub><i>Q</i><sub>-1</sub> = 10 → <i>A</i> ← <i>A</i> - <i>M</i>, Desp. aritmético</td>
  <td class="border border-gray-700 p-1 text-emerald-300">1101</td>
  <td class="border border-gray-700 p-1 text-purple-300">0111</td>
  <td class="border border-gray-700 p-1 text-amber-300">1</td>
  <td class="border border-gray-700 p-1">1</td>
  </tr>
  <tr class="bg-gray-900/50">
  <td class="border border-gray-700 p-1 font-bold text-gray-300">Ciclo 4</td>
  <td class="border border-gray-700 p-1 text-left"><i>Q</i><sub>0</sub><i>Q</i><sub>-1</sub> = 11 → Solo desp. aritmético</td>
  <td class="border border-gray-700 p-1 text-emerald-300">1110</td>
  <td class="border border-gray-700 p-1 text-purple-300">1011</td>
  <td class="border border-gray-700 p-1 text-amber-300">1</td>
  <td class="border border-gray-700 p-1">0</td>
  </tr>
  </tbody>
  </table>
</div>
<div v-click="1" class="mt-3 p-2 bg-emerald-950/30 border border-emerald-500 rounded-lg text-xs font-mono text-center">
  <span class="text-emerald-300 font-bold">Resultado final combinado [<i>A</i>, <i>Q</i>]:</span> 11101011<sub>2</sub> ⇒ -128 + 64 + 32 + 8 + 2 + 1 = -21<sub>10</sub>
</div>
<!--
Sigamos una traza real paso a paso en la tabla. Vamos a multiplicar siete por menos tres en palabras de cuatro bits, con resultado esperado de menos veintiuno.

En el ciclo uno, evaluamos uno cero, restamos M y desplazamos. En el ciclo dos, evaluamos cero uno, sumamos M y desplazamos. En el ciclo tres, evaluamos uno cero, restamos M y desplazamos. Y en el ciclo cuatro, evaluamos uno uno, donde solo desplazamos aritméticamente.

[click] Al finalizar, el resultado combinado de A y Q revela la cadena binaria de ocho bits que corresponde exactamente a menos veintiuno en base diez.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# División de enteros en hardware

<div>
La división es la operación inversa de la multiplicación, donde para un dividendo <i>D</i> y un divisor <i>V</i>, se determinan un cociente <i>Q</i> y un residuo <i>R</i> que satisfacen la relación fundamental:
</div>
<div class="mt-3 p-3 bg-gray-900 border border-gray-700 rounded-lg font-mono text-center text-sm text-cyan-300">
  <i>D</i> = <i>Q</i> × <i>V</i> + <i>R</i> &nbsp;&nbsp;(con 0 ≤ <i>R</i> &lt; <i>V</i>)
</div>
<div v-click="1" class="mt-4 p-3 bg-blue-950/30 border border-blue-800/50 rounded-lg text-xs">
<strong class="text-blue-400">Esquema de registros:</strong>
<p class="text-gray-300 mt-1">
El dividendo se carga inicialmente en el registro combinado [<i>A</i>, <i>Q</i>], mientras que el divisor se aloja en el registro <i>M</i>. El cociente final se acumula en <i>Q</i> y el residuo final queda en <i>A</i>.
</p>
</div>

::right::

<div class="mt-12 space-y-3 text-xs">
<div class="p-3 border border-gray-700 bg-gray-800/60 rounded-lg">
  <strong class="text-emerald-400 font-sans">Mecanismo secuencial:</strong>
  <ol class="list-decimal list-inside text-gray-300 mt-2 space-y-1.5 font-sans">
  <li>Desplazar la combinación [<i>A</i>, <i>Q</i>] un bit hacia la izquierda.</li>
  <li>Restar el divisor del acumulador: <i>A</i> ← <i>A</i> - <i>M</i>.</li>
  <li>Evaluar el signo del residuo parcial obtenido en <i>A</i>.</li>
  <li>Fijar el bit del cociente <i>Q</i><sub>0</sub> en 1 si el resultado fue positivo, o en 0 si fue negativo.</li>
  </ol>
</div>
<div v-click="2" class="p-3 border border-amber-500/40 bg-amber-950/20 rounded-lg text-gray-300 font-sans">
  <strong class="text-amber-400">Manejo de excepciones:</strong>
  <p class="mt-1 text-[11px]">
    Si el divisor <i>M</i> es cero, el hardware no puede completar la operación y genera una interrupción de división por cero inmediatamente antes de iniciar los ciclos.
  </p>
</div>
</div>
<!--
Pasemos ahora a la división de enteros en hardware. La división busca calcular el cociente Q y el residuo R a partir de un dividendo D y un divisor V según la fórmula que vemos arriba.

[click] A nivel microarquitectónico, el dividendo se coloca en la pareja de registros A y Q, mientras que el divisor reside en M. En cada ciclo desplazamos a la izquierda, restamos el divisor y evaluamos el signo para fijar el bit de cociente.

[click] Un aspecto crítico que todo procesador debe validar antes de empezar es comprobar si el divisor es cero, disparando una excepción de división por cero inmediatamente para proteger el sistema.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# División restauradora y no restauradora

<div>
Dependiendo de cómo el circuito gestione los residuos parciales negativos, existen dos variantes principales de implementación en hardware.
</div>
<div class="mt-4 p-3 border border-rose-500/40 bg-rose-950/20 rounded-lg text-xs">
<strong class="text-rose-400">División restauradora:</strong>
<p class="text-gray-300 mt-1">
Si la resta <i>A</i> - <i>M</i> da un resultado negativo, el divisor no cabía. Por consiguiente, se suma de nuevo <i>M</i> al acumulador (<i>A</i> ← <i>A</i> + <i>M</i>) para restaurar su valor previo y se coloca <i>Q</i><sub>0</sub> = 0.
</p>
<div class="mt-2 text-rose-300 text-[11px] font-mono">
  Desventaja: Requiere dos operaciones sobre la ALU en los ciclos donde no cabe.
</div>
</div>

::right::

<div v-click="1" class="mt-12 p-3 border border-emerald-500/40 bg-emerald-950/20 rounded-lg text-xs">
<strong class="text-emerald-400">División no restauradora:</strong>
<p class="text-gray-300 mt-1">
En lugar de restaurar el valor de <i>A</i> de inmediato, se pospone la corrección aritmética para el siguiente ciclo aprovechando el desplazamiento.
</p>
<ul class="list-disc list-inside text-gray-300 mt-2 space-y-1 text-[11px]">
  <li>Si <i>A</i> ≥ 0: Desplazar a la izquierda y restar <i>M</i> (2<i>A</i> - <i>M</i>).</li>
  <li>Si <i>A</i> &lt; 0: Desplazar a la izquierda y sumar <i>M</i> (2<i>A</i> + <i>M</i>).</li>
</ul>
<div class="mt-2 text-emerald-300 text-[11px] font-mono">
  Ventaja: Realiza exactamente una operación de ALU por ciclo de reloj, duplicando la velocidad.
</div>
</div>
<!--
Existen dos formas clásicas de implementar la división en hardware. En el método restaurador que vemos a la izquierda, si al restar el acumulador queda negativo, tenemos que sumar de nuevo el divisor para restaurar el valor previo de A, lo que introduce ciclos dobles.

[click] Para optimizar esto, el método no restaurador de la derecha pospone la corrección al ciclo siguiente, sumando o restando el divisor según el signo del residuo parcial previo y logrando exactamente una sola operación de ALU por ciclo de reloj.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Limitaciones de la coma fija

<div>
Los formatos de enteros y de coma fija asignan una cantidad invariable de bits a la parte entera y a la parte fraccionaria, restringiendo severamente su utilidad en cálculo general.
</div>
<div v-click="1" class="mt-4 p-3 bg-gray-900 border border-gray-700 rounded-lg text-xs">
<strong class="text-amber-400">El dilema de la coma fija:</strong>
<p class="text-gray-300 mt-1">
Si fijamos 16 bits para la parte entera y 16 bits para la fracción en una palabra de 32 bits, el valor máximo representable es solo ≈ 65535, y la menor fracción distinta de cero es 2<sup>-16</sup> ≈ 0.000015.
</p>
</div>

::right::

<div class="mt-12 space-y-3 text-xs">
<div class="p-3 border border-red-500/40 bg-red-950/20 rounded-lg">
  <strong class="text-red-400">Incapacidad de representar escalas dispares:</strong>
  <p class="text-gray-300 mt-1">
    No permite almacenar en un mismo formato magnitudes astronómicas (masa del sol: 1.98 × 10<sup>30</sup> kg) y fenómenos subatómicos (radio de Bohr: 5.29 × 10<sup>-11</sup> m).
  </p>
</div>
<div v-click="2" class="p-3 border border-emerald-500/40 bg-emerald-950/20 rounded-lg">
  <strong class="text-emerald-400">La solución: Punto flotante</strong>
  <p class="text-gray-300 mt-1">
    La posición del punto decimal flota dinámicamente según un exponente, permitiendo intercambiar resolución por rango dinámico según la escala de cada número mediante notación científica binaria:
  </p>
  <div class="text-center font-mono text-cyan-300 text-sm mt-1">
    ±<i>M</i> × 2<sup><i>E</i></sup>
  </div>
</div>
</div>
<!--
Hasta aquí hemos trabajado con enteros. Pero cuando necesitamos representar números reales en ingeniería, la coma fija se queda corta.

[click] Si reservamos dieciséis bits enteros y dieciséis decimales, nuestro número máximo es apenas sesenta y cinco mil, resultando insuficiente para escalas dispares como la masa de una estrella o el radio de un átomo.

[click] Para solucionar esto nació el punto flotante, donde la posición de la coma flota dinámicamente según un exponente en base dos, adaptándose a cualquier escala numérica.
-->

---
transition: slide-left | slide-right
---

# El estándar IEEE 754

<div class="text-sm mb-3">
Publicado originalmente en 1985 bajo el liderazgo de William Kahan, el estándar IEEE 754 unificó el formato y el comportamiento aritmético del punto flotante en toda la industria informática.
</div>
<div class="my-4">
  <div class="text-xs text-gray-400 mb-2 font-sans">
    Distribución de campos en una palabra IEEE 754:
  </div>
  <div class="border border-gray-800 bg-gray-900/60 rounded-xl p-2.5 font-sans">
  <div class="grid grid-cols-12 gap-2 text-center text-xs">
  <div class="col-span-2 bg-rose-950/30 border border-rose-800/30 rounded-lg p-3 text-rose-200">
  <div class="text-[11px] text-rose-300 font-medium mb-1">Signo (<i>s</i>)</div>
  <div class="text-sm font-semibold text-white">1 bit</div>
  <div class="text-[10px] text-gray-400 mt-1">0: +, 1: -</div>
  </div>
  <div class="col-span-4 bg-blue-950/30 border border-blue-800/30 rounded-lg p-3 text-blue-200">
  <div class="text-[11px] text-blue-300 font-medium mb-1">Exponente sesgado (<i>e</i>)</div>
  <div class="text-sm font-semibold text-white"><i>k</i> bits</div>
  <div class="text-[10px] text-gray-400 mt-1"><i>e</i> = <i>E</i> + sesgo</div>
  </div>
  <div class="col-span-6 bg-emerald-950/30 border border-emerald-800/30 rounded-lg p-3 text-emerald-200">
  <div class="text-[11px] text-emerald-300 font-medium mb-1">Mantisa o significando (<i>f</i>)</div>
  <div class="text-sm font-semibold text-white"><i>m</i> bits</div>
  <div class="text-[10px] text-gray-400 mt-1">Fracción normalizada (1.<i>f</i>)</div>
  </div>
  </div>
  </div>
</div>
<div v-click="1" class="p-3 bg-gray-900/80 border border-gray-800 rounded-lg text-xs font-sans text-center flex items-center justify-center space-x-3">
  <span class="text-gray-400">Fórmula de evaluación:</span>
  <span class="text-gray-100 font-mono text-sm">Valor = (-1)<sup><i>s</i></sup> × 2<sup><i>e</i> - sesgo</sup> × (1.<i>f</i>)<sub>2</sub></span>
</div>
<!--
El estándar universal que gobierna el punto flotante es el IEEE 754. Toda palabra se divide en tres campos: el bit de signo, el exponente sesgado de k bits y la mantisa o significando de m bits.

[click] La fórmula matemática inferior nos permite evaluar el valor de cualquier número normalizado combinando el signo, la potencia de dos desplazada por el sesgo y la fracción con su uno entero.
-->

---
layout: two-cols
transition: slide-up | slide-down
---

# Formatos estándar de 32 y 64 bits

<div class="p-4 bg-gray-900/60 border border-gray-800 rounded-xl text-xs font-sans">
  <div class="text-cyan-400 font-semibold text-sm mb-0.5">Simple precisión (32 bits)</div>
  <div class="text-gray-400 text-[10px] mb-3">Tipo <code class="text-cyan-300 font-mono">float</code> en lenguaje C</div>
  <ul class="space-y-1.5 text-gray-300 text-[11px]">
  <li>• <strong>Signo:</strong> 1 bit (bit 31)</li>
  <li>• <strong>Exponente:</strong> 8 bits (bits 30--23)</li>
  <li>• <strong>Sesgo:</strong> 127 (2<sup>8-1</sup> - 1)</li>
  <li>• <strong>Mantisa:</strong> 23 bits (bits 22--0)</li>
  <li>• <strong>Precisión efectiva:</strong> 24 bits (≈ 7 dígitos decimales)</li>
  <li>• <strong>Rango aproximado:</strong> 10<sup>-38</sup> a 10<sup>38</sup></li>
  </ul>
</div>

::right::

<div v-click="1" class="mt-8 p-4 bg-gray-900/60 border border-gray-800 rounded-xl text-xs font-sans">
  <div class="text-purple-400 font-semibold text-sm mb-0.5">Doble precisión (64 bits)</div>
  <div class="text-gray-400 text-[10px] mb-3">Tipo <code class="text-purple-300 font-mono">double</code> en lenguaje C</div>
  <ul class="space-y-1.5 text-gray-300 text-[11px]">
  <li>• <strong>Signo:</strong> 1 bit (bit 63)</li>
  <li>• <strong>Exponente:</strong> 11 bits (bits 62--52)</li>
  <li>• <strong>Sesgo:</strong> 1023 (2<sup>11-1</sup> - 1)</li>
  <li>• <strong>Mantisa:</strong> 52 bits (bits 51--0)</li>
  <li>• <strong>Precisión efectiva:</strong> 53 bits (≈ 16 dígitos decimales)</li>
  <li>• <strong>Rango aproximado:</strong> 10<sup>-308</sup> a 10<sup>308</sup></li>
  </ul>
</div>
<!--
El estándar define dos formatos predominantes. A la izquierda tenemos la simple precisión de treinta y dos bits, correspondiente al tipo float en C, con ocho bits de exponente, sesgo de ciento veintisiete y veintitrés bits de mantisa.

[click] A la derecha encontramos la doble precisión de sesenta y cuatro bits, correspondiente al tipo double en C, con once bits de exponente, sesgo de mil veintitrés y cincuenta y dos bits de mantisa, brindando dieciséis dígitos significativos de resolución.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Representación del exponente con sesgo

<div>
El exponente en IEEE 754 no se guarda en complemento a dos, sino mediante una representación desplazada por una constante denominada sesgo.
</div>
<div class="mt-4 p-4 bg-gray-900/60 border border-gray-800 rounded-xl text-xs font-sans">
<div class="text-amber-400 font-semibold mb-2">Fórmulas de conversión:</div>
<div class="text-gray-200 font-mono space-y-1">
  <div><i>e</i> = <i>E</i> + sesgo</div>
  <div><i>E</i> = <i>e</i> - sesgo</div>
</div>
<div class="text-[11px] text-gray-400 mt-3 font-sans leading-relaxed">
  En 32 bits: sesgo = 127. Si el exponente real es <i>E</i> = 3, se almacena <i>e</i> = 3 + 127 = 130 = 10000010<sub>2</sub>.
</div>
</div>

::right::

<div v-click="1" class="mt-12 p-4 bg-gray-900/60 border border-gray-800 rounded-xl text-xs font-sans">
<div class="text-gray-100 font-semibold mb-2">¿Por qué usar sesgo en lugar de complemento a dos?</div>
<p class="text-gray-300 text-[11px] leading-relaxed">
La razón principal es la <strong>eficiencia en la comparación de magnitudes</strong>. Al usar sesgo, todos los exponentes almacenados son enteros positivos (<i>e</i> ≥ 0).
</p>
<p class="text-gray-400 mt-2 text-[11px] leading-relaxed">
Esto permite que el hardware compare el orden de magnitud de dos números usando comparadores estándar de enteros sin signo, sin requerir lógica especial para números negativos.
</p>
</div>
<!--
El exponente se guarda desplazado por una constante de sesgo. En treinta y dos bits el sesgo vale ciento veintisiete, por lo que un exponente de tres se almacena como ciento treinta.

[click] ¿Por qué no usar complemento a dos? Como explica la tarjeta de la derecha, al usar sesgo todos los exponentes son enteros positivos, permitiendo que la CPU compare órdenes de magnitud con comparadores sin signo sencillos y ultrarrápidos.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Normalización y el bit implícito

<div>
En el sistema binario, todo número no nulo expresado en notación científica tiene la forma particular:
</div>
<div class="my-3 p-2.5 bg-gray-900/80 border border-gray-800 rounded-lg text-center font-mono text-cyan-300 text-sm">
  1.<i>b</i><sub>1</sub><i>b</i><sub>2</sub><i>b</i><sub>3</sub>…<i>b</i><sub><i>m</i></sub> × 2<sup><i>E</i></sup>
</div>
<div class="text-xs text-gray-400 font-sans leading-relaxed">
Dado que en base 2 el único dígito distinto de cero es el 1, el primer bit antes de la coma siempre es obligatoriamente 1 en cualquier número normalizado.
</div>

::right::

<div v-click="1" class="mt-8 p-4 bg-gray-900/60 border border-gray-800 rounded-xl text-xs font-sans space-y-3">
  <div class="text-gray-100 font-semibold">La ganancia del bit oculto:</div>
  <p class="text-gray-300 text-[11px] leading-relaxed">
    Dado que sabemos con total certeza que el bit entero siempre es 1, <strong>el estándar no lo almacena físicamente en la memoria</strong>.
  </p>
  <div class="p-2.5 bg-gray-900 border border-gray-800 rounded-lg text-xs font-mono text-center">
    Almacenamos: 23 bits de fracción (<i>f</i>)<br>
    Obtenemos: <span class="text-emerald-400 font-semibold">24 bits de precisión real</span>
  </div>
  <p class="text-gray-400 text-[10px]">
    Este principio duplica la resolución efectiva del formato sin gastar silicio adicional.
  </p>
</div>
<!--
En el sistema binario, todo número normalizado comienza obligatoriamente con un uno antes de la coma, pues no hay otros dígitos distintos de cero.

[click] Como el hardware ya sabe que siempre hay un uno antes de la coma, no lo almacena físicamente, logrando veinticuatro bits de precisión real en treinta y dos bits de espacio.
-->

---
transition: slide-up | slide-down
---

# Valores especiales en el estándar IEEE 754

<div class="text-xs text-gray-300 mb-2">
El estándar reserva combinaciones extremas del campo de exponente (<i>e</i> = 0 y <i>e</i> = <i>e</i><sub>máx</sub>) para codificar estados especiales del cálculo.
</div>
<div class="overflow-x-auto text-[11px] font-mono">
  <table class="w-full text-center border-collapse border border-gray-700">
  <thead>
  <tr class="bg-gray-800 text-gray-200">
  <th class="border border-gray-700 p-2" style="text-align: center;">Exponente (<i>e</i>)</th>
  <th class="border border-gray-700 p-2" style="text-align: center;">Mantisa (<i>f</i>)</th>
  <th class="border border-gray-700 p-2" style="text-align: center;">Significado</th>
  <th class="border border-gray-700 p-2 font-sans" style="text-align: left;">Valor matemático interpretado</th>
  </tr>
  </thead>
  <tbody>
  <tr class="bg-blue-950/20">
  <td class="border border-gray-700 p-1.5 font-bold text-blue-300"><i>e</i> = 0</td>
  <td class="border border-gray-700 p-1.5 font-bold text-blue-300"><i>f</i> = 0</td>
  <td class="border border-gray-700 p-1.5 text-blue-400 font-bold">Cero (+0 y -0)</td>
  <td class="border border-gray-700 p-1.5 text-left font-sans text-gray-300">(-1)<sup><i>s</i></sup> × 0.0 (El signo distingue dirección de aproximación)</td>
  </tr>
  <tr class="bg-purple-950/20">
  <td class="border border-gray-700 p-1.5 font-bold text-purple-300"><i>e</i> = 0</td>
  <td class="border border-gray-700 p-1.5 font-bold text-purple-300"><i>f</i> ≠ 0</td>
  <td class="border border-gray-700 p-1.5 text-purple-400 font-bold">Números subnormales</td>
  <td class="border border-gray-700 p-1.5 text-left font-sans text-gray-300">(-1)<sup><i>s</i></sup> × 2<sup>1 - sesgo</sup> × (0.<i>f</i>)<sub>2</sub> (Sin bit 1 implícito, desbordamiento gradual)</td>
  </tr>
  <tr class="bg-emerald-950/20">
  <td class="border border-gray-700 p-1.5 font-bold text-emerald-300">1 ≤ <i>e</i> ≤ 254</td>
  <td class="border border-gray-700 p-1.5 text-emerald-300">Cualquiera</td>
  <td class="border border-gray-700 p-1.5 text-emerald-400 font-bold">Números normalizados</td>
  <td class="border border-gray-700 p-1.5 text-left font-sans text-gray-300">(-1)<sup><i>s</i></sup> × 2<sup><i>e</i> - 127</sup> × (1.<i>f</i>)<sub>2</sub> (Rango operativo estándar)</td>
  </tr>
  <tr class="bg-amber-950/20">
  <td class="border border-gray-700 p-1.5 font-bold text-amber-300"><i>e</i> = 255</td>
  <td class="border border-gray-700 p-1.5 font-bold text-amber-300"><i>f</i> = 0</td>
  <td class="border border-gray-700 p-1.5 text-amber-400 font-bold">Infinito (+∞ / -∞)</td>
  <td class="border border-gray-700 p-1.5 text-left font-sans text-gray-300">Resultado de división por cero o desbordamiento superior</td>
  </tr>
  <tr class="bg-rose-950/20">
  <td class="border border-gray-700 p-1.5 font-bold text-rose-300"><i>e</i> = 255</td>
  <td class="border border-gray-700 p-1.5 font-bold text-rose-300"><i>f</i> ≠ 0</td>
  <td class="border border-gray-700 p-1.5 text-rose-400 font-bold">NaN</td>
  <td class="border border-gray-700 p-1.5 text-left font-sans text-gray-300">Operaciones inválidas: 0/0, √(-1), ∞ - ∞</td>
  </tr>
  </tbody>
  </table>
</div>
<!--
El estándar reserva combinaciones especiales para evitar caídas del sistema. Cuando el exponente y la mantisa son cero, representa el cero con signo. Cuando el exponente es cero pero la mantisa no, representa números subnormales sin bit implícito. Cuando el exponente llega al máximo con mantisa en cero, representa infinito, y con mantisa no nula codifica un NaN para operaciones matemáticamente indefinidas.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Errores numéricos y fenómenos de cálculo

<div>
Trabajar con punto flotante exige comprender que los números reales en una computadora son aproximaciones discretas sobre una recta numérica continua.
</div>
<div class="mt-4 p-4 bg-gray-900/60 border border-gray-800 rounded-xl text-xs font-sans">
<strong class="text-amber-400">Fracciones periódicas en base 2:</strong>
<p class="text-gray-300 mt-1 leading-relaxed text-[11px]">
Así como en base 10 la fracción 1/3 = 0.333… es infinita, en base 2 fracciones comunes como 0.1 y 0.2 se convierten en patrones binarios periódicos infinitos:
</p>
<div class="mt-2 text-cyan-300 font-mono text-[11px]">
  0.1<sub>10</sub> = 0.00011001100110011…<sub>2</sub>
</div>
</div>

::right::

<div v-click="1" class="mt-12 space-y-3 text-xs font-sans">
<div class="p-3 bg-gray-900/60 border border-gray-800 rounded-xl">
  <strong class="text-gray-200">Cancelación catastrófica:</strong>
  <p class="text-gray-400 mt-1 text-[11px] leading-relaxed">
    Ocurre al restar números casi idénticos en magnitud. Los bits significativos se cancelan a cero y el resultado queda dominado por el redondeo previo.
  </p>
</div>
<div class="p-3 bg-gray-900/60 border border-gray-800 rounded-xl">
  <strong class="text-gray-200">Desbordamiento superior e inferior:</strong>
  <p class="text-gray-400 mt-1 text-[11px] leading-relaxed">
    El desbordamiento superior excede el valor máximo representable (+&infin;). El inferior ocurre cuando la magnitud cae por debajo del rango subnormal.
  </p>
</div>
</div>
<!--
Las fracciones decimales como cero punto uno son periódicas infinitas en base dos, requiriendo truncamiento forzoso en la mantisa.

[click] A la derecha vemos dos fenómenos críticos: la cancelación catastrófica al restar números casi idénticos, y los desbordamientos superior e inferior cuando los cálculos exceden los límites del formato.
-->

---
layout: center
transition: fade
---

# Síntesis de la primera sesión

<div class="max-w-xl mx-auto text-left space-y-3 text-xs">
  <div class="p-3 bg-gray-800/80 border border-gray-700 rounded-lg">
  <strong class="text-cyan-400 font-mono">1. Aritmética de enteros en hardware:</strong>
  <p class="text-gray-300 mt-1">
      La multiplicación se optimiza mediante el algoritmo de Booth evitando conversiones con signo, mientras que la división no restauradora reduce los ciclos de ALU por iteración.
  </p>
  </div>
  <div class="p-3 bg-gray-800/80 border border-gray-700 rounded-lg">
  <strong class="text-emerald-400 font-mono">2. Estructura de IEEE 754:</strong>
  <p class="text-gray-300 mt-1">
      Combina un bit de signo, un exponente con sesgo para facilitar comparaciones y una mantisa con bit 1 implícito para maximizar la resolución.
  </p>
  </div>
  <div v-click="1" class="p-3 bg-gray-800/80 border border-gray-700 rounded-lg">
  <strong class="text-amber-400 font-mono">3. Pregunta detonante para el taller:</strong>
  <p class="text-gray-300 mt-1 italic">
      Si intentamos sumar 1.0 × 2<sup>10</sup> con 1.0 × 2<sup>-15</sup>, ¿cómo alinea la CPU los exponentes para poder sumar sus mantisas sin perder precisión?
  </p>
  </div>
</div>
<!--
Con esto concluimos la primera sesión teórica. Hemos cubierto los algoritmos de hardware para multiplicación y división, junto con la estructura matemática del estándar IEEE 754.

[click] Les dejo esta pregunta detonante para reflexionar antes del taller práctico: al sumar dos números con exponentes muy dispares, ¿cómo los alinea la CPU antes de operar?
-->

---
layout: center
transition: slide-up | slide-down
---

<div class="text-center">
  <div class="text-3xl text-gray-400 mb-4">Semana 04</div>
  <h1 class="text-6xl font-bold mb-8">Sesión 02: Taller práctico</h1>
  <div class="text-2xl text-blue-500 mt-4">IC3101: Arquitectura de computadores</div>
</div>
<!--
¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de la aritmética digital y el estándar IEEE 754, dedicaremos esta jornada completa al taller práctico y la resolución de ejercicios paso a paso.
-->

---
transition: fade
---

# Objetivos de la segunda sesión

<div class="mb-4 text-sm text-gray-300">
Desarrollar destrezas prácticas de conversión, decodificación y cálculo aritmético:
</div>
<v-clicks>

- **Conversión decimal a IEEE 754:** Dominar el procedimiento sistemático paso a paso en formatos de 32 y 64 bits.
- **Decodificación inversa:** Transformar patrones binarios y palabras hexadecimales reales a valores decimales legibles.
- **Aritmética de punto flotante:** Ejecutar sumas y restas manuales mediante la alineación de exponentes y normalización de mantisas.
- **Fenómenos en software:** Identificar fuentes de error por redondeo en lenguaje C y aplicar comparaciones seguras con épsilon.
- **Ejercicios de práctica:** Resolver problemas prácticos y trazas de hardware para afianzar el aprendizaje autónomo.

</v-clicks>
<!--
Antes de iniciar los ejercicios, repasemos los objetivos de esta segunda sesión práctica:

[click] Primero, aplicaremos la metodología sistemática para convertir números decimales con fracción a IEEE 754.

[click] Segundo, realizaremos el proceso inverso: decodificar una palabra hexadecimal de memoria para recuperar su valor real.

[click] Tercero, resolveremos sumas paso a paso ejecutando manualmente las cuatro etapas que realiza la FPU del procesador.

[click] Cuarto, analizaremos cómo se manifiestan estos fenómenos en programas reales de C y cómo evitar errores con épsilon.

[click] Y quinto, realizaremos ejercicios prácticos en parejas y dejaremos problemas recomendados para reforzar el aprendizaje autónomo.
-->

---
transition: slide-left | slide-right
---

# Metodología de conversión decimal a IEEE 754

<div class="text-xs text-gray-400 mb-6 font-sans">
Procedimiento estándar en cuatro fases para codificar una magnitud decimal en simple precisión (32 bits):
</div>
<div class="grid grid-cols-4 gap-6 font-sans my-4">
  <div v-click="1" class="space-y-2">
  <div class="flex items-center space-x-2">
  <span class="w-5 h-5 rounded-full bg-gray-800 text-gray-200 border border-gray-700 flex items-center justify-center text-[11px] font-semibold flex-shrink-0">1</span>
  <span class="text-xs font-semibold text-gray-100">Bit de signo</span>
  </div>
  <p class="text-[11px] text-gray-400 leading-relaxed">
      Identificar la polaridad de la magnitud: <i>s</i> = 0 si es positivo, <i>s</i> = 1 si es negativo.
  </p>
  </div>
  <div v-click="2" class="space-y-2">
  <div class="flex items-center space-x-2">
  <span class="w-5 h-5 rounded-full bg-gray-800 text-gray-200 border border-gray-700 flex items-center justify-center text-[11px] font-semibold flex-shrink-0">2</span>
  <span class="text-xs font-semibold text-gray-100">Magnitud binaria</span>
  </div>
  <p class="text-[11px] text-gray-400 leading-relaxed">
      Convertir la parte entera por división entre 2 y la fracción por multiplicación sucesiva hasta fijar la coma.
  </p>
  </div>
  <div v-click="3" class="space-y-2">
  <div class="flex items-center space-x-2">
  <span class="w-5 h-5 rounded-full bg-gray-800 text-gray-200 border border-gray-700 flex items-center justify-center text-[11px] font-semibold flex-shrink-0">3</span>
  <span class="text-xs font-semibold text-gray-100">Normalización</span>
  </div>
  <p class="text-[11px] text-gray-400 leading-relaxed">
      Desplazar la coma para obtener la forma 1.<i>f</i> × 2<sup><i>E</i></sup> y aislar el exponente real <i>E</i>.
  </p>
  </div>
  <div v-click="4" class="space-y-2">
  <div class="flex items-center space-x-2">
  <span class="w-5 h-5 rounded-full bg-gray-800 text-gray-200 border border-gray-700 flex items-center justify-center text-[11px] font-semibold flex-shrink-0">4</span>
  <span class="text-xs font-semibold text-gray-100">Empaquetado</span>
  </div>
  <p class="text-[11px] text-gray-400 leading-relaxed">
      Calcular el sesgo <i>e</i> = <i>E</i> + 127, rellenar la mantisa a 23 bits y convertir a hexadecimal.
  </p>
  </div>
</div>
<div class="mt-8 pt-4 border-t border-gray-800 flex items-center justify-between text-[11px] text-gray-400 font-sans px-2">
  <span>Decimal</span>
  <span class="text-gray-600 font-bold">&rarr;</span>
  <span>Signo (<i>s</i>)</span>
  <span class="text-gray-600 font-bold">&rarr;</span>
  <span>Coma fija</span>
  <span class="text-gray-600 font-bold">&rarr;</span>
  <span>Forma 1.<i>f</i> × 2<sup><i>E</i></sup></span>
  <span class="text-gray-600 font-bold">&rarr;</span>
  <span class="text-gray-200 font-medium">Palabra IEEE 754</span>
</div>
<!--
Para convertir cualquier número decimal al estándar IEEE 754 de 32 bits seguimos un flujo algorítmico estricto en cuatro etapas.

[click] Primero, inspeccionamos el signo del número decimal para fijar directamente el bit treinta y uno: cero si es positivo o uno si es negativo.

[click] Segundo, transformamos la magnitud absoluta a binario en coma fija, dividiendo la parte entera entre dos y multiplicando la fracción por dos.

[click] Tercero, normalizamos la expresión desplazando la coma para aislar el exponente real E y la mantisa fraccionaria con su bit uno implícito.

[click] Y cuarto, calculamos el exponente con sesgo sumando ciento veintisiete, rellenamos los veintitrés bits de mantisa y agrupamos los treinta y dos bits en hexadecimal.
-->

---
transition: slide-up | slide-down
---

# Ejemplo guiado 1: Número con fracción exacta

<div class="text-xs mb-2 text-gray-300">
Convertir el número decimal <span class="text-cyan-400 font-bold font-mono">+26.625</span> a formato IEEE 754 de simple precisión (32 bits).
</div>
<div class="grid grid-cols-2 gap-3 text-xs font-mono">
  <div class="p-2.5 bg-gray-900 border border-gray-700 rounded-lg space-y-1.5">
  <div class="text-blue-400 font-bold font-sans">1. Signo y parte entera:</div>
  <div class="text-gray-300 text-[11px]"><i>s</i> = 0 (positivo)</div>
  <div class="text-gray-300 text-[11px]">26 ÷ 2 = 13 (residuo 0)</div>
  <div class="text-gray-300 text-[11px]">13 ÷ 2 = 6 (residuo 1)</div>
  <div class="text-gray-300 text-[11px]">6 ÷ 2 = 3 (residuo 0)</div>
  <div class="text-gray-300 text-[11px]">3 ÷ 2 = 1 (residuo 1) &rarr; 1 ÷ 2 = 0 (residuo 1)</div>
  <div class="text-emerald-400 font-bold">26<sub>10</sub> = 11010<sub>2</sub></div>
  </div>
  <div class="p-2.5 bg-gray-900 border border-gray-700 rounded-lg space-y-1.5">
  <div class="text-amber-400 font-bold font-sans">2. Parte fraccionaria:</div>
  <div class="text-gray-300 text-[11px]">0.625 × 2 = 1.25 → entero 1</div>
  <div class="text-gray-300 text-[11px]">0.25 × 2 = 0.50 → entero 0</div>
  <div class="text-gray-300 text-[11px]">0.50 × 2 = 1.00 → entero 1</div>
  <div class="text-emerald-400 font-bold">0.625<sub>10</sub> = 0.101<sub>2</sub></div>
  <div class="text-gray-400 text-[10px] mt-1 font-sans">Número en coma fija: 11010.101<sub>2</sub></div>
  </div>
</div>
<div v-click="1" class="mt-2 p-2.5 bg-gray-900/80 border border-emerald-500/50 rounded-lg text-xs font-mono space-y-1">
  <div class="text-emerald-300 font-bold font-sans">3. Normalización y empaquetado:</div>
  <div class="text-gray-200 text-[11px]">Normalizado: 11010.101<sub>2</sub> = 1.1010101<sub>2</sub> × 2<sup>4</sup> ⇒ <i>E</i> = 4</div>
  <div class="text-gray-200 text-[11px]">Exponente con sesgo: <i>e</i> = 4 + 127 = 131<sub>10</sub> = 10000011<sub>2</sub></div>
  <div class="text-gray-200 text-[11px]">Mantisa (23 bits): 10101010000000000000000<sub>2</sub></div>
  <div class="text-cyan-300 font-bold text-[12px] pt-1">
    Binario: <span class="text-rose-400">0</span> <span class="text-amber-400">10000011</span> <span class="text-emerald-400">10101010000000000000000</span> &rarr; Hex: <span class="text-white">0x41D54000</span>
  </div>
</div>
<!--
Apliquemos el método al número positivo veintiséis punto seiscientos veinticinco. El signo es cero, la parte entera es once cero diez y la fracción es cero punto ciento uno.

[click] Al normalizar desplazando cuatro lugares obtenemos exponente real cuatro, sesgo de ciento treinta y uno, y la mantisa empaquetada produce el valor hexadecimal cero cuatro uno de cinco cuatro cero cero cero.
-->

---
transition: slide-up | slide-down
---

# Ejemplo guiado 2: Fracción periódica y truncamiento

<div class="text-xs mb-2 text-gray-300">
Convertir el número decimal <span class="text-rose-400 font-bold font-mono">-13.1</span> a formato IEEE 754 de 32 bits y analizar la pérdida por redondeo.
</div>
<div class="grid grid-cols-2 gap-3 text-xs font-mono">
  <div class="p-2.5 bg-gray-900 border border-gray-700 rounded-lg space-y-1">
  <div class="text-rose-400 font-bold font-sans">Signo y parte entera:</div>
  <div class="text-gray-300 text-[11px]"><i>s</i> = 1 (negativo)</div>
  <div class="text-emerald-400 font-bold text-[11px]">13<sub>10</sub> = 1101<sub>2</sub></div>
  <div class="text-amber-400 font-bold font-sans mt-2">Fracción decimal recurrente:</div>
  <div class="text-gray-300 text-[10px]">0.1 × 2 = 0.2 → 0 | 0.2 × 2 = 0.4 → 0</div>
  <div class="text-gray-300 text-[10px]">0.4 × 2 = 0.8 → 0 | 0.8 × 2 = 1.6 → 1</div>
  <div class="text-gray-300 text-[10px]">0.6 × 2 = 1.2 → 1 | 0.2 × 2 = 0.4 → 0 …</div>
  <div class="text-cyan-300 font-bold text-[11px]">0.1<sub>10</sub> = 0.0<span class="underline">0011</span><sub>2</sub> (Periódico)</div>
  </div>
  <div class="p-2.5 bg-gray-900 border border-gray-700 rounded-lg space-y-1">
  <div class="text-emerald-400 font-bold font-sans">Normalización a 23 bits:</div>
  <div class="text-gray-300 text-[10px]">1101.0001100110011…<sub>2</sub></div>
  <div class="text-gray-300 text-[10px]">Normalizado: 1.10100011001100110011001… × 2<sup>3</sup></div>
  <div class="text-gray-300 text-[10px]"><i>E</i> = 3 ⇒ <i>e</i> = 3 + 127 = 130 = 10000010<sub>2</sub></div>
  <div class="text-gray-400 text-[10px] font-sans mt-1">
      Bit siguiente al corte es 1, aplicando redondeo al par más cercano:
  </div>
  <div class="text-emerald-300 text-[10px] font-bold">
  <i>f</i> = 10100011001100110011010<sub>2</sub>
  </div>
  </div>
</div>
<div v-click="1" class="mt-2 p-2 bg-rose-950/30 border border-rose-500 rounded-lg text-xs font-mono text-center">
  <span class="text-rose-300 font-bold font-sans">Representación final:</span>
  <span class="text-rose-400 ml-2 font-bold">1</span> <span class="text-amber-400 font-bold">10000010</span> <span class="text-emerald-400 font-bold">10100011001100110011010</span> &rarr; Hex: <span class="text-white font-bold">0xC151999A</span>
</div>
<!--
Para el número negativo menos trece punto uno, el signo es uno y la parte entera es once cero uno, pero la fracción de cero punto uno entra en un ciclo periódico infinito de ceros y unos.

[click] Al normalizar con exponente tres y aplicar el redondeo obligatorio al bit más cercano sobre los veintitrés bits de mantisa, obtenemos el valor hexadecimal C uno cinco uno nueve nueve nueve A.
-->

---
transition: slide-left | slide-right
---

# Decodificación inversa: De hexadecimal a decimal

<div class="text-xs mb-2 text-gray-300">
Determinar el valor decimal real codificado en la palabra hexadecimal IEEE 754 de 32 bits: <span class="text-cyan-400 font-bold font-mono">0xC24C0000</span>.
</div>
<div class="border border-gray-700 bg-gray-900 rounded-lg p-3 my-2 font-mono text-xs space-y-2">
  <div class="text-gray-400 text-[11px] font-sans">Paso 1: Expansión a 32 bits binarios</div>
  <div class="text-center font-bold text-gray-200">
  <span class="text-rose-400">1</span><span class="text-amber-400">10000100</span><span class="text-emerald-400">10011000000000000000000</span>
  </div>
  <div class="grid grid-cols-3 gap-2 pt-1 text-[11px]">
  <div class="p-1.5 bg-rose-950/30 border border-rose-700 rounded text-center">
  <span class="text-rose-300 font-bold">Signo:</span> <i>s</i> = 1 ⇒ Negativo
  </div>
  <div class="p-1.5 bg-amber-950/30 border border-amber-700 rounded text-center">
  <span class="text-amber-300 font-bold">Exponente:</span> <i>e</i> = 132<sub>10</sub>
  </div>
  <div class="p-1.5 bg-emerald-950/30 border border-emerald-700 rounded text-center">
  <span class="text-emerald-300 font-bold">Exp. real:</span> <i>E</i> = 132 - 127 = 5
  </div>
  </div>
</div>
<div v-click="1" class="p-3 bg-gray-900 border border-emerald-500/50 rounded-lg text-xs font-mono space-y-1.5">
  <div class="text-emerald-300 font-bold font-sans">Paso 2: Reconstrucción del número con bit 1 implícito</div>
  <div class="text-gray-300 text-[11px]">Significando completo: 1.<i>f</i> = 1.10011000…<sub>2</sub></div>
  <div class="text-gray-300 text-[11px]">Multiplicación por 2<sup><i>E</i></sup>: Desplazar la coma 5 posiciones a la derecha:</div>
  <div class="text-cyan-300 font-bold text-[12px]">110011.0<sub>2</sub> = 32 + 16 + 2 + 1 = 51<sub>10</sub></div>
  <div class="text-emerald-400 font-bold text-sm pt-1">
    Valor decimal final: <span class="text-white">-51.0</span>
  </div>
</div>
<!--
Para el camino inverso, expandimos la palabra hexadecimal C dos cuatro C cero cero cero cero a binario, extrayendo el signo negativo y el exponente ciento treinta y dos, que corresponde a un exponente real de cinco.

[click] Al agregar el uno implícito y desplazar la coma cinco lugares a la derecha, reconstruimos el entero binario cincuenta y uno, confirmando que el valor codificado es exactamente menos cincuenta y uno punto cero.
-->

---
transition: slide-up | slide-down
---

# Aritmética de punto flotante: Suma y resta

<div class="text-xs text-gray-400 mb-6 font-sans">
A diferencia de los enteros, operar dos números en punto flotante exige un procedimiento en cuatro etapas de hardware en la FPU:
</div>
<div class="grid grid-cols-4 gap-6 font-sans my-4">
  <div v-click="1" class="space-y-2">
  <div class="flex items-center space-x-2">
  <span class="w-5 h-5 rounded-full bg-gray-800 text-gray-200 border border-gray-700 flex items-center justify-center text-[11px] font-semibold flex-shrink-0">1</span>
  <span class="text-xs font-semibold text-gray-100">Alinear exponentes</span>
  </div>
  <p class="text-[11px] text-gray-400 leading-relaxed">
      Restar exponentes (<i>e</i><sub>1</sub> - <i>e</i><sub>2</sub>) y desplazar a la derecha la mantisa del menor hasta igualar escalas.
  </p>
  </div>
  <div v-click="2" class="space-y-2">
  <div class="flex items-center space-x-2">
  <span class="w-5 h-5 rounded-full bg-gray-800 text-gray-200 border border-gray-700 flex items-center justify-center text-[11px] font-semibold flex-shrink-0">2</span>
  <span class="text-xs font-semibold text-gray-100">Operar mantisas</span>
  </div>
  <p class="text-[11px] text-gray-400 leading-relaxed">
      Sumar o restar algebraicamente los significandos alineados considerando sus signos de polaridad.
  </p>
  </div>
  <div v-click="3" class="space-y-2">
  <div class="flex items-center space-x-2">
  <span class="w-5 h-5 rounded-full bg-gray-800 text-gray-200 border border-gray-700 flex items-center justify-center text-[11px] font-semibold flex-shrink-0">3</span>
  <span class="text-xs font-semibold text-gray-100">Normalizar</span>
  </div>
  <p class="text-[11px] text-gray-400 leading-relaxed">
      Reajustar la coma a la forma 1.<i>f</i> y compensar el exponente tras posibles desbordamientos o cancelaciones.
  </p>
  </div>
  <div v-click="4" class="space-y-2">
  <div class="flex items-center space-x-2">
  <span class="w-5 h-5 rounded-full bg-gray-800 text-gray-200 border border-gray-700 flex items-center justify-center text-[11px] font-semibold flex-shrink-0">4</span>
  <span class="text-xs font-semibold text-gray-100">Redondear</span>
  </div>
  <p class="text-[11px] text-gray-400 leading-relaxed">
      Ajustar la mantisa a los 23 bits definitivos y verificar excepciones de desbordamiento (+&infin; / underflow).
  </p>
  </div>
</div>
<div class="mt-8 pt-4 border-t border-gray-800 flex items-center justify-between text-[11px] text-gray-400 font-sans px-2">
  <span>Operandos (<i>A</i>, <i>B</i>)</span>
  <span class="text-gray-600 font-bold">&rarr;</span>
  <span>Alineación (<i>e</i><sub>1</sub> = <i>e</i><sub>2</sub>)</span>
  <span class="text-gray-600 font-bold">&rarr;</span>
  <span>Suma de mantisas</span>
  <span class="text-gray-600 font-bold">&rarr;</span>
  <span>Normalización</span>
  <span class="text-gray-600 font-bold">&rarr;</span>
  <span class="text-gray-200 font-medium">Resultado final</span>
</div>
<!--
Sumar dos números en punto flotante en hardware no es directo; la FPU ejecuta un pipeline de cuatro fases obligatorias.

[click] Primero, alinea los exponentes calculando la diferencia y desplazando la mantisa menor a la derecha para equiparar sus escalas de magnitud.

[click] Segundo, realiza la suma o resta aritmética de los significandos ya alineados en la ALU.

[click] Tercero, normaliza el resultado forzando la forma uno punto f y ajustando el exponente según haya ocurrido desbordamiento o cancelación.

[click] Y cuarto, redondea a la cantidad exacta de bits del formato verificando posibles desbordamientos hacia infinito o cero.
-->

---
transition: slide-left | slide-right
---

# Traza práctica de suma en punto flotante

<div class="text-xs mb-3 text-gray-400 font-sans">
Sumar en punto flotante: <i>A</i> = 1.000<sub>2</sub> × 2<sup>3</sup> (8.0) y <i>B</i> = 1.100<sub>2</sub> × 2<sup>1</sup> (3.0).
</div>
<div class="grid grid-cols-4 gap-3 font-sans my-3">
  <div class="p-3 bg-gray-900/60 border border-gray-800 rounded-xl">
  <div class="text-gray-100 font-semibold text-xs mb-1">1. Alinear</div>
  <div class="text-gray-400 text-[11px]">Diferencia: 3 - 1 = 2</div>
  <div class="text-gray-400 text-[11px]">Desplazar <i>B</i> 2 bits:</div>
  <div class="text-emerald-400 font-mono text-[11px] mt-1"><i>B</i> = 0.011<sub>2</sub> × 2<sup>3</sup></div>
  </div>
  <div class="p-3 bg-gray-900/60 border border-gray-800 rounded-xl">
  <div class="text-gray-100 font-semibold text-xs mb-1">2. Sumar</div>
  <div class="text-gray-400 text-[11px]">Mantisa <i>A</i>: 1.000<sub>2</sub></div>
  <div class="text-gray-400 text-[11px]">+ Mantisa <i>B</i>: 0.011<sub>2</sub></div>
  <div class="text-cyan-300 font-mono text-[11px] mt-1">= Suma: 1.011<sub>2</sub></div>
  </div>
  <div class="p-3 bg-gray-900/60 border border-gray-800 rounded-xl">
  <div class="text-gray-100 font-semibold text-xs mb-1">3. Normalizar</div>
  <div class="text-gray-400 text-[11px]">Forma ya normalizada:</div>
  <div class="text-amber-300 font-mono text-[11px] mt-1">1.011<sub>2</sub> × 2<sup>3</sup></div>
  <div class="text-gray-500 text-[10px] mt-1">No requiere ajuste</div>
  </div>
  <div class="p-3 bg-gray-900/60 border border-gray-800 rounded-xl">
  <div class="text-gray-100 font-semibold text-xs mb-1">4. Resultado</div>
  <div class="text-gray-400 text-[11px]">1.011<sub>2</sub> × 2<sup>3</sup></div>
  <div class="text-purple-300 font-mono text-[11px] mt-1">1011.0<sub>2</sub> = 11.0<sub>10</sub></div>
  <div class="text-emerald-400 text-[10px] mt-1">Exacto: 8 + 3 = 11</div>
  </div>
</div>
<div v-click="1" class="p-3 bg-gray-900/80 border border-gray-800 rounded-lg text-xs font-sans text-gray-300">
  <span class="text-rose-400 font-semibold">Peligro de absorción:</span> Si la diferencia de exponentes es mayor a 24 en simple precisión, la mantisa del sumando menor se desplazará más de 23 posiciones hacia la derecha, expulsando todos sus bits significativos. En tal caso, <i>A</i> + <i>B</i> = <i>A</i>, absorbiendo el número menor como si fuera cero.
</div>
<!--
En el ejemplo de ocho más tres, alineamos B desplazando su mantisa dos posiciones, sumamos obteniendo uno punto cero once, y al multiplicarlo por dos al cubo obtenemos once punto cero en decimal.

[click] Noten la advertencia inferior sobre la absorción: si la diferencia de exponentes supera veinticuatro, todos los bits del sumando menor se expulsan al desplazarse, haciendo que el número pequeño sea absorbido por completo como si fuera cero.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Fenómenos en software: La ilusión de los flotantes

<div>
Las particularidades del hardware de punto flotante impactan directamente el desarrollo de software en lenguajes como C, C++ o Python.
</div>
<div class="mt-3 p-3 bg-gray-900 border border-gray-700 rounded-lg text-xs font-mono">
<div class="text-red-400 font-bold mb-1">// El error clásico en C:</div>

```c
float a = 0.1f;
float b = 0.2f;
if (a + b == 0.3f) {
    printf("Iguales\n");
} else {
    printf("Distintos: %.9f\n", a + b);
}
// Salida real: Distintos: 0.300000012
```

</div>

::right::

<div class="mt-8 space-y-3 text-xs">
<div class="p-3 border border-emerald-500/40 bg-emerald-950/20 rounded-lg">
  <strong class="text-emerald-400 font-sans">Comparación segura mediante épsilon (ε):</strong>
  <p class="text-gray-300 mt-1 text-[11px] leading-relaxed">
    Nunca se debe usar el operador de igualdad directa <code class="text-rose-400">==</code> con números de punto flotante. En su lugar, se verifica si la diferencia absoluta es menor que una tolerancia mínima admisible:
  </p>
  <div class="mt-2 p-2 bg-gray-900 border border-gray-700 rounded font-mono text-[11px] text-cyan-300">
    #define EPSILON 1e-6<br>
    if (fabs(a + b - 0.3f) &lt; EPSILON) ...
  </div>
</div>
<div v-click="1" class="p-3 border border-amber-500/40 bg-amber-950/20 rounded-lg text-gray-300">
  <strong class="text-amber-400 font-sans">Acumulación de error en ciclos:</strong>
  <p class="mt-1 text-[11px]">
    Sumar <code class="text-amber-300">0.1f</code> diez millones de veces en un ciclo no produce exactamente un millón, sino un valor desviado debido al redondeo en cada iteración.
  </p>
</div>
</div>
<!--
En el código de la izquierda vemos por qué cero punto uno más cero punto dos no es igual a cero punto tres en C, imprimiendo cero punto trescientos millones doce debido al redondeo de fracciones periódicas.

[click] La solución profesional mostrada a la derecha consiste en comparar siempre con una tolerancia épsilon y tener sumo cuidado con la acumulación progresiva de error en ciclos repetitivos.
-->

---
transition: slide-up | slide-down
---

# Taller en vivo: Ejercicios para resolver en parejas

<div class="text-xs mb-3 text-gray-400 font-sans">
Formen parejas y resuelvan en papel los siguientes dos ejercicios de aplicación práctica en los próximos 10 minutos.
</div>
<div class="grid grid-cols-2 gap-4 text-xs font-sans">
  <div class="p-4 bg-gray-900/60 border border-gray-800 rounded-xl space-y-2">
  <div class="text-blue-400 font-semibold text-sm">Reto A: Conversión a IEEE 754</div>
  <p class="text-gray-200 text-[11px] leading-relaxed">
      Convertir el número decimal <span class="text-cyan-300 font-mono font-bold">-45.75</span> a formato IEEE 754 de simple precisión (32 bits).
  </p>
  <div class="text-gray-400 text-[10px] pt-1 leading-relaxed">
      • Determinar signo, binario entero y fraccionario.<br>
      • Normalizar y calcular exponente sesgado.<br>
      • Expresar el resultado final en hexadecimal.
  </div>
  </div>
  <div class="p-4 bg-gray-900/60 border border-gray-800 rounded-xl space-y-2">
  <div class="text-purple-400 font-semibold text-sm">Reto B: Decodificación inversa</div>
  <p class="text-gray-200 text-[11px] leading-relaxed">
      Decodificar la siguiente palabra hexadecimal de 32 bits a su valor decimal real: <span class="text-purple-300 font-mono font-bold">0x42E80000</span>.
  </p>
  <div class="text-gray-400 text-[10px] pt-1 leading-relaxed">
      • Desglosar campos de signo, exponente y mantisa.<br>
      • Calcular exponente real <i>E</i> = <i>e</i> - 127.<br>
      • Reconstruir el significando con el 1 implícito.
  </div>
  </div>
</div>
<div v-click="1" class="mt-4 p-3 bg-gray-900/80 border border-gray-800 rounded-lg text-xs text-center text-gray-300 font-sans">
  Levanten la mano si tienen dudas intermedias. En breve revisaremos la solución detallada de ambos problemas en la pizarra.
</div>
<!--
Llegó el momento del taller en parejas. Tienen diez minutos para resolver en papel estos dos retos: convertir menos cuarenta y cinco punto setenta y cinco a hexadecimal, y decodificar el valor cuatro dos E ocho cero cero cero cero a decimal.

[click] Trabajen con su compañero y levanten la mano si tienen dudas para asistirles de inmediato.
-->

---
layout: two-cols
transition: slide-left | slide-right
---

# Solución detallada de los ejercicios de taller

<div class="p-4 bg-gray-900/60 border border-gray-800 rounded-xl text-xs font-mono space-y-1">
  <div class="text-blue-400 font-bold font-sans">Solución Reto A: -45.75</div>
  <div class="text-gray-300 text-[11px]">• Signo: <i>s</i> = 1 (negativo)</div>
  <div class="text-gray-300 text-[11px]">• Entero: 45 = 101101<sub>2</sub></div>
  <div class="text-gray-300 text-[11px]">• Fracción: 0.75 = 0.11<sub>2</sub></div>
  <div class="text-gray-300 text-[11px]">• Coma fija: 101101.11<sub>2</sub></div>
  <div class="text-gray-300 text-[11px]">• Normalizado: 1.0110111<sub>2</sub> × 2<sup>5</sup> ⇒ <i>E</i> = 5</div>
  <div class="text-gray-300 text-[11px]">• Exponente: <i>e</i> = 5 + 127 = 132 = 10000100<sub>2</sub></div>
  <div class="text-gray-300 text-[11px]">• Mantisa: 01101110000000000000000<sub>2</sub></div>
  <div class="text-cyan-300 font-bold text-[11px] pt-1">
    Hexadecimal: <span class="text-white">0xC236C000</span>
  </div>
</div>

::right::

<div v-click="1" class="p-4 bg-gray-900/60 border border-gray-800 rounded-xl text-xs font-mono space-y-1">
  <div class="text-purple-400 font-bold font-sans">Solución Reto B: 0x42E80000</div>
  <div class="text-gray-300 text-[11px]">• Binario: <span class="text-rose-400">0</span> <span class="text-amber-400">10000101</span> <span class="text-emerald-400">11010000000...</span></div>
  <div class="text-gray-300 text-[11px]">• Signo: <i>s</i> = 0 (positivo)</div>
  <div class="text-gray-300 text-[11px]">• Exponente: <i>e</i> = 133<sub>10</sub> ⇒ <i>E</i> = 133 - 127 = 6</div>
  <div class="text-gray-300 text-[11px]">• Significando: 1.1101<sub>2</sub></div>
  <div class="text-gray-300 text-[11px]">• Desplazamiento por 2<sup>6</sup>: 1110100.0<sub>2</sub></div>
  <div class="text-gray-300 text-[11px]">• Cálculo: 64 + 32 + 16 + 4 = 116<sub>10</sub></div>
  <div class="text-purple-300 font-bold text-[11px] pt-1">
    Decimal real: <span class="text-white">+116.0</span>
  </div>
</div>
<!--
Revisemos las soluciones: para el Reto A de la izquierda, la normalización da exponente sesgado ciento treinta y dos y mantisa que empaqueta en C dos tres seis C cero cero cero.

[click] Para el Reto B de la derecha, al desempaquetar el exponente ciento treinta y tres y desplazar la mantisa seis lugares obtenemos exactamente ciento dieciséis punto cero.
-->

---
transition: slide-up | slide-down
---

# Ejercicios de práctica recomendados

<div class="text-xs mb-4 text-gray-400 font-sans">
Problemas seleccionados para consolidar el dominio del estándar IEEE 754 y la aritmética en hardware mediante trabajo autónomo:
</div>
<div class="grid grid-cols-2 gap-4 text-xs font-sans">
  <div class="p-4 bg-gray-900/60 border border-gray-800 rounded-xl space-y-2">
  <div class="text-cyan-400 font-semibold text-sm">1. Conversiones y decodificaciones:</div>
  <ul class="space-y-1.5 text-gray-300 text-[11px]">
  <li>• <strong>Ejercicio A:</strong> Convertir -85.125<sub>10</sub> a formato IEEE 754 de simple precisión (32 bits).</li>
  <li>• <strong>Ejercicio B:</strong> Decodificar el patrón hexadecimal <code class="text-cyan-300 font-mono">0x41E40000</code> a su valor decimal.</li>
  <li>• <strong>Ejercicio C:</strong> Representar +0.05<sub>10</sub> en 32 bits identificando su fracción periódica y redondeo.</li>
  </ul>
  </div>
  <div class="p-4 bg-gray-900/60 border border-gray-800 rounded-xl space-y-2">
  <div class="text-amber-400 font-semibold text-sm">2. Aritmética y trazas en hardware:</div>
  <ul class="space-y-1.5 text-gray-300 text-[11px]">
  <li>• <strong>Ejercicio D:</strong> Sumar en 32 bits <i>A</i> = 1.010<sub>2</sub> × 2<sup>4</sup> y <i>B</i> = 1.100<sub>2</sub> × 2<sup>2</sup> con las 4 etapas.</li>
  <li>• <strong>Ejercicio E:</strong> Multiplicar (-6) × (-5) en palabras de 4 bits mediante el algoritmo de Booth.</li>
  <li>• <strong>Ejercicio F:</strong> Explicar si ocurre absorción al sumar 1.0 × 2<sup>30</sup> con 1.0 × 2<sup>5</sup> en 32 bits.</li>
  </ul>
  </div>
</div>
<div v-click="1" class="mt-4 p-3 bg-gray-900/80 border border-gray-800 rounded-lg text-xs text-gray-300 font-sans text-center">
  Recomendación metodológica: Resolver estos ejercicios paso a paso en papel antes de verificar sus resultados con una calculadora binaria o código en C.
</div>
<!--
Para consolidar todo lo aprendido hoy, les dejo esta serie de ejercicios de práctica recomendados.

[click] Incluyen conversiones directas, decodificaciones inversas, sumas en punto flotante y trazas completas de Booth para afianzar el dominio operativo de forma autónoma.
-->

---
transition: slide-left | slide-right
---

# Quiz formativo interactivo

<div class="text-xs mb-4 text-gray-400 font-sans">
Evaluemos los conceptos clave de la jornada contestando mentalmente las siguientes tres preguntas:
</div>
<div class="space-y-3 font-sans">
  <div v-click="1" class="p-3.5 bg-gray-900/60 border border-gray-800 rounded-xl">
  <div class="text-gray-100 font-semibold text-xs mb-1">Pregunta 1:</div>
  <p class="text-gray-300 text-xs">
      En el algoritmo de Booth, si la pareja de bits [<i>Q</i><sub>0</sub>, <i>Q</i><sub>-1</sub>] evaluada es 10, ¿qué operación realiza la ALU?
  </p>
  <div class="text-gray-400 text-[11px] mt-2 font-mono">A) <i>A</i> ← <i>A</i> + <i>M</i> &nbsp;|&nbsp; B) <i>A</i> ← <i>A</i> - <i>M</i> &nbsp;|&nbsp; C) Ninguna operación aritmética</div>
  </div>
  <div v-click="2" class="p-3.5 bg-gray-900/60 border border-gray-800 rounded-xl">
  <div class="text-gray-100 font-semibold text-xs mb-1">Pregunta 2:</div>
  <p class="text-gray-300 text-xs">
      ¿Cuál es el valor del sesgo utilizado en el formato IEEE 754 de simple precisión (32 bits)?
  </p>
  <div class="text-gray-400 text-[11px] mt-2 font-mono">A) 128 &nbsp;|&nbsp; B) 127 &nbsp;|&nbsp; C) 1023</div>
  </div>
  <div v-click="3" class="p-3.5 bg-gray-900/60 border border-gray-800 rounded-xl">
  <div class="text-gray-100 font-semibold text-xs mb-1">Pregunta 3:</div>
  <p class="text-gray-300 text-xs">
      ¿Qué estado especial representa una palabra con todos los bits del exponente en 1 y mantisa distinta de cero?
  </p>
  <div class="text-gray-400 text-[11px] mt-2 font-mono">A) Infinito &nbsp;|&nbsp; B) Cero negativo &nbsp;|&nbsp; C) NaN</div>
  </div>
</div>
<!--
Para cerrar la jornada, hagamos un quiz formativo interactivo.

[click] Pregunta uno: en el algoritmo de Booth, cuando evaluamos la pareja uno cero, ¿qué operación realiza la ALU sobre el acumulador?

[click] Pregunta dos: ¿cuál es el valor exacto del sesgo en simple precisión de treinta y dos bits?

[click] Y pregunta tres: ¿qué representa en IEEE 754 una palabra con exponente lleno de unos y mantisa no nula? Piénsenlo unos segundos antes de ver las soluciones.
-->

---
transition: slide-up | slide-down
---

# Respuestas comentadas del quiz

<div class="space-y-3 font-sans">
  <div v-click="1" class="p-3.5 bg-gray-900/60 border border-gray-800 rounded-xl">
  <div class="flex justify-between items-center text-xs">
  <span class="text-emerald-400 font-semibold">Respuesta 1: B) <i>A</i> ← <i>A</i> - <i>M</i></span>
  <span class="text-gray-400 text-[10px]">Inicio de bloque</span>
  </div>
  <p class="text-gray-300 text-[11px] mt-1.5 leading-relaxed">
      La transición 10 marca el inicio de una secuencia de unos consecutivos en el multiplicador, lo que exige restar el multiplicando del acumulador antes del desplazamiento aritmético.
  </p>
  </div>
  <div v-click="2" class="p-3.5 bg-gray-900/60 border border-gray-800 rounded-xl">
  <div class="flex justify-between items-center text-xs">
  <span class="text-emerald-400 font-semibold">Respuesta 2: B) 127</span>
  <span class="text-gray-400 text-[10px]">Sesgo de 8 bits</span>
  </div>
  <p class="text-gray-300 text-[11px] mt-1.5 leading-relaxed">
      Para un campo de 8 bits de exponente, el sesgo estándar corresponde a 2<sup>8-1</sup> - 1 = 128 - 1 = 127, permitiendo representar exponentes reales entre -126 y +127.
  </p>
  </div>
  <div v-click="3" class="p-3.5 bg-gray-900/60 border border-gray-800 rounded-xl">
  <div class="flex justify-between items-center text-xs">
  <span class="text-emerald-400 font-semibold">Respuesta 3: C) NaN</span>
  <span class="text-gray-400 text-[10px]">Indeterminación</span>
  </div>
  <p class="text-gray-300 text-[11px] mt-1.5 leading-relaxed">
      El exponente máximo con mantisa no nula codifica una indeterminación matemática producida por operaciones inválidas, preservando la estabilidad del procesador.
  </p>
  </div>
</div>
<!--
Revisemos las respuestas:

[click] Para la pregunta uno, la opción correcta es B: restar M del acumulador, pues uno cero señala la entrada a una cadena de unos.

[click] Para la pregunta dos, la opción correcta es B: ciento veintisiete en simple precisión.

[click] Y para la pregunta tres, la opción correcta es C: NaN, codificando una indeterminación matemática por operaciones inválidas.
-->

---
layout: center
transition: fade
---

# Conclusiones y preparación para la Semana 05

<div class="max-w-xl mx-auto text-center space-y-4">
  <div class="text-sm text-gray-300 leading-relaxed font-sans">
    Hemos culminado con éxito el bloque fundacional de sistemas numéricos y aritmética digital de bajo nivel (Semanas 01 a 04).
  </div>
  <div class="p-4 bg-gray-900/90 border border-blue-500/50 rounded-xl text-left text-xs space-y-2 font-sans">
  <div class="text-blue-400 font-bold font-mono text-sm">Próxima sesión: Semana 05</div>
  <div class="text-white font-semibold">Introducción al lenguaje C y ensamblador x86</div>
  <ul class="space-y-1 text-gray-300 text-[11px] pt-1">
  <li>• Estructura básica de un programa en lenguaje C y en NASM</li>
  <li>• Banco de registros x86: RAX, RBX, RCX, RDX, RSI, RDI, RSP, RBP</li>
  <li>• Primeras instrucciones de transferencia y aritmética: <code class="text-cyan-300">mov</code>, <code class="text-cyan-300">add</code>, <code class="text-cyan-300">sub</code></li>
  <li>• Depuración interactiva paso a paso con GDB</li>
  </ul>
  </div>
  <div class="text-xs text-gray-400 font-sans">
    ¡Muchos éxitos con los ejercicios de práctica y nos vemos la próxima semana!
  </div>
</div>
<!--
Hemos llegado al final de nuestra sesión y con ello cerramos el primer bloque del curso. 

La próxima semana daremos inicio a la programación en ensamblador x86 con NASM y C. No olviden repasar los ejercicios prácticos recomendados. ¡Muchas gracias a todos y nos vemos en la próxima tutoría!
-->
