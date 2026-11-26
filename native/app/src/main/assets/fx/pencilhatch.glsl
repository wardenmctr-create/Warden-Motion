// pencilhatch
INCLUDE(_mat)
uniform float p_tarama, p_cizgiKali, p_cizgiAral, p_cizgiUzun, p_birinciAci, p_ikinciAci, p_taramaKatm, p_kalemBasi, p_tonHass, p_cizgiDuze, p_ucYumu, p_kagitDoku, p_cizgilerCanl, p_yenilenmAral; uniform vec3 c_kalemReng;
float hatchLayer(vec2 q, float ang, float k, float tick) { vec2 r = rot2(-ang) * q; float sp = max(p_cizgiAral, 1.0); float row = floor(r.y / sp); float segL = max(p_cizgiUzun, 2.0);
  float sx = r.x / segL + hash1(vec2(row, k + tick)) * 3.0; float seg = floor(sx); float fx = fract(sx); float jy = (hash1(vec2(seg, row + k * 7.0 + tick)) - 0.5) * p_cizgiDuze / 100.0 * sp;
  float y = abs(mod(r.y + jy, sp) - sp * 0.5); float w = max(p_cizgiKali, 0.3) * 0.5; float taper = smoothstep(0.0, p_ucYumu / 100.0 * 0.4 + 0.01, fx) * smoothstep(1.0, 1.0 - p_ucYumu / 100.0 * 0.4 - 0.01, fx);
  return (1.0 - smoothstep(w * 0.5, w + 0.6 / max(u_s, 0.1), y)) * taper * step(0.08, hash1(vec2(seg + 0.5, row))); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float tick = p_cizgilerCanl > 0.5 ? floor(u_t * 24.0 / max(p_yenilenmAral, 1.0)) : 0.0;
  float L = luma(unpre(s)); float dark = clamp((1.0 - L) * (0.5 + p_tonHass / 100.0), 0.0, 1.0); int K = int(clamp(p_taramaKatm, 1.0, 6.0)); float acc = 0.0;
  for (int k = 0; k < 6; k++) { if (k >= K) break; float th = float(k) / float(K); if (dark < th + 0.05) continue; float ang = p_tarama < 0.5 ? p_birinciAci : p_tarama < 1.5 ? (k % 2 == 0 ? p_birinciAci : p_ikinciAci) : p_birinciAci + float(k) * 180.0 / float(K);
    if (p_tarama > 2.5) { vec2 g = lumGrad(here(), 2.0 * u_s); if (length(g) > 1e-3) ang = degrees(atan(g.y, g.x)) + 90.0 + float(k) * 30.0; }
    acc = max(acc, hatchLayer(q, ang, float(k), tick) * smoothstep(th, th + 0.15, dark)); }
  float edge = smoothstep(0.3, 0.7, sobel(here(), u_s) + length(alphaGrad(here(), u_s))); acc = max(acc, edge * 0.8);
  vec3 paper = vec3(0.98, 0.97, 0.94); if (p_kagitDoku > 0.5) paper = matSample(1, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb;
  vec3 c = mix(paper, c_kalemReng * (0.6 + 0.4 * vnoise(q * 0.8)), acc * p_kalemBasi / 100.0 * 1.4); o = pre(clamp(c, 0.0, 1.0), s.a); }
