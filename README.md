# 🌍 Mis mundos de Roblox

Aquí creamos mundos de Roblox **con código** (en un lenguaje que se llama **Luau**).
Le pides a Claude lo que quieres ("quiero un castillo", "quiero que las monedas den velocidad"…),
Claude escribe el código, y tú lo metes en **Roblox Studio** para jugarlo.

## 📁 Qué hay aquí

| Archivo | Qué hace | Dónde va en Roblox Studio |
|---|---|---|
| `src/server/MiMundo.server.luau` | Construye el mundo: parkour de colores, lava, meta con trofeo, monedas y marcador | `ServerScriptService` → **Script** |
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

## 🚀 Forma pro: Rojo (conexión en directo)

Con **Rojo**, lo que hay en esta carpeta aparece **solo** en Roblox Studio, sin copiar y pegar.
Un adulto lo prepara una vez en el ordenador:

1. Instala **Git** y descarga este proyecto: `git clone https://github.com/ernestobm2012-tech/roblox.git`
2. Instala **Rokit** (https://github.com/rojo-rbx/rokit) y, dentro de la carpeta del proyecto, ejecuta `rokit install` (esto instala Rojo).
3. En Roblox Studio, instala el **plugin de Rojo** (pestaña Plugins → buscar "Rojo" en la tienda de Creator, el de *rojo-rbx*).

Cada vez que quieras trabajar:

1. En la carpeta del proyecto: `git pull` (para bajar lo último que ha hecho Claude).
2. Ejecuta `rojo serve`.
3. En Roblox Studio, abre el plugin de **Rojo** y pulsa **Connect**. ¡Listo! Los scripts aparecen solos.

## 💡 Ideas para pedirle a Claude

- "Haz que la lava se mueva de un lado a otro"
- "Pon plataformas que desaparecen cuando las pisas"
- "Quiero una tienda donde gastar las monedas en velocidad o salto"
- "Construye un castillo con torres al lado del parkour"
- "Añade checkpoints para no volver al principio"
- "Haz que sea de noche y que haya farolas"
- "Pon un trampolín que te lance muy alto"
