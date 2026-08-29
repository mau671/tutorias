# Reglas Globales para Presentaciones y Tutorías de Arquitectura de Computadores (IC3101)

Cuando se generen, modifiquen o planifiquen presentaciones, diapositivas, materiales de tutoría o guiones para el curso IC3101 (Arquitectura de Computadores), se deben cumplir estrictamente las siguientes directrices:

## 1. Nomenclatura de Carpetas y Estructura Semanal
- **Formato de carpetas:** Las carpetas semanales deben nombrarse con el prefijo `S` en mayúscula seguido de dos dígitos: `S01/`, `S02/`, `S03/`, ..., `S16/`.
- **Una presentación por semana:** Cada carpeta semanal contiene un único proyecto Slidev y un único archivo `slides.md`.
- **Estructura bi-sesional (2 tutorías de 1.5 horas por semana):** Cada presentación debe estructurarse internamente para cubrir dos sesiones independientes de 90 minutos (3 horas semanales en total).
- **Diapositiva divisoria intermedia:** Debe existir una diapositiva de transición clara (`layout: section` o portada de capítulo intermedia) que marque el inicio de la **Sesión 2**, incluyendo los objetivos de la segunda jornada y los requisitos de práctica.

## 2. Distribución de Contenido por Sesión (1.5 horas c/u)
- **Sesión 1 (90 min - Fundamentos teóricos y modelos arquitectónicos):**
  - Introducción y contexto histórico / conceptual (10 min).
  - Desarrollo de teoría sustancial y diagramas arquitectónicos de alto nivel (45 min).
  - Primeros ejemplos guiados o demostraciones de código base (30 min).
  - Cierre y conexión con la sesión práctica (5 min).
- **Diapositiva divisoria:** Separador temático de Sesión 2.
- **Sesión 2 (90 min - Profundización, taller de ensamblador y práctica en vivo):**
  - Reactivación conceptual de la sesión anterior (10 min).
  - Teoría avanzada de bajo nivel / formatos de instrucción / registros / microarquitectura (30 min).
  - Taller práctico guiado paso a paso (ejercicios en NASM/C, trazas de memoria, depuración o cálculos) (40 min).
  - Quiz formativo de cierre / simulacro de examen (10 min).

## 3. Gestor de Paquetes y Herramientas
- **Uso exclusivo de pnpm:** Ejecutar siempre comandos de gestión de dependencias mediante `pnpm` (ej. `pnpm install`, `pnpm run dev`, `pnpm add -D`).
- **Comandos al vuelo:** Usar `pnpx` o `pnpm dlx` (ej. `pnpx create-slidev`).
- **Scripts auxiliares:** Ejecutar herramientas en Python mediante `uv run` (ej. `uv run .agents/skills/slidev-presentations/scripts/extract_figure.py ...`).
- **Prohibido:** Queda terminantemente prohibido el uso de `npm` o `yarn`.

## 4. Regla Estricta de Sentence Case (Formato de Oración)
- **Obligatorio en todo el documento:** Aplica a títulos principales (`#`), subtítulos (`##`, `###`), títulos de diapositivas, encabezados de columnas, tablas, etiquetas de diagramas, viñetas y elementos visuales.
- **Formato:** Únicamente la primera letra de la frase u oración se escribe en mayúscula. Todas las demás palabras van en minúscula, salvo que se trate de:
  1. Nombres propios reconocidos (*Linux*, *Intel*, *AMD*, *ARM*, *Stallings*, *Sivarama*, *Von Neumann*).
  2. Siglas y acrónimos estándar de arquitectura de hardware y software (*CPU*, *ALU*, *RAM*, *ROM*, *RISC*, *CISC*, *CPI*, *IEEE*, *NASM*, *ISA*, *DMA*, *GDT*, *LDT*, *EFLAGS*, *RAX*, *EAX*, *EBX*, *ECX*, *EDX*, *ESP*, *EBP*, *ESI*, *EDI*, *EIP*, *ASCII*, *BSS*, *I/O*, *FIFO*).

