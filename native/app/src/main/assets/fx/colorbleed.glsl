// colorbleed
uniform sampler2D s_dolguKayn; uniform float p_dolguKaynOn, p_sizma, p_guc, p_koyuCizgMerk;
// Koyu çizgi pikselleri, sızma mesafesindeki çizgi olmayan komşu renkleri içine çeker; çizgi merkezi koyu kalabilir
float ink(vec2 p) { vec4 c = texPx(p); return c.a > 0.5 && luma(unpre(c)) < 0.3 ? 1.0 : 0.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); if (ink(p) < 0.5) { o = s; return; } float R = max(p_sizma * u_s, 1.0); vec3 acc = vec3(0.0); float w = 0.0; float dmin = 1e5;
  for (int i = 0; i < 12; i++) { float a = float(i) / 12.0 * TAU; vec2 d = vec2(cos(a), sin(a)); for (int k = 1; k <= 8; k++) { vec2 q = p + d * float(k) / 8.0 * R * 2.0; if (ink(q) > 0.5) continue;
      vec4 c = p_dolguKaynOn > 0.5 ? texture(s_dolguKayn, boxUV(q)) : texPx(q); if (c.a < 0.3) break; float dist = float(k) / 8.0 * R * 2.0; acc += unpre(c) / dist; w += 1.0 / dist; dmin = min(dmin, dist); break; } }
  if (w <= 0.0) { o = s; return; } vec3 fill = acc / w; float k = exp(-dmin / R) * p_guc / 100.0; if (p_koyuCizgMerk > 0.5) k *= smoothstep(R * 1.6, R * 0.4, dmin);
  o = pre(mix(unpre(s), fill * 0.8, k), s.a); }
