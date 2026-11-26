// pipe3d
INCLUDE(_3d)
uniform float p_disCap, p_uzunluk, p_duvarKali, p_kesit, p_boruYolu, p_bukulmeAcis, p_bukulmeYari, p_koniklik, p_baslangiKapa, p_bitisKapa, p_icYuzeGost; uniform vec3 c_icYuzeReng;
float sec(vec2 q, float r) { if (p_kesit < 0.5) return length(q) - r; if (p_kesit < 1.5) { vec2 d = abs(q) - r; return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0); } vec2 a = abs(q); return max(a.x * 0.866 + a.y * 0.5, a.y) - r; }
vec2 pipeCoord(vec3 p, out float s) { float L = max(p_uzunluk, 1.0);
  if (p_boruYolu < 0.5 || (p_boruYolu < 1.5 && abs(p_bukulmeAcis) < 0.5)) { s = p.y / L + 0.5; return p.xz; }
  if (p_boruYolu < 1.5) { float R = max(p_bukulmeYari, p_disCap); vec2 c = vec2(R, 0.0); vec2 q = p.xy - vec2(-R, -L * 0.0); float a = atan(q.y, q.x); float A = radians(p_bukulmeAcis);
    float ac = clamp(a, -A * 0.5, A * 0.5); s = ac / A + 0.5; vec2 on = vec2(cos(ac), sin(ac)) * R; return vec2(length(q) - R, p.z) + (a != ac ? vec2(1e3) : vec2(0.0)); }
  float R = max(p_bukulmeYari, p_disCap); float pitch = max(p_disCap * 2.5, 10.0); float a = atan(p.z, p.x); float yy = p.y - a / TAU * pitch; float k = floor(yy / pitch + 0.5); float y0 = k * pitch + a / TAU * pitch; s = (y0 / L) + 0.5; return vec2(length(p.xz) - R, p.y - y0); }
float sdf(vec3 p) { float s; vec2 q = pipeCoord(p, s); float r = max(p_disCap * 0.5, 1.0) * mix(1.0, 1.0 - p_koniklik / 100.0, clamp(s, 0.0, 1.0));
  float outer = sec(q, r); float wall = max(outer, -(sec(q, max(r - max(p_duvarKali, 0.5), 0.1)))); float caps = (p_baslangiKapa > 0.5 || p_bitisKapa > 0.5) ? outer : 1e5;
  float d = wall; float ends = max(-s, s - 1.0) * max(p_uzunluk, 1.0);
  if (p_baslangiKapa > 0.5) d = min(d, max(caps, max(-s * p_uzunluk, (s - 0.01) * p_uzunluk))); if (p_bitisKapa > 0.5) d = min(d, max(caps, max((0.99 - s) * p_uzunluk, (s - 1.0) * p_uzunluk)));
  return max(d, ends); }
vec4 surf(vec3 p, vec3 n) { float s; vec2 q = pipeCoord(p, s); float r = max(p_disCap * 0.5, 1.0); bool inner = sec(q, r) < -max(p_duvarKali, 0.5) * 0.5;
  if (inner && p_icYuzeGost > 0.5) return vec4(c_icYuzeReng, 1.0); vec4 c = layerAt(vec2(atan(q.y, q.x) / TAU + 0.5, 1.0 - s)); return vec4(c.a > 0.0 ? c.rgb / c.a : c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
