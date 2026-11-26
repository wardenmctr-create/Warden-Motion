// cbblush
uniform vec2 p_solMerk, p_sagMerk; uniform vec3 c_renk; uniform float p_boyut, p_cizgiSayi, p_aci, p_opaklik, p_yumusakl, p_alfayaKirp;
float marks(vec2 q, vec2 c) { vec2 r = rot2(-p_aci) * (q - c); float n = max(1.0, floor(p_cizgiSayi)); float sp = p_boyut * 0.45; float m = 0.0;
  for (int i = 0; i < 10; i++) { if (float(i) >= n) break; float x = (float(i) - (n - 1.0) * 0.5) * sp; vec2 d = r - vec2(x, 0.0); float L = p_boyut * 0.5;
    float k = 1.0 - smoothstep(p_boyut * 0.08, p_boyut * 0.08 + 1.0 + p_yumusakl * 0.05, length(vec2(d.x - clamp(d.x, -0.0, 0.0), max(abs(d.y) - L, 0.0)) + vec2(abs(d.x), 0.0) * 0.0)); m = max(m, k); }
  float glow = exp(-dot(r, r) / pow(p_boyut * 1.2, 2.0)) * 0.35; return max(m, glow); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float m = max(marks(q, p_solMerk), marks(q, p_sagMerk)) * p_opaklik / 100.0; if (p_alfayaKirp > 0.5) m *= s.a; o = overPre(vec4(c_renk, 1.0) * m, s); }
