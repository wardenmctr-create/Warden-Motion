// radiowaves
uniform vec2 p_merkez; uniform float p_halkaSayi, p_yayilmaHizi, p_halkaKali, p_enBuyuYari, p_solma, p_dongu; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); float d = length(toUnit(here()) - p_merkez); float n = max(1.0, floor(p_halkaSayi)); float R = max(p_enBuyuYari, 1.0); float acc = 0.0;
  for (int i = 0; i < 32; i++) { if (float(i) >= n) break; float ph = u_t * p_yayilmaHizi * 0.5 + float(i) / n; if (p_dongu > 0.5) ph = fract(ph); else if (ph > 1.0) continue;
    float rr = ph * R; float k = 1.0 - smoothstep(p_halkaKali * 0.5 - 0.7, p_halkaKali * 0.5 + 0.7, abs(d - rr)); acc = max(acc, k * (1.0 - ph * p_solma / 100.0)); }
  o = overPre(vec4(c_renk, 1.0) * acc, s);
}
