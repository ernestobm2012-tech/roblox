# 🌍 Mis mundos de Roblox

Aquí creamos mundos de Roblox **con código** (en un lenguaje que se llama **Luau**).
Le pides a Claude lo que quieres ("quiero un castillo", "quiero que las monedas den velocidad"…),
Claude escribe el código, y tú lo metes en **Roblox Studio** para jugarlo.

## 📁 Qué hay aquí

| Archivo | Qué hace | Dónde va en Roblox Studio |
|---|---|---|
| `src/server/MiMundo.server.luau` | Construye el mundo: parkour de colores, lava, meta con trofeo, monedas y marcador | `ServerScriptService` → **Script** |
| `src/server/Catapulta.server.luau` | Catapulta junto a la salida: te lanza por los aires hasta la meta | `ServerScriptService` → **Script** |
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

## 💡 Ideas para pedirle a Claude

- "Haz que la lava se mueva de un lado a otro"
- "Pon plataformas que desaparecen cuando las pisas"
- "Quiero una tienda donde gastar las monedas en velocidad o salto"
- "Construye un castillo con torres al lado del parkour"
- "Añade checkpoints para no volver al principio"
- "Haz que sea de noche y que haya farolas"
- "Pon un trampolín que te lance muy alto"
