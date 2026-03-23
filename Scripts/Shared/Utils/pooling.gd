## Used to create Pooling optimisation for SFX, Rapid instanciation and destroy object (like bullet or particules)
class_name Pooling

var _inactive_pool : Array
var _active_pool : Array

#region Properties
## Get the number of active elements
var count_active : int :
	get: return _active_pool.size()
	
## Get the number of inactive elements
var count_inactive : int :
	get: return _inactive_pool.size()

## Get the number of elements (active and inactive)
var count_all : int :
	get: return count_active + count_inactive
#endregion

## Callable() -> Variant : Crée une nouvelle instance
var _onCreate : Callable
## Callable(instance: Variant) -> void : Appelé quand on prend une instance
var _onTake : Callable
## Callable(instance: Variant) -> void : Appelé quand on retourne une instance
var _onReturn : Callable
## Callable(instance: Variant) -> void : Appelé quand on détruit une instance
var _onDestroy : Callable

## The number by default of element (even if we haven't get one)
var default_capacity : int

## The number of elements before we start deleting
var max_items : int


func _init(onCreate : Callable, onTake: Callable, onReturn: Callable, onDestroy: Callable, capacity:int, max_elements: int):
	_onCreate = onCreate
	_onTake = onTake
	_onReturn = onReturn
	_onDestroy = onDestroy
	default_capacity = capacity
	max_items = max_elements
	
	_inactive_pool = []
	_active_pool = []
	
	for i in range(capacity):
		_inactive_pool.append(_onCreate.call())

## return one element by getting or creating the element
func take():
	var instance = _onCreate.call() if _inactive_pool.is_empty() else _inactive_pool.pop_back()
	_active_pool.append(instance)
	_onTake.call(instance)
	return instance

## release an active element
func release(element):
	var index = _active_pool.find(element)
	if index == -1:
		push_warning("Tentative de release d'un élément qui n'est pas actif")
		return
		
	_active_pool.remove_at(index)
	
	if count_inactive >= max_items:
		_onDestroy.call(element)
	else:
		_onReturn.call(element)
		_inactive_pool.append(element)
