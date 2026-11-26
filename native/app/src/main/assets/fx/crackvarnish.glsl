// crackvarnish
uniform sampler2D s_altYuze; uniform float p_altYuzeOn, p_catlakOlce, p_genislik, p_vernikOpak;
// Vernik katmanı (sarımsı) altındaki görüntü; Voronoi kenarları çatlak olur ve alt yüzeyi gösterir
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 q = toUnit(here()) / max(p_catlakOlce, 1.0); q += vec2(fbm(q * 2.0, 2.0), fbm(q * 2.0 + 5.0, 2.0)) * 0.25;
  vec4 v = voronoi(q); float edge = v.y - v.x; float w = p_genislik / max(p_catlakOlce, 1.0); float crack = 1.0 - smoothstep(w * 0.5, w * 0.5 + 0.03, edge);
  vec3 under = p_altYuzeOn > 0.5 ? unpre(texture(s_altYuze, boxUV(here()))) : unpre(s) * 0.35; vec3 varn = mix(unpre(s), unpre(s) * vec3(1.05, 0.95, 0.72), p_vernikOpak / 100.0);
  o = pre(mix(varn, under, crack), s.a); }
