// flowlines
INCLUDE(_chart)
uniform float p_kalinlik, p_okHizi, p_bagEgri, p_ciftYon;
// Satır: x1 %, y1 %, x2 %, y2 %, değer → yay (jeodezik) ya da düz çizgi; kalınlık değerle, üzerinde akan ok işaretleri
vec2 bez(vec2 a, vec2 c, vec2 b, float t) { return mix(mix(a, c, t), mix(c, b, t), t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = here(); int N = int(min(dR(), 32.0)); float M = 1e-6; for (int r = 0; r < 32; r++) { if (r >= N) break; M = max(M, abs(dat(float(r), 4.0))); } vec4 res = s;
  for (int r = 0; r < 32; r++) { if (r >= N) break; vec2 A = boxPx(vec2(dat(float(r), 0.0), dat(float(r), 1.0)) / 100.0), B = boxPx(vec2(dat(float(r), 2.0), dat(float(r), 3.0)) / 100.0); if (dC() < 5.0) { A = boxPx(vec2(0.15 + 0.1 * float(r), 0.75)); B = boxPx(vec2(0.85 - 0.08 * float(r), 0.3)); }
    vec2 C = (A + B) * 0.5 + (p_bagEgri < 0.5 ? vec2(-(B - A).y, (B - A).x) * 0.25 : vec2(0.0)); float w = max(abs(dat(float(r), 4.0)) / M * p_kalinlik * u_s, 1.0) * 0.5; float bd = 1e5, bt = 0.0; vec2 pv = A;
    for (int k = 1; k <= 20; k++) { float t = float(k) / 20.0; vec2 pt = bez(A, C, B, t); vec2 ab = pt - pv; float tt = clamp(dot(q - pv, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); float d = length(q - pv - ab * tt); if (d < bd) { bd = d; bt = (float(k - 1) + tt) / 20.0; } pv = pt; }
    if (bd > w + 1.5) continue; float L = length(B - A); float ph = fract(bt * L / max(24.0 * u_s, 1.0) - u_t * p_okHizi / 24.0); float ph2 = fract(bt * L / max(24.0 * u_s, 1.0) + u_t * p_okHizi / 24.0 + 0.5);
    float arrow = smoothstep(0.55, 0.6, ph) * (1.0 - smoothstep(0.85, 0.9, ph)); if (p_ciftYon > 0.5) arrow = max(arrow, smoothstep(0.55, 0.6, ph2) * (1.0 - smoothstep(0.85, 0.9, ph2)) * 0.8);
    float a = 1.0 - smoothstep(w - 0.8, w + 0.8, bd); res = overPre(vec4(mix(vec3(0.25, 0.65, 1.0), vec3(1.0), arrow * 0.8), 0.85) * a, res); }
  o = res; }
