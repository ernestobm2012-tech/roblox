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
| `src/server/Mascotas.server.luau` | Mascotas que te siguen, se compran con ~30 monedas y te hacen correr más rápido 🐾 | `ServerScriptService` → **Script** |
| `src/server/Misiones.server.luau` | 3 misiones nuevas cada día con premio de monedas 📅 | `ServerScriptService` → **Script** |
| `src/client/Mascotas.client.luau` | Botón "🐾 Mascotas" y su ventana | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/client/Misiones.client.luau` | Botón "📅 Misiones" y su ventana | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/client/Tormenta.client.luau` | La lluvia, el cielo oscuro y los rayos de las tormentas ⛈️ | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
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

## 🐾 Mascotas

El botón **🐾 Mascotas** (a la izquierda) abre la lista. Cada mascota **te sigue a todas partes** y **te hace correr más rápido**. Se compran con monedas, una sola vez, y puedes tener todas pero solo una puesta a la vez (o ninguna: **Quitar**). Se guardan.

| Mascota | Precio | Velocidad extra |
|---|---|---|
| 🐶 Perrito · 🐱 Gatito · 🐥 Pollito | 30 🪙 | +2 |
| 🐰 Conejito | 40 🪙 | +3 |
| 🐲 Dragoncito | 60 🪙 | +5 |
| 🤖 Robot | 80 🪙 | +6 |

La velocidad de la mascota se **suma** a la de la mejora "Correr" de la tienda. Precios y velocidades se cambian en `Mascotas.server.luau`.

## 📅 Misiones del día

El botón **📅 Misiones** enseña tus **3 misiones de hoy**, lo que llevas de cada una y el premio. Al cumplir una te dan monedas al momento, y si cumples las 3 hay **premio extra (30 🪙)**. Salen misiones nuevas cada día a medianoche (hora UTC).
- Ejemplos: 🪙 *Recoge 50 monedas* · 🗼 *Llega al nivel 30* (se adapta a tu nivel) · 🎁 *Abre un cofre* · 🛒 *Compra una mejora* · 🏁 *Corre una carrera*.
- El progreso se guarda (necesita el guardado activado para recordarlo de un día a otro).

## ⛈️ Tormentas

En los **niveles 50, 100, 150, 200, 250, 300, 350, 400, 450 y 500** hay tormenta: **llueve**, el cielo se oscurece y de vez en cuando cae un **rayo** con destello y un temblor de trueno. Se ve en el cartel del checkpoint ("⛈️ Tormenta"). Es **solo un adorno**: no hace daño ni cambia los saltos. Los niveles con tormenta se cambian en `Niveles.server.luau` (`nivelesConTormenta`).

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
