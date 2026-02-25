// Hey this is Hei! This shader "fakes" a 3D-camera perspective on CanvasItems.
// License: MIT
 
shader_type canvas_item;

uniform sampler2D noise_texture;

void fragment(){
	float w = sin(TIME) * 0.5 + 0.5;
	
	vec4 noise_tex = texture(noise_texture, UV);
	
	COLOR.rgb = vec3(dot(COLOR.rgb, noise_tex.rgb * 0.5));
}