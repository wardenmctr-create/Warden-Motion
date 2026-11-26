// smoke
GRADIENT(renkGeci)
uniform vec2 p_dumanMerk; uniform float p_yogunluk, p_olcek, p_yukselmeHizi, p_turbulan, p_evrim, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 r = q - p_dumanMerk; float sc = max(p_olcek, 1.0);
  vec2 p = r / sc; p.y += u_t * p_yukselmeHizi / sc; vec2 w = vec2(fbm(p + seedf(p_tohum), 3.0), fbm(p + 5.2 + p_evrim * 0.03, 3.0)) * p_turbulan / 100.0 * 2.0;
  float n = fbm(p + w, 4.0) * 0.5 + 0.5; float up = clamp(-r.y / (boxU().y * 0.9), 0.0, 1.0); float plume = exp(-pow(r.x / (sc * (0.4 + up * 1.2)), 2.0)) * smoothstep(0.0, 0.08, up + 0.05) * (1.0 - up * 0.5);
  float d = clamp(smoothstep(0.35, 0.8, n) * plume * p_yogunluk / 100.0 * 1.8, 0.0, 1.0);
  o = overPre(vec4(grad_renkGeci(clamp(up + (n - 0.5) * 0.3, 0.0, 1.0)), 1.0) * d, s);
}
