# 🌍 Mis mundos de Roblox

Aquí creamos mundos de Roblox **con código** (en un lenguaje que se llama **Luau**).
Le pides a Claude lo que quieres ("quiero un castillo", "quiero que las monedas den velocidad"…),
Claude escribe el código, y tú lo metes en **Roblox Studio** para jugarlo.

## 📁 Qué hay aquí

| Archivo | Qué hace | Dónde va en Roblox Studio |
|---|---|---|
| `src/server/MiMundo.server.luau` | La base: suelo, punto de salida, monedas y marcador (Monedas, Victorias) | `ServerScriptService` → **Script** |
| `src/server/Niveles.server.luau` | Los **500 niveles**: no todos iguales (círculos, cuadrados entre lava, vigas, torres...), cada uno más difícil, largo y alto, con checkpoint, lava, paredes, obstáculos, monedas y cofres. Al final, la meta 🏆 | `ServerScriptService` → **Script** |
| `src/server/SaltoCheckpoint.server.luau` | El pago (5 Robux) y el salto a un checkpoint ya alcanzado. ⚠️ Falta poner el ID del producto (ver abajo) | `ServerScriptService` → **Script** |
| `src/server/Noche.server.luau` | Se hace de noche poco a poco y se encienden las farolas 🌙 | `ServerScriptService` → **Script** |
| `src/server/Catapulta.server.luau` | Catapulta junto a la salida: te lanza por los aires hasta el checkpoint del nivel 5 | `ServerScriptService` → **Script** |
| `src/server/Tienda.server.luau` | Tienda con 3 mejoras que se compran **una tras otra** con monedas: 🦘 salto y 👟 correr (hasta el nivel 600) y ✨ brillo en la espalda (hasta el 100) | `ServerScriptService` → **Script** |
| `src/server/Clasificacion.server.luau` | Tablero con los 10 mejores jugadores por nivel 🏆 (necesita el guardado activado) | `ServerScriptService` → **Script** |
| `src/server/PasesRobux.server.luau` | Cosas que se compran con Robux: el 🚀 Jetpack. ⚠️ Falta poner el ID del pase (ver abajo) | `ServerScriptService` → **Script** |
| `src/server/Guardado.server.luau` | Guarda monedas, victorias, mejoras de la tienda, cofres, estilo, mascotas, misiones, nivel y récord para la próxima vez (⚠️ necesita publicar el mundo, ver abajo) | `ServerScriptService` → **Script** |
| `src/server/Cronometro.server.luau` | Mide el tiempo hasta la meta y pone la columna "Mejor tiempo" en el marcador | `ServerScriptService` → **Script** |
| `src/client/Cronometro.client.luau` | Dibuja el reloj en la pantalla | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/client/SaltoCheckpoint.client.luau` | El botón "🚀 Saltar a checkpoint" y su ventanita | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/server/Estilo.server.luau` | Colores y estelas para el personaje, se compran con monedas 🎨 | `ServerScriptService` → **Script** |
| `src/server/Carrera.server.luau` | Modo carrera 🏁: todos salen a la vez y gana el primero en llegar a un nivel | `ServerScriptService` → **Script** |
| `src/client/Estilo.client.luau` | Botón "🎨 Estilo" y su ventana | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/client/Carrera.client.luau` | Botón "🏁 Carrera" y el cartel de arriba | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/client/Progreso.client.luau` | Barra de progreso "Nivel X de 500" | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/server/Mascotas.server.luau` | Mascotas que te siguen, se compran con ~30 monedas, te hacen correr más rápido y **suben de nivel** mientras juegas 🐾 | `ServerScriptService` → **Script** |
| `src/client/Mascotas.client.luau` | Botón "🐾 Mascotas" y su ventana | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/server/Logros.server.luau` | Insignias por logros (primer cofre, nivel 100, 10 carreras ganadas...) con premio de monedas 🏅 | `ServerScriptService` → **Script** |
| `src/server/Casas.server.luau` | El barrio de casitas: privadas, con visitas, muebles, colores de pared y estantería de trofeos 🏠 | `ServerScriptService` → **Script** |
| `src/client/Logros.client.luau` | Botón "🏅 Logros" y su ventana | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/client/Casa.client.luau` | Botón "🏠 Mi casa": ir a casa, visitas, paredes, muebles, 🛍️ mi puesto y 📸 álbum | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/server/Bosque.server.luau` | Prado de hierba y un bosque de árboles alrededor de la zona de salida 🌲 | `ServerScriptService` → **Script** |
| `src/client/Bosque.client.luau` | El bosque gigante de fondo del parkour, la neblina (espesa por las mañanas), rayos de sol, luciérnagas, hojas, 🐦 pájaros y 🦌 ciervos | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/server/JuegosCasa.server.luau` | Minijuegos de la casa: 🎯 diana, ⚽ pelota que bota y 🍳 cocina de comida de adorno | `ServerScriptService` → **Script** |
| `src/server/Album.server.luau` | Álbum de fotos 📸: la cámara cuelga cuadros con tus mejores momentos en la pared | `ServerScriptService` → **Script** |
| `src/server/Mercadillo.server.luau` | Puesto de venta 🛍️ en el jardín: vende muebles a otros jugadores por monedas | `ServerScriptService` → **Script** |
| `src/server/Retos.server.luau` | Reto de la semana y temporadas 🏆, con premios que decoran el jardín | `ServerScriptService` → **Script** |
| `src/client/Retos.client.luau` | Botón "🏆 Reto semanal" y su ventana | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/client/Mapa.client.luau` | Botón "🗺️ Mapa": tu nivel, los checkpoints y hasta dónde han llegado tus amigos | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/server/TiendaTemporada.server.luau` | Tienda de temporada 🎁: un mueble de jardín distinto cada semana, solo esa semana | `ServerScriptService` → **Script** |
| `src/server/RetoEquipo.server.luau` | Reto en equipo 🤝: tú y un amigo llegáis los dos al nivel 100 | `ServerScriptService` → **Script** |
| `src/server/CarreraMascotas.server.luau` | Carrera de tus dos mascotas en una pista junto al jardín 🐾🏁 | `ServerScriptService` → **Script** |
| `src/client/Pintar.client.luau` | Ventana para pintar un cuadro de 10 x 10 y colgarlo en tu casa 🎨 | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/client/EstadoGuardado.client.luau` | Etiqueta abajo a la izquierda: dice si tus monedas se están guardando 💾 | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/server/Playa.server.luau` | La playa y el mar 🏖️ con tiburones, delfines, ballena, tortugas, medusas, pulpos, estrellas de mar, cangrejos, focas... (se tocan y se les hace foto) | `ServerScriptService` → **Script** |
| `src/server/Pisos.server.luau` | Hasta 4 pisos para tu casa 🏢, con monedas, y el ascensor entre ellos | `ServerScriptService` → **Script** |
| `src/client/Jetpack.client.luau` | El jetpack: botón de comprar, botón de volar y barra de combustible | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/client/Mejoras.client.luau` | Panelito con el nivel de tus mejoras y lo que cuesta la siguiente | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/client/GirarMonedas.client.luau` | Hace girar las monedas que tienes cerca | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/client/Bienvenida.client.luau` | Enseña un mensaje de bienvenida en la pantalla | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |

