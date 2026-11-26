// shapemask
uniform float p_sekil, p_boyutX, p_boyutY, p_aci, p_yumusatm, p_ters; uniform vec2 p_merkez;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 B = boxU() * 0.5; vec2 sz = vec2(p_boyutX, p_sekil < 0.5 || p_sekil > 2.5 ? p_boyutX : p_boyutY) / 100.0 * min(B.x, B.y);
  if (p_sekil > 0.5 && p_sekil < 2.5) sz = vec2(p_boyutX, p_boyutY) / 100.0 * B;
  vec2 p = rot2(-p_aci) * (toUnit(here()) - p_merkez); float d;
  if (p_sekil < 1.5) d = (length(p / max(sz, vec2(1.0))) - 1.0) * min(sz.x, sz.y);
  else if (p_sekil < 2.5) { vec2 q = abs(p) - sz; d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0); }
  else if (p_sekil < 3.5) d = heartSDF(p / max(sz.x, 1.0)) * sz.x;
  else { float n = 5.0; float a = atan(p.x, -p.y); float rr = length(p) / max(sz.x, 1.0); float k = cos(PI / n) / cos(mod(a + PI / n, TAU / n) - PI / n); float sp = mix(0.45, 1.0, pow(abs(cos(a * n * 0.5)), 3.0)); d = (rr - sp) * sz.x * 0.6; }
  float w = max(p_yumusatm, 0.5 / u_s); float m = 1.0 - smoothstep(-w, w, d); if (p_ters > 0.5) m = 1.0 - m;
  o = s * m;
}
