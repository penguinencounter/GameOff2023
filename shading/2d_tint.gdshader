shader_type canvas_item;

uniform vec4 tint_color: source_color;
uniform bool enabled;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (enabled) {
		COLOR.r = (COLOR.r + tint_color.r) / 2.0;
		COLOR.g = (COLOR.g + tint_color.g) / 2.0;
		COLOR.b = (COLOR.b + tint_color.b) / 2.0;
		COLOR.a *= tint_color.a;
	}
}
