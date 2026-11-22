#!/bin/bash
# INSTALAR (Mac, solo UNA vez): descarga Rojo y pone su plugin en Roblox Studio.
cd "$(dirname "$0")" || exit 1
VERSION=7.7.1
if [ "$(uname -m)" = "arm64" ]; then ARQ=aarch64; else ARQ=x86_64; fi
echo ""
echo " Descargando Rojo $VERSION... (espera un momento)"
if curl -fsSL -o rojo.zip "https://github.com/rojo-rbx/rojo/releases/download/v$VERSION/rojo-$VERSION-macos-$ARQ.zip" \
  && unzip -o -q rojo.zip && rm -f rojo.zip && chmod +x rojo \
  && { xattr -d com.apple.quarantine rojo 2>/dev/null; true; } \
  && mkdir -p "$HOME/Documents/Roblox/Plugins" \
  && curl -fsSL -o "$HOME/Documents/Roblox/Plugins/Rojo.rbxm" "https://github.com/rojo-rbx/rojo/releases/download/v$VERSION/Rojo.rbxm"; then
  echo ""
  echo " LISTO! Si Roblox Studio estaba abierto, cierralo y abrelo."
else
  echo ""
  echo " Algo ha fallado. Haz una foto a esta ventana y ensenasela a Claude."
fi
echo ""
read -r -p " Pulsa Enter para cerrar..."
