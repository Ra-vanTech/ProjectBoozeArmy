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

## Si trabajas en una rama sin mergear (léelo antes de mergear)

Las ramas activas (`experimental`, `developer`, `feat/persistence`,
`feat/Boos-esqueleto`, …) se crearon cuando los `.uid` todavía estaban ignorados.
Cada una arrastra los UIDs que **tu** máquina generó en su momento, así que al
traer este fix vas a ver conflictos en archivos `.uid`.

**La regla es simple: en cualquier conflicto sobre un `.uid`, se toma siempre la
versión de `main`.** Los UIDs de `main` son los que coinciden con lo que ya
referencian los `.tscn` commiteados; los de tu rama son regeneraciones locales.
Quedarte con "los tuyos" reintroduce el bug para todo el equipo.

```bash
git checkout tu-rama
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

Si tu rama **añade** scripts nuevos que no existen en `main`, sus `.uid` no dan
conflicto y se commitean tal cual: son legítimos. Ojo con un caso concreto:
`core/persistence/persistence_manager.gd` vive en `origin/feat/persistence` pero su
`.uid` ya está versionado en `main` (`uid://c83jokc7wbbyn`). Al mergear, conserva
ese UID — no dejes que Godot lo regenere, o el autoload `Store` volverá a aparecer
con la ruta vacía, que es exactamente el problema que estamos cerrando.

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
