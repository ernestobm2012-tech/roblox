#!/bin/bash
# CONECTAR (Mac): enciende Rojo. NO cierres esta ventana mientras juegas.
cd "$(dirname "$0")" || exit 1
if [ ! -x ./rojo ]; then
  echo " Falta Rojo. Primero haz doble clic en INSTALAR.command"
  read -r -p " Pulsa Enter para cerrar..."
  exit 1
fi
echo ""
echo " Rojo esta ENCENDIDO. NO cierres esta ventana."
echo " Ahora en Roblox Studio: pestana Plugins, boton Rojo, Connect."
echo ""
./rojo serve
