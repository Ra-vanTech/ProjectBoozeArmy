extends Node

## Bus de eventos de ciclo de partida (autoload "Events").
##
## Sirve para avisos globales donde el emisor no tiene —ni debe tener— una
## referencia al receptor. El caso que lo motivó: los estados del jugador
## buscaban las pantallas por grupo y les tocaban el `visible` a mano, así que
## una máquina de estados de gameplay manipulaba nodos de UI directamente.
##
## NO es un cajón para todas las señales del juego. Cuando alguien ya tiene una
## referencia natural al emisor —la UI que lee su gestor, un componente que
## avisa a su dueño— la señal se queda donde está: moverla aquí solo añadiría
## un salto indirecto y haría más difícil seguir el flujo. Por eso XPManager,
## UpgradeManager y compañía conservan las suyas.
##
## Regla práctica para lo que venga: si al emitir tienes que buscar a quién
## avisar, el evento va aquí; si ya lo tienes delante, no.

## El ejército ha caído y la partida termina. La pantalla de muerte lo escucha.
signal jugador_muerto

## Entrada y salida de pausa. Lo emite el estado del jugador; lo escucha la
## pantalla de pausa (y cualquier sistema que necesite enterarse en el futuro).
signal pausa_cambiada(en_pausa: bool)

## El jugador ha pulsado "continuar" en la pantalla de pausa. Antes era una
## señal de la propia pantalla, cableada a mano en la escena principal.
signal reanudacion_solicitada
