class_name VisualRef

## Localiza la malla visible de una entidad (para el flash de golpe, la
## embestida, etc.) sin depender de que se llame "MeshInstance3D".
##
## Hoy las entidades son primitivas puestas a mano y ese nombre coincide, pero
## al sustituirlas por modelos importados (.glb/.blend) la malla queda anidada
## y con otro nombre. Buscarla por nombre literal fallaría en silencio —
## get_node_or_null devuelve null y el efecto desaparece sin ningún error—, así
## que la resolución va en cascada:
##
##   1. El nodo marcado como %Visual (nombre único en la escena). Es la
##      convención a usar al meter arte: basta con marcar así la malla del
##      modelo importado y nada más hay que tocar.
##   2. Un hijo directo llamado "MeshInstance3D" (los placeholders actuales).
##   3. La primera MeshInstance3D en profundidad (modelos importados sin marcar).
##
## El resultado se cachea en el propio nodo, porque esto se llama en cada golpe.

const META_CACHE: String = "_visual_ref"


static func obtener(raiz: Node) -> MeshInstance3D:
	if raiz == null:
		return null
	if raiz.has_meta(META_CACHE):
		var cacheado: Variant = raiz.get_meta(META_CACHE)
		if is_instance_valid(cacheado):
			return cacheado
	var mesh: MeshInstance3D = _buscar(raiz)
	if mesh != null:
		raiz.set_meta(META_CACHE, mesh)
	return mesh


static func _buscar(raiz: Node) -> MeshInstance3D:
	var marcado := raiz.get_node_or_null("%Visual")
	if marcado is MeshInstance3D:
		return marcado

	var directo := raiz.get_node_or_null("MeshInstance3D")
	if directo is MeshInstance3D:
		return directo

	return _primera_en_profundidad(raiz)


static func _primera_en_profundidad(nodo: Node) -> MeshInstance3D:
	for hijo in nodo.get_children():
		if hijo is MeshInstance3D:
			return hijo
		var anidada: MeshInstance3D = _primera_en_profundidad(hijo)
		if anidada != null:
			return anidada
	return null
