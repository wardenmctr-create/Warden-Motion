// contourgrad
GRADIENT(gecis)
uniform float p_kenarMesa, p_yumusakl, p_tersCevi, p_icDis;
void main() {
  vec4 s = texture(u_tex, v_uv); float R = max(p_kenarMesa * u_s, 1.0);
  float din = innerDist(here(), R) / R, dout = outerDist(here(), R) / R;
  float x; float a;
  if (p_icDis < 0.5) { if (s.a <= 0.0) { o = s; return; } x = din; a = s.a; }
  else if (p_icDis < 1.5) { x = dout; a = s.a > 0.5 ? 0.0 : (1.0 - step(0.999, dout)); }
  else { x = s.a > 0.5 ? din : dout; a = max(s.a, 1.0 - step(0.999, dout)); }
  x = pow(x, mix(2.0, 0.5, p_yumusakl / 100.0)); if (p_tersCevi > 0.5) x = 1.0 - x;
  vec4 g = pre(grad_gecis(x), a);
  o = p_icDis > 0.5 && p_icDis < 1.5 ? overPre(s, g) : g;
}
