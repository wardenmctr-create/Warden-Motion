// lathe3d
INCLUDE(_3d)
uniform float p_donusEkse, p_donusAcis, p_uclariKapa, p_yuzeyKali;
// Profil: katmanın sağ yarısının siluetini (alfa) dönüş ekseni etrafında çevirir
float prof(float r, float y) { vec2 B = boxU(); vec2 u = vec2(0.5 + r / B.x, 0.5 - y / B.y); if (u.x > 1.0 || u.y < 0.0 || u.y > 1.0) return 0.0; return texPx(boxPx(u)).a; }
float sdf(vec3 p) { vec3 a = p_donusEkse < 0.5 ? p.yxz : p_donusEkse < 1.5 ? p : p.xzy; float r = length(a.xz); float ang = degrees(atan(a.z, a.x)) + 180.0; if (ang > p_donusAcis + 0.01) return max(length(vec2(r, 0.0)) * sin(radians(min(ang - p_donusAcis, 90.0))), 1.0);
  float in_ = prof(r, a.y); float d = (0.5 - in_) * 6.0; if (p_yuzeyKali > 0.0) d = max(d, -(d + p_yuzeyKali)); return d; }
vec4 surf(vec3 p, vec3 n) { vec3 a = p_donusEkse < 0.5 ? p.yxz : p_donusEkse < 1.5 ? p : p.xzy; vec2 B = boxU(); vec2 u = vec2(0.5 + length(a.xz) / B.x, 0.5 - a.y / B.y); vec4 c = texPx(boxPx(clamp(u, 0.0, 1.0)));
  return vec4(c.a > 0.0 ? c.rgb / c.a : c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
