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

float draw_antenna(int x, int y)
{
	if (x == 7)
	{
		return (y > 4) ? 1.0 : 0.0;
	}
	else if (y == 4 && (x == 4 || x == 10))
		return 1.0;
	else if (y == 5 && (x == 5 || x == 9))
		return 1.0;
	else if (y == 6 && (x == 6 || x == 8))
		return 1.0;
	
	return 0.0;
}

float draw_ground(int x, int y)
{
	if (x == 7 && (y == 10 || y < 4))
	{
		return 1.0;
	}
	else if (y == 4 && x > 3 && x < 11)
	{
		return 1.0;
	}
	else if (y == 7 && x > 5 && x < 9)
	{
		return 1.0;
	}
	else if (y == 10 && x == 7)
	{
		return 1.0;
	}
	
	return 0.0;
}

float draw_orphan(int x, int y, float rnd, bool top, bool bottom, bool right, bool left)
{
	if (rnd > 0.5)
	{
		if (bottom)
			return draw_antenna(x, y);
		else if (top)
			return draw_antenna(x, 14 - y);
		else if (right)
			return draw_antenna(y, x);
		else
			return draw_antenna(y, 14 - x);
	}
	else
	{
		if (top)
			return draw_ground(x, y);
		else if (bottom)
			return draw_ground(x, 14 - y);
		else if (left)
			return draw_ground(y, x);
		else
			return draw_ground(y, 14 - x);
	}
}

float draw_horizontal(int x, int y, float rnd)
{
	if (rnd < 0.25)
	{
		return (y == 7) ? 1.0 : 0.0;
	}
	else if (rnd > 0.75)
	{
		if (x == 7)
			return y < 6 || y > 8 ? 1.0 : 0.0;
		if (y == 5)
			return x > 4 && x < 10 ? 1.0 : 0.0;
		if (y == 9)
			return x > 2 && x < 12 ? 1.0 : 0.0;
		return 0.0;
	}
	else if (rnd > 0.5)
	{
		if (y == 4 || y == 10)
		{
			return (x > 2 && x < 12) ? 1.0 : 0.0;
		}
		else if (y == 5 || y == 6 || y == 8 || y == 9)
		{
			return (x == 3 || x == 11) ? 1.0 : 0.0;
		}
		else if (y == 7)
		{
			return 1.0;
		}
		
		return 0.0;
	}
	else
	{
		if (y == 5 || y == 9)
		{
			return (x > 2 && x < 12) ? 1.0 : 0.0;
		}
		else if (y == 6 || y == 8)
		{
			return (x == 3 || x == 11) ? 1.0 : 0.0;
		}
		else if (y == 7)
		{
			return (x < 4 || x > 10) ? 1.0 : 0.0;
		}
		
		return 0.0;
	}
}

float draw_vertical(int x, int y, float rnd)
{
	return draw_horizontal(y, x, rnd);
}

float draw_corner(int x, int y, float rnd, bool top, bool bottom, bool right, bool left)
{
	if (x == 7 && y == 7)
		return 1.0;
	if (x == 7)
	{
		return (top && y < 7) || (bottom && y > 7) ? 1.0 : 0.0;
	}
	if (y == 7)
	{
		return (left && x < 7) || (right && x > 7) ? 1.0 : 0.0;
	}
	return 0.0;
}

float draw_and_gate(int x, int y)
{
	if (y < 2)
		return x == 7 ? 1.0 : 0.0;
	if (y == 2)
		return (x > 5 && x < 9) ? 1.0 : 0.0;
	if (y == 3)
		return (x == 5 || x == 9) ? 1.0 : 0.0;
	if (y > 3 && y < 6)
		return (x == 4 || x == 10) ? 1.0 : 0.0;
	if (y == 6)
	    return (x > 3 && x < 11) ? 1.0 : 0.0;
	if (y == 7)
		return (x == 5 || x == 9 || x < 2 || x > 12) ? 1.0 : 0.0;
	if (y == 8)
		return (x == 5 || x == 9 || x == 1 || x == 13) ? 1.0 : 0.0;
	if (y == 9)
		return (x > 0 && x < 6) || (x > 8 && x < 14) ? 1.0 : 0.0;
		
	return 0.0;
}

