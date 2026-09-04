---
name: slidev-presentations
description: Skill unificada para diseñar, programar y estructurar presentaciones web inmersivas y dinámicas con Slidev (Markdown + Vue) para tutorías de Arquitectura de Computadores (IC3101), incluyendo estructura bi-sesional (2 sesiones de 1.5h por semana en S01-S16 con diapositiva divisoria), extracción de figuras PDF, generación de guiones orales de exposición con [click], diagramación técnica en código y gestión estricta con pnpm.
---

# Generador Unificado de Presentaciones con Slidev (IC3101)

Este agente/skill automatiza el diseño, programación y redacción de presentaciones web interactivas y material pedagógico para las tutorías de **Arquitectura de Computadores (IC3101)**, empleando el framework **Slidev** (basado en Vite, Vue y Markdown).

---

## 1. Nomenclatura y Estructura Bi-Sesional (2 sesiones x 1.5 h por semana)
* **Nomenclatura de carpetas:** Nombrar las semanas estrictamente como `S01/`, `S02/`, `S03/`, ..., `S16/` (prefijo `S` en mayúscula y dos dígitos).
* **Un único proyecto Slidev por semana:** Cada carpeta `SXX/` contiene su propio proyecto Slidev y un único archivo `slides.md`.
* **Capacidad bi-sesional completa:** Cada presentación `slides.md` debe estructurarse para cubrir dos sesiones independientes de tutoría de **1.5 horas (90 minutos)** cada una (3 horas totales a la semana):
  - **Bloque 1 (Sesión 1 - 90 min):** Fundamentos teóricos, modelos arquitectónicos, análisis de conceptos clave y primeros ejemplos guiados.
  - **Diapositiva divisoria intermedia:** Diapositiva especial (`layout: section`) que marca el inicio de la **Sesión 2**, recapitulando los fundamentos previos y listando los objetivos del taller práctico.
  - **Bloque 2 (Sesión 2 - 90 min):** Profundización técnica de bajo nivel, taller práctico en vivo (ejercicios paso a paso en ensamblador / C / cálculo binario / trazas de pipeline) y retos formativos de consolidación.
* **Extensión adecuada:** Generar un deck completo (generalmente entre 20 y 35 diapositivas bien estructuradas) para cubrir holgadamente ambas jornadas con alta densidad técnica y visual.
* **Alineación y verificación obligatoria contra `CRONOGRAMA.md`:**
  - Antes de diseñar o dar por concluida cualquier semana `SXX/slides.md`, se DEBE cotejar punto por punto la lista de temas teóricos (Sesión 1) y prácticos (Sesión 2) definidos en `CRONOGRAMA.md`.
  - Todo concepto de teoría debe tener su diapositiva explicativa y todo taller práctico, herramienta (ej. GDB, Make, GCC) o trampa recurrente debe estar integrado con ejemplos interactivos y ejercicios de consolidación correspondientes.

---

## 2. Reglas de Herramientas y Terminal
* **Gestor de paquetes exclusivo:** DEBES usar EXCLUSIVAMENTE `pnpm` para la instalación y gestión de dependencias (ej. `pnpm install`, `pnpm run dev`, `pnpm add -D`).
* **Ejecución al vuelo:** Usar `pnpx` o `pnpm dlx` (ej. `pnpx create-slidev`).
* **Herramientas auxiliares de Python:** Ejecutar los scripts auxiliares con `uv run` (ej. `uv run .agents/skills/slidev-presentations/scripts/extract_figure.py ...`).
* **Prohibido:** Queda terminantemente prohibido usar `npm` o `yarn`.

---

## 3. Reglas de Diseño Visual y Aprovechamiento de Slidev
Las diapositivas NO deben ser genéricas ni consistir únicamente en listas interminables de viñetas (*bullet points*).
* **Aprovechamiento intensivo de layouts:**
  - `layout: two-cols` para contrastar conceptos teóricos o dividir texto y diagramas (usando `::right::`).
  - `layout: section` para la diapositiva divisoria intermedia de la **Sesión 2**.
  - `layout: statement` o `quote` para axiomas, definiciones críticas o cambios de bloque temático.
  - `layout: image-right` o `image-left` para explicaciones asistidas por diagramas o figuras extraídas.
* **Separación garantizada en `two-cols` (Evitar columnas pegadas):**
  - La plantilla base de Slidev define `grid grid-cols-2` sin separación horizontal, provocando que los bloques de ambas columnas se toquen en la línea media.
  - En cada proyecto `SXX/` se debe incluir un layout personalizado en `layouts/two-cols.vue` con la clase de separación **`gap-x-12`** (o `gap-x-10`):
    ```vue
    <script setup lang="ts">
    const props = defineProps({ class: { type: String }, layoutClass: { type: String } })
    </script>
    <template>
      <div class="slidev-layout two-columns w-full h-full grid grid-cols-2 gap-x-12" :class="props.layoutClass">
        <div class="col-left" :class="props.class"><slot /><slot name="left" /></div>
        <div class="col-right" :class="props.class"><slot name="right" /></div>
      </div>
    </template>
    ```
