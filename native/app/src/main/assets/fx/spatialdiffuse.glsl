// spatialdiffuse
uniform float p_yayilim, p_parlakliAgir, p_karisim;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = srgb2lin(unpre(s)); float R = max(p_yayilim, 0.5) * u_s; vec3 acc = vec3(0.0); float ws = 0.0;
  for (int i = 0; i < 32; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 32.0); vec3 n = srgb2lin(unpre(texPx(here() + vec2(cos(a), sin(a)) * r))); float w = exp(-r / R * 2.0) * mix(1.0, luma(n) * 3.0, p_parlakliAgir / 100.0); acc += n * w; ws += w; }
  vec3 d = acc / max(ws, 1e-4); o = pre(clamp(lin2srgb(mix(c, max(c, d), p_karisim / 100.0)), 0.0, 1.0), s.a); }
