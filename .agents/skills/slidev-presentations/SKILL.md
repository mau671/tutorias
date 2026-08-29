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
  - **Bloque 2 (Sesión 2 - 90 min):** Profundización técnica de bajo nivel, taller práctico en vivo (ejercicios paso a paso en ensamblador / C / cálculo binario / trazas de pipeline) y evaluación corta / quiz formativo.
* **Extensión adecuada:** Generar un deck completo (generalmente entre 20 y 35 diapositivas bien estructuradas) para cubrir holgadamente ambas jornadas con alta densidad técnica y visual.

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
  - **Superficies sobrias y elegantes:** Usar tarjetas con fondo neutro sutil (`bg-gray-900/60 border border-gray-800 rounded-xl`), tipografía sans-serif limpia y amplia respiración.
  - **Pipelines y pasos ordenados:** En lugar de cajas desconectadas o tablas pesadas, usar flujos de procesos limpios con números circulares sobrios (`1`, `2`, `3`, `4`) y conectores sutiles en escala de grises.
  - **Registros y diagramas de bits:** Diseñar los campos de datos como barras segmentadas elegantes de una sola pieza con tintes pasteles/apagados (`bg-rose-950/30`, `bg-blue-950/30`, `bg-emerald-950/30`) y etiquetas en minúsculas (*Signo (s)*, *Exponente (e)*, *Mantisa (f)*).
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
* **Sesión 1 (Teoría):** Modo dual (usuario / núcleo). Interrupciones por software y mecanismo de *syscalls* en Linux (x86 `int 0x80` vs x86-64 `syscall`).
* **Sesión 2 (Práctica):** Taller de E/S básica: lectura y escritura en consola mediante llamadas al sistema. Manejo de archivos desde ensamblador.
* **Bibliografía:** Libro C (capítulo 7), Sivarama (capítulos 17 y 18).

### S10: Macros, directivas de memoria y arreglos
* **Sesión 1 (Teoría):** Macros de preensamblado vs rutinas. Directivas de datos (`db`, `dw`, `dd`, `resb`, `resd`). Organización de arreglos contiguos en memoria.
* **Sesión 2 (Práctica):** Taller de recorrido y manipulación de arreglos numéricos y cadenas en NASM. Práctica guiada con arreglos.
* **Bibliografía:** Sivarama (capítulos 19 y 20).

### S11: Modularización, enlazado y segmentación
* **Sesión 1 (Teoría):** Compilación y ensamblado separado. Símbolos globales (`global`) y externos (`extern`). Proceso de enlazado (*linking*) y resolución de direcciones.
* **Sesión 2 (Práctica):** Taller de integración de módulos mixtos: invocar rutinas escritas en NASM desde un programa principal en C y viceversa.
* **Bibliografía:** Sivarama (capítulos 21 y 22).

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
