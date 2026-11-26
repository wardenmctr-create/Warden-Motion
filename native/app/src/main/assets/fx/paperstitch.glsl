// paperstitch
uniform vec3 c_iplikReng; uniform float p_delikAral, p_delikCapi, p_iplik, p_deliklerAlfaYap;
// Kenardan içeri sabit mesafede delik dizisi; delikler arasında iplik; delikler gerçek saydamlık olabilir
void main() { vec4 s = texture(u_tex, v_uv); if (s.a < 0.5) { o = s; return; } vec2 p = here(); float inset = p_delikAral * u_s * 0.8; float d = innerDist(p, inset * 2.0);
  vec2 q = toUnit(p); float per = atan(q.y, q.x) * length(q); float sp = max(p_delikAral, 1.0); float k = fract(per / sp); float onRing = 1.0 - smoothstep(0.5 * u_s, 1.5 * u_s, abs(d - inset));
  float hole = onRing * (1.0 - smoothstep(p_delikCapi * 0.35, p_delikCapi * 0.5, abs(k - 0.5) * sp));
  float thread = (1.0 - smoothstep(p_iplik * u_s * 0.4, p_iplik * u_s * 0.6 + 0.5, abs(d - inset))) * step(k, 0.5) * (1.0 - hole);
  vec4 res = overPre(vec4(c_iplikReng, 1.0) * thread, s); if (hole > 0.0) res = p_deliklerAlfaYap > 0.5 ? res * (1.0 - hole) : mix(res, vec4(0.1, 0.1, 0.1, 1.0), hole); o = res; }
