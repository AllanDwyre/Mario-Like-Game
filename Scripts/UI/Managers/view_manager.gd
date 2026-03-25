extends Node
# Autoload : ViewManager

const DEFAULT_CONTEXT = &"main"
var contexts: Dictionary[StringName, ViewContext] = {}  # "player_1" -> ViewContext, etc.

func _ready() -> void:
	var default_ctx = ViewContext.new()
	add_child(default_ctx)
	register_context(DEFAULT_CONTEXT, default_ctx)

#region Handle Contexts
func register_context(id: StringName, ctx: ViewContext) -> void:
	if not ctx.get_parent():
		push_warning("ViewContext '%s' has no parent, adding to ViewManager by default" % id)
		add_child(ctx)
	contexts[id] = ctx
	ctx.name = id

func unregister_context_by_value(ctx: ViewContext) -> void:
	for id in contexts:
		if contexts[id] == ctx:
			contexts.erase(id)
			return

func get_context(id: StringName) -> ViewContext:
	return contexts.get(id)
#endregion

#region Direct context access
## Clear & Insert, permet d'inseret une view deja existante dans le tree 
## Comme lorsque le jeu commence avec le main_menu
func insert(v: View) -> void:
	get_context(DEFAULT_CONTEXT).insert_view(v)
	
func push(v: View, contextName : StringName = DEFAULT_CONTEXT, hide: bool = true) -> void:
	if contextName == DEFAULT_CONTEXT and hide:
		_hide_alternative_contexts()
	get_context(contextName).push(v, hide)

func pop(contextName : StringName = DEFAULT_CONTEXT) -> void:
	var ctx = get_context(contextName)
	ctx.pop()
	if contextName == DEFAULT_CONTEXT and not ctx.active_view:
		_show_alternative_contexts()

func clear_history(contextName : StringName = DEFAULT_CONTEXT) -> void:
	get_context(contextName).clear_history()
#endregion
	
func clear_all_history() -> void:
	for ctx in contexts.values():
		ctx.clear_history()
	
func _hide_alternative_contexts() -> void:
	for id in contexts:
		if id == DEFAULT_CONTEXT:
			continue
		if contexts[id].active_view:
			contexts[id].active_view.hide_view()
func _show_alternative_contexts() -> void:
	for id in contexts:
		if id == DEFAULT_CONTEXT:
			continue
		if contexts[id].active_view:
			contexts[id].active_view.show_view()

func debug_print():
	for ctx_id in contexts.keys():
		print("==========%s==========" % ctx_id)
		var history = contexts[ctx_id].history
		for i in history.size():
			print("\t%d - %s" % [i, history[i].name])
