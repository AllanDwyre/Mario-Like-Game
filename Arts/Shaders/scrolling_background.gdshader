shader_type canvas_item;

// Uniforms for the user to play with in the Inspector
uniform float time_speed : hint_range(0.01, 5.0) = 1.0;
uniform float darker : hint_range(0.01, 1.0) = 0.15;
uniform float checker_opacity : hint_range(0.01, 1.0) = 0.1;
uniform int squares : hint_range(2, 50) = 8;

float checker(vec2 uv){
 	uv = uv * float(squares);
	vec2 cell = floor(uv);
	float checker = mod(cell.x + cell.y, 2.0);
	return checker;
}
	

void fragment(){
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	
	vec2 uv = UV;
	uv.x *= aspect;
	float t = TIME * time_speed;
	vec3 col = 0.5 + 0.5 * cos(t + uv.xyx + vec3(0.0, 2.0, 4.0));
	
	float checker = checker(vec2(uv.r + t, uv.g - t));
	vec3 color = mix(col,col * (1. - checker_opacity), checker);
	color = mix(color, vec3(.0), darker);
	COLOR = vec4(vec3(color), 1.0);
}
//void fragment() {
	//float gradient = UV.x;
	//vec2 st = UV;
	//int grid_cells = int(UV.x * scale);
	//bool is_left_side = UV.x < 0.5;
	//vec3 animated_rgb = vec3(
		//0.5 + 0.5 * cos(TIME * time_speed + float(grid_cells) + vec3(0, 2, 4))
	//);
	//vec4 final_pixel = vec4(animated_rgb, 1.0) * custom_color;
	//if (brighten) {
		//final_pixel.rgb += 0.5;
	//}
	//
	//COLOR = final_pixel;
//}