// bokeh
GRADIENT(renkler)
uniform float p_isikSayi, p_boyut, p_bulanikl, p_hiz, p_opaklik, p_boyutDegi, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec3 acc = vec3(0.0);
  int N = int(clamp(p_isikSayi, 1.0, 80.0));
  for (int i = 0; i < 80; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum) + 2.0)); vec2 h2 = hash2(vec2(float(i) + 0.5, 9.0));
    vec2 c = (h - 0.5) * B + vec2(sin(u_t * 0.3 + h2.x * 6.0), cos(u_t * 0.25 + h2.y * 6.0)) * p_hiz * 0.3 - vec2(0.0, fract(u_t * p_hiz / max(B.y, 1.0) * 0.3 + h2.x) - 0.5) * B.y * 0.0;
    float r = p_boyut * 0.5 * mix(1.0, 0.4 + h2.y * 1.2, p_boyutDegi / 100.0); float d = length(q - c);
    float k = 1.0 - smoothstep(r - max(p_bulanikl * 0.5, 0.5), r + max(p_bulanikl * 0.5, 0.5), d); k *= 0.75 + 0.25 * smoothstep(r * 0.6, r, d);
    acc += palc_renkler(i % paln_renkler()) * k * p_opaklik / 100.0; }
  o = vec4(min(s.rgb + acc * (1.0 - s.rgb * 0.5), vec3(1.0)), max(s.a, clamp(max(acc.r, max(acc.g, acc.b)), 0.0, 1.0)));
}
