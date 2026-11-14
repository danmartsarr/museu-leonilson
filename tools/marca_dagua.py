"""Grava a marca d'água do Projeto Leonilson dentro de cada foto publicada.

Uma marca só desenhada por cima na tela não basta: no site, os arquivos de
imagem ficam acessíveis pelo endereço e podem ser baixados sem ela. Por isso a
marca vai para o próprio arquivo.

    python3 tools/marca_dagua.py          # gera assets/ a partir de originais/
    python3 tools/marca_dagua.py --conferir

- originais/  arquivos sem marca, em resolução de impressão (NÃO vão para o git)
- assets/imagens_obras/, assets/fotos_familia/  versões publicadas: RGB, lado
  maior até 2000 px (obras) e com a marca: logo no canto e "© Projeto Leonilson"
  repetido em diagonal sobre a imagem inteira.

--conferir compara cada arquivo publicado com o original e falha se algum for
idêntico ao original, tiver menos de 3 % dos pixels alterados pela marca, não
tiver o selo claro no canto, ou se faltar/sobrar arquivo.
"""
import argparse
import hashlib
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageOps, ImageStat

Image.MAX_IMAGE_PIXELS = None
RAIZ = Path(__file__).resolve().parent.parent
ORIGINAIS = RAIZ / "originais"
ASSETS = RAIZ / "assets"
PASTAS = ["imagens_obras", "fotos_familia"]
EXT = {".jpg", ".jpeg", ".png"}
LOGO = ASSETS / "design" / "P.leonilson-02.jpg"
FONTE = "/usr/share/fonts/truetype/lato/Lato-Bold.ttf"
TEXTO = "© Projeto Leonilson"
LADO_MAX = 2000


def fotos(base):
    for pasta in PASTAS:
        for f in sorted((base / pasta).rglob("*")):
            if f.suffix.lower() in EXT:
                yield f.relative_to(base)


def marcar(img):
    img = ImageOps.exif_transpose(img).convert("RGB")
    img.thumbnail((LADO_MAX, LADO_MAX), Image.LANCZOS)
    w, h = img.size
    lado = max(w, h)

    # 1) texto repetido em diagonal, semitransparente, com contorno para
    #    aparecer tanto em áreas claras quanto escuras
    tam = max(14, lado // 34)
    fonte = ImageFont.truetype(FONTE, tam)
    camada = Image.new("RGBA", (lado * 2, lado * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(camada)
    passo_x, passo_y = int(tam * 13), int(tam * 5)
    for j, y in enumerate(range(0, lado * 2, passo_y)):
        desloc = (j % 2) * passo_x // 2
        for x in range(-passo_x, lado * 2, passo_x):
            d.text((x + desloc, y), TEXTO, font=fonte, fill=(255, 255, 255, 92),
                   stroke_width=max(1, tam // 12), stroke_fill=(0, 0, 0, 105))
    camada = camada.rotate(30, resample=Image.BICUBIC)
    cx, cy = camada.width // 2, camada.height // 2
    camada = camada.crop((cx - w // 2, cy - h // 2, cx - w // 2 + w, cy - h // 2 + h))
    saida = Image.alpha_composite(img.convert("RGBA"), camada)

    # 2) logo do Projeto Leonilson no canto inferior direito, sobre fundo branco
    logo = Image.open(LOGO).convert("RGB")
    lw = max(90, int(w * 0.24))
    logo = logo.resize((lw, round(logo.height * lw / logo.width)), Image.LANCZOS)
    m = max(6, lw // 18)
    selo = Image.new("RGBA", (logo.width + 2 * m, logo.height + 2 * m), (255, 255, 255, 230))
    selo.paste(logo, (m, m))
    margem = max(8, w // 40)
    saida.alpha_composite(selo, (w - selo.width - margem, h - selo.height - margem))
    return saida.convert("RGB")


def gerar():
    n = 0
    for rel in fotos(ORIGINAIS):
        destino = ASSETS / rel
        destino.parent.mkdir(parents=True, exist_ok=True)
        img = marcar(Image.open(ORIGINAIS / rel))
        if destino.suffix.lower() == ".png":
            img.save(destino, optimize=True)
        else:
            img.save(destino, quality=85, optimize=True, progressive=True)
        n += 1
    print(f"{n} fotos marcadas em {ASSETS}")


def conferir():
    erros = []
    minimo = (100.0, "")
    originais = set(fotos(ORIGINAIS))
    publicados = set(fotos(ASSETS))
    for rel in sorted(publicados - originais):
        erros.append(f"sem original (não passou pela marca): {rel}")
    for rel in sorted(originais - publicados):
        erros.append(f"faltando em assets: {rel}")
    for rel in sorted(originais & publicados):
        a = Image.open(ASSETS / rel).convert("RGB")
        o = ImageOps.exif_transpose(Image.open(ORIGINAIS / rel)).convert("RGB").resize(a.size, Image.LANCZOS)
        # fração dos pixels que a marca mudou de forma visível (> 20 níveis);
        # numa foto sem marca, só o reescalonamento, isso fica perto de 0 %
        dif_img = ImageChops.difference(a, o).convert("L")
        hist = dif_img.histogram()
        dif = 100 * sum(hist[21:]) / (a.width * a.height)
        # canto inferior direito tem de ser o selo: claro
        canto = a.crop((int(a.width * 0.80), int(a.height * 0.90), a.width - 4, a.height - 4))
        claro = sum(ImageStat.Stat(canto).mean) / 3
        if hashlib.md5((ASSETS / rel).read_bytes()).digest() == hashlib.md5((ORIGINAIS / rel).read_bytes()).digest():
            erros.append(f"idêntico ao original: {rel}")
        elif dif < 3 or claro < 150:
            erros.append(f"marca fraca ou ausente: {rel} ({dif:.1f}% dos pixels marcados, canto {claro:.0f})")
        else:
            minimo = min(minimo, (dif, str(rel)))
    total = len(originais | publicados)
    if erros:
        print("\n".join(erros))
        sys.exit(f"{len(erros)} problema(s) em {total} fotos")
    print(f"OK: {total} fotos, todas com marca d'água gravada "
          f"(menor cobertura: {minimo[0]:.1f}% dos pixels, em {minimo[1]})")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--conferir", action="store_true")
    a = ap.parse_args()
    conferir() if a.conferir else gerar()
