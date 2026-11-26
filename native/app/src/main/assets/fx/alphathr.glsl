// alphathr
uniform float p_esik, p_gecis, p_ters, p_saydamRgbTemi;
void main() { vec4 s = texture(u_tex, v_uv); float w = max(p_gecis / 200.0, 0.002); float a = smoothstep(p_esik / 100.0 - w, p_esik / 100.0 + w, s.a); if (p_ters > 0.5) a = 1.0 - a;
  vec3 c = s.a > 0.0 ? unpre(s) : vec3(0.0); if (p_saydamRgbTemi > 0.5 && a < 0.01) c = vec3(0.0); o = pre(c, a); }
