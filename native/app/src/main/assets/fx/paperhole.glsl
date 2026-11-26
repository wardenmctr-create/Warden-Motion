// paperhole
INCLUDE(_mat)
uniform float p_delikIler, p_kenarKivr, p_lif, p_kagitMalz;
void main() { vec4 s = texture(u_tex, v_uv); float p = p_delikIler / 100.0; vec2 q = toUnit(here()); float R = p * length(boxU()) * 0.6; float r = length(q) + fbm(q * 0.03, 4.0) * 30.0 * (0.5 + p_lif / 100.0);
  if (r < R) { o = vec4(0.0); return; } float rim = 1.0 - smoothstep(R, R + 8.0 + p_kenarKivr * 0.3, r); int id = p_kagitMalz < 0.5 ? 1 : p_kagitMalz < 1.5 ? 3 : 5; vec3 paper = matSample(id, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.5, 0.0).rgb;
  o = overPre(vec4(mix(paper, vec3(0.97, 0.95, 0.9), 0.4), 1.0) * rim * step(0.001, p), s * (1.0 - rim * 0.8)); }
