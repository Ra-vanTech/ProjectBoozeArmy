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

**Dónde van los archivos.** `assets/` está dividido en `models/`, `textures/`,
`materials/`, `audio/sfx`, `audio/music` y `fonts/`. Los formatos binarios
(`.png`, `.glb`, `.blend`, `.ogg`, `.ttf`…) van por Git LFS, ya configurado en
`.gitattributes`.

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
son informativos: Godot los ignora, y varios corresponden a scripts que viven en
ramas todavía sin mergear.
