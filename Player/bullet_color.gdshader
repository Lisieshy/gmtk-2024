shader_type canvas_item;

uniform vec4 energy_color : source_color;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float luminance = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 result_color = mix(vec3(1.0), energy_color.rgb, luminance);

    // Set the final color
    COLOR = vec4(result_color, tex_color.a);
}