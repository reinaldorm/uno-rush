shader_type canvas_item;

uniform float speed = 2.0;
uniform sampler2D noise_tex;
uniform bool disabled;

void fragment() {
    vec2 uv = UV;
    
    float noise = texture(noise_tex, uv + vec2(TIME * speed, 0.0)).r;
    
    vec4 base = texture(TEXTURE, uv);
    
    vec3 foil = vec3(0.5 + 0.5 * sin(TIME * speed + uv.x * 10.0));
    
	if (!disabled) {
	    base.rgb += foil * noise * 0.4;
	};
	
    COLOR = base;
}