- Los archivos que terminan en `.server.luau` son **Scripts** (funcionan en el servidor, para todos).
- Los que terminan en `.client.luau` son **LocalScripts** (funcionan en la pantalla de cada jugador).

## 🧒 Forma fácil: copiar y pegar

1. Abre **Roblox Studio** y crea un mundo nuevo con la plantilla **Baseplate**.
2. Si no ves los paneles, ve a la pestaña **Ver (View)** y activa **Explorador (Explorer)** y **Propiedades (Properties)**.
3. En el Explorador, pon el ratón encima de **ServerScriptService**, pulsa el **+** y elige **Script**.
4. Borra lo que trae dentro, y pega el código de `src/server/MiMundo.server.luau`.
5. Haz lo mismo con `src/client/Bienvenida.client.luau`, pero en
   **StarterPlayer → StarterPlayerScripts**, y eligiendo **LocalScript**.
6. Pulsa **▶ Jugar (Play)**. ¡A jugar!

> Para copiar el código desde GitHub: abre el archivo y pulsa el botón de **copiar** (dos cuadraditos) arriba a la derecha.
> Ojo: mira la rama donde Claude ha guardado los cambios (el desplegable de ramas arriba a la izquierda).

## 🚀 Forma pro: Rojo (conexión en directo, sin copiar y pegar)