float draw_three_way(int x, int y, float rnd, bool top, bool bottom, bool right, bool left)
{
	if (rnd < 0.5)
	{
	if (bottom == false)
		return draw_and_gate(x, y);
	if (top == false)
		return draw_and_gate(x, 14 - y);
	if (right == false)
		return draw_and_gate(y, x);
	if (left == false)
		return draw_and_gate(y, 14 - x);
	}
	else
	{
		float v = 0.0;
		if (x == 7)
		{
			if (y < 6 && top)
				v = 1.0;
			else if (y > 8 && bottom)
				v = 1.0;
		}
		else if (y == 7)
		{
			if (x < 6 && left)
				v = 1.0;
			else if (x > 8 && right)
				v = 1.0;
		}
		
		if ((x == 6 || x == 8) && y > 5 && y < 9)
			v = 1.0;
		if ((y == 6 || y == 8) && x > 5 && x < 9)
			v = 1.0;
		
		return v;
	}
}

float draw_four_way(int x, int y, float rnd)
{
	if (rnd < 0.333)
	{
		return (x == 7 || y == 7) ? 1.0 : 0.0;
	}
	else
	{
		if (x == 7)
			return 1.0;
		if (y == 7)
		    return (x < 4 || x > 10) ? 1.0 : 0.0;
		if (y == 6 || y == 5)
			return (x == 3 || x == 11) ? 1.0 : 0.0;
		if (y == 4 || y == 3)
			return (x == 4 || x == 10) ? 1.0 : 0.0;
		if (y == 2)
			return (x == 5 || x == 9) ? 1.0 : 0.0;
		if (y == 1)
			return (x > 5 && x < 9) ? 1.0 : 0.0;
	}
	//if (x > 3 && x < 11 && y > 3 && y < 11)
	//{
	//	if (x + 2 == y - 2)
	//		v = 1.0;
	//	else if (x - 2 == y + 2)
	//		v = 1.0;
	//	else if (x + 2 == 12 - y)
	//		v = 1.0;
	//	else if (x - 6 == 12 - y)
	//		v = 1.0;
	//}
	return 0.0;
}

// First pass at making an ever changing circuit diagram in the background
// but maybe draw more symbols from https://electronicsclub.info/circuitsymbols.htm
//
// NOTE: Please do not take this for good shader code - for one thing, it's
// more if-than branches than computations, which is EXCATLY the wrong thing
// to do for shaders. The right way to do this, is, rather than a shader,
// we have nice larger drawn circuit symbols sampled on larger images,
// and put the whole thing on a tilemap that animated behind the game.
void fragment() {
	float tm = 0.15 * timeScale * TIME;
	vec2 zup = floor(UV * zoom);
	vec2 inner_coord = floor((UV * zoom - zup) * 15.0);
	vec2 coord = zup / zoom;
	float offset = 1.0 / (2.0 * zoom);
	float inner_const = fbm2(coord);
	float top_val = round(fbm3(coord - offset * vec2(0, 1), tm));
	float bot_val = round(fbm3(coord + offset * vec2(0, 1), tm));
	float right_val = round(fbm3(coord + offset * vec2(1, 0), tm));
	float left_val = round(fbm3(coord - offset * vec2(1, 0), tm));
	int x = int(inner_coord.x);
	int y = int(inner_coord.y);
	float v = 0.0;
	int itot = int(round(top_val + bot_val + right_val + left_val));
	switch (itot)
	{
		case 1:
			v = draw_orphan(x, y, inner_const, top_val > 0.5, bot_val > 0.5, right_val > 0.5, left_val > 0.5);
			break;
		case 2:
			int horizontal_line = int(round(right_val + left_val));
			int vertical_line = int(round(top_val + bot_val));
			if (horizontal_line == 2)
				v = draw_horizontal(x, y, inner_const);
			else if (vertical_line == 2)
				v = draw_vertical(x, y, inner_const);
			else
				v = draw_corner(x, y, inner_const, top_val > 0.5, bot_val > 0.5, right_val > 0.5, left_val > 0.5);
			break;
		case 3:
			v = draw_three_way(x, y, inner_const, top_val > 0.5, bot_val > 0.5, right_val > 0.5, left_val > 0.5);
			break;
		case 4:
			v = draw_four_way(x, y, inner_const);
			break;
	}
	
	COLOR = mix(color_a, color_b, round(v));
}
