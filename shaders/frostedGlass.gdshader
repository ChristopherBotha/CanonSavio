shader_type spatial;

uniform float distortion_size = 0.4;
uniform sampler2D glass;

void fragment() {
	vec2 d = texture(glass, UV).xy - vec2(0.5);
	ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV + d * distortion_size).rgb;
}