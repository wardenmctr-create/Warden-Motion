// halation
uniform float p_parlakliEsig, p_esikYumu, p_yayilim, p_guc, p_kenarAgir, p_orijinalParlKoru, p_karisim; uniform vec3 c_haleReng;
float brightAt(vec2 px) { vec3 c = unpre(texPx(px)); float l = luma(c); return smoothstep(p_parlakliEsig / 100.0 - p_esikYumu / 200.0, p_parlakliEsig / 100.0 + p_esikYumu / 200.0, l) * texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); float R = max(p_yayilim, 0.5) * u_s; float acc = 0.0, ws = 0.0;
  for (int i = 0; i < 32; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 32.0); float w = exp(-r * r / (R * R) * 2.0); acc += brightAt(here() + vec2(cos(a), sin(a)) * r) * w; ws += w; }
  float h = acc / ws; float self = brightAt(here()); h = mix(h, max(h - self, 0.0), p_kenarAgir / 100.0); vec3 add = c_haleReng * h * p_guc / 100.0 * 1.5; vec3 c = unpre(s);
  vec3 r = p_karisim < 0.5 ? screenB(c, add) : p_karisim < 1.5 ? c + add : mix(c, c_haleReng, clamp(h * p_guc / 100.0, 0.0, 1.0)); if (p_orijinalParlKoru > 0.5) r = mix(r, c, self * 0.5);
  o = pre(clamp(r, 0.0, 1.0), max(s.a, clamp(h * p_guc / 100.0, 0.0, 1.0) * (1.0 - s.a) * 0.0 + s.a)); }
