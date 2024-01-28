shader_type canvas_item;

uniform vec4 color : source_color  = vec4(1.0);
uniform float radius : hint_range(0.0, 1.0) = 0.1; // Change this to adjust the size of the circles
uniform vec2 center = vec2(0.5,0.5); // Change this to adjust the position of the circles
uniform vec2 grid_size = vec2(10.0, 10.0); // Change this to adjust the number of circles
uniform vec2 offset = vec2(0.0, 0.0); // Change this to adjust the offset of the pattern

void fragment() {
    // Calculate the UV coordinates for the grid
    vec2 grid_uv = mod(UV * grid_size + offset, 1.0);

    // Calculate the distance from the center of the circle
    float dist = distance(grid_uv, center);

    // Create a circle pattern
    float pattern = smoothstep(radius, radius + 0.01, dist);

    // Get the original color from the texture
    vec4 original_color = texture(TEXTURE, UV);

    // At the pattern position, replace the color with the original color
    COLOR.r = original_color.r -  pattern*0.3;
    COLOR.g = original_color.g -  pattern*0.3;
    COLOR.b = original_color.b -  pattern*0.3;
}