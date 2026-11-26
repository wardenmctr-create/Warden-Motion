// flagpole3d
INCLUDE(_3d)
uniform sampler2D s_bayrakKatm, s_bayrakGors; uniform float p_bayrakKatmOn, p_bayrakGorsOn;
uniform vec2 p_bayrakBoyu; uniform float p_enBoyOran, p_sabitKena, p_dalgaYuks, p_dalgaBoyu, p_ruzgarHizi, p_kumasSert, p_diregiGost, p_direkYuks, p_direkKali, p_direkMalz, p_direkTepe, p_bayraginYuks, p_baglantiIpi, p_ipKali; uniform vec3 c_direkReng;
vec2 FS() { vec2 s = max(p_bayrakBoyu, vec2(10.0)); if (p_enBoyOran > 0.5) s.y = s.x * boxU().y / max(boxU().x, 1.0); return s; }
float poleX() { return -FS().x * 0.5; }
float topY() { return p_direkYuks * 0.5; }
float flagW(float u) { return sin(TAU * (u * FS().x / max(p_dalgaBoyu, 1.0) - p_ruzgarHizi * u_t)) * p_dalgaYuks * pow(u, mix(0.6, 1.6, p_kumasSert / 100.0)); }
vec3 flagLocal(vec3 p) { float y0 = topY() - FS().y * 0.5 - (topY() * 2.0 - FS().y) * (1.0 - p_bayraginYuks / 100.0); return vec3(p.x - poleX(), p.y - y0, p.z); }
float flagD(vec3 p) { vec3 f = flagLocal(p); float u = clamp(f.x / FS().x, 0.0, 1.0); float z = f.z - flagW(u); vec3 b = vec3(FS().x * 0.5, FS().y * 0.5, 0.8); vec3 q = abs(vec3(f.x - FS().x * 0.5, f.y, z)) - b; return (length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0)) * 0.6; }
float poleD(vec3 p) { if (p_diregiGost < 0.5) return 1e5; vec3 c = p - vec3(poleX() - p_direkKali * 0.5, 0.0, 0.0); float r = p_direkKali * 0.5; float d = max(length(c.xz) - r, abs(c.y) - p_direkYuks * 0.5);
  vec3 tp = c - vec3(0.0, topY() + r * 1.2, 0.0); if (p_direkTepe < 0.5) d = min(d, length(tp) - r * 1.6); else if (p_direkTepe < 1.5) d = min(d, max(length(tp.xz) - r * 1.5, abs(tp.y) - r * 0.4)); else if (p_direkTepe < 2.5) d = min(d, max(length(tp.xz) - r * (1.2 - (tp.y + r) / (r * 4.0)) * 1.2, abs(tp.y) - r * 2.0));
  if (p_baglantiIpi > 0.5) { vec3 rp = c - vec3(r * 1.6, 0.0, 0.0); d = min(d, max(length(rp.xz) - max(p_ipKali * 0.5, 0.3), abs(rp.y) - p_direkYuks * 0.48)); } return d; }
float sdf(vec3 p) { return min(flagD(p), poleD(p)); }
vec4 surf(vec3 p, vec3 n) { if (flagD(p) < poleD(p)) { vec3 f = flagLocal(p); vec2 uv = vec2(f.x / FS().x, 0.5 - f.y / FS().y);
    vec4 c = p_bayrakKatmOn > 0.5 ? texture(s_bayrakKatm, clamp(uv, 0.0, 1.0)) : p_bayrakGorsOn > 0.5 ? texture(s_bayrakGors, clamp(uv, 0.0, 1.0)) : layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.9), 1.0); }
  vec3 pc = c_direkReng; if (p_direkMalz > 0.5 && p_direkMalz < 1.5) pc *= 0.8 + 0.3 * vnoise(vec2(p.y * 0.08, atan(p.x, p.z) * 3.0)); return vec4(pc, 1.0); }
void main() { o = render3d(vec3(0.0)); }
