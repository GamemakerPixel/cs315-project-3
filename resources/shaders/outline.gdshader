shader_type spatial;

uniform vec3 base_color: source_color = vec3(0.0);
uniform vec3 stripe_color: source_color = vec3(1.0);
uniform float time_frequency = 1.0;
uniform float space_frequency = 1.0;
uniform float duty_cycle: hint_range(0.0, 1.0) = 0.5;

varying vec3 current_vertex;

void vertex() {
	current_vertex = VERTEX;
}


void fragment() {
	ALBEDO = base_color;
	float duty_cycle_offset = cos(PI * duty_cycle);
	bool stripe = step(
		sin(TAU
		* (time_frequency * TIME + (current_vertex.x + current_vertex.z) * space_frequency)
		* 0.25) + duty_cycle_offset,
		0.0
	) == 1.0;
	if (stripe) {
		ALBEDO = stripe_color;
	}
}