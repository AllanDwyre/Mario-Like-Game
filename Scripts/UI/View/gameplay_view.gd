extends View
class_name GameplayView

@onready var coins_label : Label = $Control/MarginContainer/Coins/CoinsText
@onready var time_label : Label = $Control/MarginContainer/Time/TimeLeft

var level : Level

func setup(level_ : Level):
	level = level_

func _ready():
	set_coins(0)
	set_time_left(0)

func show_view():
	super()

func set_time_left(timeleft : float):
	time_label.text = str(int(timeleft))

func set_coins(coins : int):
	coins_label.text = "x" + str(coins)
