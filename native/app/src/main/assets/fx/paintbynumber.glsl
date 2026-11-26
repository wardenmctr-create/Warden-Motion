// paintbynumber
uniform float p_renkSayi, p_enKucuBolg, p_sinirYumu, p_mod, p_sinirKali, p_numaralaGost, p_yaziBuyu, p_boyamaIler, p_boyamaSira; uniform vec3 c_sinirReng;
float k3() { return max(2.0, floor(pow(max(p_renkSayi, 2.0), 1.0 / 3.0) + 0.5)); }
vec3 qz(vec3 c) { float k = k3(); return floor(c * (k - 1.0) + 0.5) / (k - 1.0); }
vec3 regionCol(vec2 px) { vec3 acc = vec3(0.0); float r = p_enKucuBolg * u_s * 0.15 + p_sinirYumu * 0.05 * u_s; for (int i = 0; i < 5; i++) { float a = float(i) * 1.2566; acc += unpre(texPx(px + vec2(cos(a), sin(a)) * r)); } return qz(acc / 5.0); }
float idx(vec3 c) { float k = k3(); vec3 i = floor(c * (k - 1.0) + 0.5); return i.r + i.g * k + i.b * k * k; }
float seg7(vec2 p, int d) { int m[10] = int[10](63, 6, 91, 79, 102, 109, 125, 7, 127, 111); int b = m[d % 10]; float r = 0.0;
  vec2 a[7] = vec2[7](vec2(0.0, 0.8), vec2(0.45, 0.4), vec2(0.45, -0.4), vec2(0.0, -0.8), vec2(-0.45, -0.4), vec2(-0.45, 0.4), vec2(0.0, 0.0));
  for (int i = 0; i < 7; i++) { if ((b / int(pow(2.0, float(i)))) % 2 == 0) continue; vec2 q = p - a[i]; bool hz = i == 0 || i == 3 || i == 6; vec2 e = hz ? vec2(0.36, 0.08) : vec2(0.08, 0.34); vec2 dd = abs(q) - e; r = max(r, 1.0 - smoothstep(0.0, 0.06, max(dd.x, dd.y))); } return r; }
void main() { vec4 s = texture(u_tex, v_uv); vec3 rc = regionCol(here()); float id = idx(rc); float bw = max(p_sinirKali, 0.3) * u_s; float border = 0.0;
  for (int i = 0; i < 4; i++) { vec2 o2 = (i == 0 ? vec2(1, 0) : i == 1 ? vec2(0, 1) : i == 2 ? vec2(-1, 0) : vec2(0, -1)) * bw; if (idx(regionCol(here() + o2)) != id) border = 1.0; }
  float order = p_boyamaSira < 0.5 ? id / (k3() * k3() * k3()) : p_boyamaSira < 1.5 ? 1.0 - luma(rc) : hash1(vec2(id, 3.0)); bool painted = p_mod > 0.5 && (p_mod < 1.5 || order < p_boyamaIler / 100.0);
  vec3 c = painted ? rc : vec3(1.0);
  if (p_numaralaGost > 0.5 && !painted) { float cs = max(p_yaziBuyu * 3.0, 12.0) * u_s; vec2 cc = (floor(here() / cs) + 0.5) * cs; vec3 cr = regionCol(cc); if (idx(cr) == id && idx(regionCol(cc + vec2(cs * 0.3, 0.0))) == id) {
      vec2 lp = (here() - cc) / (p_yaziBuyu * u_s * 0.5); int n = int(mod(id, 99.0)) + 1; float dg = n < 10 ? seg7(lp, n) : max(seg7(lp * vec2(1.0, 1.0) + vec2(0.7, 0.0), n / 10), seg7(lp - vec2(0.7, 0.0), n % 10)); c = mix(c, c_sinirReng, dg * 0.8); } }
  c = mix(c, c_sinirReng, border); o = pre(c, s.a); }
