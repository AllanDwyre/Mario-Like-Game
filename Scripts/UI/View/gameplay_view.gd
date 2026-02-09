extends View

@onready var coins_label : Label = $Control/MarginContainer/Coins/CoinsText
@onready var time_label : Label = $Control/MarginContainer/Time/TimeLeft

func _ready():
	set_coins(0)
	set_time_left(0)

func show_view():
	super()

func set_time_left(timeleft : int):
	time_label.text = str(timeleft)

func set_coins(coins : int):
	coins_label.text = "x" + str(coins)
