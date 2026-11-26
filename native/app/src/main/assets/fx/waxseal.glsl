// waxseal
uniform float p_kenarTasm, p_izDeri; uniform vec3 c_mumReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R = (p_kenarTasm + 2.0) * u_s; float body = smoothstep(0.3, 0.6, dilateA(here(), R * (0.7 + 0.3 * fbm01(q * 0.05, 3.0))));
  float hgt = body * 0.5 - s.a * p_izDeri / 50.0 * 0.5; vec3 n = normalize(vec3(-dFdx(hgt) * 30.0, -dFdy(hgt) * 30.0, 1.0)); float lit = 0.5 + 0.7 * max(dot(n, normalize(vec3(-0.4, -0.6, 0.7))), 0.0);
  float sp = pow(max(dot(reflect(normalize(vec3(0.4, 0.6, -0.7)), n), vec3(0.0, 0.0, 1.0)), 0.0), 20.0) * 0.5; o = vec4(clamp(c_mumReng * lit + sp, 0.0, 1.0), 1.0) * body; }