📘 **Guía paso a paso con dibujos:** [`guia/GUIA-Mundos-Roblox.pdf`](guia/GUIA-Mundos-Roblox.pdf)

Resumen:

| Archivo (doble clic) | Cuándo | Qué hace |
|---|---|---|
| `INSTALAR` (.bat Windows / .command Mac) | Una sola vez | Descarga Rojo y pone su plugin en Roblox Studio |
| `ACTUALIZAR` | Cada vez que Claude hace algo nuevo | Baja de GitHub lo último (elige sola la rama más reciente) |
| `CONECTAR` | Cada vez que juegas | Enciende Rojo. En Studio: Plugins → Rojo → Connect |

Antes hay que instalar Roblox Studio y Git, y bajar el proyecto una vez con
`git clone https://github.com/ernestobm2012-tech/roblox.git` (todo explicado en la guía).

## 🗼 Los 500 niveles

- Cada nivel empieza en un **checkpoint**: plataforma blanca con el número, una **moneda**, una farola y un **sol blanco** encima. Si te caes o tocas la lava, vuelves al último que alcanzaste.
- **Cada nivel sube un poquito más que el anterior**: el nivel 1 sube 6 studs, el 2 sube 6,1, el 3 sube 6,2... y el 500 sube 60. Como también tiene más plataformas, cada nivel es **más largo y más alto**.
  Además las plataformas son más pequeñas, y hay más zigzag.
- **No todos los niveles son iguales.** El cartel del checkpoint dice cómo es el nivel:
  - ⭕ **Círculos**: plataformas redondas que van en zigzag (por ejemplo el **nivel 7**)
  - 🔥 **Cuadrados en la lava**: cuadraditos pequeños en medio de un mar de lava (por ejemplo el nivel 12)
  - 🪵 **Vigas**: tablones finos y largos (por ejemplo el nivel 15)
  - 🗼 **Torre**: una escalera altísima con pilares, mucho más alta que sus vecinos (por ejemplo el nivel 20)
  - En el resto, unos 4 de cada 10 niveles tienen una de estas formas al azar. Los niveles 1 y 2 son siempre normales.
- **Plataformas especiales:** desde el nivel 60, **naranjas que se caen** al pisarlas; desde el 150, **azules que se mueven**; desde el 300, de **hielo** que resbalan (si no resbalan, díselo a Claude); desde el 40, **verdes** que son trampolines y te lanzan hacia arriba.
- **Tramos de obstáculos** (una plataforma larga donde hay que saltar):
  - **rodillos** que ruedan: en **todos los niveles del 1 al 200** (y después, a veces)
  - desde el nivel 10: **cubos** fijos (muros bajos, no hacen daño)
  - desde el 20: **charcos de lava**
  - desde el 80: **cuadrados** que se deslizan
  - desde el 250: **barras de lava que giran** como una hélice
