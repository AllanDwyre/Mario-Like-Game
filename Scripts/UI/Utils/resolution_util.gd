
class_name ResolutionUtil extends RefCounted

## Various common window Y values
const COMMON_RESOLUTIONS = [
	240, 360, 480, 720, 900, 1080, 1200,
	1440, 1600, 2160, 2400, 2880, 4320
]
## Aspect ratio strings -> float factor
const COMMON_ASPECT_RATIOS : Dictionary = {
	#"4:3" : 4.0 / 3,
	"16:9" : 16.0 / 9,
	"16:10" : 16.0 / 10,
	"21:9" : 21.0 / 9,
}

## Screen's width and height
static var screen_size : Vector2i :
	get : return DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)
## Screen's aspect ratio
static var aspect_ratio : float :
	get : return float(screen_size.x) / screen_size.y

## Returns a list of possible window resolutions
static func retrieve_possible_resolutions() -> Dictionary[StringName, Vector2i]:
	var resolutions : Dictionary[StringName, Vector2i] = {}
	
	for resolution in COMMON_RESOLUTIONS:
		if screen_size.y >= resolution:
			for key in COMMON_ASPECT_RATIOS.keys():
				var target_ratio := COMMON_ASPECT_RATIOS[key] as float
				
				if aspect_ratio >= target_ratio:
					var calculated_resolution = Vector2i(
						floor(resolution * target_ratio),
						resolution
					)
					
					var res_x := calculated_resolution.x as int
					var res_y := calculated_resolution.y as int
					var resolution_key := "%dx%d (%s)" % [res_x, res_y, key]
					resolutions[StringName(resolution_key)] = Vector2i(res_x, res_y)
				
				else:
					continue
	
	resolutions[&"Fit To Window"] = Vector2.INF
	return resolutions
