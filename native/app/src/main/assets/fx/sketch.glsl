// sketch
uniform float p_cizgiGucu, p_kalemKali, p_taramaYogu, p_renkliKale; uniform vec3 c_kagitReng, c_kalemReng;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float e = sobel(here(), max(1.0, p_kalemKali * u_s * 0.6)) * p_cizgiGucu / 100.0 * 1.6;
  float l = luma(c); vec2 p = here() / max(u_s * 4.0, 2.0);
  float h1 = step(0.5, fract((p.x + p.y) * 0.7)) * (1.0 - smoothstep(0.35, 0.6, l)); float h2 = step(0.5, fract((p.x - p.y) * 0.7)) * (1.0 - smoothstep(0.1, 0.35, l));
  float ink = clamp(e + (h1 + h2) * p_taramaYogu / 100.0 * 0.5, 0.0, 1.0);
  vec3 pen = p_renkliKale > 0.5 ? c * 0.6 : c_kalemReng;
  o = pre(mix(c_kagitReng, pen, ink), s.a);
}
