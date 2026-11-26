// focusstack
uniform sampler2D s_odakKatm; uniform float p_odakKatmOn, p_odakPencBoyu, p_kenarGeci, p_otomatikHiza;
// Her pikselde iki görüntünün yerel Laplace enerjisi karşılaştırılır; keskin olan seçilir, kenar geçişiyle yumuşatılır
float sharp(bool other, vec2 px) { float R = max(p_odakPencBoyu * u_s * 0.5, 1.0); float e = 0.0; for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 q = px + vec2(i, j) / 2.0 * R;
    float c = other ? luma(unpre(texture(s_odakKatm, boxUV(q)))) : luma(unpre(texPx(q))); float n = other ? luma(unpre(texture(s_odakKatm, boxUV(q + vec2(1.0, 0.0))))) + luma(unpre(texture(s_odakKatm, boxUV(q - vec2(1.0, 0.0))))) + luma(unpre(texture(s_odakKatm, boxUV(q + vec2(0.0, 1.0))))) + luma(unpre(texture(s_odakKatm, boxUV(q - vec2(0.0, 1.0)))))
      : lumAt(q + vec2(1.0, 0.0)) + lumAt(q - vec2(1.0, 0.0)) + lumAt(q + vec2(0.0, 1.0)) + lumAt(q - vec2(0.0, 1.0)); e += abs(4.0 * c - n); } return e; }
void main() { vec4 s = texture(u_tex, v_uv); if (p_odakKatmOn < 0.5) { o = s; return; } vec4 b = texture(s_odakKatm, boxUV(here())); float a = sharp(false, here()), c = sharp(true, here());
  float w = smoothstep(-0.02 - p_kenarGeci * 0.004, 0.02 + p_kenarGeci * 0.004, c - a); o = mix(s, b, w); }