- **Lava debajo de todos los saltos** (cerquita) y, muy abajo, otra por si te caes más. **Paredes** transparentes a los dos lados de la pista para no salirse.
- **Monedas por todas partes** 🪙: encima de las plataformas, flotando sobre los obstáculos (¡se cogen al saltarlos!) y una de 5 en cada checkpoint. Giran. Vuelven a aparecer al minuto.
- **Cofre sorpresa** 🎁 en los checkpoints 50, 100, 150... Cada jugador lo abre una vez (mantén **E**) y da monedas.
- **El checkpoint del nivel 250 es enorme**: un bloque de unos 5 metros (18 studs).
- Llegar a un nivel nuevo da 🪙 monedas y sale **confeti** 🎉. Tu nivel sale en el marcador (columna **Nivel**), en una **barra de progreso** arriba y se guarda.
- **Cada 100 niveles** (100, 200, 300…), ¡todos los jugadores ven en pantalla quién ha llegado!
- Al llegar a la meta 🏆 (nivel 500) ganas y vuelves a empezar.
- **Tablero de los 10 mejores jugadores** 🏆 detrás de la salida (se actualiza cada minuto; necesita el guardado activado).
- Al darle a Play, el juego tarda unos segundos en construir los 500 niveles (en **Salida** pondrá `🗼 ¡500 niveles construidos!`).
- El mundo es **enorme** (~18.000 piezas, ~80 km). ¿Va lento? En `Niveles.server.luau` (tabla `AJUSTES`) puedes bajar `numeroDeNiveles`, subir `farolaCadaNiveles`, o activar `StreamingEnabled` en Workspace.

## 🏁 Modo carrera

Pulsa el botón **🏁 Carrera** (a la izquierda) para apuntarte. Cuando hay **2 jugadores o más**, empieza una cuenta atrás de 20 segundos; después todos aparecen en la salida del nivel 1, ven un **3, 2, 1** quietos y **salen a la vez**. **Gana el primero en llegar al checkpoint del nivel 10**: se lleva 100 🪙 (los demás, 10) y su nombre sale en la pantalla de todos. Luego cada uno **vuelve a su nivel de siempre**: la carrera no cambia tu nivel guardado.
- Se puede cambiar a qué nivel hay que llegar, cuántos jugadores hacen falta y los premios en `Carrera.server.luau` (tabla `AJUSTES`).
- El récord de carrera se guarda: si alguien lo bate, sale un mensaje a todos. (Necesita el guardado activado.)

## ⏱️ Mensajes de récord

- Cuando alguien llega a la meta con **su mejor tiempo**, sale un mensaje a todos: *"¡Fulano ha batido su récord de tiempo!"*
- Si además es el mejor tiempo de **todos los jugadores de todos los tiempos**, sale un mensaje extra: *"🌟 ¡RÉCORD DEL MUNDO!"*. (Para esto hace falta el guardado activado.)

## 🐾 Mascotas (¡suben de nivel!)

El botón **🐾 Mascotas** (a la izquierda) abre la lista. Cada mascota **te sigue a todas partes** y **te hace correr más rápido**. Se compran con monedas, una sola vez. Puedes tener todas y llevar **DOS puestas a la vez** (una a cada lado, y **sus velocidades se suman**). Pulsa una que ya llevas para quitártela, o **Quitar las mascotas** para quedarte sin ninguna.

| Mascota | Precio | Velocidad extra (nivel 1) |
|---|---|---|
| 🐶 Perrito · 🐱 Gatito · 🐥 Pollito | 30 🪙 | +2 |
| 🐰 Conejito | 40 🪙 | +3 |
| 🐲 Dragoncito | 60 🪙 | +5 |
| 🤖 Robot | 80 🪙 | +6 |

⭐ **Las mascotas que llevas puestas suben de nivel mientras juegas** (hasta el nivel 30, las dos a la vez). Gana experiencia (XP) por:
- cada rato que juegas con ella (1 XP cada 10 segundos),
- cada moneda que recoges (1 XP),
- cada nivel nuevo del parkour (5 XP).

Cada nivel que sube: **corres un poquito más** (+0,15), la mascota se hace **un poco más grande** y sale un aviso. Cada mascota guarda **su propio nivel** (se guarda). En la ventana ves su nivel y lo que le falta para el siguiente. Se cambia lo rápido que sube, el máximo, etc. en `Mascotas.server.luau` (tabla `AJUSTES`). La velocidad de la mascota se **suma** a la de "Correr" de la tienda.

✨ **¡Evolución!** Cuando una mascota llega al **nivel 30 cambia de aspecto**: se convierte en su forma final, con otro color, piezas nuevas, un **aura de chispas** y **+2 de velocidad extra**. Sale un aviso morado cuando pasa.

