// areasample
uniform sampler2D s_agirlikHari; uniform float p_agirlikHariOn, p_nokta, p_enAzMesa, p_tohum;
// Yüzey (alfa) üzerinde alana göre eşit dağılım; ağırlık haritası parlak yerlerde yoğunluğu artırır; en az mesafe hücre boyunu büyütür
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cell = max(sqrt(boxU().x * boxU().y / max(p_nokta, 1.0)), p_enAzMesa); vec2 id0 = floor(q / cell); float v = 0.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = id0 + vec2(i, j); vec2 c = (id + 0.15 + hash2(id + p_tohum) * 0.7) * cell; vec4 base = texU(c); if (base.a < 0.5) continue;
    float w = p_agirlikHariOn > 0.5 ? luma(texture(s_agirlikHari, boxUV(fromUnit(c))).rgb) : 1.0; if (hash1(id * 1.7 + p_tohum) > w) continue; v = max(v, 1.0 - smoothstep(1.2, 1.2 + 1.0 / u_s, length(q - c))); }
  o = overPre(vec4(1.0, 0.9, 0.4, 1.0) * v, vec4(s.rgb * 0.6, s.a)); }
