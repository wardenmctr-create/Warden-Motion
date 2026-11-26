// texturecut
uniform sampler2D s_hedef; uniform float p_hedefOn, p_dokuOlce, p_ilerleme, p_eslesmeEsig;
// Hedefe geçiş: yerel dokusu (yama ortalaması ve kontrastı) iki görüntüde benzer bölgeler önce değişir
vec2 stat(bool tgt, vec2 b, float r) { float m = 0.0, m2 = 0.0; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 q = b + vec2(i, j) * r; float l = tgt ? (p_hedefOn > 0.5 ? luma(texture(s_hedef, q).rgb) : 1.0 - lumAt(boxPx(q))) : lumAt(boxPx(q)); m += l; m2 += l * l; } m /= 9.0; return vec2(m, sqrt(max(m2 / 9.0 - m * m, 0.0))); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float r = p_dokuOlce * u_s / max(u_box.z, 1.0); vec2 a = stat(false, b, r), c = stat(true, b, r); float simv = 1.0 - clamp(length(a - c) * 3.0, 0.0, 1.0);
  float order = mix(1.0 - simv, hash1(floor(b * 40.0)), 0.15); float th = p_eslesmeEsig / 100.0; order = simv >= th ? order * 0.5 : 0.5 + order * 0.5; float k = smoothstep(order - 0.04, order + 0.04, p_ilerleme / 100.0);
  vec4 t = p_hedefOn > 0.5 ? texture(s_hedef, b) : vec4(1.0 - unpre(s), 1.0) * s.a; o = mix(s, t, k); }