| Mascota | Evoluciona en | Cómo se ve |
|---|---|---|
| 🐶 Perrito | 🐺 Lobo | gris, con capa roja de superhéroe y collar que brilla |
| 🐱 Gatito | 🦁 León | dorado, con melena y corona |
| 🐥 Pollito | 🦅 Águila | marrón, con alas y cabeza blanca |
| 🐰 Conejito | 🦄 Unicornio | con cuerno que brilla y crin de colores |
| 🐲 Dragoncito | 🐉 Dragón | rojo, con alas de fuego |
| 🤖 Robot | 🛸 Mega Robot | azul, con un aro brillante y hombreras |

## 🏅 Logros (insignias)

El botón **🏅 Logros** enseña las 12 insignias: las que ya tienes y las que te faltan. Al conseguir una ganas **monedas de premio**:

| Insignia | Cómo se consigue | Premio |
|---|---|---|
| 🎁 Primer cofre | Abrir tu primer cofre sorpresa | 10 🪙 |
| 🗝️ Cazatesoros | Abrir 10 cofres | 50 🪙 |
| 🥉 🥈 🥇 💎 Nivel 10 / 50 / 100 / 250 | Llegar a ese nivel | 10 / 30 / 60 / 150 🪙 |
| 🏆 ¡Campeón! | Llegar a la meta del nivel 500 | 300 🪙 |
| 🏁 Primera victoria | Ganar una carrera | 25 🪙 |
| 🏎️ Piloto | Ganar 10 carreras | 100 🪙 |
| 💰 Millonario | Recoger 1000 monedas | 50 🪙 |
| 🐾 Amigo fiel | Conseguir tu primera mascota | 15 🪙 |
| ⭐ Gran entrenador | Subir una mascota al nivel 10 | 80 🪙 |

Se guardan, y además salen como **trofeos dorados** en la estantería de tu casa.

## 🏠 Tu casita (en el barrio, fuera del parkour)

A los dos lados de la zona de salida (en la hierba, **fuera del parkour**) hay un **barrio de 12 casitas**. Cada jugador que entra se queda con una y en el tejado pone **"🏠 Casa de <tu nombre>"** y un candado (🔒 cerrada · 🔓 abierta a los amigos).
- Es **privada**: la puerta está cerrada para todos menos para ti. Pulsa **E** en la puerta, o usa el botón **🏠 Mi casa**, y apareces dentro. Para **salir**, pulsa **E** en la alfombrilla verde de la puerta (o el botón): vuelves a tu nivel.
- **👋 Visitas:** en el botón **🏠 Mi casa** puedes **abrir tu casa a tus amigos de Roblox** (🔓). Sus amigos entran pulsando **E** en la puerta, ven la casa y salen por la alfombrilla. También puedes **invitar a jugadores concretos** que estén en el juego (aunque no sean amigos de Roblox) y **quitarles la invitación**. Si cierras la casa, quitas la invitación o te vas del juego, los visitantes salen. Por defecto la casa está **cerrada**.
- **🏡 Jardín:** delante de cada casa hay un jardín con **césped, un camino, una valla blanca y flores** (cada casa tiene sus flores).
- **🎉 Fiestas:** cuando hay **visitas dentro** (o cuando el dueño pulsa **🎉 Poner una fiesta** en "Mi casa") se encienden **4 focos de colores** en el techo y una **bola de discoteca**, sale **confeti** y el cartel del tejado se llena de 🎉. Si quieres **música**, busca una canción en la Toolbox/Creator Store (pestaña Audio) y dile a Claude su número (ID): se pone en `Casas.server.luau` (`musicaDeLaFiesta`). Sin número no suena nada.
- **🎨 Paredes:** compra colores de pared (10–15 🪙): crema, rosa, azul cielo, verde menta, limón, lila, naranja, gris, blanco, rojo, azul y verde. Se pintan por fuera y por dentro.
- **🛋️ Muebles** (se compran con monedas y se colocan **solos**, se guardan): 🛏️ cama (3), 🛋️ sofá (2), 🍽️ mesa (2), 🪑 silla (3), 💡 lámpara (3), 🪴 planta (4), 📚 librería (2), 📺 tele, 🧊 nevera, 🟥 alfombra (2), 🖼️ cuadros (3), y nuevos: 🛏️ mesitas de noche (2), 🧰 baúl de juguetes, 🐠 acuario, 🖥️ escritorio con ordenador, y **colgados en la pared**: ⏰ relojes (2), 🪞 espejos (2) y 🪟 ventanas (2). No caben más de cada tipo que huecos hay.
- En la pared de la puerta hay una **estantería con 12 trofeos**, uno por cada logro: dorado si lo tienes, gris con candado si no.
- Si hay más de 12 jugadores a la vez, los últimos se quedan sin casa. Se puede cambiar el número de casas en `Casas.server.luau`.

