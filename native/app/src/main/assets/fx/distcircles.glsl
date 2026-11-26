// distcircles
INCLUDE(_chart)
uniform vec2 p_merkez; uniform float p_mesafe, p_cember, p_mesafeEtik;
// Eşdikdörtgen harita üzerinde gerçek büyük çember uzaklığı (km) ile eş uzaklık halkaları; halka üstünde mesafe etiketi
float gc(vec2 a, vec2 b) { vec2 r1 = radians(a), r2 = radians(b); float h = pow(sin((r2.y - r1.y) * 0.5), 2.0) + cos(r1.y) * cos(r2.y) * pow(sin((r2.x - r1.x) * 0.5), 2.0); return 2.0 * 6371.0 * asin(min(1.0, sqrt(h))); }
vec2 ll(vec2 b) { return vec2((b.x - 0.5) * 360.0, (0.5 - b.y) * 180.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 c = ll(boxUV(fromUnit(p_merkez))); float d = gc(c, ll(b)); float step2 = max(p_mesafe, 1.0) * 10.0; float k = d / step2; float res2 = 0.0; vec4 res = s;
  if (k < p_cember + 0.5) { float fw = fwidth(k) + 1e-5; res2 = 1.0 - smoothstep(0.0, fw * 1.5, abs(k - floor(k + 0.5))); res2 *= step(0.5, k); }
  res = overPre(vec4(1.0, 0.85, 0.3, 1.0) * res2, res); res = overPre(vec4(1.0, 0.3, 0.25, 1.0) * (1.0 - smoothstep(3.0, 4.5, length((b - boxUV(fromUnit(p_merkez))) * u_box.zw))), res);
  if (p_mesafeEtik > 0.5) for (int i = 1; i <= 20; i++) { if (float(i) > p_cember) break; float latN = c.y + degrees(float(i) * step2 / 6371.0); if (latN > 89.0) break; vec2 lb = vec2(c.x / 360.0 + 0.5, 0.5 - latN / 180.0);
    vec2 lp = (b - lb - vec2(0.0, -0.025)) * u_box.zw / (8.0 * u_s); res = overPre(vec4(1.0) * numAt(lp, float(i) * step2), res); }
  o = res; }
