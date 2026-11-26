// contourstrips
GRADIENT(renkGeci)
uniform float p_seritSayi, p_faz, p_kenarKali, p_yumusakl; uniform vec3 c_kenarReng;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float n = max(2.0, floor(p_seritSayi)); float l = luma(unpre(s)) + p_faz / 100.0; float x = l * n;
  float band = floor(x) / max(n - 1.0, 1.0); float f = fract(x); float soft = p_yumusakl / 100.0;
  vec3 c = grad_renkGeci(fract(band)); if (soft > 0.0) c = mix(c, grad_renkGeci(fract(band + 1.0 / n)), smoothstep(1.0 - soft, 1.0, f));
  float g = length(vec2(dFdx(x), dFdy(x))); float e = 1.0 - smoothstep(p_kenarKali * u_s * 0.5 * g, p_kenarKali * u_s * 0.5 * g + g, min(f, 1.0 - f));
  c = mix(c, c_kenarReng, e * step(0.01, p_kenarKali));
  o = pre(c, s.a);
}