## 🌲 El bosque

El parkour está **en medio de un bosque**:
- En la **zona de salida**, el suelo es un **prado de hierba** y alrededor hay **robles, pinos, arbustos y rocas**.
- A los dos lados de la **pista** salen **árboles altísimos** (troncos y copas verdes) a medida que avanzas, como si estuvieras saltando entre las copas. Hay una **neblina verde** suave, **luciérnagas** que flotan alrededor (se ven mejor de noche) y **hojas que caen**.
- El bosque de la pista **se dibuja solo en tu pantalla** (no pesa nada). Si quieres menos neblina o árboles más lejos, se cambia en `Bosque.client.luau` (tabla `AJUSTES`).

## 🌤️ Día y noche, niebla y animales

Ahora el día **da la vuelta entera** (unos 6 minutos): tarde → noche → **mañana con niebla espesa** → mediodía con **rayos de sol** entre los árboles. Los **pájaros** cruzan el cielo y los **ciervos** pasean junto a la pista (solo en tu pantalla). Se ajusta en `Noche.server.luau` (`segundosPorDia`) y `Bosque.client.luau`.

## 🏡 Casa: minijuegos, álbum y puesto

- **Minijuegos** (se compran en 🛋️ Muebles): 🎯 **diana** (lanza dardos, récord de puntos), ⚽ **pelota** que bota y 🍳 **cocina** (cocinas pizza, tarta, donuts... de adorno).
- **📸 Álbum**: compra la **cámara**, pulsa *Hacer una foto* y tu personaje queda en un cuadro en la pared. Salen fotos solas al conseguir logros y cada 50 niveles. Las fotos son un retrato de tu personaje (Roblox no deja guardar capturas de pantalla reales).
- **🛍️ Mi puesto**: en el jardín tienes una mesa donde vendes hasta 3 muebles. Pones tú el precio (1–999 🪙). El comprador necesita casa, sitio y monedas.

## 🏆 Reto semanal y temporadas

Cada semana hay un **reto nuevo** (por ejemplo *sube 80 niveles sin morir*). Al cumplirlo ganas monedas y un **premio para el jardín** (⛲ fuente, 🗽 estatua, 🏮 farolillos, 🚀 cohete, 🦩 flamenco, 🌈 arcoíris). Cada 4 semanas empieza una **temporada**. Cambia los jueves a las 00:00 UTC. Se ve en el botón **🏆 Reto semanal**.

## 🎁🤝🐾🎨 Temporada, equipo, carrera de mascotas y cuadros

- **🎁 Tienda de temporada** (en "Mi casa"): cada semana hay UN mueble de jardín (⛄🎃🏖️🌻🎄🪁) que **solo se puede comprar esa semana**. Cuesta 60 🪙 y es tuyo para siempre. Sale en la franja de césped a la derecha de tu jardín.
- **🤝 Reto en equipo** (en "Reto semanal"): invitas a un **amigo de Roblox** y tenéis que llegar **los dos** al nivel 100. Si lo conseguís, ganáis 200 🪙 cada uno y la siguiente meta es 200, 300...
- **🐾 Carrera de mascotas**: junto a tu jardín hay una pista de dos carriles. Corren tus dos mascotas (cuanto más nivel, más rápidas). Pulsa **E** en una banderita para animar a una; si gana, +5 🪙.
- **🎨 Pintar cuadros**: en "Mi casa → Álbum → Pintar un cuadro" pintas un dibujo de 10 x 10 con 12 colores y se cuelga en la pared con tus fotos.

