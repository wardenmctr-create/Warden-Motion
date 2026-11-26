// contourlines
uniform float p_cizgiSayi, p_aralik, p_kalinlik, p_faz, p_iceDogr, p_disaDogr; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); float sp = max(p_aralik * u_s, 1.0); float N = max(1.0, floor(p_cizgiSayi)); float R = sp * N + sp;
  float l = 0.0;
  if (p_iceDogr > 0.5 && s.a >= 0.5) { float d = innerDist(here(), R) - p_faz * u_s; float k = d / sp; if (k > 0.3 && k < N + 0.5) l = 1.0 - smoothstep(p_kalinlik * u_s * 0.5 - 0.6, p_kalinlik * u_s * 0.5 + 0.6, abs(fract(k + 0.5) - 0.5) * sp); }
  if (p_disaDogr > 0.5 && s.a < 0.5) { float d = outerDist(here(), R) + p_faz * u_s; float k = d / sp; if (k > 0.3 && k < N + 0.5) l = 1.0 - smoothstep(p_kalinlik * u_s * 0.5 - 0.6, p_kalinlik * u_s * 0.5 + 0.6, abs(fract(k + 0.5) - 0.5) * sp); }
  o = overPre(vec4(c_renk, 1.0) * l, s);
}
