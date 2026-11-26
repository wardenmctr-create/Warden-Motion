// cbmaphl
uniform sampler2D s_bolgeMask; uniform float p_bolgeMaskOn; uniform float p_dolguOpak, p_kontur, p_parlama, p_nabiz, p_nabizAcik, p_sinirlarKoru; uniform vec3 c_dolgu, c_konturReng;
float mAt(vec2 px) { return p_bolgeMaskOn > 0.5 ? texture(s_bolgeMask, clamp(boxUV(px), 0.0, 1.0)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); float m = mAt(here()); float pulse = p_nabizAcik > 0.5 ? 0.7 + 0.3 * sin(u_t * p_nabiz * TAU) : 1.0;
  float w = p_kontur * u_s; float mx = m, mn = m; for (int i = 0; i < 12; i++) { float a = float(i) * TAU / 12.0; float x = mAt(here() + vec2(cos(a), sin(a)) * max(w, 0.5)); mx = max(mx, x); mn = min(mn, x); }
  float ring = clamp(mx - mn, 0.0, 1.0); float g = 0.0; for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; g += mAt(here() + vec2(cos(a), sin(a)) * p_parlama * u_s); } g = g / 8.0 * (1.0 - m);
  vec4 c = overPre(vec4(c_dolgu, 1.0) * m * p_dolguOpak / 100.0 * pulse, s); c = overPre(vec4(c_konturReng, 1.0) * ring, c); c = overPre(vec4(c_dolgu, 1.0) * g * 0.6 * pulse, c); o = c; }
