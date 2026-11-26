// heartrain
GRADIENT(renkler)
uniform float p_kalpSayi, p_boyut, p_hiz, p_yon, p_donusHizi, p_rastgele, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec2 dir = vec2(cos(radians(p_yon)), sin(radians(p_yon))); vec4 acc = vec4(0.0);
  int N = int(clamp(p_kalpSayi, 1.0, 80.0));
  for (int i = 0; i < 80; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum))); float sz = p_boyut * mix(1.0, 0.5 + h.y, p_rastgele / 100.0);
    float span = dot(B, abs(dir)) + sz * 2.0; float tpos = fract(h.x * 3.7 + u_t * p_hiz / span * mix(1.0, 0.6 + h.y * 0.8, p_rastgele / 100.0));
    vec2 perp = vec2(-dir.y, dir.x); vec2 c = perp * (h.x - 0.5) * dot(B, abs(perp)) + dir * (tpos - 0.5) * span + perp * sin(u_t * 1.5 + float(i)) * sz * 0.4;
    vec2 r = rot2(-p_donusHizi * u_t * (h.y - 0.5) * 2.0) * (q - c) / max(sz, 0.5); float d = heartSDF(r);
    float k = 1.0 - smoothstep(-0.02, 0.02, d); vec3 col = palc_renkler(i % paln_renkler()); acc = overPre(vec4(col, 1.0) * k, acc); }
  o = overPre(acc, s);
}
