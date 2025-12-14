shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec3 output = texture(screen_texture, SCREEN_UV).xyz;
	
	output *= 6.0;
	output.x /= 6.0;
	output.y /= 6.0;
	output.z /= 5.0;
	COLOR.xyz = output;
}
