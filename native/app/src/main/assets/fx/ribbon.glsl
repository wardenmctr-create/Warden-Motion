// ribbon
GRADIENT(renkGeci)
uniform vec2 p_baslangi, p_bitis; uniform float p_kurdeleGeni, p_dalgaYuks, p_dalgaBoyu, p_hiz, p_parlama;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 ab = p_bitis - p_baslangi; float L = max(length(ab), 1.0); vec2 d = ab / L, n = vec2(-d.y, d.x);
  float t = dot(q - p_baslangi, d); float y = dot(q - p_baslangi, n);
  float ph = t / max(p_dalgaBoyu, 1.0) * TAU - u_t * p_hiz * TAU; float cy = sin(ph) * p_dalgaYuks; float tw = cos(ph * 0.5 + u_t * p_hiz);
  float hw = p_kurdeleGeni * 0.5 * (0.35 + 0.65 * abs(tw)); float k = 1.0 - smoothstep(hw - 0.8, hw + 0.8, abs(y - cy));
  k *= step(-5.0, t) * step(t, L + 5.0);
  vec3 c = grad_renkGeci(clamp(t / L, 0.0, 1.0)) * (0.75 + 0.25 * tw) + pow(max(0.0, 1.0 - abs(y - cy) / max(hw, 0.5)), 6.0) * p_parlama / 100.0;
  o = overPre(vec4(c, 1.0) * k, s);
}
