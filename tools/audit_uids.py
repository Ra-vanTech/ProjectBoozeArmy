#!/usr/bin/env python3
"""Auditoría de UIDs de Godot 4.

Recorre el proyecto, recolecta todos los `uid://` *declarados* por algún archivo
(.uid, cabecera de .tscn/.tres, bloque [remap] de .import) y los compara con
todos los `uid://` *referenciados* desde project.godot, .tscn, .tres, .import y
.gd. Reporta cualquier referencia que no resuelva a ningún archivo del proyecto,
además de .uid huérfanos y duplicados.

Uso:  python3 tools/audit_uids.py [ruta_proyecto]
Salida: 0 si no hay referencias rotas, 1 si las hay.
"""

from __future__ import annotations

import os
import re
import sys
from collections import defaultdict

UID_RE = re.compile(r"uid://[a-z0-9]+")
HEADER_UID_RE = re.compile(r'\buid\s*=\s*"(uid://[a-z0-9]+)"')
# Líneas tipo [ext_resource ... uid="uid://x" path="res://y"] llevan ambos datos.
PATH_RE = re.compile(r'\bpath\s*=\s*"(res://[^"]+)"')

SKIP_DIRS = {".godot", ".git", "export", "build", "dist", "android", ".venv"}
SCAN_EXTS = {".tscn", ".tres", ".import", ".gd", ".gdshader", ".godot"}


def iter_files(root: str):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            yield os.path.join(dirpath, name)


def read(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        return fh.read()


def collect(root: str):
    """Devuelve (declarados, referencias, huerfanos).

    declarados: uid -> lista de rutas relativas que lo declaran
    referencias: uid -> lista de (ruta relativa, nº de línea)
    huerfanos: rutas de .uid cuyo archivo dueño no existe
    """
    declared: dict[str, list[str]] = defaultdict(list)
    refs: dict[str, list[tuple[str, int, str | None]]] = defaultdict(list)
    orphans: list[str] = []
    # ruta res:// -> uid que ese archivo declara (vía .uid, cabecera o .import)
    uid_of_path: dict[str, str] = {}

    for path in iter_files(root):
        rel = os.path.relpath(path, root)
        ext = os.path.splitext(path)[1]

        if ext == ".uid":
            owner = path[: -len(".uid")]
            uid = read(path).strip()
            if uid:
                declared[uid].append(rel)
                uid_of_path["res://" + os.path.relpath(owner, root)] = uid
            if not os.path.exists(owner):
                orphans.append(rel)
            continue

        if ext not in SCAN_EXTS and os.path.basename(path) != "project.godot":
            continue

        text = read(path)

        # Declaración propia: cabecera de escena/recurso o bloque [remap].
        for line in text.splitlines()[:20]:
            stripped = line.strip()
            is_header = stripped.startswith("[gd_scene") or stripped.startswith("[gd_resource")
            is_remap_uid = stripped.startswith("uid=") and ext == ".import"
            if is_header or is_remap_uid:
                m = HEADER_UID_RE.search(line)
                if m:
                    declared[m.group(1)].append(rel)
                    # El .import declara el uid del recurso importado, que las
                    # escenas referencian por la ruta del archivo fuente.
                    owner_rel = rel[: -len(".import")] if ext == ".import" else rel
                    uid_of_path["res://" + owner_rel] = m.group(1)

        for lineno, line in enumerate(text.splitlines(), 1):
            path_m = PATH_RE.search(line)
            for uid in UID_RE.findall(line):
                refs[uid].append((rel, lineno, path_m.group(1) if path_m else None))

    return declared, refs, orphans, uid_of_path


def main() -> int:
    root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
    declared, refs, orphans, uid_of_path = collect(root)

    # Las líneas que declaran el uid también lo "referencian"; no son fallos.
    broken = {uid: locs for uid, locs in refs.items() if uid not in declared}
    duplicates = {uid: owners for uid, owners in declared.items() if len(owners) > 1}

    print(f"Proyecto: {root}")
    print(f"UIDs declarados: {len(declared)}   UIDs referenciados: {len(refs)}")
    print()

    if duplicates:
        print(f"UIDs DUPLICADOS ({len(duplicates)}):")
        for uid, owners in sorted(duplicates.items()):
            print(f"  {uid}")
            for owner in owners:
                print(f"      declarado por {owner}")
        print()

    if orphans:
        print(f".uid HUERFANOS — sin archivo dueño ({len(orphans)}):")
        for rel in sorted(orphans):
            print(f"  {rel}")
        print()

    # Clasificar: si la referencia lleva path= y el archivo existe, el uid
    # simplemente ha derivado (se regeneró distinto). Si no, falta el archivo.
    drift: dict[str, tuple[str, str]] = {}   # uid referenciado -> (path, uid real)
    missing: dict[str, list[tuple[str, int, str | None]]] = {}

    for uid, locs in broken.items():
        paths = {p for _, _, p in locs if p}
        resolved = {p: uid_of_path[p] for p in paths if p in uid_of_path}
        if len(resolved) == 1:
            path, real = next(iter(resolved.items()))
            drift[uid] = (path, real)
        else:
            missing[uid] = locs

    if drift:
        print(f"UIDs DERIVADOS — el archivo existe pero declara otro uid ({len(drift)}):")
        for uid, (path, real) in sorted(drift.items()):
            print(f"  {uid}  ->  {path}")
            print(f"      el archivo declara actualmente {real}")
        print()

    if missing:
        print(f"REFERENCIAS ROTAS — no resuelven a ningún archivo ({len(missing)}):")
        for uid, locs in sorted(missing.items()):
            print(f"  {uid}")
            for rel, lineno, path in locs:
                extra = f'  path="{path}"' + ("" if not path or os.path.exists(
                    os.path.join(root, path[len("res://"):])) else "  [ARCHIVO NO EXISTE]")
                print(f"      referenciado en {rel}:{lineno}{extra}")
        print()

    if not drift and not missing:
        print("REFERENCIAS ROTAS: 0 — todos los uid:// resuelven.")

    return 1 if broken else 0


if __name__ == "__main__":
    sys.exit(main())
