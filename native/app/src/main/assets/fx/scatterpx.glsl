// scatterpx
uniform float p_amount; uniform float p_dir; uniform float p_anim;
void main() { vec2 px = v_uv * u_res; float fr = p_anim > 0.5 ? floor(u_t * 24.0) : 0.0; vec2 r = (hash2(floor(px) + fr * 13.1) - 0.5) * 2.0 * p_amount * u_s;
  int d = int(p_dir + 0.5); if (d == 1) r.y = 0.0; if (d == 2) r.x = 0.0; o = tex((px + r) / u_res); }
