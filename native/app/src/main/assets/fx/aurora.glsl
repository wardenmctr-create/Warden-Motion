// aurora
GRADIENT(renkGeci)
uniform float p_seritSayi, p_yuksekli, p_dalgaGeni, p_hiz, p_parlakli, p_yumusakl, p_aci;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_aci) * toUnit(here()); vec3 acc = vec3(0.0); int N = int(clamp(p_seritSayi, 1.0, 12.0));
  for (int i = 0; i < 12; i++) { if (i >= N) break; float fi = float(i); float base = -boxU().y * 0.25 + fi * 18.0;
    float cy = base + sin(q.x / max(p_dalgaGeni, 1.0) * TAU + u_t * p_hiz * TAU + fi * 1.7) * 25.0 + fbm(vec2(q.x / max(p_dalgaGeni, 1.0) + u_t * p_hiz * 0.5, fi), 3.0) * 30.0;
    float dy = cy - q.y; float h = max(p_yuksekli, 1.0);
    float k = smoothstep(0.0, 6.0, dy + 2.0) * exp(-max(dy, 0.0) / (h * mix(0.15, 0.6, p_yumusakl / 100.0))) * (0.6 + 0.4 * vnoise(vec2(q.x * 0.08, fi * 3.0 + u_t)));
    acc += grad_renkGeci(clamp(max(dy, 0.0) / h, 0.0, 1.0)) * k; }
  acc *= p_parlakli / 100.0 * 1.3;
  o = vec4(min(s.rgb + acc * (1.0 - s.rgb * 0.4), vec3(1.0)), max(s.a, clamp(max(acc.r, max(acc.g, acc.b)), 0.0, 1.0)));
}
