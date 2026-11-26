// weightedstipple
uniform sampler2D s_yogunlukKayn; uniform float p_yogunlukKaynOn, p_nokta, p_yineleme, p_noktaCapi;
// Koyuluğa göre nokta: ince ızgara + tohumlu titreme; yineleme arttıkça titreme azalır (daha düzenli aralık)
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0 && p_yogunlukKaynOn < 0.5) { o = s; return; } vec2 q = toUnit(here()); float cell = sqrt(boxU().x * boxU().y / max(p_nokta, 10.0)) * 0.5; vec2 id0 = floor(q / cell);
  float jit = 0.45 / sqrt(max(p_yineleme, 1.0)) + 0.05; float v = 0.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = id0 + vec2(i, j); vec2 c = (id + 0.5 + (hash2(id) - 0.5) * jit * 2.0) * cell; vec4 src = p_yogunlukKaynOn > 0.5 ? texture(s_yogunlukKayn, boxUV(fromUnit(c))) : texU(c);
    float dark = 1.0 - luma(unpre(src)); if (hash1(id + 3.3) > dark * 1.1) continue; v = max(v, 1.0 - smoothstep(p_noktaCapi * 0.5 - 0.6 / u_s, p_noktaCapi * 0.5 + 0.6 / u_s, length(q - c))); }
  vec3 paper = vec3(0.97, 0.96, 0.93); o = vec4(mix(paper, vec3(0.06), v), 1.0) * max(s.a, p_yogunlukKaynOn); }
