// lightvoronoi
uniform sampler2D s_engelMask; uniform vec4 p_dv4[4]; float dvAt(int i) { return i < 0 || i >= 16 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_engelMaskOn, p_dvN, p_cozunurl, p_kenarGeni, p_bolgelerRenk;
// Işık kaynakları (motor: seçili katmanların konumları); her piksel, engel kesmeden gördüğü en yakın ışığın bölgesi; bölge sınırları çizgi
vec2 Lp(int i) { if (p_dvN > 1.5) return vec2(dvAt(i * 2), dvAt(i * 2 + 1)); vec2 bu = boxU(); return vec2(i == 0 ? -0.3 : (i == 1 ? 0.3 : 0.0), i == 2 ? 0.3 : -0.2) * bu; }
float occ(vec2 u) { return p_engelMaskOn > 0.5 ? texture(s_engelMask, boxUV(fromUnit(u))).a : 0.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); int N = p_dvN > 1.5 ? int(p_dvN / 2.0) : 3; float b1 = 1e9, b2 = 1e9; int bi = -1;
  if (occ(q) > 0.5) { o = vec4(0.1, 0.1, 0.12, 1.0); return; }
  for (int i = 0; i < 8; i++) { if (i >= N) break; vec2 L = Lp(i); float D = length(q - L); bool vis = true; for (int k = 1; k < 24; k++) { if (occ(mix(q, L, float(k) / 24.0)) > 0.5) { vis = false; break; } }
    if (!vis) D += 1e5; if (D < b1) { b2 = b1; b1 = D; bi = i; } else if (D < b2) b2 = D; }
  vec4 res = s; if (bi >= 0 && b1 < 1e5) { vec3 c = hsv2rgb(vec3(float(bi) * 0.17 + 0.05, 0.55, 1.0)); if (p_bolgelerRenk > 0.5) res = vec4(mix(s.rgb, c * max(s.a, 0.3), 0.5), max(s.a, 0.3)); float edge = 1.0 - smoothstep(p_kenarGeni * 0.5, p_kenarGeni * 0.5 + 1.0 / u_s, (b2 - b1) * 0.5);
    res = overPre(vec4(1.0, 1.0, 0.85, 1.0) * edge * step(b2, 1e5), res); } else res = vec4(s.rgb * 0.25, s.a);
  for (int i = 0; i < 8; i++) { if (i >= N) break; res = overPre(vec4(1.0, 0.9, 0.4, 1.0) * (1.0 - smoothstep(3.0, 4.0, length(q - Lp(i)))), res); } o = res; }
