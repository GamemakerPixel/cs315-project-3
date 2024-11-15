shader_type spatial;

uniform sampler2D color_gradient;
uniform float roughness: hint_range(0.0, 1.0) = 1.0;

uniform int color_octaves = 1;
uniform int normal_octaves = 1;
uniform float normal_depth: hint_range(0.0, 1.0) = 0.5;
uniform float lacunarity = 1;
uniform float base_uv_scale = 4;
uniform float persistance = 1;

varying vec3 world_position;

void vertex() {
	world_position = (NODE_POSITION_WORLD + VERTEX);
}

// Noise generation from https://godotshaders.com/snippet/2d-noise/
vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}

// I've added this to allow more complex use of noise in the shader.
float layered_noise(vec2 uv, int octaves) {
	float result = 0.0;
	float max_value = 0.0;
	for (int octave_index = 0; octave_index < octaves; octave_index++) {
		float uv_scale = pow(lacunarity, float(octave_index));
		float value_scale = pow(persistance, float(octave_index));
		max_value += value_scale;
		result += noise(uv * uv_scale) * value_scale;
	}
	
	return result / max_value;
}


vec3 calculate_normal(vec2 uv) {
	float center_depth = layered_noise(uv, normal_octaves);
	float nearby_depths[4];
	
	nearby_depths[0] = layered_noise(uv + vec2(1.0, 0.0), normal_octaves);
	nearby_depths[1] = layered_noise(uv + vec2(-1.0, 0.0), normal_octaves);
	nearby_depths[2] = layered_noise(uv + vec2(0.0, 1.0), normal_octaves);
	nearby_depths[3] = layered_noise(uv + vec2(0.0, -1.0), normal_octaves);
	
	float nearby_differences[4];
	
	for (int index = 0; index < nearby_differences.length(); index++) {
		nearby_differences[index] = center_depth - nearby_depths[index];
	}
	
	// <1, 0> = angled right
	// <-1, 0> = angled left
	// <0, 1> = angled up
	// <1, 0> = angled down
	vec2 average_differences = vec2(
		(nearby_differences[0] + nearby_differences[1]) / 2.0,
		(nearby_differences[2] + nearby_differences[3]) / 2.0
	);
	
	vec2 normalized_differences = (average_differences + 1.0) / 2.0;
	
	return vec3(normalized_differences, 1.0);
}


void fragment() {
	vec2 world_uv = world_position.xz * base_uv_scale;
	
	float noise_value = layered_noise(world_uv, color_octaves);
	ALBEDO = texture(color_gradient, vec2(noise_value, 0.0)).rgb;
	ROUGHNESS = roughness;
	NORMAL_MAP = calculate_normal(world_uv);
	NORMAL_MAP_DEPTH = normal_depth;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
