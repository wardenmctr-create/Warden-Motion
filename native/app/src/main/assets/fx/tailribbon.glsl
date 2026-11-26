// tailribbon
uniform vec4 p_dv4[16]; float dvAt(int i) { return i < 0 || i >= 64 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform vec3 c_renk; uniform float p_dvN, p_kuyrukSure, p_basKali;
// Kuyruk noktaları (motor: nesnenin geçmiş konumları, katman biriminde) → başta kalın, sona doğru incelen şerit
vec2 P(int i) { if (p_dvN > 1.5) return vec2(dvAt(i * 2), dvAt(i * 2 + 1)); float t = u_t - float(i) * p_kuyrukSure / 15.0; return vec2(sin(t * 2.0) * boxU().x * 0.3, cos(t * 1.4) * boxU().y * 0.25); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); int N = p_dvN > 1.5 ? int(p_dvN / 2.0) : 16; float v = 0.0;
  for (int i = 0; i < 31; i++) { if (i + 1 >= N) break; vec2 a = P(i), b = P(i + 1); vec2 ab = b - a; float t = clamp(dot(q - a, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); float d = length(q - a - ab * t);
    float u = (float(i) + t) / float(N - 1); float w = p_basKali * 0.5 * (1.0 - u); v = max(v, (1.0 - smoothstep(w - 0.7 / u_s, w + 0.7 / u_s, d)) * (1.0 - u * 0.6)); }
  o = overPre(vec4(c_renk, 1.0) * v, s); }