* **Estilos globales y animaciones suaves (`styles/index.css`):**
  - En Slidev, los bloques `<style>` colocados dentro de `slides.md` quedan automáticamente aislados (*scoped*) a la diapositiva específica donde se redactan.
  - Para animaciones globales y estilos transversales, crear siempre `styles/index.css`:
    ```css
    .slidev-vclick-target {
      transition: opacity 350ms cubic-bezier(0.16, 1, 0.3, 1), transform 350ms cubic-bezier(0.16, 1, 0.3, 1);
    }
    .slidev-vclick-hidden {
      opacity: 0;
      transform: translateY(10px);
      pointer-events: none;
    }
    ```
* **Transiciones direccionales bidireccionales:**
  - Emplear siempre transiciones bidireccionales (`transition: slide-left | slide-right` para el flujo general, `transition: slide-up | slide-down` para divisoria de sesión, y `transition: fade` para portadas y conclusiones) de modo que el avance y retroceso entre diapositivas sea natural y consistente.
* **Jerarquía de texto (Evitar subtítulos atenuados):**
  - En Slidev, colocar un encabezado `##` inmediatamente después de un `#` hace que se renderice automáticamente con estilo opaco (*muted*). Si se trata de un párrafo normal o descriptivo, usar párrafos estándar de Markdown, no un encabezado.
* **Prohibición de sangría de 4 espacios tras línea en blanco en HTML:**
  - En la especificación estándar de Markdown, cualquier línea indentada con 4 espacios o tabulaciones después de una línea en blanco se interpreta automáticamente como un **bloque de código indentado** (`<pre><code>`), escapando las etiquetas HTML como texto crudo visible.
  - Al escribir estructuras HTML (como tarjetas dentro de un grid), NUNCA dejar líneas en blanco intermedias seguidas de etiquetas sangradas con 4 espacios; mantener el bloque HTML continuo o indentado con 2 espacios.
* **Estética visual minimalista y técnica (Evitar diseño genérico/boilerplate):**
  - **Prohibición de bordes gruesos y franjas de colores chillones:** NO usar `border-2 border-color-500`, `border-t-4`, `border-l-4` ni fondos hipersaturados que parezcan generados por plantillas automáticas.
  - **Prohibición de tarjetas monótonas repetitivas en la columna izquierda:** NO estructurar todas las diapositivas con 3 cajas rectangulares genéricas apiladas verticalmente. Emplear una rica variedad de patrones de diseño:
    1. **Patrón A — Jerarquía vertical / Línea de tiempo conectada:** Línea guía vertical (`border-l-2 border-gray-200 dark:border-gray-800`), nodos con puntos de color (`w-2.5 h-2.5 rounded-full ring-4 ring-white dark:ring-gray-950`), badges en sans-serif (`text-[9.5px] font-semibold px-2 py-0.5 rounded-full`), conectores de transición (`&darr;`) y párrafos fluidos sin recuadros pesados.
    2. **Patrón B — Flujo conector con flechas (`Concepto ----> Sintaxis/Código`):** Título a la izquierda, flecha estilizada `&mdash;&mdash;&gt;`, etiqueta de código/sintaxis (`<code>`) y explicación directa indentada sin cajas envolventes.
    3. **Patrón C — Tarjeta unificada estructural (Blueprint card):** Un único contenedor estilizado que refleja la anatomía del archivo de código (ej. `.data`, `.bss`, `.text` divididos con separadores `border-t border-gray-200 dark:border-gray-800/80`), en simetría con el bloque de código de la derecha.
    4. **Patrón D — Tablas comparativas y matrices técnicas independientes:** Tablas compactas con cabeceras sobrias, bordes limpios y título fuera del contenedor, sin envolverlas innecesariamente en tarjetas cerradas.
  - **Tablas limpias sin tarjeta envolvente:**
    - El título de la tabla debe situarse fuera (`<div class="text-blue-600 dark:text-blue-400 font-bold mb-2 text-[11px] font-sans">Título</div>`).
    - La tabla debe tener sus propios encabezados limpios (`border-b border-gray-300 dark:border-gray-700`), filas contrastadas (`divide-y divide-gray-200 dark:divide-gray-800 text-gray-700 dark:text-gray-300`) y estructura independiente.
  - **Accesibilidad y soporte bidireccional de temas (Claro y Oscuro):**
    - Todo texto, tarjeta, badge y elemento visual DEBE tener contraste accesible verificado tanto en tema claro como en tema oscuro (usando prefijos `dark:`).
    - **Subtítulos bajo `# Título`:** Usar siempre `text-gray-600 dark:text-gray-400` (NUNCA `text-gray-300` a secas, ya que resulta invisible sobre fondo blanco).
    - **Párrafos descriptivos:** Usar `text-gray-600 dark:text-gray-300` o `text-gray-700 dark:text-gray-300`.
    - **Contenedores y tarjetas:** Usar `bg-gray-50 border border-gray-200 dark:bg-gray-900/60 dark:border-gray-800`.
    - **Badges y chips de código:**
      - Azul: `bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/60 dark:text-blue-300 dark:border-blue-800/40`
      - Esmeralda: `bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-300 dark:border-emerald-800/40`
      - Ámbar: `bg-amber-50 text-amber-800 border border-amber-200 dark:bg-amber-950/60 dark:text-amber-300 dark:border-amber-800/40`
      - Púrpura: `bg-purple-50 text-purple-700 border border-purple-200 dark:bg-purple-950/60 dark:text-purple-300 dark:border-purple-800/40`
      - Rosa: `bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/60 dark:text-rose-300 dark:border-rose-800/40`
      - Cyan: `bg-cyan-50 text-cyan-800 border border-cyan-200 dark:bg-cyan-950/60 dark:text-cyan-300 dark:border-cyan-800/40`
  - **Pipelines y pasos ordenados:** En lugar de cajas desconectadas o tablas pesadas, usar flujos de procesos limpios con números circulares sobrios (`1`, `2`, `3`, `4`) y conectores sutiles en escala de grises.
  - **Registros y diagramas de bits:** Diseñar los campos de datos como barras segmentadas elegantes de una sola pieza con tintes pasteles/apagados (`bg-rose-950/30`, `bg-blue-950/30`, `bg-emerald-950/30`) y etiquetas en minúsculas (*Signo (s)*, *Exponente (e)*, *Mantisa (f)*).
