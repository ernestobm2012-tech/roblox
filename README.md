# 🌍 Mis mundos de Roblox

Aquí creamos mundos de Roblox **con código** (en un lenguaje que se llama **Luau**).
Le pides a Claude lo que quieres ("quiero un castillo", "quiero que las monedas den velocidad"…),
Claude escribe el código, y tú lo metes en **Roblox Studio** para jugarlo.

## 📁 Qué hay aquí

| Archivo | Qué hace | Dónde va en Roblox Studio |
|---|---|---|
| `src/server/MiMundo.server.luau` | La base: suelo, punto de salida, monedas y marcador (Monedas, Victorias) | `ServerScriptService` → **Script** |
| `src/server/Niveles.server.luau` | Los **500 niveles**: cada uno más difícil, más largo y más alto, con checkpoint, lava, obstáculos y farola. Al final, la meta 🏆 | `ServerScriptService` → **Script** |
| `src/server/SaltoCheckpoint.server.luau` | El pago (5 Robux) y el salto a un checkpoint ya alcanzado. ⚠️ Falta poner el ID del producto (ver abajo) | `ServerScriptService` → **Script** |
| `src/server/Noche.server.luau` | Se hace de noche poco a poco y se encienden las farolas 🌙 | `ServerScriptService` → **Script** |
| `src/server/Catapulta.server.luau` | Catapulta junto a la salida: te lanza por los aires hasta el checkpoint del nivel 5 | `ServerScriptService` → **Script** |
| `src/server/Tienda.server.luau` | Tienda con 3 puestos (botas veloces, súper salto, brillos) que se compran con las monedas | `ServerScriptService` → **Script** |
| `src/server/Guardado.server.luau` | Guarda monedas, victorias, compras, nivel y récord para la próxima vez (⚠️ necesita publicar el mundo, ver abajo) | `ServerScriptService` → **Script** |
| `src/server/Cronometro.server.luau` | Mide el tiempo hasta la meta y pone la columna "Mejor tiempo" en el marcador | `ServerScriptService` → **Script** |
| `src/client/Cronometro.client.luau` | Dibuja el reloj en la pantalla | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
| `src/client/SaltoCheckpoint.client.luau` | El botón "🚀 Saltar a checkpoint" y su ventanita | `StarterPlayer` → `StarterPlayerScripts` → **LocalScript** |
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

- Cada nivel empieza en un **checkpoint** (plataforma blanca con el número). Si te caes o tocas la lava, vuelves al último que alcanzaste.
- **Cada nivel es más difícil, más largo y más alto**: el nivel 1 tiene 3 plataformas y casi no sube; el 500 tiene 20 y sube unos 60 studs.
  Las plataformas son más pequeñas y más separadas, y hay más zigzag y más escalones.
- **Plataformas especiales:** desde el nivel 60, **naranjas que se caen** al pisarlas; desde el 150, **azules que se mueven**.
- **Tramos de obstáculos** (una plataforma larga donde hay que saltar):
  - desde el nivel 10: **cubos** fijos (muros bajos, no hacen daño)
  - desde el 20: **charcos de lava**
  - desde el 30: **rodillos** que ruedan de un lado a otro
  - desde el 80: **cuadrados** que se deslizan
  - desde el 250: **barras de lava que giran** como una hélice
- Llegar a un nivel nuevo da 🪙 monedas. Tu nivel sale en el marcador (columna **Nivel**) y se guarda.
- **Cada 100 niveles** (100, 200, 300…), ¡todos los jugadores ven en pantalla quién ha llegado!
- Al llegar a la meta 🏆 (nivel 500) ganas y vuelves a empezar.
- Al darle a Play, el juego tarda unos segundos en construir los 500 niveles (en **Salida** pondrá `🗼 ¡500 niveles construidos!`).
- ¿Va lento? En `Niveles.server.luau` (tabla `AJUSTES`) puedes bajar `numeroDeNiveles` o subir `farolaCadaNiveles`.

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

## 💾 Para que se guarden las monedas (una sola vez, un adulto)

Roblox solo guarda datos de un mundo que está **publicado**. En Roblox Studio:

1. Menú **Archivo → Publicar en Roblox** (*File → Publish to Roblox*). Ponle nombre y pulsa **Crear**.
2. Pestaña **Inicio → Configuración del juego** (*Game Settings*) → **Seguridad** (*Security*) →
   activa **Habilitar acceso de Studio a servicios de API** (*Enable Studio Access to API Services*) → **Guardar**.
3. Dale a Play. En **Vista → Salida** tiene que poner `💾 Guardado listo.`
   (y, la segunda vez que juegues, `💾 ¡Datos de … cargados!`).

Si no lo haces, el juego funciona igual pero **no guarda nada**, y en Salida verás un aviso amarillo `💾 ⚠️ NO SE GUARDARÁ NADA…`.

## 💡 Ideas para pedirle a Claude

- "Pon un tobogán de hielo en los niveles de la 300 en adelante"
- "Pon plataformas que desaparecen cuando las pisas"
- "Construye un castillo con torres al lado del parkour"
- "Que de noche salgan estrellas fugaces"
- "Pon un trampolín que te lance muy alto"
