// foam
uniform vec2 p_yayici; uniform float p_kopukSayi, p_boyut, p_boyutDegi, p_yukselmeHizi, p_birlesme, p_opaklik, p_tohum; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec4 acc = vec4(0.0); int N = int(clamp(p_kopukSayi, 1.0, 96.0)); float field = 0.0;
  for (int i = 0; i < 96; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum) + 3.0)); float life = boxU().y / max(p_yukselmeHizi, 1.0); float lt = mod(u_t + h.x * life, life);
    vec2 pos = p_yayici + vec2((h.y - 0.5) * boxU().x * 0.6 + sin(lt * 2.0 + h.x * 6.0) * 6.0, -p_yukselmeHizi * lt); float r = p_boyut * mix(1.0, 0.4 + h.y, p_boyutDegi / 100.0);
    float d = length(q - pos); field += exp(-pow(d / max(r, 0.5), 2.0) * mix(6.0, 2.0, p_birlesme / 100.0)); float ring = smoothstep(r * 0.7, r, d) * (1.0 - smoothstep(r, r + 1.0, d)); acc = max(acc, vec4(ring)); }
  float m = smoothstep(0.4, 0.6, field); vec3 col = c_renk * (0.85 + 0.15 * acc.r); o = overPre(vec4(col, 1.0) * m * p_opaklik / 100.0, s);
}
