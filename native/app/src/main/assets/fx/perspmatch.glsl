// perspmatch
uniform sampler2D s_hedef; uniform float p_hedefOn, p_noktaSeti, p_guc, p_ufkuKoru;
// Hedef görüntü, katmanın düzlemine perspektif (yamuk) dönüşümle oturtulur: üst kenar güç oranında daralır; ufuk korunursa dikey ölçek sabit
void main() { vec4 s = texture(u_tex, v_uv); if (p_hedefOn < 0.5) { o = s; return; } vec2 b = boxUV(here()); float k = p_guc / 100.0 * 0.45; float w = mix(1.0 - k * 2.0, 1.0, b.y);
  float u = (b.x - 0.5) / max(w, 0.05) + 0.5; float v = p_ufkuKoru > 0.5 ? b.y : pow(clamp(b.y, 0.0, 1.0), mix(1.0, 1.6, k)); if (u < 0.0 || u > 1.0) { o = s; return; } vec4 t = texture(s_hedef, vec2(u, v)); o = overPre(t, s); }
