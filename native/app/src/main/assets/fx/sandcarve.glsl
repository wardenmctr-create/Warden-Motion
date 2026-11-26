// sandcarve
uniform sampler2D s_yol; uniform float p_yolOn, p_kaziDeri, p_kumTane;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float path = p_yolOn > 0.5 ? texture(s_yol, clamp(boxUV(here()), 0.0, 1.0)).a : s.a; float r = 3.0 * u_s;
  float around = 0.0; for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; around += p_yolOn > 0.5 ? texture(s_yol, clamp(boxUV(here() + vec2(cos(a), sin(a)) * r), 0.0, 1.0)).a : texPx(here() + vec2(cos(a), sin(a)) * r).a; } around /= 8.0;
  float ridge = clamp(around - path, 0.0, 1.0) * 1.5; float grain = vnoise(q / max(p_kumTane, 0.5)) * 0.15; vec3 sand = vec3(0.86, 0.75, 0.55) * (0.9 + grain);
  vec3 c = sand * (1.0 - path * p_kaziDeri / 50.0 * 0.5) * (1.0 + ridge * 0.25); o = vec4(clamp(c, 0.0, 1.0), 1.0); }
