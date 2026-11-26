// vectorblur
uniform sampler2D s_yonKatm; uniform float p_yonKatmOn; uniform float p_akisUzun, p_yonKayn, p_yonAcis, p_ornekSayi, p_ciftYon;
void main() {
  vec2 p = here(); int N = int(clamp(p_ornekSayi, 4.0, 64.0)); float L = p_akisUzun * u_s; vec4 acc = vec4(0.0);
  for (int i = 0; i < 64; i++) { if (i >= N) break;
    vec2 g; if (p_yonKayn > 0.5 && p_yonKatmOn > 0.5) { vec3 m = unpre(texture(s_yonKatm, clamp(boxUV(p), 0.0, 1.0))); g = (m.rg - 0.5); g = vec2(-g.y, g.x); } else g = lumGrad(p, 2.0);
    vec2 d = length(g) > 1e-5 ? normalize(vec2(-g.y, g.x)) : vec2(1.0, 0.0); d = rot2(p_yonAcis) * d;
    acc += texPx(p); p += d * L / float(N) * (p_ciftYon > 0.5 && i % 2 == 1 ? -1.0 : 1.0); }
  o = acc / float(N);
}
