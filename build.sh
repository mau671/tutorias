#!/bin/bash
set -e

echo "🚀 Iniciando compilación de presentaciones (S04, S09, S10)..."

# Limpiar y preparar directorios
rm -rf dist
mkdir -p dist/tutorias/IC3101

# Lista de semanas a publicar
WEEKS=("S04" "S09" "S10")

for week in "${WEEKS[@]}"; do
  if [ -d "$week" ] && [ -f "$week/slides.md" ]; then
    echo "🔨 Compilando $week con base /tutorias/IC3101/$week/ ..."
    (cd "$week" && pnpm install && pnpm exec slidev build --base "/tutorias/IC3101/$week/" --out "../../dist/tutorias/IC3101/$week/")
  else
    echo "⚠️  Advertencia: No se encontró la carpeta o slides.md para $week"
  fi
done

# Portal índice en /tutorias/IC3101/index.html
cat << 'PORTAL' > dist/tutorias/IC3101/index.html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tutorías IC3101 - Arquitectura de Computadores</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-950 text-gray-100 min-h-screen p-6 md:p-12 flex flex-col items-center justify-center font-sans antialiased">
  <main class="max-w-2xl w-full">
    <div class="mb-8">
      <span class="px-3 py-1 bg-blue-950/80 border border-blue-800 text-blue-400 rounded-full text-xs font-mono font-semibold">IC3101</span>
      <h1 class="text-3xl md:text-4xl font-bold mt-3 text-white tracking-tight">Arquitectura de Computadores</h1>
      <p class="text-gray-400 mt-1 text-sm">Presentaciones interactivas de tutoría</p>
    </div>

    <div class="grid gap-3.5">
      <a href="./S04/" class="group p-4 bg-gray-900/80 border border-gray-800 rounded-xl hover:border-blue-500 hover:bg-gray-900 transition block">
        <div class="flex items-center justify-between mb-1">
          <span class="font-bold text-white group-hover:text-blue-400 transition font-mono text-sm">Semana 04</span>
          <span class="text-xs text-gray-500 font-mono">18 slides</span>
        </div>
        <p class="text-gray-300 text-xs leading-relaxed">Multiplicación, división entera y formato de punto flotante IEEE 754</p>
      </a>

      <a href="./S09/" class="group p-4 bg-gray-900/80 border border-gray-800 rounded-xl hover:border-blue-500 hover:bg-gray-900 transition block">
        <div class="flex items-center justify-between mb-1">
          <span class="font-bold text-white group-hover:text-blue-400 transition font-mono text-sm">Semana 09</span>
          <span class="text-xs text-gray-500 font-mono">19 slides</span>
        </div>
        <p class="text-gray-300 text-xs leading-relaxed">Llamadas al sistema (int 0x80), descriptores de archivo y depuración con GDB</p>
      </a>

      <a href="./S10/" class="group p-4 bg-gray-900/80 border border-gray-800 rounded-xl hover:border-blue-500 hover:bg-gray-900 transition block">
        <div class="flex items-center justify-between mb-1">
          <span class="font-bold text-white group-hover:text-blue-400 transition font-mono text-sm">Semana 10</span>
          <span class="text-xs text-gray-500 font-mono">19 slides</span>
        </div>
        <p class="text-gray-300 text-xs leading-relaxed">Instrucciones de bloque (MOVS, STOS, LODS, CMPS, SCAS) y prefijos de repetición</p>
      </a>
    </div>

    <footer class="mt-8 text-center text-xs text-gray-600 font-mono">
      Mauricio Gutiérrez &bull; Tutorías IC3101
    </footer>
  </main>
</body>
</html>
PORTAL

# Copiar portal a /tutorias/index.html por si se accede a /tutorias/ directamente
cp dist/tutorias/IC3101/index.html dist/tutorias/index.html

echo "✨ Compilación finalizada con éxito en ./dist"
