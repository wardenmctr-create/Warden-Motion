// cbmaphl
uniform sampler2D s_bolgeMask, s_dolguGorsel; uniform float p_bolgeMaskOn, p_dolguGorselOn;
uniform float p_dolguOpak, p_kontur, p_parlama, p_nabiz, p_nabizAcik, p_sinirlarKoru, p_dolguBicim, p_taramaAci, p_taramaAral, p_taramaKalin, p_sinirKirp, p_sinirCiz, p_cizimIler, p_dolguIler, p_konturSabit;
uniform vec3 c_dolgu, c_konturReng, c_dolgu2;
float mAt(vec2 px) { return p_bolgeMaskOn > 0.5 ? texture(s_bolgeMask, clamp(boxUV(px), 0.0, 1.0)).a : texPx(px).a; }
void main() {
  vec4 s = texture(u_tex, v_uv); float m = mAt(here()); float pulse = p_nabizAcik > 0.5 ? 0.7 + 0.3 * sin(u_t * p_nabiz * TAU) : 1.0; float ks = p_konturSabit > 0.5 ? 1.0 : u_s;
  float w = p_kontur * ks; float mx = m, mn = m; for (int i = 0; i < 12; i++) { float a = float(i) * TAU / 12.0; float x = mAt(here() + vec2(cos(a), sin(a)) * max(w, 0.5)); mx = max(mx, x); mn = min(mn, x); }
  float ring = clamp(mx - mn, 0.0, 1.0);
  if (p_sinirCiz > 0.5) { vec2 q = toUnit(here()); float ang = fract(atan(q.y, q.x) / TAU + 0.25); ring *= step(ang, p_cizimIler / 100.0); }
  float g = 0.0; for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; g += mAt(here() + vec2(cos(a), sin(a)) * p_parlama * u_s); } g = g / 8.0 * (1.0 - m);
  vec3 fc = c_dolgu; vec2 q = toUnit(here());
  if (p_dolguBicim > 0.5 && p_dolguBicim < 1.5) fc = mix(c_dolgu, c_dolgu2, clamp(boxUV(here()).y, 0.0, 1.0));
  else if ((p_dolguBicim > 1.5 && p_dolguBicim < 2.5) || p_dolguBicim > 4.5) fc = p_dolguGorselOn > 0.5 ? unpre(texture(s_dolguGorsel, clamp(boxUV(here()), 0.0, 1.0))) : c_dolgu;
  float pat = 1.0; if (p_dolguBicim > 2.5 && p_dolguBicim < 3.5) { vec2 r = rot2(-p_taramaAci) * q; pat = 1.0 - smoothstep(p_taramaKalin * 0.5, p_taramaKalin * 0.5 + 0.8, abs(mod(r.y, max(p_taramaAral, 1.0)) - p_taramaAral * 0.5)); }
  else if (p_dolguBicim > 3.5 && p_dolguBicim < 4.5) { vec2 f = mod(q, max(p_taramaAral, 1.0)) - p_taramaAral * 0.5; pat = 1.0 - smoothstep(p_taramaKalin * 0.5, p_taramaKalin * 0.5 + 0.8, length(f)); }
  float fill = m * p_dolguOpak / 100.0 * pulse * pat * p_dolguIler / 100.0; if (p_sinirKirp < 0.5) fill = max(fill, mx * p_dolguOpak / 100.0 * pat * 0.5);
  vec4 c = overPre(vec4(fc, 1.0) * fill, s); c = overPre(vec4(c_konturReng, 1.0) * ring, c); c = overPre(vec4(c_dolgu, 1.0) * g * 0.6 * pulse, c); o = c;
}
