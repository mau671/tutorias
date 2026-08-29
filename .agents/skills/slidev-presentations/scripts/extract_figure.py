#!/usr/bin/env python3
# /// script
# dependencies = [
#     "pillow>=10.0.0",
# ]
# ///
"""
extract_figure.py - Extractor y recortador de figuras desde PDFs para presentaciones Slidev de IC3101.

Uso:
  uv run .agents/skills/slidev-presentations/scripts/extract_figure.py --pdf <ruta_al_pdf> --page <numero_pagina_en_pdf> --output <ruta_imagen_salida.png> [--bbox ymin xmin ymax xmax] [--dpi 300] [--no-autocrop]

Parámetros:
  --pdf: Ruta al archivo PDF (capítulo o libro completo, ej. Libros/Stallings...).
  --page: Número de página (1-indexado dentro del PDF proporcionado).
  --output: Ruta del archivo PNG de salida (ej. semana_01/public/images/fig_alu.png).
  --bbox: Coordenadas relativas (de 0.0 a 1.0) para el recorte: [ymin xmin ymax xmax].
          Ejemplo: --bbox 0.15 0.10 0.60 0.90 recorta desde el 15% superior hasta el 60%, y del 10% izquierdo al 90%.
  --dpi: Resolución en DPI para el renderizado (por defecto 300).
  --no-autocrop: Desactiva el recorte automático de bordes blancos sobrantes.
"""

import argparse
import os
import subprocess
import sys
from PIL import Image, ImageChops

def trim_whitespace(im, border_padding=15, threshold=245):
    """Elimina los bordes blancos/claros alrededor de una imagen."""
    bg = Image.new(im.mode, im.size, (255, 255, 255) if im.mode == 'RGB' else 255)
    diff = ImageChops.difference(im, bg)
    if im.mode == 'RGB':
        diff = diff.convert('L')
    
    diff = diff.point(lambda p: 255 if p > (255 - threshold) else 0)
    bbox = diff.getbbox()
    if bbox:
        left, top, right, bottom = bbox
        width, height = im.size
        left = max(0, left - border_padding)
        top = max(0, top - border_padding)
        right = min(width, right + border_padding)
        bottom = min(height, bottom + border_padding)
        return im.crop((left, top, right, bottom))
    return im

def extract_and_crop(pdf_path, page_num, output_path, bbox=None, dpi=300, autocrop=True):
    if not os.path.exists(pdf_path):
        raise FileNotFoundError(f"PDF no encontrado: {pdf_path}")

    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    temp_prefix = f"/tmp/extract_fig_{os.getpid()}"
    
    try:
        cmd = [
            "pdftoppm",
            "-png",
            "-r", str(dpi),
            "-f", str(page_num),
            "-l", str(page_num),
            pdf_path,
            temp_prefix
        ]
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if res.returncode != 0:
            raise RuntimeError(f"Error al ejecutar pdftoppm: {res.stderr}")

        rendered_files = [f for f in os.listdir("/tmp") if f.startswith(f"extract_fig_{os.getpid()}") and f.endswith(".png")]
        if not rendered_files:
            raise RuntimeError("No se generó el archivo PNG temporal con pdftoppm.")
        
        temp_img_path = os.path.join("/tmp", rendered_files[0])
        img = Image.open(temp_img_path)

        if bbox and len(bbox) == 4:
            ymin, xmin, ymax, xmax = bbox
            width, height = img.size
            crop_area = (
                int(xmin * width),
                int(ymin * height),
                int(xmax * width),
                int(ymax * height)
            )
            img = img.crop(crop_area)

        if autocrop:
            img = trim_whitespace(img)

        img.save(output_path, "PNG", optimize=True)
        print(f"Figura extraída exitosamente en: {output_path} (dimensiones: {img.size[0]}x{img.size[1]})")

    finally:
        for f in os.listdir("/tmp"):
            if f.startswith(f"extract_fig_{os.getpid()}"):
                try:
                    os.remove(os.path.join("/tmp", f))
                except Exception:
                    pass

def main():
    parser = argparse.ArgumentParser(description="Extrae y recorta figuras desde PDFs.")
    parser.add_argument("--pdf", required=True, help="Ruta al archivo PDF")
    parser.add_argument("--page", required=True, type=int, help="Número de página en el PDF (1-indexado)")
    parser.add_argument("--output", required=True, help="Ruta de destino del archivo de imagen PNG")
    parser.add_argument("--bbox", nargs=4, type=float, metavar=('YMIN', 'XMIN', 'YMAX', 'XMAX'),
                        help="Coordenadas relativas 0.0-1.0 (ej. --bbox 0.15 0.1 0.5 0.9)")
    parser.add_argument("--dpi", type=int, default=300, help="Resolución DPI (por defecto 300)")
    parser.add_argument("--no-autocrop", action="store_true", help="Desactiva el recorte automático de bordes blancos")

    args = parser.parse_args()
    extract_and_crop(
        pdf_path=args.pdf,
        page_num=args.page,
        output_path=args.output,
        bbox=args.bbox,
        dpi=args.dpi,
        autocrop=not args.no_autocrop
    )

if __name__ == "__main__":
    main()
