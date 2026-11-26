// chain3d
INCLUDE(_3d)
uniform float p_halkaSayi, p_halkaKali, p_halkaAral, p_ardisikHalkDonu, p_halkaBici, p_yol, p_sarkma, p_sallanma, p_sallanmaBuyu, p_sallanmaHizi; uniform vec2 p_halkaBoyu, p_baslangiNokt, p_bitisNokt;
float linkD(vec3 p) { vec2 S = max(p_halkaBoyu, vec2(4.0)) * 0.5; float th = max(p_halkaKali, 0.5) * 0.5; vec2 q = p.xy;
  float d2 = p_halkaBici < 0.5 ? length(vec2(max(abs(q.x) - (S.x - S.y * 0.0) * 0.0, 0.0), max(abs(q.y) - (S.y - S.x), 0.0))) - S.x + th : p_halkaBici < 1.5 ? length(q) - S.x + th : max(abs(q.x) - S.x + th, abs(q.y) - S.y + th);
  if (p_halkaBici < 0.5) { vec2 r = vec2(abs(q.x), max(abs(q.y) - (S.y - S.x), 0.0)); d2 = length(r) - (S.x - th); }
  return length(vec2(d2, p.z)) - th; }
vec2 pathPt(float s, out vec2 tg) { vec2 A = p_baslangiNokt, B = p_bitisNokt; if (length(B - A) < 1.0) { A = vec2(-boxU().x * 0.4, 0.0); B = vec2(boxU().x * 0.4, 0.0); }
  vec2 d = B - A; float L = length(d); vec2 u = d / L, nrm = vec2(-u.y, u.x); vec2 pt;
  if (p_yol < 0.5) { pt = A + u * s; tg = u; }
  else if (p_yol < 1.5) { float ang = (s / L - 0.5) * 2.0; pt = A + u * s - nrm * (1.0 - ang * ang) * L * 0.25; tg = normalize(u + nrm * ang * 2.0 * 0.25 * 2.0); }
  else if (p_yol < 2.5) { float R = L / TAU; float a = s / R; pt = (A + B) * 0.5 + vec2(cos(a), sin(a)) * R; tg = vec2(-sin(a), cos(a)); }
  else { float x = s / L * 2.0 - 1.0; float sw = p_sallanma > 0.5 ? sin(u_t * p_sallanmaHizi * TAU) * p_sallanmaBuyu : 0.0; pt = A + u * s + vec2(0.0, (1.0 - x * x) * p_sarkma) + vec2(sw * (1.0 - x * x), 0.0); tg = normalize(u + vec2(0.0, -2.0 * x / L * 2.0 * p_sarkma)); }
  return pt; }
float sdf(vec3 p) { float N = clamp(floor(p_halkaSayi), 1.0, 60.0); float sp = max(p_halkaBoyu.y - p_halkaKali * 1.5, 2.0) * (1.0 - p_halkaAral / 200.0); float d = 1e5;
  vec2 P = vec2(p.x, -p.y); float best = 1e9; float bi = 0.0;
  for (int i = 0; i < 60; i++) { if (float(i) >= N) break; vec2 tg; vec2 c = pathPt(float(i) * sp, tg); float dd = length(P - c); if (dd < best) { best = dd; bi = float(i); } }
  for (int k = -1; k <= 1; k++) { float i = bi + float(k); if (i < 0.0 || i >= N) continue; vec2 tg; vec2 c = pathPt(i * sp, tg); vec2 lq = P - c; float an = atan(tg.y, tg.x) - PI * 0.5;
    vec3 l = vec3(rot2(degrees(an)) * lq * vec2(1.0, 1.0), p.z); l.y = -l.y; float ra = radians(p_ardisikHalkDonu) * mod(i, 2.0); l.xz = mat2(cos(ra), sin(ra), -sin(ra), cos(ra)) * l.xz; d = min(d, linkD(l)); }
  return d; }
vec4 surf(vec3 p, vec3 n) { return vec4(c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
