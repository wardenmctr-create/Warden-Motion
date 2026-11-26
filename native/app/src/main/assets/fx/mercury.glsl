// mercury
uniform vec2 p_yayici; uniform float p_damlacikSayi, p_damlacikBoyu, p_hiz, p_yercekim, p_viskozit, p_omur, p_metalParl, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float field = 0.0; vec3 col = vec3(0.0); int N = int(clamp(p_damlacikSayi, 1.0, 48.0));
  for (int i = 0; i < 48; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum))); float life = max(p_omur, 0.1); float lt = mod(u_t + h.x * life, life);
    vec2 v = vec2(cos(h.y * TAU), sin(h.y * TAU) - 0.5) * p_hiz * mix(1.0, 0.4, p_viskozit / 100.0); vec2 pos = p_yayici + v * lt + vec2(0.0, 0.5 * p_yercekim * lt * lt);
    float r = p_damlacikBoyu * (1.0 - lt / life * 0.5); float d2 = dot(q - pos, q - pos); float f = r * r / max(d2, 1e-3); field += f; col += texU(pos).rgb * f; }
  float own = s.a * 1.5; field += own; float m = smoothstep(0.9, 1.1, field);
  vec2 g = vec2(dFdx(field), dFdy(field)); vec3 nrm = normalize(vec3(-g * 0.5, 1.0)); float spec = pow(max(dot(reflect(vec3(-0.5, 0.5, -1.0), nrm), vec3(0, 0, 1)), 0.0), 20.0) * p_metalParl / 100.0;
  vec3 base = mix(vec3(0.75, 0.78, 0.82), unpre(s), 0.25) * (0.6 + 0.4 * nrm.z) + spec; o = pre(clamp(base, 0.0, 1.0), m);
}
