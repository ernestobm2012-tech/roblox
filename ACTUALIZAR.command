#!/bin/bash
# ACTUALIZAR (Mac): baja de GitHub lo ultimo que ha hecho Claude.
cd "$(dirname "$0")" || exit 1
echo ""
echo " Bajando lo ultimo que ha hecho Claude..."
git fetch origin --prune \
  && git remote set-head origin -d >/dev/null 2>&1
RAMA=$(git for-each-ref --sort=-committerdate --count=1 --format='%(refname:lstrip=3)' refs/remotes/origin)
if [ -n "$RAMA" ] && git checkout -f -B "$RAMA" "origin/$RAMA"; then
  echo ""
  echo " LISTO! Ya tienes lo ultimo de Claude."
  echo " Si CONECTAR esta abierto, ya esta en Roblox Studio."
  echo " Para probarlo: para el juego y dale otra vez a Play."
else
  echo ""
  echo " Algo ha fallado. Haz una foto a esta ventana y ensenasela a Claude."
fi
echo ""
read -r -p " Pulsa Enter para cerrar..."