## 🏖️ Playa, 🦊 más animales y 🏢 pisos

- **Más animales en el bosque** (cada uno con su comida): 🦌 ciervo (manzana), 🐰 conejo (zanahoria), 🦊 zorro (uvas), 🐿️ ardilla (nuez), 🐻 oso (miel), 🐦 pájaros, 🦋 mariposas (de día) y 🦉 búhos (de noche). **E** = acariciar, **R** = dar de comer, **F** = hacerle una **foto 📸** con tu cámara (sale en tu álbum).
- **Playa**: al fondo, detrás de la zona de salida, sigue el **camino de madera**. Hay palmeras, sombrillas y un mar (el agua llega al pecho, no pasa nada por entrar) con 🦈 tiburones, 🐬 delfines, 🐋 una ballena, 🐢 tortugas, 🐠 peces payaso, 🪼 medusas, 🐙 pulpos, 🐴 caballitos de mar, 🐡 peces globo, ⭐ estrellas de mar, 🦀 cangrejos y 🦭 focas. Se tocan (E) y se les hace foto (F).
- **Pisos**: en "Mi casa → Pisos" compras hasta **4 pisos** (150, 300 y 600 🪙): dormitorio, sala de juegos y mirador de cristal. Te mueves con el **🛗 Ascensor**.

## 💾 Todo se guarda

Se guardan las **monedas, las victorias, el nivel, el récord y todo lo que compras** (mejoras, estilos, mascotas, muebles, premios, muebles de temporada, cuadros y fotos). Se guarda a los pocos segundos de cambiar algo, cada 30 segundos y al salir. Recuerda: hay que **publicar el mundo** y activar "acceso de Studio a servicios de API".

## 🌍 Mundo 2

En la meta ahora pone **"🌍 ¡MUNDO 2 muy pronto!"**. El mundo 2 se hará más adelante.

## 🗺️ Mapa

El botón **🗺️ Mapa** enseña tu nivel, un punto cada 10 checkpoints y a tus **amigos de Roblox que están jugando ahora** (los que no están conectados no salen).

## 🎨 Estilo: colores y estelas

El botón **🎨 Estilo** (a la izquierda) abre una ventana con **colores** (tu personaje se pone de ese color) y **estelas** (te sale una cola detrás al correr: fuego, hielo, veneno, estrellas, corazón, fantasma y arcoíris). Se compran con monedas, una sola vez; después puedes cambiar de uno a otro gratis o pulsar **Quitar**. Se guardan.

## ✨ Más cosas

- 🌠 De noche pasan **estrellas fugaces** por el cielo.
- 🎉 **Confeti** al llegar a un checkpoint nuevo.
- 📈 **Barra de progreso** arriba con tu nivel.
- 🟢 **Trampolines** desde el nivel 40.

## 🛒 La tienda de mejoras

Tres puestos junto a la salida. Cada puesto vende una mejora que se compra **una tras otra**: cada compra sube **un nivel** y la siguiente cuesta un poquito más.
- 🦘 **Súper salto** (hasta el nivel 600) · 👟 **Correr** (hasta el nivel 600) · ✨ **Brillo en la espalda** (hasta el nivel 100)
- Mantén **E** delante del puesto. En la pantalla (a la izquierda) ves tu nivel de cada mejora y lo que cuesta la siguiente. Se guardan.
- ⚠️ En el nivel 600 de salto saltas mucho más alto que al principio: puedes cambiar cuánto da cada nivel en `Tienda.server.luau` (`saltoPorNivel`, `velocidadPorNivel`).

## 🚀 Saltar a un checkpoint (5 Robux) — ⚠️ un adulto debe activarlo