* **Iluminación progresiva de líneas de código (*Line Highlighting* interactivo):**
  - Siempre que se explique un fragmento de código, utilizar la sintaxis `{all|rango_1|rango_2|...}` sincronizada 1:1 con las revelaciones de la columna izquierda (ej. ````c {all|1|7,16-17|4-5,9-10|12-15}````).
* **Centrado limpio y temas automáticos de diagramas Mermaid:**
  - **Prohibición de `theme: 'dark'` o `theme: 'neutral'` cableados:** NO fijar temas rígidos en el bloque ```` ```mermaid {theme: 'dark'} ````; permitir que el sistema CSS global (`styles/index.css`) controle la reactividad clara/oscura.
  - **Pipelines con salidas/artefactos laterales:** Cuando un flujo requiera una columna central rígida (ej. fases de compilación `gcc`, pipelines de instrucciones) con flechas hacia la derecha apuntando a artefactos (`ejemplo.c`, `ejemplo.s`), NO usar diagramas ramificados en Mermaid (el motor Dagre fuerza una estructura en árbol/zigzag desplazando la columna principal). En su lugar, estructurar el pipeline con HTML/Tailwind nativo, donde la columna principal se mantiene 100% vertical, los conectores verticales cortan limpiamente en las etiquetas de herramientas (`gcc -E`, `as`, `ld`) sin líneas cruzadas, y las flechas laterales apuntan con precisión a badges de archivo (`bg-emerald-50 text-emerald-700`).
* **Separación estricta de la Sesión 2 en 2 diapositivas independientes:**
  - **Diapositiva A (Portada de Sesión 2):** Diapositiva centrada (`layout: center`, `transition: slide-up | slide-down`) con número de semana, título de la sesión (usar `# Sesión 02: Práctica guiada` o `# Sesión 02: Práctica de laboratorio`, PROHIBIDO "Taller práctico") y subtítulo. Queda estrictamente prohibido colocar los objetivos en esta diapositiva.
  - **Diapositiva B (Objetivos de la Sesión 2):** Diapositiva independiente (`transition: fade`) con `# Objetivos de la segunda sesión`, lista `<v-clicks>` y guión oral sincronizado.
* **Estandarización de actividades prácticas (Kicker `Práctica`):**
  - **Prohibición de `# Taller X: [Nombre]`:** En las diapositivas de la Sesión 2, PROHIBIDO titular directamente con `Taller 1`, `Taller 2`, etc.
  - **Kicker sobrio y Sentence Case:** Utilizar un kicker superior con la palabra fija **`Práctica`** en Sentence Case y color apagado (*muted*), seguido del título temático en `# [Nombre en Sentence Case]`:
    ```html
    <div class="text-[10px] font-semibold text-gray-500 dark:text-gray-400 tracking-wider mb-1 font-mono">
      Práctica
    </div>

    # Nombre de la actividad práctica
    ```
* **Cobertura y estructura de preguntas de práctica (Sin límite de 3 preguntas):**
  - **Prohibición de "Mini-quiz":** PROHIBIDO titular `# Mini-quiz formativo (Sesión X)` o `# Quiz corto`. Utilizar denominaciones académicas limpias como `# Ejercicios de práctica` y `# Ejercicios de práctica (Parte 2)` (o `# Desafíos de consolidación`).
  - **Multi-diapositiva de práctica obligatoria:** En las tutorías de 90 minutos de práctica, 3 preguntas resultan insuficientes para evaluar la totalidad de destrezas de la semana. Por lo tanto, **NO limitar los ejercicios a una sola diapositiva ni a un máximo de 3 preguntas**.
  - **Distribución balanceada (6 a 9 preguntas en 2 o 3 diapositivas):**
    - Diseñar **entre 2 y 3 diapositivas consecutivas de ejercicios de práctica**.
    - Mantener un máximo de **3 preguntas por diapositiva** para garantizar aireación vertical, tipografía legible y evitar saturación visual.
    - Asegurar que el conjunto de preguntas cubra exhaustivamente todas las áreas de la Sesión 2 descritas en `CRONOGRAMA.md` (ej. sintaxis y tipos de datos, interpretación de registros y banderas, depuración con GDB/herramientas y diagnóstico de trampas/errores comunes).
