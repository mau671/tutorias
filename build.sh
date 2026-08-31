#!/bin/bash
set -e

echo "🚀 Iniciando compilación de presentaciones (S04, S05, S09, S10)..."

# Limpiar y preparar directorios
rm -rf dist
mkdir -p dist/tutorias/IC3101

# Instalar dependencias con caché y lockfile estricto
pnpm install --frozen-lockfile

# Lista de semanas a publicar
WEEKS=("S04" "S05" "S09" "S10")

for week in "${WEEKS[@]}"; do
  if [ -d "$week" ] && [ -f "$week/slides.md" ]; then
    echo "🔨 Compilando $week con base /tutorias/IC3101/$week/ ..."
    pnpm --filter "./$week" exec slidev build --base "/tutorias/IC3101/$week/" --out "../dist/tutorias/IC3101/$week/"
  else
    echo "⚠️  Advertencia: No se encontró la carpeta o slides.md para $week"
  fi
done

# Portal índice monocromático canónico en /tutorias/IC3101/index.html
cat << 'PORTAL' > dist/tutorias/IC3101/index.html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tutorías IC3101 - Arquitectura de computadores</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-neutral-950 text-neutral-100 min-h-screen p-6 md:p-12 flex flex-col items-center justify-center font-sans antialiased selection:bg-neutral-800 selection:text-white">
  <main class="max-w-xl w-full">
    <div class="mb-8">
      <h1 class="text-3xl md:text-4xl font-bold text-white tracking-tight">Arquitectura de computadores</h1>
    </div>

    <div class="grid gap-3">
      <a href="/tutorias/IC3101/S04/" class="group p-4 bg-neutral-900/50 border border-neutral-800/80 rounded-xl hover:border-neutral-500 hover:bg-neutral-900 transition duration-150 block">
        <div class="flex items-center justify-between mb-1">
          <span class="font-bold text-white group-hover:text-neutral-200 transition font-mono text-sm">Semana 04</span>
          <span class="text-xs text-neutral-500 font-mono">18 slides</span>
        </div>
        <p class="text-neutral-400 text-xs leading-relaxed">Multiplicación, división entera y formato de punto flotante IEEE 754</p>
      </a>

      <a href="/tutorias/IC3101/S05/" class="group p-4 bg-neutral-900/50 border border-neutral-800/80 rounded-xl hover:border-neutral-500 hover:bg-neutral-900 transition duration-150 block">
        <div class="flex items-center justify-between mb-1">
          <span class="font-bold text-white group-hover:text-neutral-200 transition font-mono text-sm">Semana 05</span>
          <span class="text-xs text-neutral-500 font-mono">22 slides</span>
        </div>
        <p class="text-neutral-400 text-xs leading-relaxed">Introducción a C y x86: registros, mapa de memoria, MOV, ADD, SUB y GDB</p>
      </a>

      <a href="/tutorias/IC3101/S09/" class="group p-4 bg-neutral-900/50 border border-neutral-800/80 rounded-xl hover:border-neutral-500 hover:bg-neutral-900 transition duration-150 block">
        <div class="flex items-center justify-between mb-1">
          <span class="font-bold text-white group-hover:text-neutral-200 transition font-mono text-sm">Semana 09</span>
          <span class="text-xs text-neutral-500 font-mono">19 slides</span>
        </div>
        <p class="text-neutral-400 text-xs leading-relaxed">Llamadas al sistema (int 0x80), descriptores de archivo y depuración con GDB</p>
      </a>

      <a href="/tutorias/IC3101/S10/" class="group p-4 bg-neutral-900/50 border border-neutral-800/80 rounded-xl hover:border-neutral-500 hover:bg-neutral-900 transition duration-150 block">
        <div class="flex items-center justify-between mb-1">
          <span class="font-bold text-white group-hover:text-neutral-200 transition font-mono text-sm">Semana 10</span>
          <span class="text-xs text-neutral-500 font-mono">19 slides</span>
        </div>
        <p class="text-neutral-400 text-xs leading-relaxed">Instrucciones de bloque (MOVS, STOS, LODS, CMPS, SCAS) y prefijos de repetición</p>
      </a>
    </div>

    <footer class="mt-12 text-center text-xs text-neutral-500 font-sans">
      Hecho con ❤️ por <a href="https://maugp.com" target="_blank" rel="noopener noreferrer" class="text-neutral-300 hover:text-white hover:underline transition font-medium">Mauricio González Prendas</a>
    </footer>
  </main>
</body>
</html>
PORTAL

# Redirección automática si se accede a la raíz /tutorias/
cat << 'REDIRECT' > dist/tutorias/index.html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="refresh" content="0; url=/tutorias/IC3101/">
  <script>window.location.replace("/tutorias/IC3101/");</script>
  <title>Redirigiendo a Tutorías IC3101...</title>
</head>
<body style="background-color: #0a0a0a; color: #fff; font-family: sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0;">
  <p>Redirigiendo a <a href="/tutorias/IC3101/" style="color: #fff;">/tutorias/IC3101/</a>...</p>
</body>
</html>
REDIRECT

echo "✨ Compilación finalizada con éxito en ./dist"
