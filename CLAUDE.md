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
  `require`: `Mejora_<id>` y `Precio_<id>` (tienda de mejoras por niveles), `Cofre_<nivel>` (cofres abiertos), `Estilo_*` y `Equipo_*` (estilo y mascotas), `Logro_*`, `Casa_*`, `Mascota_xp_*` y `Estad_*` (contadores, se guardan), `Pase_<clave>` (pases de Robux), `Nivel` (el más alto alcanzado), `SaltarANivel`, `CreditosSalto`, `MejorTiempo`, `CronoEstado`/`CronoInicio`/`CronoFinal`/`CronoRecord`
  (cronómetro). `Guardado` guarda todo lo que empiece por `Compra_`, `Cofre_` o `Mejora_` (lista `PREFIJOS`, valores sí/no, números o textos de hasta 40 letras), `Nivel` y `MejorTiempo`, y el marcador `leaderstats`
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
- Formas de nivel (`temaDelNivel` en `Niveles`): "normal", "circulos", "lava", "vigas", "torre" (los niveles 7, 12, 15 y 20
  están fijados en `temasFijos`). El tema solo cambia cómo se ponen las plataformas; la altura, el checkpoint y los tramos
  funcionan igual. Si añades una forma nueva, compruébala con los límites HUECO_MAXIMO / SUBIDA_MAXIMA.
- Carrera (`Carrera`): lleva a todos al nivel 1 con el atributo `SaltarANivel`, congela con `Anchored` durante la cuenta atrás y
  los devuelve a su `Nivel`. El cartel de la pantalla sale de `workspace:GetAttribute("CarreraTexto")`. RemoteEvent `Carrera`.
- Estilo (`Estilo`): atributos `Estilo_<tipo>_<id>` (comprado) y `Equipo_color` / `Equipo_estela` (puesto, texto); el catálogo
  se publica en `ReplicatedStorage.CatalogoEstilo` y el cliente pide cosas con el RemoteEvent `EstiloAccion`.
- Récords: `Cronometro` y `Carrera` usan el DataStore `MiMundoRecords_v1` (claves `recordMeta` y `recordCarrera`).
- Mascotas (`Mascotas`): modelos de partes ancladas que siguen al dueño con `PivotTo` en Heartbeat (pocas, nada de física).
  Compradas = `Estilo_mascota_<id>`, puesta = `Equipo_mascota`, XP de cada una = `Mascota_xp_<id>` (se guarda); el nivel sale del XP
  (`nivelDeXP`). Suman velocidad con el atributo `BonusMascota`, que `Tienda` suma a `WalkSpeed` (la ÚNICA que toca `WalkSpeed`).
  RemoteEvent `MascotaAccion`, catálogo `ReplicatedStorage.CatalogoMascotas`. Solo se da XP por lo que pasa DESPUÉS de cargar lo guardado.
- Logros (`Logros`): lista `LOGROS` (12, uno por trofeo de la casa); el estado es `Logro_<id>`; leen `Estad_*`, `Nivel`, `MascotaMaxNivel`
  y el marcador `Victorias`. Catálogo en `ReplicatedStorage.CatalogoLogros`. Para un logro nuevo: añádelo a `LOGROS` (y súbele
  el límite de huecos de trofeos en `Casas` si pasa de 12). `Guardado` pone `DatosCargados` al terminar de cargar.
- Dos mascotas a la vez: hay dos HUECOS (`HUECOS` en `Mascotas`): `Equipo_mascota` (derecha) y `Equipo_mascota2` (izquierda). Las dos ganan XP,
  `BonusMascota` es la SUMA de las dos, y `mascotas[jugador][hueco]` guarda cada modelo. Un `Estilo_mascota_<id>` solo se puede poner en un hueco.
- Jardín y fiestas (`Casas`): el jardín (césped, camino, valla, flores) se construye en `construirCasa`. Fiesta = `casa.fiestaManual` (botón del dueño,
  atributo `FiestaManual`, no se guarda) o `hayVisitas(casa)`; un bucle de 0.4 s llama a `actualizarFiesta` y cambia los colores de los focos. La música es
  `AJUSTES.musicaDeLaFiesta` (0 = sin música; NUNCA inventes un ID de audio).
- Evolución de mascotas: cada mascota de `MASCOTAS` tiene una `evolucion` (nombre, color, piezas extra, color de aura) que se
  usa al llegar a `nivelMaximo`; `actualizarMascota` reconstruye el modelo (`ponerMascota`) cuando cambia de forma y suma `bonusEvolucion`.
- Bosque: `Bosque` (servidor) pinta el suelo y planta árboles en la zona de salida; `Bosque` (cliente) dibuja árboles gigantes solo en la pantalla
  del jugador a los lados de la pista (trozos de 50 studs alrededor del jugador, alturas sacadas de los `Checkpoint_*`), más
  `Atmosphere`, luciérnagas y hojas. Nada de miles de piezas en el servidor para esto.