* **Distribución en columnas para opciones de preguntas (`A)`, `B)`, `C)`, `D)`):**
  - **Prohibición de opciones en párrafo continuo:** PROHIBIDO listar opciones dentro de un mismo `<p>` o en texto continuo donde las opciones largas salten de línea hacia el margen izquierdo cortando la lectura de la opción previa.
  - **Columnas alineadas con envoltura vertical interna:** Estructurar las opciones en columnas independientes con cuadrícula (`grid grid-cols-... items-start`) o flexbox, con la letra fija (`<span class="font-bold shrink-0">A)</span>`) y el texto al lado (`<span>`):
    ```html
    <div class="grid grid-cols-3 gap-3 text-[9.5px] text-gray-700 dark:text-gray-300 mt-1.5 items-start leading-snug">
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">A)</span>
        <span>Opción corta</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">B)</span>
        <span>Opción larga cuyo texto si supera el ancho envuelve debajo de sí misma sin saltar al inicio de la fila</span>
      </div>
      <div class="flex items-start gap-1">
        <span class="font-bold text-gray-900 dark:text-gray-100 shrink-0">C)</span>
        <span>Tercera opción en su respectiva columna</span>
      </div>
    </div>
    ```
* **Principio de ligereza visual y anti-cajas (*Anti-card wrapping*):**
  - **Las tarjetas NO son un fondo decorativo universal:** PROHIBIDO envolver tablas comparativas, diagramas Mermaid, bloques de código, flujos con flechas o capturas de terminal dentro de tarjetas genéricas (`bg-gray-50 border ... rounded-xl`).
  - Cada componente técnico debe lucir su propia estructura: las tablas con sus cabeceras limpias, los terminales con su marco nativo de ventana, y los flujos con sus nodos y conectores directos.
  - Usar tarjetas exclusivamente cuando sea necesario agrupar semánticamente bloques fragmentados de texto o pares de datos (como la cuadrícula 2x2 de los registros EAX, EBX, ECX, EDX).
* **Centrado armónico de títulos en artefactos técnicos:**
  - Todo título que corone una tabla, una jerarquía de registros, un bloque de comandos o una captura gráfica en la columna derecha debe estar centrado horizontalmente (`text-center`), en tipografía sans-serif (`font-sans`), peso negrita (`font-bold`) y tamaño sobrio (`text-[11px]` o `text-[10.5px]`), con el acento cromático institucional (`text-blue-600 dark:text-blue-400 mb-1.5`).
* **Prohibición de mini-títulos redundantes dentro de paneles:**
  - Evitar colocar mini-encabezados interiores que repitan lo que ya declara el título principal `#` o el subtítulo de la diapositiva (ej. en una diapositiva titulada `# Banco de registros x86`, evitar insertar un subtítulo interno como `Registros de propósito general (32 bits)`). Reducir el ruido textual para resaltar el contenido técnico.
* **Ajuste compacto de tarjetas (*Fit-content* sin vacíos innecesarios):**
  - Las tarjetas (`cards`) deben abrazar su contenido real con espaciado vertical ceñido (`px-2 py-1` o `p-2`, `leading-tight` o `leading-snug`). PROHIBIDO dejar tarjetas con alturas desmedidas o vacíos verticales desproporcionados.
  - En desglose de registros o banderas (ej. FLAGS), evitar badges redundantes de cabecera (`Acarreo`, `Cero`) cuando la estructura directa en una sola fila `FLAG: Explicación` resulte más compacta y legible.
* **Prohibición de acotaciones redundantes entre paréntesis:**
  - PROHIBIDO incluir notas obvias o redundantes entre paréntesis dentro de títulos o tarjetas (ej. `(TUI: ...)`, `(16 bits)` cuando el bus o registro lo hace evidente, `(IA-32)`, `(sin prefijos %)`). Redactar explicaciones limpias y directas.
* **Alineación geométrica y flechas explicativas en comandos:**
  - Al desglosar comandos o instrucciones mediante flechas SVG:
    - La coordenada $X$ de origen de cada flecha debe coincidir con el centro geométrico exacto del parámetro o badge superior.
    - Configurar los marcadores con `refX="5"` y finalizar la línea 4px antes del borde de la tarjeta para evitar que la punta quede tapada o cortada por el contenedor receptor.
    - Para tarjetas contiguas, emplear codos en ángulo recto (`└──►`) que desplacen la tarjeta lateralmente.
* **Marcadores y transformaciones animadas:**
  - Usar marcadores visuales `v-mark` (ej. `<span v-mark="{ at: 1, color: 'red', type: 'underline' }">...</span>`).
  - Utilizar transformaciones de código animadas con `magic-move` (```` ````md magic-move ```` ````).
  - Usar revelado progresivo con `<v-clicks>` o directivas `v-click="N"`.

---

## 4. Renderizado de Expresiones Matemáticas y Variables (Regla Anti-Dólar)
* **Limitación de Markdown-it en etiquetas HTML:**
  - La sintaxis LaTeX `$ ... $` solo es procesada por Slidev cuando se encuentra en texto Markdown puro. Si se coloca dentro de etiquetas HTML personalizadas (`<div class="...">`, `<p>`, `<td>`, `<span>`, tarjetas o grids de Tailwind), el parser no la interpreta y renderiza los signos de dólar crudos (`$n$`, `$Q_0$`).
