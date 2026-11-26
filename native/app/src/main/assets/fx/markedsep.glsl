// markedsep
uniform sampler2D s_onIsaret, s_arkaIsaret; uniform float p_onIsaretOn, p_arkaIsaretOn, p_yineleme, p_yumusatm;
void main() { vec4 s = texture(u_tex, v_uv); if (p_onIsaretOn < 0.5 || p_arkaIsaretOn < 0.5) { o = s; return; } vec3 fg = vec3(0.0), bg = vec3(0.0); float nf = 0.0, nb = 0.0;
  for (int j = 0; j < 12; j++) for (int i = 0; i < 12; i++) { vec2 uv = (vec2(i, j) + 0.5) / 12.0; vec3 c = unpre(texPx(boxPx(uv))); float f = texture(s_onIsaret, uv).a, b = texture(s_arkaIsaret, uv).a; fg += c * f; nf += f; bg += c * b; nb += b; }
  fg /= max(nf, 1e-3); bg /= max(nb, 1e-3); float R = max(p_yumusatm, 0.5) * u_s; float acc = 0.0; int K = int(clamp(p_yineleme, 1.0, 30.0)); int S = min(16, 4 + K);
  for (int i = 0; i < 16; i++) { if (i >= S) break; float a = float(i) * 2.39996; float r = R * sqrt(float(i) / float(S)); vec3 c = unpre(texPx(here() + vec2(cos(a), sin(a)) * r)); acc += step(length(c - fg), length(c - bg)); }
  float m = acc / float(S); vec2 b0 = clamp(boxUV(here()), 0.0, 1.0); m = max(m, texture(s_onIsaret, b0).a); m = min(m, 1.0 - texture(s_arkaIsaret, b0).a); o = s * smoothstep(0.3, 0.7, m); }
