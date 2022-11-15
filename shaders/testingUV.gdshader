shader_type canvas_item;

uniform sampler2D distortionTexture;

void fragment() {
	// Place fragment code here.
	vec2 distortedUV = SCREEN_UV + texture(TEXTURE,UV).r * 0.05;
	vec4 screenColor = texture(SCREEN_TEXTURE,SCREEN_UV);
	COLOR = screenColor;
}