* **Tipografía semántica y nativa HTML/Unicode obligatoria en tarjetas y tablas:**
  - **Variables y dimensiones:** Usar cursiva estándar `<i>n</i> bits`, `2<i>n</i> bits`, `<i>s</i>`, `<i>e</i>`, `<i>f</i>`, `<i>E</i>`.
  - **Subíndices y registros:** Usar `<i>Q</i><sub>0</sub>`, `<i>Q</i><sub>-1</sub>`, `[<i>Q</i><sub>0</sub>, <i>Q</i><sub>-1</sub>]`, `[<i>A</i>, <i>Q</i>]`, `<i>A</i><sub><i>n</i>-1</sub>`.
  - **Operaciones y flechas:** Usar `<i>A</i> ← <i>A</i> - <i>M</i>`, `<i>A</i> ← <i>A</i> + <i>M</i>`, `<i>D</i> = <i>Q</i> × <i>V</i> + <i>R</i> (con 0 ≤ <i>R</i> &lt; <i>V</i>)`.
  - **Bases y exponentes:** Usar `26<sub>10</sub> = 11010<sub>2</sub>`, `2<sup>8-1</sup> - 1 = 127`, `1.98 × 10<sup>30</sup> kg`.
  - **Fórmulas destacadas:** `Valor = (-1)<sup><i>s</i></sup> × 2<sup><i>e</i> - sesgo</sup> × (1.<i>f</i>)<sub>2</sub>`.
* **Bloques KaTeX puros:** Reservar `$$ ... $$` exclusivamente para bloques de ecuaciones complejas independientes, separados con líneas en blanco y fuera de etiquetas HTML.

---

## 5. Diagramación Técnica y Recursos Gráficos
* **Prioridad absoluta al código:**
  - Diseñar todos los diagramas arquitectónicos (buses, ALU, microarquitecturas, pipelines, layouts de memoria, mapas de registros) mediante código nativo en `mermaid`, `plantuml`, HTML/Tailwind Grid o LaTeX/KaTeX.
  - Consultar `references/diagram_templates_slidev.md` para ver patrones listos de registros x86, stack frames, matrices de pipeline con stalls y jerarquías de memoria.
* **Extracción limpia de figuras desde PDFs (`extract_figure.py`):**
  - Cuando se requiera un esquema de alta complejidad proveniente de los libros oficiales en `Libros/` (*Stallings*, *Sivarama*, *Peter Abel*, *Libro C*), extraer la figura mediante el script:
    ```bash
    uv run .agents/skills/slidev-presentations/scripts/extract_figure.py \
      --pdf "Libros/Stallings - Computer_Organization_and_Architecture_9th_Edition.pdf" \
      --page 54 \
      --output "S01/public/images/fig_alu.png" \
      --bbox 0.15 0.10 0.55 0.90
    ```
  - **PROHIBIDO incluir leyendas o números de figura del libro original** dentro del recorte. El recorte debe contener estrictamente el gráfico limpio.
* **Capturas reales de terminal para ejecución y depuración de programas (Skill `capturas-terminal`):**
  - **Evidencia verídica obligatoria:** Siempre que una diapositiva requiera mostrar la ejecución de un programa en terminal, depuración interactiva con GDB, salida de comandos de Linux, árboles de procesos o pruebas prácticas, DEBES usar EXCLUSIVAMENTE la skill `capturas-terminal`.
  - **Prohibición terminante de imágenes sintéticas o maquetas HTML:**
    - PROHIBIDO crear tarjetas con fondo negro simulando ventanas de terminal (`<div class="bg-gray-950 ...">`).
    - PROHIBIDO generar imágenes sintéticas con Python (Pillow/PIL), SVG o Canvas.
    - Se debe abrir una ventana gráfica real de **Alacritty**, ejecutar el comando o sesión de depuración y capturar la ventana activa con **Spectacle** (`spectacle -b -n -a -o ...`).
  - **Uso exclusivo de Alacritty y Spectacle:**
    - Usar `alacritty` exclusivamente (NO Konsole, NO xterm).
    - Dimensiones controladas: `-o "window.dimensions.columns=80..85"` y `-o "window.dimensions.lines=20..24"`.
    - Título de ventana descriptivo y en **Sentence Case** obligatorio (PROHIBIDO títulos genéricos como `"Terminal"`, `"Mockup"`, `"Prueba"` o `"Consola"`).
  - **Ubicación limpia fuera de tarjetas envolventes (Anti-card wrapping):**
    - Las capturas de terminal de Alacritty ya incorporan de forma nativa la barra de título, controles de ventana, bordes y sombra de KDE Plasma / Wayland.
    - PROHIBIDO envolver la captura dentro de un contenedor o tarjeta adicional (`bg-gray-50 border ... rounded-xl`).
    - Colocar el título temático afuera (`<div class="text-blue-600 dark:text-blue-400 font-bold text-center mb-1.5 font-sans text-[11px]">Título</div>`), la imagen directa (`<img src="/images/...png" class="rounded-lg shadow-md max-h-72 object-contain" />`) y el pie explicativo abajo en texto sutil (`text-[9px] text-gray-500 dark:text-gray-400 text-center font-sans mt-1.5`).
  - **Seguridad en la gestión de procesos (PROHIBIDO `killall alacritty`):**
    - NUNCA ejecutar `killall alacritty` ni `killall -9 alacritty`, ya que cierra de golpe la terminal de trabajo activa del usuario.
    - Capturar siempre el PID específico del subshell o terminal lanzado en segundo plano (`TERM_PID=$!`) y finalizar estrictamente dicho proceso (`kill -9 $TERM_PID 2>/dev/null || true`).
  - **Rutas de depuración limpias y sin saltos feos:**
    - Al compilar binarios para depuración con GDB, usar rutas relativas o `-fdebug-prefix-map=$PWD=.` para evitar que rutas absolutas largas provoquen saltos de línea antiestéticos en el terminal.