- Casas (`Casas`): barrio de casas FUERA del parkour (a los lados de la zona de salida, `casasPorLado`), cada jugador se queda con
  una (`CasaNumero`). Privadas: la puerta es sólida y solo el dueño entra con `ProximityPrompt`/botón (se teletransporta dentro; mientras
  tanto `EnCasa` = true para que `Niveles` no lo "tire" por estar lejos de su checkpoint). Muebles = `Casa_<id>` (cantidad, en huecos
  fijos de `MUEBLES`; los huecos están comprobados para que no se pisen: si cambias uno, comprueba que no choque). Trofeos
  desde `Logro_*`. Visitas: `Casa_abierta` (1 = amigos de Roblox pueden entrar, vía `IsFriendsWith`) e `Invitado_<idDelDueño>` (atributo en
  el INVITADO, no se guarda); el visitante lleva `CasaVisitada` y `EnCasa`. Paredes: `Casa_pared` (color puesto) y `Casa_pared_<id>` (comprado).
  RemoteEvent `CasaAccion` (ir, salir, comprar, pared, abrir, invitar), catálogos `ReplicatedStorage.CatalogoMuebles` y `CatalogoParedes`.
- Botones de la pantalla: columna a la izquierda desde `UDim2.new(0, 12, 0.3, 0)`, cada uno 54 px más abajo (checkpoint 0,
  estilo 54, carrera 108, jetpack 162, mascotas 216, logros 270, casa 324, reto semanal 378, mapa 432). El panel de mejoras va a la derecha.
- Casa ampliada: minijuegos (`JuegosCasa`, etiquetas `JuegoDiana`/`JuegoPelota`/`JuegoCocina` puestas por `Casas` en los muebles `diana`/`pelota`/`cocina`),
  álbum (`Album`, mueble `camara`, atributos `Foto_<n>_pie/fecha/nivel`, RemoteEvent `AlbumAccion`) y puesto de venta (`Mercadillo`, atributos
  `Venta_<hueco>_id/precio`, RemoteEvent `MercadilloAccion`; mueve monedas y `Casa_<id>` de forma atómica). Las casas llevan una pieza `Origen` con la
  etiqueta `CasaOrigen` y atributo `Indice`: otros scripts cuelgan cosas de ahí. Zonas libres en el jardín: puesto (x −10.7..−3.5, z −22.7..−17.5) y `SITIOS_DE_PREMIOS`.
- Retos (`Retos`): reto semanal rotando (`RETOS`, semana = `os.time() // 604800`), progreso con `Reto_*` y los contadores `Estad_*`; premios `Premio_<id>` que
  `Retos` dibuja en la carpeta `Premios` del jardín. Datos de la semana en atributos de `workspace` (`RetoTipo`, `RetoObjetivo`...). RemoteEvent `RetoAccion`,
  catálogo `ReplicatedStorage.CatalogoPremios`. `Guardado` también guarda `Venta_`, `Foto_`, `Premio_`, `Reto_`.
- Tiempo: `Noche` hace un día continuo (`segundosPorDia`); `Bosque` (cliente) pone niebla de mañana, `SunRaysEffect`, haces de luz, pájaros y ciervos locales. `Mapa` (cliente)
  dibuja el mapa con `Nivel` de los jugadores y `IsFriendsWith` (solo amigos presentes).
- Temporada y más: `TiendaTemporada` (mueble de la semana en `workspace:GetAttribute("TemporadaMueble")`, compra con RemoteEvent `TemporadaAccion`, atributo `Temporada_<id>` que se guarda,
  dibujado en la franja x=+14 del jardín), `RetoEquipo` (RemoteEvent `EquipoAccion`, atributos `Pareja`, `ParejaNombre`, `ParejaMeta`, `EquipoInvita*`; solo amigos de Roblox, NO empiezan por `Equipo_`
  porque eso se guarda), `CarreraMascotas` (pista en la franja x=−14 del jardín, lee `Equipo_mascota`/`Equipo_mascota2` y `Mascota_xp_*`), `Pintar` (cliente) + `Album` (acción `cuadro`: 100 letras de la
  paleta en `Foto_<n>_d1..d3`, 3 trozos de ≤40 letras para que `Guardado` los guarde). `Casas.separacion` es 38 (casa 22 + jardín 13 + hueco) para que los jardines no pisen la casa vecina.
- `Guardado` guarda también a los pocos segundos de cambiar monedas/victorias/algo guardable (`guardarPronto`). Prefijos: añade `Temporada_`. La meta lleva el cartel "MUNDO 2 muy pronto" (el mundo 2 es un proyecto futuro).
- Brillo: `Noche` tiene `brilloDeNoche`, `brilloDeDia`, `exposicion` (bajados a petición del usuario).
- Animales: en `Bosque` (cliente) la tabla `ESPECIES` (suelo/aire) con prompts E (acariciar), R (comida) y F (foto → RemoteEvent `AlbumAccion` "fotoAnimal"); `Playa` (servidor) hace la playa en z −190..−350 y los
  animales del mar (lista `animales`, solo se mueven si hay un jugador cerca; foto con el atributo `PedirFotoAnimal` = "clave:n"). `Album` tiene la lista blanca `ANIMALES` (clave → emoji/nombre) y guarda `Foto_<n>_animal`.
- Pisos (`Pisos`): atributo `Casa_pisos` (1–4, se guarda), RemoteEvent `PisosAccion` ("comprar", "ir", n), catálogo `CatalogoPisos`. Cada piso mide 11 de alto (`yBase(k) = 0.6 + 11*(k-1)`), sube la pieza `Tejado`
  de `Casas` y el ascensor es un botón (no hay escaleras). Si cambias el tamaño de la casa en `Casas`, revisa `Pisos`.
- Barcos (`Barcos`, VehicleSeat movido por script, límites del mar y zonas prohibidas) y tiburones de `Playa` (zona z < −298: persiguen y ponen `Health = 0`; el que va sentado en barco está a salvo). `Bosque` (servidor) no planta árboles dentro del barrio de casas ni en el camino (`hayCasaOCamino`).
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
