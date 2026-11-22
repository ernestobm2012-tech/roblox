# Guía para Claude

## Quién usa este proyecto
Un **niño** crea sus mundos de Roblox con ayuda de Claude, con la supervisión de su padre.
- Habla siempre en **español**, con frases cortas, claras y con ánimo. Nada de jerga sin explicar.
- Cuando expliques algo, usa ejemplos del propio juego ("este número es lo alto que salta").
- Celebra los avances y propón 2–3 ideas para seguir cuando termines algo.
- Si pide algo inseguro o que va contra las normas de Roblox (datos personales, contenido no apto,
  trampas para otros juegos), dilo con amabilidad y propón otra cosa divertida.

## Cómo está organizado
- Proyecto **Rojo** (`default.project.json`), código en **Luau**.
- `src/server/*.server.luau` → Scripts en `ServerScriptService`.
- `src/client/*.client.luau` → LocalScripts en `StarterPlayer/StarterPlayerScripts`.
- Si hace falta código compartido, crea `src/shared/` y añádelo a `ReplicatedStorage` en `default.project.json`.

## Reglas para escribir código
- Cada script debe funcionar **solo y sin otros archivos** (para que se pueda copiar y pegar en Studio
  sin pasos extra). Si hay que repetir una función pequeña, mejor repetirla que crear dependencias.
- Pon al principio de cada archivo un comentario que diga **qué hace** y **dónde va en Roblox Studio**.
- Comentarios y nombres de variables en español, sencillos. Los números que se pueden tocar,
  en una tabla `AJUSTES` arriba del todo.
- El mundo se construye con código (`Instance.new`) dentro de una carpeta en `workspace`.
- Luau moderno: `task.wait`/`task.delay`/`task.spawn` (nunca `wait`/`spawn`/`delay`), `game:GetService`,
  `Players:GetPlayerFromCharacter`, `+=`, iteración `for _, x in tabla do`.
- **No inventes IDs de assets** (sonidos, mallas, imágenes `rbxassetid://`). Si hacen falta, pide al
  usuario que busque uno en la Toolbox/Creator Store y lo pegue.
- Los scripts se hablan entre sí **solo con atributos del jugador** (`jugador:SetAttribute`), nunca con
  `require`: `Compra_<id>` (tienda), `MejorTiempo`, `CronoEstado`/`CronoInicio`/`CronoFinal`/`CronoRecord`
  (cronómetro). `Guardado` guarda todo `Compra_*` y `MejorTiempo`, y el marcador `leaderstats`
  (Monedas, Victorias) que crea `MiMundo`. Si añades algo que deba guardarse, usa un atributo
  `Compra_<id>` o añádelo en `recogerDatos`/`cargarJugador` de `Guardado`.
- `DataStore` solo funciona con el mundo publicado y con "acceso de Studio a servicios de API" activado.
  Nunca guardes si la lectura falló (se borrarían los datos). Si cambias `nombreDelGuardado`, todos empiezan de cero.
- Nada de `HttpService` a webs externas ni de `require` de módulos de terceros por ID.

## Cómo le llega el código al niño
- Hace doble clic en `ACTUALIZAR` (baja la rama de GitHub con el commit más reciente) y tiene `CONECTAR`
  (Rojo) abierto, así que los cambios aparecen solos en Studio. Por eso **siempre hay que hacer push**.
- La guía para principiantes está en `guia/guia.html` (fuente) y `guia/GUIA-Mundos-Roblox.pdf`.
  Si cambias el proceso, actualiza las dos.
- Cuando termines, dile: "Para, dale a **ACTUALIZAR** y luego a **Play**".

## Al terminar un cambio
1. Explica en 2–4 frases qué has hecho y **dónde pegar** cada archivo en Roblox Studio.
2. Haz commit y push a la rama de trabajo.
3. Si añades archivos o cambias dónde va algo, actualiza la tabla del `README.md`.