* **Prohibición de estilo IA neón:**
  - Queda prohibido generar imágenes con estética *cyberpunk*, neón, brillos exagerados o degradados magenta/cyan. Los gráficos deben ser sobrios, planos (*flat design*) y académicos.
* **Rutas públicas en Slidev:**
  - Todas las imágenes deben ubicarse en `SXX/public/` para que las rutas relativas en Markdown (`/images/nombre.png`) funcionen correctamente.

---

## 6. Reglas Estrictas de Redacción y Calidad Editorial
* **Sentence Case estricto:** Obligatorio en todos los títulos (`#`), subtítulos, viñetas, tarjetas, diagramas y tablas. Solo la primera letra va en mayúscula, salvo nombres propios y acrónimos estándar (*CPU*, *ALU*, *RAM*, *ROM*, *RISC*, *CISC*, *CPI*, *NASM*, *ISA*, *RAX*, *EAX*, *ESP*, *EBP*).
* **Prohibición de redundancia bilingüe:**
  - PROHIBIDO duplicar términos en español e inglés entre paréntesis (ej. evitar *Pila (stack)*, *Montículo (heap)*, *Registros (registers)*, *Interrupciones (interrupts)*).
  - Usar directamente el término técnico formal en español (o el término estándar en inglés si aplica, pero nunca ambos duplicados).
* **Puntuación y fluidez:**
  - PROHIBIDO usar el símbolo de punto y coma (`;`) y los guiones (`-` o `—`) para separar oraciones o ideas secundarias dentro del texto continuo.
  - Emplear párrafos cohesionados con conectores de transición (*asimismo*, *por consiguiente*, *de manera complementaria*, *en este sentido*).
* **Prohibición de emojis y meta-texto:**
  - Cero emojis en títulos, diapositivas o guiones.
  - Cero frases auto-referenciales ("En esta diapositiva veremos...").

---

## 7. Guiones de Exposición Oral y Sincronización de Clics
Cada diapositiva debe contar con su correspondiente bloque de notas (`<!-- ... -->`) estructurado como un **guión oral completo**:
* **Rol y tono:** Redactado en primera persona con la voz de un tutor universitario dinámico, empático y técnicamente riguroso (*"Notemos cómo el registro EAX...", "Veamos qué ocurre en el bus cuando..."*).
* **Complementariedad oral-visual:** El guión NO debe limitarse a leer lo que está escrito en pantalla. Debe aportar la **explicación profunda**, la **analogía intuitiva** y el hilo conductor que acompaña a los diagramas.
* **Regla de sincronización exacta de `[click]` en modo presentador:**
  - **Click 0 (estado inicial):** El texto de las notas que precede al primer marcador `[click]` debe corresponder **estrictamente a la introducción o contexto visible al entrar a la diapositiva**.
  - **Click 1 y subsecuentes:** La explicación del primer elemento que aparece con `v-click="1"` o `<v-clicks>` **debe situarse inmediatamente después del primer marcador `[click]`**, nunca antes de este.
  - **Concordancia 1:1:** Cada aparición o transición interactiva debe tener exactamente un marcador `[click]` en la posición correspondiente del guión oral.
* **Preguntas de verificación e interacción:**
  - Incluir preguntas detonantes al final de conceptos clave para fomentar la participación de los estudiantes en ambas sesiones.
* **Guión consolidado (`GUION.md`):**
  - Cada proyecto de semana debe compilar el guión completo en `SXX/GUION.md` para lectura continua, repaso o impresión del tutor.

---

## 7. Temario Integrado y Distribución Bi-Sesional (Semanas S01 a S16)

Cada semana desglosa con precisión el contenido de la **Sesión 1** y la **Sesión 2**:

### S01: Introducción a la arquitectura de computadoras
* **Sesión 1 (Teoría):** Arquitectura vs organización. Evolución histórica de computadoras. Visión del programador (CPU, registros, memoria). Métricas de rendimiento, frecuencia de reloj y CPI.
* **Sesión 2 (Práctica):** Diagnóstico de conocimientos previos. Ejercicios de bases de programación y sistemas numéricos. Preparación metodológica de la tutoría.
* **Bibliografía:** Stallings (capítulos 1 y 2), Sivarama (capítulos 1 y 4).

### S02: Infraestructura de software y sistemas numéricos
* **Sesión 1 (Teoría):** Cadena de desarrollo: compilador, ensamblador, linker, loader y OS. Código fuente vs objeto vs ejecutable. Representación binaria y hexadecimal.
* **Sesión 2 (Práctica):** Taller de conversiones numéricas avanzadas. Configuración del entorno Linux y primer programa en ensamblador con NASM.
* **Bibliografía:** Stallings (capítulo 9), Sivarama (capítulos 5 al 8).

