shader_type sky;

uniform sampler2D testure;
uniform float tiling = 2.0;

void sky() {
	vec2 uv = vec2(SCREEN_UV.s * tiling + TIME * 0.05, SCREEN_UV.t * tiling * .5);
	COLOR = texture(testure, uv).rgb;
}
