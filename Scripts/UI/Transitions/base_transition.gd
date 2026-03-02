@abstract
## Peut être une scene pour un meilleur control, ou tout sinon on peut tout instancier ici.
## Ce qui est sur, c'est que l'on peut paramètrer la transition
class_name BaseTransition
extends Node

@warning_ignore("unused_signal")
## Lorsqu'une transition est finit, peut importe la quelle. Cela permet à scene manager
## de ne pas a faire des pool de l'état chaque frame
signal finished

@abstract
## La transition qui cache ce qu'il y a à l'écran (on sort de la scene actuelle)
func play_out() -> void

@abstract
## La transition qui révèle la nouvelle scène
func play_in() -> void
