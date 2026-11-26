// evolute
uniform vec4 p_dv4[64]; float dvAt(int i) { return i < 0 || i >= 256 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_dvN, p_tur, p_ilerleme, p_cizgi;
// Motor: temel eğri (soluk) + evolüt/involüt eğrisi, ilerlemeye kadar
vec2 A(int i) { if (p_dvN > 1.5) return vec2(dvAt(i * 2), dvAt(i * 2 + 1)); float u = float(i) / 64.0 * 6.2832; return vec2(cos(u) * 70.0, sin(u) * 40.0); }
vec2 B(int i) { if (p_dvN > 1.5) return vec2(dvAt(128 + i * 2), dvAt(129 + i * 2)); float u = float(i) / 64.0 * 6.2832; float c = 70.0 * 70.0 - 40.0 * 40.0; return p_tur < 0.5 ? vec2(c / 70.0 * pow(cos(u), 3.0), -c / 40.0 * pow(sin(u), 3.0)) : A(i) - vec2(-sin(u), cos(u)) * u * 12.0; }
float seg(vec2 p, vec2 a, vec2 b) { vec2 ab = b - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float lw = max(p_cizgi, 0.2) * 0.5; float aa = 0.8 / u_s; float d0 = 1e5, d1 = 1e5; int lim = int(p_ilerleme / 100.0 * 63.0);
  for (int i = 0; i < 64; i++) { d0 = min(d0, seg(q, A(i), A((i + 1) % 64))); if (i < lim) d1 = min(d1, seg(q, B(i), B(i + 1))); }
  vec4 res = overPre(vec4(0.7, 0.75, 0.85, 1.0) * (1.0 - smoothstep(lw * 0.6 - aa, lw * 0.6 + aa, d0)) * 0.6, s); o = overPre(vec4(1.0, 0.5, 0.3, 1.0) * (1.0 - smoothstep(lw - aa, lw + aa, d1)), res); }
