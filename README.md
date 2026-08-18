# ProjectBoozeArmy

Proyecto de Godot 4.

## ⚠️ Acción requerida una sola vez: reconstruir la caché de UIDs

Hasta ahora el `.gitignore` incluía `*.uid` y `*.import`. Desde Godot 4.4 los
archivos `.gd.uid` forman parte del proyecto: `project.godot`, los `.tscn` y los
`.tres` referencian recursos por `uid://`. Al ignorarlos, cada máquina generaba
UIDs distintos al abrir el editor y esas referencias dejaban de resolver — de ahí
los autoloads que aparecían con la ruta vacía y los scripts desasignados.

Ya se corrigió: los `.uid`/`.import` están versionados y sus UIDs realineados con
lo que referencian las escenas.

**Tras hacer pull de este cambio, cada dev debe hacer esto una vez:**

```bash
rm -rf .godot && godot --headless --import
```

Luego abre el proyecto en el editor con normalidad. Esto descarta la caché local
de UIDs (que aún guarda los identificadores viejos de tu máquina) y la reconstruye
desde los `.uid` versionados. Si te saltas este paso seguirás viendo referencias
rotas aunque tu working tree esté al día.

No vuelvas a añadir `*.uid` ni `*.import` al `.gitignore`, y no "arregles" un
autoload reasignando el script a mano: eso genera un UID nuevo y rompe el
proyecto para el resto del equipo.

## Conflictos en archivos `.uid`

Todas las ramas del equipo están integradas en `main` (ver el tag
`convergencia-equipo`), pero si recuperas una rama vieja verás conflictos en los
`.uid`, porque se crearon cuando todavía estaban ignorados y cada máquina generó
los suyos.

**La regla: gana siempre el `.uid` versionado en `main`.** Es tentador enunciarla
como "gana lo que referencian los `.tscn`", pero eso falla justo cuando hace
falta: al integrar `feat/summoner` y `feat/Boos-esqueleto` aparecieron scripts
con **dos UIDs distintos en circulación a la vez** — `slime`/`skeleton`/`bat`
usaban uno y `summoner`/`boss_skeleton` otro. Cuando las escenas se contradicen
entre sí no hay nada que "ganar"; el `.uid` versionado es la referencia.

```bash
git merge main
# resolver TODOS los conflictos de .uid con la versión de main:
git checkout --theirs -- '*.uid'   # 'theirs' = main durante un merge
git add -- '*.uid'
git commit
```

Después, obligatorio una vez:

```bash
rm -rf .godot && godot --headless --import
python3 tools/audit_uids.py   # debe reportar 0 referencias rotas
```

Los `.uid` de scripts que tu rama **añade** y no existen en `main` no dan
conflicto y se commitean tal cual: son legítimos.

## Meter assets (sustituir los placeholders)

Todo lo que se ve ahora son primitivas de Godot (cápsulas, cilindros, cajas)
puestas a mano. Para que cambiarlas por arte real no rompa nada:

**Una carpeta por entidad.** Cada cosa del juego tiene su carpeta con todo lo
suyo dentro — escena, script y, cuando llegue, su modelo:

```
entities/enemies/bat/          bat.tscn, bat.gd…      → aquí va bat.glb
entities/player/dwarves/enano_guerrero/
entities/weapons/projectile/
```

Antes esto estaba repartido entre subcarpetas `scenes/` y `scripts/` en unos
sitios y plano en otros, así que meter el arte de un enemigo obligaba a tocar
tres directorios. Al añadir contenido nuevo, sigue el patrón: carpeta propia,
nombre igual al de la entidad.

**Dónde va cada cosa.** Los assets compartidos entre entidades (texturas de
terreno, fuentes, música, materiales comunes) van a `assets/`, dividido en
`models/`, `textures/`, `materials/`, `audio/sfx`, `audio/music` y `fonts/`. Lo
que pertenece a una sola entidad va en su carpeta. Las estadísticas viven
aparte, en `assets/stats/enemies/`, a propósito: así se compara el balance de
todos los tipos de un vistazo sin abrir cinco escenas.

Los formatos binarios (`.png`, `.glb`, `.blend`, `.ogg`, `.ttf`…) van por Git
LFS, ya configurado en `.gitattributes`.

**Un enemigo nuevo no necesita código.** Duplica la carpeta de uno existente,
crea su `.tres` en `assets/stats/enemies/` y asígnalo al campo *Stats* de la
raíz de la escena. Vida, oro, XP, velocidad y si puede aparecer por el spawner
salen de ahí.

**Los `.import` NO van a LFS.** Son texto de ~1 KB y contienen el `uid://` del
recurso; si acaban en LFS, quien clone sin LFS configurado recibe un puntero en
lugar del UID y vuelve a romperse el proyecto igual que antes del fix de UIDs.
Tampoco deben ir al `.gitignore`. Se commitean junto al asset, siempre.

**Marca la malla como `%Visual`.** El flash de golpe y la embestida de los enanos
necesitan encontrar la malla de la entidad. Hoy funciona porque los placeholders
tienen un hijo llamado `MeshInstance3D`, pero un modelo importado la deja anidada
y con otro nombre, y la búsqueda fallaría **en silencio** (sin error: el efecto
simplemente desaparece). Al sustituir un placeholder, marca la `MeshInstance3D`
del modelo como nombre único `Visual` (botón derecho → *Access as Unique Name*).

`core/bases/visual_ref.gd` resuelve en cascada — `%Visual`, luego un hijo
`MeshInstance3D`, luego la primera malla en profundidad — así que el proyecto
funciona durante toda la transición, con placeholders y con modelos mezclados.
Marcar `%Visual` es lo que garantiza que se elija la malla correcta y no la
primera que aparezca.

**El modelo que rota es un `@export`.** `MovementComponent.MODEL` se asigna desde
el inspector, no por nombre: al cambiar el placeholder hay que reasignarlo.

**Importación.** Las texturas nuevas entran comprimidas para VRAM y con mipmaps
por defecto (`[importer_defaults]` en `project.godot`), que es lo que quiere el
renderer móvil. No hace falta tocarlo asset por asset.

## Auditoría de UIDs

`tools/audit_uids.py` recorre el proyecto, recolecta todos los `uid://` declarados
(`.uid`, cabeceras de `.tscn`/`.tres`, bloques `[remap]` de `.import`) y reporta
cualquier referencia que no resuelva a un archivo real:

```bash
python3 tools/audit_uids.py
```

Devuelve código de salida 1 si hay referencias rotas, así que sirve tal cual en un
hook de pre-commit o en CI. También lista `.uid` huérfanos (sin archivo dueño), que
son informativos: Godot los ignora.

## Verificar que todas las escenas cargan

```bash
godot --headless --script tools/verificar_escenas.gd
```

Carga todos los `.tscn` y `.tres` del proyecto y falla si alguno no abre.
Cubre el punto ciego de `audit_uids.py`: ese solo comprueba los `uid://`, y una
ruta `res://` que apunta a un archivo movido no la detecta. Pásalo siempre
después de mover o renombrar archivos.

Los dos juntos son la red mínima antes de subir cambios estructurales:

```bash
python3 tools/audit_uids.py && godot --headless --script tools/verificar_escenas.gd
```