## 5. Prohibición de Redundancia Bilingüe
- **PROHIBIDO duplicar términos en español e inglés entre paréntesis** o mediante fórmulas como *Término en español (término en inglés)*.
- **Ejemplos prohibidos y corrección:**
  - `Pila (stack)` $\rightarrow$ Usar: `Pila` o `Stack` (elegir uno de forma consistente en el contexto técnico).
  - `Montículo (heap)` $\rightarrow$ Usar: `Montículo` o `Heap`.
  - `Registros (registers)` $\rightarrow$ Usar: `Registros`.
  - `Interrupciones (interrupts)` $\rightarrow$ Usar: `Interrupciones`.
  - `Búsqueda (fetch)` $\rightarrow$ Usar: `Búsqueda` o `Fetch`.
  - `Segmentación (pipelining)` $\rightarrow$ Usar: `Segmentación` o `Pipeline`.
- Emplear directamente el término técnico formal, manteniendo una redacción profesional, directa y limpia.

## 6. Puntuación, Fluidez y Anti-Prosa
- **Puntuación prohibida:** Está PROHIBIDO usar el símbolo de punto y coma (`;`) y los guiones (`-` o `—`) para separar cláusulas o ideas dentro de párrafos o listas de texto continuo.
- **Prohibición de emojis:** Cero emojis en títulos, diapositivas, diagramas o guiones.
- **Fluidez con conectores:** Emplear oraciones cohesionadas mediante conectores lógicos (*asimismo*, *por consiguiente*, *de manera análoga*, *en consecuencia*, *además*).
- **Prohibición de meta-texto:** Evitar frases auto-referenciales como "En esta diapositiva aprenderemos...", "Este slide muestra...", "A continuación se presenta...". Ir directo al contenido técnico.

## 7. Diseño Visual y Layouts en Slidev
- **Variedad visual (Cero diapositivas de solo viñetas):** Prohibido crear presentaciones monótonas que sean listas infinitas de viñetas.
- **Uso intensivo de layouts:** Emplear `layout: two-cols` para contrastar conceptos, `layout: statement` o `quote` para axiomas fundamentales, `layout: image-right` / `image-left` para explicaciones asistidas por diagramas, y `layout: section` para la separación de sesiones.
- **Jerarquía de texto:** No colocar un encabezado `##` inmediatamente debajo de un `#` si el texto es un párrafo descriptivo, ya que Slidev aplica estilos atenuados (*muted*).
- **Animaciones e interactividad:** Utilizar transiciones (`transition: slide-left`, `fade`), marcadores dinámicos (`v-mark`), revelado progresivo (`<v-clicks>`, `v-click`) y transformaciones fluidas de código (`magic-move`).

## 8. Diagramación y Recursos Gráficos
- **Prioridad absoluta al código:** Todos los diagramas arquitectónicos (buses, ALU, pipeline, layouts de memoria, mapas de registros) deben generarse mediante código nativo (`mermaid`, `plantuml`, tablas estilizadas con Tailwind CSS o LaTeX/KaTeX).
- **Extracción de figuras originales de libros:** Cuando se requiera un esquema del libro de texto (*Stallings*, *Sivarama*, *Peter Abel*), utilizar el script `extract_figure.py` a 300 DPI con autocrop de márgenes blancos y sin incluir las leyendas o números de figura del libro original.
- **Prohibición de estilo IA neón:** Si en caso excepcional se genera una imagen, está prohibido el estilo *cyberpunk*, neón, degradados magenta/cyan o brillos ficticios. El estilo debe ser sobrio, plano (*flat design*) y estrictamente académico.

## 9. Guiones de Exposición Oral (Speaker Scripts)
- **Notas de presentador con propósito:** Cada diapositiva debe incluir en su bloque de notas (`<!-- ... -->`) el guión oral que el tutor dirá durante la exposición.
- **Primera persona pedagógica:** Redactado en tono de tutor universitario (*"Notemos cómo el registro...", "Imaginemos que tenemos..."*), claro, elocuente y dinámico.
- **Complementariedad oral-visual:** El guión NO debe limitarse a leer lo que está en pantalla; debe explicar el *por qué*, desarrollar la analogía intuitiva y profundizar en los detalles técnicos.
- **Sincronización con animaciones:** Incluir marcadores `[click]` en el guión exactamente donde el tutor debe hacer avanzar la animación o viñeta.
- **Preguntas de verificación:** Incluir al menos una pregunta reflexiva o de interacción hacia los estudiantes en las diapositivas conceptuales clave de ambas sesiones.
