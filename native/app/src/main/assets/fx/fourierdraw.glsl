// fourierdraw
uniform vec4 p_dv4[44]; float dvAt(int i) { return i < 0 || i >= 176 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_dvN, p_harmonik, p_ilerleme, p_dairelerGost, p_cizgi;
// Motor: harmoniklerle yeniden kurulmuş eğri (64 nokta) ve dönen dairelerin merkez/yarıçapları; veri yoksa örnek epicycle
vec2 P(int i) { if (p_dvN > 1.5) return vec2(dvAt(i * 2), dvAt(i * 2 + 1)); float u = float(i) / 63.0 * max(p_ilerleme / 100.0, 0.02) * 6.2832; return vec2(cos(u) * 50.0 + cos(3.0 * u) * 18.0, sin(u) * 50.0 - sin(3.0 * u) * 18.0); }
float seg(vec2 p, vec2 a, vec2 b) { vec2 ab = b - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float lw = max(p_cizgi, 0.2) * 0.5; float aa = 0.8 / u_s; float d = 1e5;
  for (int i = 0; i < 63; i++) d = min(d, seg(q, P(i), P(i + 1))); float v = 1.0 - smoothstep(lw - aa, lw + aa, d); vec4 res = overPre(vec4(1.0, 0.85, 0.3, 1.0) * v, s);
  if (p_dairelerGost > 0.5) { float c = 0.0; if (p_dvN > 1.5) { for (int k = 0; k < 16; k++) { vec2 cc = vec2(dvAt(128 + k * 3), dvAt(129 + k * 3)); float r = dvAt(130 + k * 3); if (r <= 0.0) continue; c = max(c, (1.0 - smoothstep(0.4, 0.4 + aa * 2.0, abs(length(q - cc) - r))) * 0.55); } }
    else { c = (1.0 - smoothstep(0.4, 0.4 + aa * 2.0, abs(length(q) - 50.0))) * 0.55; } res = overPre(vec4(0.6, 0.8, 1.0, 1.0) * c, res); }
  o = res; }
