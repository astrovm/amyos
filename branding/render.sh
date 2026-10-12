#!/usr/bin/env bash
# Rebuild all brand assets from mark.svg. Requires librsvg and Python 3.
set -euo pipefail
cd "$(dirname "$0")/.."
command -v rsvg-convert >/dev/null
command -v python3 >/dev/null
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT
python3 - "$temporary" <<'PY'
import pathlib
import sys
import xml.etree.ElementTree as ET

ET.register_namespace('', 'http://www.w3.org/2000/svg')
master = ET.parse('branding/mark.svg').getroot()
paths = ET.tostring(master.find('{http://www.w3.org/2000/svg}g'), encoding='unicode')
temporary = pathlib.Path(sys.argv[1])

def svg(width, height, content):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">{content}</svg>\n'

def cat(x, y, size, color='#ffffff'):
    return f'<g color="{color}" transform="translate({x} {y}) scale({size / 512})">{paths}</g>'

for color, value in [('black', '#000000'), ('white', '#ffffff')]:
    (temporary / f'{color}.svg').write_text(svg(512, 512, cat(0, 0, 512, value)))
icon = '<g stroke="#ffffff" stroke-width="8" stroke-linejoin="round" paint-order="stroke">' + cat(0, 0, 256, '#1b1e20') + '</g>'
(temporary / 'icon.svg').write_text(svg(256, 256, icon))
(temporary / 'watermark.svg').write_text(svg(149, 149, cat(0, 0, 149)))
(temporary / 'logo.svg').write_text(svg(256, 256, cat(0, 0, 256)))
welcome = '<g stroke="#ffffff" stroke-width="8" stroke-linejoin="round" paint-order="stroke">' + cat(78.5, 0, 300, '#1b1e20') + '</g>'
(temporary / 'welcome.svg').write_text(svg(457, 300, welcome))
boot = '<rect width="640" height="480" fill="#1b1e20"/>' + cat(250, 28, 140)
pathlib.Path('debian/live/config/bootloaders/splash.svg').write_text(svg(640, 480, boot))
PY
installer=debian/live/config/includes.chroot_after_packages/etc/calamares/branding/amyos
rsvg-convert "$temporary/black.svg" -o repo_files/amy-logo-black.png
rsvg-convert "$temporary/white.svg" -o repo_files/amy-logo-white.png
rsvg-convert "$temporary/icon.svg" -o branding/usr/share/icons/hicolor/256x256/apps/amyos.png
rsvg-convert "$temporary/watermark.svg" -o branding/usr/share/plymouth/themes/amyos/watermark.png
rsvg-convert "$temporary/logo.svg" -o "$installer/logo.png"
rsvg-convert "$temporary/welcome.svg" -o "$installer/welcome.png"
cp branding/usr/share/icons/hicolor/256x256/apps/amyos.png "$installer/icon.png"
