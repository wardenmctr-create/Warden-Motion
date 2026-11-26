// diffmap
uniform sampler2D s_karsilas; uniform float p_karsilasOn, p_renkMetr, p_esik;
void main() { vec4 s = texture(u_tex, v_uv); if (p_karsilasOn < 0.5) { o = s; return; } vec3 a = unpre(s), b = unpre(texture(s_karsilas, clamp(boxUV(here()), 0.0, 1.0)));
  float d = p_renkMetr < 0.5 ? length(a - b) * 1.2 : p_renkMetr < 1.5 ? length(a - b) / 1.732 : abs(luma(a) - luma(b)); float v = smoothstep(p_esik / 100.0, 1.0, d) ; vec3 heat = v <= 0.0 ? vec3(0.0) : hsv2rgb(vec3(0.66 - clamp(v * 2.0, 0.0, 1.0) * 0.66, 1.0, 1.0)); o = vec4(heat, 1.0) * max(s.a, 1.0); }
