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
  `require`: `Mejora_<id>` y `Precio_<id>` (tienda de mejoras por niveles), `Cofre_<nivel>` (cofres abiertos), `Pase_<clave>` (pases de Robux), `Nivel` (el más alto alcanzado), `SaltarANivel`, `CreditosSalto`, `MejorTiempo`, `CronoEstado`/`CronoInicio`/`CronoFinal`/`CronoRecord`
  (cronómetro). `Guardado` guarda todo lo que empiece por `Compra_`, `Cofre_` o `Mejora_` (lista `PREFIJOS`), `Nivel` y `MejorTiempo`, y el marcador `leaderstats`
  (Monedas, Victorias) que crea `MiMundo`. Si añades algo que deba guardarse, usa un atributo
  `Compra_<id>` o añádelo en `recogerDatos`/`cargarJugador` de `Guardado`.
- Mundo: `workspace.MiMundo` (lo crea `MiMundo`) contiene `Checkpoint_<n>` y `Meta` directamente (otros scripts
  los buscan por nombre, p. ej. la catapulta y el cronómetro) y la subcarpeta `Niveles` con plataformas,
  lava y farolas. `Niveles` construye el mundo en segundo plano (`task.wait()` por lotes): quien necesite
  una pieza debe usar `WaitForChild` con tiempo largo. Nivel actual del jugador = atributo `Nivel`.
  Las luces de las farolas llevan la etiqueta `FarolaLuz` (CollectionService); `Noche` las enciende/apaga.
  Con miles de piezas: nada de bucles por frame sobre todas ellas (las plataformas móviles solo se
  actualizan si hay un jugador cerca) y `CastShadow = false`.
- Obstáculos (`Niveles`): los peligrosos son `CanCollide = false` + `hacerMortal` (Touched → `Health = 0`);
  las cosas animadas van a la lista `animados` y solo se mueven si hay un jugador a menos de 250 studs.
- Salto a checkpoint: `SaltoCheckpoint` (servidor) recibe el `RemoteEvent` `SaltarCheckpoint` (ReplicatedStorage),
  valida SIEMPRE todo lo que manda el cliente, cobra con un Producto de desarrollador y pide el salto con el
  atributo `SaltarANivel` (que `Niveles` ejecuta y borra). Los saltos pagados son el atributo `CreditosSalto`
  y se guardan en su propio DataStore. Solo ese script puede usar `MarketplaceService.ProcessReceipt`.
- Monedas de los niveles: llevan la etiqueta `MonedaGiratoria` y las hace girar el cliente (`GirarMonedas`), solo las cercanas.
  Nunca muevas miles de piezas desde el servidor cada frame.
- Clasificación: `OrderedDataStore` con el nivel más alto de cada jugador (`Clasificacion`). Pases de Robux: `PasesRobux`
  (`MarketplaceService:PromptGamePassPurchase`, `RemoteEvent` `ComprarPase`).
- **Dinero (Robux):** hoy hay DOS cosas de pago: el salto a checkpoint (producto de desarrollador, `SaltoCheckpoint`) y el
  Jetpack (pase de juego, `PasesRobux`). Los ids se dejan en 0 hasta que el adulto los pase. el usuario es un niño. Nunca inventes IDs de productos ni precios (el precio se pone en la web
  de Roblox y la pantalla lo lee del producto). No añadas compras con Robux ni cambies cuánto o cuándo se cobra sin que
  el adulto lo pida claramente. Mientras `idDelProducto` sea 0 no se cobra nada.
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
