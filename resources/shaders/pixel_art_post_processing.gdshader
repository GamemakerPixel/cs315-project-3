// Shader by Crigz Vs Game Dev (https://www.youtube.com/watch?v=WBoApONC7bM&t=24s)
// with some modifications.
shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture, filter_nearest;
uniform sampler2D depth_texture : source_color, hint_depth_texture, filter_nearest;
uniform sampler2D normal_texture : source_color, hint_normal_roughness_texture, filter_nearest;

uniform float depth_outline_threshold : hint_range(0.0, 1.0) = 0.05;
uniform float normal_outline_threshold : hint_range(0.0, 1.0) = 0.6;
uniform float depth_outline_value_scale : hint_range(0.0, 1.0) = 0.5;
uniform float normal_outline_value_scale: hint_range(1.0, 2.0) = 1.5;
uniform vec3 normal_edge_bias = vec3(1, 1, 1);

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float get_linearized_depth(vec2 screen_uv, mat4 inv_projection_matrix) {
	float depth = texture(depth_texture, screen_uv).r;
	vec3 normalized_device_coords = vec3(screen_uv * 2.0 - 1.0, depth);
	vec4 view = inv_projection_matrix * vec4(normalized_device_coords, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;

	return linear_depth;
}

vec3 get_normal(vec2 screen_uv) {
	return texture(normal_texture, screen_uv).rgb * 2.0 - 1.0;
}

void fragment() {
	vec3 result = texture(screen_texture, SCREEN_UV).rgb;

	// INV_PROJECTION_MATRIX is broken for orthographic cameras.
	mat4 inverse_projection_matrix = inverse(PROJECTION_MATRIX);
	float depth = get_linearized_depth(SCREEN_UV, inverse_projection_matrix);
	vec3 normal = get_normal(SCREEN_UV);
	vec2 texel_size = 1.0 / VIEWPORT_SIZE.xy;

	vec2 uvs[4];
	uvs[0] = vec2(SCREEN_UV.x, SCREEN_UV.y + texel_size.y);
	uvs[1] = vec2(SCREEN_UV.x, SCREEN_UV.y - texel_size.y);
	uvs[2] = vec2(SCREEN_UV.x + texel_size.x, SCREEN_UV.y);
	uvs[3] = vec2(SCREEN_UV.x - texel_size.x, SCREEN_UV.y);

	float total_depth_difference = 0.0;
	float nearest_depth = depth;
	vec2 nearest_uv = SCREEN_UV;

	float total_normal_sum = 0.0;
	for (int index = 0; index < uvs.length(); index++) {
		float shifted_depth = get_linearized_depth(uvs[index], inverse_projection_matrix);
		total_depth_difference += depth - shifted_depth;

		if (shifted_depth < nearest_depth) {
			nearest_depth = shifted_depth;
			nearest_uv = uvs[index];
		}

		vec3 shifted_normal = get_normal(uvs[index]);
		vec3 normal_difference = normal - shifted_normal;
		float normal_bias_difference = dot(normal_difference, normal_edge_bias);
		float normal_indicator = smoothstep(-0.01, 0.01, normal_bias_difference);

		total_normal_sum += dot(normal_difference, normal_difference) * normal_indicator;
	}

	float depth_outline = step(depth_outline_threshold, total_depth_difference);
	float normal_outline = step(normal_outline_threshold, sqrt(total_normal_sum));

	vec3 nearest_color = texture(screen_texture, nearest_uv).rgb;
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;

	if (depth_outline > 0.0) {
		result = mix(result, nearest_color * depth_outline_value_scale, depth_outline);
	}
	else {
		result = mix(result, color * normal_outline_value_scale, normal_outline);
	}

	ALBEDO = result;
	//ALBEDO = vec3(normal_outline);
	//ALBEDO = get_normal(SCREEN_UV);
	//ALBEDO = vec3(depth_outline);
	//ALBEDO = vec3(total_depth_difference, total_depth_difference * 100.0, total_depth_difference * 10000.0);
	//ALBEDO.rgb = vec3(get_linearized_depth(SCREEN_UV, inverse_projection_matrix) / 50.0);
}