El botón **🚀 Saltar a checkpoint** (a la izquierda de la pantalla) deja volver a cualquier checkpoint que ya hayas alcanzado.
**Cada salto cuesta 5 Robux.** Roblox enseña su propia ventana de compra y hay que confirmarla.

**Mientras no esté activado no se cobra nada:** en Roblox Studio el salto es gratis (modo prueba), y en el juego publicado el botón dice que aún no está activada la compra.

Para activarlo (una sola vez; los nombres de los menús de Roblox pueden cambiar un poco):
1. Entra en **create.roblox.com** → **Creaciones** (*Creations*) → tu mundo → **Monetización** → **Productos de desarrollador** (*Developer Products*) → **Crear**.
2. Nombre: `Saltar checkpoint`. Precio: **5 Robux**. Guarda.
3. Copia el **número (ID)** del producto.
4. Díselo a Claude: *"El ID del producto es 123456789"*. Claude lo pondrá en `SaltoCheckpoint.server.luau` (si lo cambias tú dentro de Studio, Rojo lo borra).
5. **ACTUALIZAR**, publica el mundo y pruébalo con una compra de verdad.

⚠️ **Importante:** la compra gasta los Robux de la **cuenta que está jugando**. Como el creador tiene 11 años, conviene revisar los **controles parentales** de su cuenta de Roblox (límite de gasto mensual, PIN). Roblox se queda con una parte de cada venta.
Si compras y algo falla, el salto pagado queda guardado y se puede usar después: no se pierde.

## 🚀 El Jetpack (se compra con Robux) — ⚠️ un adulto debe activarlo

Con el **Pase del Jetpack** puedes **volar un ratito**: mantén **ESPACIO** en el aire (o el botón 🚀 de la pantalla, que sirve en el móvil) y subes echando fuego. Tienes combustible para unos segundos y se recarga al pisar el suelo. Se paga **una sola vez** y es tuyo para siempre.

**Mientras no esté activado no se cobra nada:** en Studio es gratis (modo prueba) y en el juego publicado el botón dice que aún no está activado.

Para activarlo (los nombres de los menús pueden cambiar un poco):
1. **create.roblox.com** → **Creaciones** → tu mundo → **Monetización** → **Pases** (*Passes*) → **Crear un pase**.
2. Nombre: `Jetpack`. Pon el **precio en Robux** que quieras (lo decides tú). Guarda y **ponlo a la venta**.
3. Copia el **número (ID)** del pase y díselo a Claude: *"El ID del pase del jetpack es 123456789"*. Claude lo pone en `PasesRobux.server.luau`.
4. **ACTUALIZAR**, publica y prueba. La pantalla enseña el precio real del pase.

⚠️ Igual que con el salto: gasta los Robux de la cuenta que juega. Revisa los controles parentales.
⚠️ El jetpack deja saltarse partes de los niveles (por eso el combustible dura poco y las paredes son altas).

## 💾 Para que se guarden las monedas (una sola vez, un adulto)

Roblox solo guarda datos de un mundo que está **publicado**. En Roblox Studio:

1. Menú **Archivo → Publicar en Roblox** (*File → Publish to Roblox*). Ponle nombre y pulsa **Crear**.
2. Pestaña **Inicio → Configuración del juego** (*Game Settings*) → **Seguridad** (*Security*) →
   activa **Habilitar acceso de Studio a servicios de API** (*Enable Studio Access to API Services*) → **Guardar**.
3. Dale a Play. En **Vista → Salida** tiene que poner `💾 Guardado listo.`
   (y, la segunda vez que juegues, `💾 ¡Datos de … cargados!`).

Si no lo haces, el juego funciona igual pero **no guarda nada**, y en Salida verás un aviso amarillo `💾 ⚠️ NO SE GUARDARÁ NADA…`.

## 💡 Ideas para pedirle a Claude

- "Pon un segundo cofre sorpresa en cada checkpoint de la 25"
- "Pon plataformas que desaparecen cuando las pisas"
- "Construye un castillo con torres al lado del parkour"
- "Que de noche salgan estrellas fugaces"
- "Pon un trampolín que te lance muy alto"
