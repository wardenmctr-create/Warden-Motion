// shakeparts
uniform float p_parcaTuru, p_satir, p_sutun, p_konumSidd, p_aciSidd, p_frekans, p_tohum, p_yumusatm;
void main() {
  vec2 b = boxUV(here()); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); if (p_parcaTuru > 0.5) n = vec2(max(1.0, floor(p_sutun * 2.0)), 1.0); vec2 B = boxU();
  vec4 res = vec4(0.0);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = floor(b * n) + vec2(float(i), float(j)); if (any(lessThan(id, vec2(0.0))) || any(greaterThanEqual(id, n))) continue;
    vec2 c = (id + 0.5) / n; float x = u_t * p_frekans; float sd = seedf(p_tohum) + dot(id, vec2(7.1, 3.3)); float sm = p_yumusatm / 100.0;
    vec2 off = vec2(mix(hash1(vec2(floor(x), sd)) - 0.5, vnoise(vec2(x, sd)) - 0.5, sm), mix(hash1(vec2(floor(x), sd + 9.0)) - 0.5, vnoise(vec2(x, sd + 9.0)) - 0.5, sm)) * 2.0 * p_konumSidd;
    float ang = (mix(hash1(vec2(floor(x), sd + 4.0)), vnoise(vec2(x, sd + 4.0)), sm) - 0.5) * 2.0 * p_aciSidd;
    vec2 lu = rot2(-ang) * ((b - c) * B - off) / B + c; if (any(greaterThan(abs(lu - c), 0.5 / n))) continue; res = overPre(res, texPx(boxPx(lu))); }
  o = res;
}
