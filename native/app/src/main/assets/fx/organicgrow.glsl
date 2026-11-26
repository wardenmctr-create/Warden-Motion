// organicgrow
uniform sampler2D s_anl; uniform float p_anlOn, p_cizgiKali; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } vec2 b = clamp(boxUV(here()), 0.0, 1.0); float g = 0.0; float r = max(p_cizgiKali, 0.5) * 0.002;
  for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; g = max(g, texture(s_anl, b + vec2(cos(a), sin(a)) * r).r); } g = max(g, texture(s_anl, b).r); o = overPre(vec4(c_renk, 1.0) * smoothstep(0.2, 0.6, g), s); }
