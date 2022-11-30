shader_type canvas_item;
//render_mode unshaded;

//void fragment() {
//	// Place fragment code here.
//	vec4 c = textureLod(SCREEN_TEXTURE,SCREEN_UV,0.0).rgba;
//	c.r = 1.0 - c.r;
//	c.b = 1.0 - c.b;
//	c.g = 1.0 - c.g;
//	//c.r = 1.0;
//
//	COLOR.rgba = c;
//
//}


uniform bool hide = false;
uniform vec4 color : source_color = vec4(1);
uniform float strength = 0.2;

void fragment(){
	vec4 pixel = texture(SCREEN_TEXTURE, SCREEN_UV);
        COLOR = pixel;
	if (hide == false){ 
		
		vec3 grayscale_value = vec3(dot(pixel.rgb, vec3(0.299, 0.587, 0.114)));
		float range = 1.0 - step(distance(pixel.rgb, color.rgb), strength);
		COLOR.rgb = mix(pixel.rgb, grayscale_value, range);
	}
	
}