### S03: Enteros, complemento a dos y unidad aritmético lógica (ALU)
* **Sesión 1 (Teoría):** Enteros con y sin signo, rangos y desbordamiento (*overflow*). Complemento a dos. Arquitectura interna y funciones de la ALU.
* **Sesión 2 (Práctica):** Taller de operaciones aritméticas/lógicas binarias en papel y en NASM. Verificación práctica de banderas (*flags*).
* **Bibliografía:** Stallings (capítulo 10).

### S04: Multiplicación, división y punto flotante (IEEE 754)
* **Sesión 1 (Teoría):** Algoritmos de multiplicación y división en hardware. Formato estándar IEEE 754 (signo, exponente con sesgo, mantisa implícita). Errores de precisión.
* **Sesión 2 (Práctica):** Taller de conversión manual decimal a IEEE 754 simple/doble precisión y ejercicios de práctica recomendados.
* **Bibliografía:** Stallings (capítulo 10).

### S05: Introducción al lenguaje C y ensamblador x86
* **Sesión 1 (Teoría):** Estructura básica de programas en C y NASM. Banco de registros x86 (RAX, RBX, RCX, RDX, RSI, RDI, RSP, RBP). Segmentación de memoria básica.
* **Sesión 2 (Práctica):** Taller guiado: traducción de asignaciones simples de C a instrucciones `mov`, `add`, `sub` en NASM. Depuración con GDB.
* **Bibliografía:** Libro C (capítulos 1 y 2), Sivarama (capítulos 9 y 10).

### S06: Formatos de instrucción y modos de direccionamiento
* **Sesión 1 (Teoría):** Anatomía de una instrucción (código de operación, operandos). Modos de direccionamiento: inmediato, directo, por registro, indirecto e indexado.
* **Sesión 2 (Práctica):** Taller de decodificación y cálculo de direcciones efectivas. Ejercicios de traducción de accesos a memoria de C a ensamblador.
* **Bibliografía:** Libro C (capítulos 3 y 4), Sivarama (capítulos 11 y 12).

### S07: Operaciones aritméticas, lógicas y flujo de control
* **Sesión 1 (Teoría):** Instrucciones `cmp`, `test`, saltos condicionales (`je`, `jne`, `jg`, `jl`) e incondicionales (`jmp`). Punteros y aritmética de punteros en C.
* **Sesión 2 (Práctica):** Taller de construcción de estructuras de control (`if-else`, `while`, `for`) en ensamblador y ejercicios de práctica.
* **Bibliografía:** Libro C (capítulo 5), Sivarama (capítulos 13 y 14).

### S08: Rutinas, pila (stack frame) y evaluación intermedia
* **Sesión 1 (Teoría):** Mecanismo de llamadas: `call`, `ret`. Convención de llamadas (*cdecl*), construcción y destrucción del *stack frame* con `EBP` y `ESP`.
* **Sesión 2 (Práctica):** Taller de funciones recursivas (factorial/fibonacci) en NASM. Simulacro guiado de primer examen parcial.
* **Bibliografía:** Libro C (capítulo 6), Sivarama (capítulos 15 y 16).

### S09: Llamadas al sistema e interacción con el sistema operativo
* **Sesión 1 (Teoría):** Modo dual (usuario / núcleo). Interrupciones por software y mecanismo de *syscalls* en Linux (x86 `int 0x80` vs x86-64 `syscall`). Descriptores de archivo estándar POSIX (`stdin = 0`, `stdout = 1`, `stderr = 2`).
* **Sesión 2 (Práctica):** Taller de E/S básica por consola: captura de texto desde teclado con `sys_read` en buffers `.bss` y despliegue interactivo con `sys_write`.
* **Bibliografía:** Libro C (capítulo 7), Sivarama (capítulos 17 y 18).

### S10: Procesamiento de cadenas y manipulación de memoria
* **Sesión 1 (Teoría):** Representación de cadenas ASCIIZ, registros especializados (ESI, EDI, ECX), bandera DF (`cld`/`std`), instrucciones de bloque (`movsb`/`movsd`, `stosb`/`stosd`, `lodsb`/`lodsd`, `cmpsb`/`cmpsd`, `scasb`/`scasd`) y prefijos de repetición (`rep`, `repe`, `repne`).
* **Sesión 2 (Práctica):** Taller de implementación de funciones estándar de memoria en NASM: `strlen`, `memcpy`, `strcpy`, `memset`, `strcmp` y análisis de eficiencia en ciclos de procesador.
* **Bibliografía:** Sivarama (capítulos 17 y 18).

### S11: Manejo de archivos en disco, macros y modularización (C con NASM)
* **Sesión 1 (Teoría):** Persistencia en disco en Linux (`sys_open`, `sys_creat`, `sys_close`, `sys_lseek`), modos de apertura y permisos octales. Preprocesador de NASM (`%define`, `%include`, `%macro`). Modularización y enlace separado (`global`, `extern`).
* **Sesión 2 (Práctica):** Taller de creación y escritura de archivos en disco, lectura por bloques a buffers de memoria y proyecto híbrido modular C + NASM compilado con `gcc -m32`.
* **Bibliografía:** Sivarama (capítulos 19, 20 y 21), Libro C (capítulo 8).

