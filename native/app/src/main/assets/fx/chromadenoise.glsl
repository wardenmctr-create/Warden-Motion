// chromadenoise
uniform float p_kromaYari, p_renkEsig, p_parlakliKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float L = luma(c); float R = max(p_kromaYari, 0.3) * u_s; vec3 acc = c - L; float ws = 1.0;
  for (int i = 0; i < 24; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 24.0); vec3 n = unpre(texPx(here() + vec2(cos(a), sin(a)) * r)); float w = 1.0 - smoothstep(p_renkEsig / 100.0 * 0.5, p_renkEsig / 100.0, length((n - luma(n)) - (c - L))); acc += (n - luma(n)) * w; ws += w; }
  vec3 ch = acc / ws; vec3 r = L + ch; if (p_parlakliKoru < 0.5) r = mix(r, unpre(texture(u_tex, v_uv)), 0.0); o = pre(clamp(r, 0.0, 1.0), s.a); }
