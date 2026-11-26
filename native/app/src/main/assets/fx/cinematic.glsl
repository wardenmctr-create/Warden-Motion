// cinematic
uniform vec3 c_golgeReng, c_acikTonReng; uniform float p_golgeGucu, p_acikTonGucu, p_ortaNokt, p_notrRenkKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = luma(c); float m = p_ortaNokt / 100.0;
  float wS = 1.0 - smoothstep(0.0, m * 1.6, l), wH = smoothstep(m * 0.6, 1.0, l);
  float sat = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b)); float k = p_notrRenkKoru > 0.5 ? mix(0.4, 1.0, smoothstep(0.0, 0.3, sat)) : 1.0;
  vec3 r = mix(c, softLightB(c, c_golgeReng), wS * p_golgeGucu / 100.0 * k); r = mix(r, softLightB(r, c_acikTonReng), wH * p_acikTonGucu / 100.0 * k);
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
