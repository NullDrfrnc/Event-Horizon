shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_never;

uniform vec3 planet_position;
uniform float planet_radius;
uniform float atmosphere_radius;
uniform float scatter_strength = 1.0;
uniform float scale_height;
uniform vec3 light_dir;
uniform vec3 scatter_coeffs = vec3(0.18, 0.42, 1.0);
uniform vec3 mie_coeffs = vec3(1.0, 0.8, 0.6);
uniform float mie_anisotropy = 0.76;
uniform float depth_color_shift = 2.0;
uniform float ambient = 0.0015;

const int VIEW_STEPS = 16;
const int SUN_STEPS = 8;

varying vec3 world_pos;
varying vec3 world_camera_pos;

vec2 sphere_ray(vec3 sphere_center, float sphere_radius, vec3 ray_origin, vec3 ray_dir) {
	vec3 offset = ray_origin - sphere_center;
	float a = 1.0;
	float b = 2.0 * dot(offset, ray_dir);
	float c = dot(offset, offset) - sphere_radius * sphere_radius;
	float d = b * b - 4.0 * a * c;
	
	if (d > 0.0) {
		float s = sqrt(d);
		float dst_to_sphere_near = max(0.0, (-b -s) / (2.0 * a));
		float dst_to_sphere_far = (-b + s) / (2.0 * a);
		
		// Ignore intersections that occur behind the ray
		if (dst_to_sphere_far >= 0.0) {
			return vec2(dst_to_sphere_near, dst_to_sphere_far - dst_to_sphere_near);
		}
	}
	
	// Did not intersect sphere
	return vec2(1e10, 0.0);
}

float sun_optical_depth(vec3 point) {
	vec2 sun_hit = sphere_ray(planet_position, atmosphere_radius, point, light_dir);
	float step_size = sun_hit.y / float(SUN_STEPS);
	float depth = 0.0;
	
	for (int i = 0; i < SUN_STEPS; i++) {
		vec3 sun_sample = point + light_dir * (step_size * (float(i) + 0.5));
		float height = length(sun_sample - planet_position) - planet_radius;
		float density = exp(-height / (scale_height * atmosphere_radius));
		depth += density * step_size;
	}
	
	return depth;
}

float mie_phase(float cos_theta, float g) {
	float g2 = g * g;
	return (1.0 - g2) / pow(1.0 + g2 - 2.0 * g * cos_theta, 1.5);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_camera_pos = (INV_VIEW_MATRIX * vec4(0, 0, 0, 1)).xyz;
}

void fragment() {
	vec3 ray_dir = normalize(world_pos - world_camera_pos);
	
	vec2 atmosphere_hit = sphere_ray(planet_position, atmosphere_radius, world_camera_pos, ray_dir);
	vec2 planet_hit = sphere_ray(planet_position, planet_radius, world_camera_pos, ray_dir);
	
	float ray_length = min(atmosphere_hit.y, planet_hit.x - atmosphere_hit.x);
	
	if (ray_length > 0.0) {
		float step_size = ray_length / float(VIEW_STEPS);
		vec3 scattered_light = vec3(0.0);
		vec3 mie_light = vec3(0.0);
		float optical_depth = 0.0;
		float cos_theta = dot(ray_dir, light_dir);
		float mie = mie_phase(cos_theta, mie_anisotropy);
		
		for (int i = 0; i < VIEW_STEPS; i++) {
			vec3 sample_point = world_camera_pos + ray_dir * (atmosphere_hit.x + step_size * (float(i) + 0.5));
			float height = length(sample_point - planet_position) - planet_radius;
			float density = exp(-height / (scale_height * atmosphere_radius));
			
			float sun_depth = sun_optical_depth(sample_point);
			float transmittance = exp(-(optical_depth + sun_depth)) + ambient;
			scattered_light += scatter_coeffs * density * transmittance * step_size;
			mie_light += mie_coeffs * mie * density * transmittance * step_size;
			optical_depth += density * step_size;
		}
		
		float depth_ratio = 1.0 - exp(-optical_depth * depth_color_shift);
		vec3 depth_color = mix(scatter_coeffs, mie_coeffs, depth_ratio);
		ALBEDO = (depth_color * scattered_light + mie_light) * scatter_strength;
		ALPHA = clamp(1.0 - exp(-optical_depth), 0.0, 0.85);
	} else {
		ALBEDO = vec3(0.0);
		ALPHA = 0.0;
	}
}