### S12: Arquitectura del procesador, segmentación (pipeline) y riesgos
* **Sesión 1 (Teoría):** Concepto de pipeline y etapas clásicas (IF, ID, EX, MEM, WB). Riesgos estructurales, de datos (dependencias RAW, WAR, WAW) y de control. Comparación RISC vs CISC.
* **Sesión 2 (Práctica):** Taller de diagramación de trazas de pipeline, cálculo de ciclos con paradas (*stalls*) y técnicas de reenvío (*forwarding*).
* **Bibliografía:** Stallings (capítulos sobre procesador y arquitectura RISC).

### S13: Entrada y salida a nivel de hardware
* **Sesión 1 (Teoría):** Controladores de dispositivos. Sondeo periódico (*polling*) vs interrupciones de hardware. Acceso directo a memoria (*DMA*). E/S mapeada en memoria vs aislada.
* **Sesión 2 (Práctica):** Taller de análisis comparativo de diagramas de tiempo: cálculo de sobrecarga de CPU en polling vs interrupciones y transferencias DMA.
* **Bibliografía:** Stallings (capítulos de E/S).

### S14: Jerarquía de memoria y memorias caché
* **Sesión 1 (Teoría):** Principio de localidad espacial y temporal. Arquitectura de niveles de caché (L1, L2, L3). Funciones de mapeo (directo, asociativo, asociativo por conjuntos) y políticas de reemplazo (LRU, FIFO).
* **Sesión 2 (Práctica):** Taller de cálculo de aciertos y fallos (*hit/miss rate*), tiempo de acceso efectivo y ejercicios de análisis de fragmentos de código sensibles a caché.
* **Bibliografía:** Stallings (capítulos de memoria y caché).

### S15: Multiprocesadores, coherencia y sistemas empotrados
* **Sesión 1 (Teoría):** Arquitecturas multinúcleo (SMP, NUMA). Problema de coherencia de caché y protocolo MESI. Introducción a sistemas empotrados y microcontroladores.
* **Sesión 2 (Práctica):** Taller de análisis de condiciones de carrera a nivel de hardware y ejercicios de práctica integradores.
* **Bibliografía:** Stallings (capítulos de multiprocesamiento).

### S16: Repaso integrador final y preparación de examen
* **Sesión 1 (Teoría):** Síntesis global del curso: conexión de alto nivel entre software en C, ensamblador x86 y organización de hardware.
* **Sesión 2 (Práctica):** Examen simulacro intensivo de práctica con resolución guiada de ejercicios teóricos y problemas de bajo nivel.

---

## 8. Flujo de Trabajo para Generar una Presentación

1. **Revisión temática:** Consultar la semana objetivo (`SXX`) en el temario bi-sesional integrado y en `PLAN.md`.
2. **Selección visual y diagramas:**
   - Consultar `references/diagram_templates_slidev.md` para reutilizar estructuras de diagramas (registros, stack, pipeline).
   - Si se requiere una figura del libro, extraerla con `uv run .agents/skills/slidev-presentations/scripts/extract_figure.py` hacia `SXX/public/images/`.
3. **Estructuración en Slidev:**
   - Crear el directorio `SXX/` e inicializar el proyecto con `pnpm`.
   - Redactar `slides.md` estructurando claramente el bloque de la **Sesión 1**, la **Diapositiva Divisoria de Sesión** (`layout: section`) y el bloque de la **Sesión 2**.
   - Aplicar sentence case estricto, sin redundancias bilingües y sin símbolos prohibidos (`;`, `-`, `—`).
4. **Redacción del guión oral:**
   - Incorporar en cada diapositiva de ambas sesiones el bloque de notas `<!-- ... -->` con el discurso oral del tutor y los marcadores `[click]`.
5. **Validación:**
   - Ejecutar `pnpm run dev` y confirmar que no existan errores de renderizado o desbordamientos visuales.

---

## 9. Catálogo de Referencias Rápidas

| Tema | Descripción | Archivo de referencia |
| :--- | :--- | :--- |
| **Plantillas de diagramas y divisorias** | Registros x86, stack frames, pipeline, ciclos CPU, portada de Sesión 2 | [diagram_templates_slidev](references/diagram_templates_slidev.md) |
| **Extractor de figuras** | Script para recorte de PDFs con autocrop a 300 DPI | [extract_figure.py](scripts/extract_figure.py) |
| **Animaciones y clics** | v-click, v-clicks, motion, transiciones | [core-animations](references/core-animations.md) |
| **Animaciones de código** | magic-move entre bloques de código | [code-magic-move](references/code-magic-move.md) |
| **Layouts de Slidev** | two-cols, section, statement, quote, image layouts | [core-layouts](references/core-layouts.md) |
| **Sintaxis y Frontmatter** | Separadores, headmatter, configuraciones globales | [core-syntax](references/core-syntax.md) |
| **Diagramas Mermaid/LaTeX** | Sintaxis nativa en Slidev | [diagram-mermaid](references/diagram-mermaid.md) / [diagram-latex](references/diagram-latex.md) |
| **Modo presentador** | Notas, sincronización [click] y timer | [presenter-recording](references/presenter-recording.md) |
