shader_type canvas_item;

uniform float zoom = 12;
uniform float timeScale = 1;
uniform sampler3D noiseImage;
uniform vec4 color_a : source_color = vec4(0.901961,0.919608,0.966667, 1);
uniform vec4 color_b : source_color = vec4(0.366667,0.366667,0.298039, 1);

float fbm3 (in vec2 st, in float z) {
	vec3 dummy;
	vec3 m = modf(vec3(st, z), dummy);
	float tul = texture(noiseImage, m).r;
	return tul;
}

float fbm2 (in vec2 st) {
	return fbm3(st, 0.5);
}

vec2 center(in vec2 p)
{
	return (p / 2.0) + vec2(0.5, 0.5);
}

float uncenter(in float p)
{
	return (p * 2.0) - 1.;
}


// First pass at making an ever changing circuit diagram in the background
// but maybe draw more symbols from https://electronicsclub.info/circuitsymbols.htm
// also turn single input lines (inner_tot set to 1) to either a ground or
// antenna.
void fragment() {
	float tm = 0.15 * timeScale * TIME;
	vec2 zup = floor(UV * zoom);
	vec2 inner_coord = floor((UV * zoom - zup) * 15.0);
	vec2 coord = zup / zoom;
	float offset = 1.0 / (2.0 * zoom);
	float inner_val = fbm3(coord, tm);
	float top_val = round(fbm3(coord - offset * vec2(0, 1), tm));
	float bot_val = round(fbm3(coord + offset * vec2(0, 1), tm));
	float right_val = round(fbm3(coord + offset * vec2(1, 0), tm));
	float left_val = round(fbm3(coord - offset * vec2(1, 0), tm));
	int x = int(inner_coord.x);
	int y = int(inner_coord.y);
	float v = 0.0;
	float inner_tot = top_val + bot_val + right_val + left_val;
	int d = 0;
	if (inner_tot < 2.5)
	{
		d = 2;
	}
	else if (inner_tot > 3.5)
	{
		d = -2;
	}
	if (x == 7)
	{
		if (y - d < 6 && top_val > 0.5)
			v = 1.0;
		else if (y + d > 8 && bot_val > 0.5)
			v = 1.0;
			
		if (inner_tot > 0.5 && inner_tot < 2.5 && y == 7)
			v = 1.0;
	}
	else if (y == 7)
	{
		if (x - d < 6 && left_val > 0.5)
			v = 1.0;
		else if (x + d > 8 && right_val > 0.5)
			v = 1.0;
	}
	if (inner_tot > 2.5)
	{
		if (inner_tot > 3.5)
		{
			if (x > 3 && x < 11 && y > 3 && y < 11)
			{
				if (x + 2 == y - 2)
					v = 1.0;
				else if (x - 2 == y + 2)
					v = 1.0;
				else if (x + 2 == 12 - y)
					v = 1.0;
				else if (x - 6 == 12 - y)
					v = 1.0;
			}
		}
		else
		{
			if ((x == 6 || x == 8) && y > 5 && y < 9)
				v = 1.0;
			if ((y == 6 || y == 8) && x > 5 && x < 9)
				v = 1.0;
		}
	}
	
	COLOR = mix(color_a, color_b, round(v));
}
