// rgbsplit
uniform vec2 p_kirmiziOfse, p_yesilOfse, p_maviOfse; uniform float p_ayrim, p_aci, p_kenarModu, p_alfayiBirl;
void main() {
  mat2 R = rot2(p_aci); float k = p_ayrim * u_s;
  float m = p_kenarModu < 0.5 ? 0.0 : p_kenarModu < 1.5 ? 3.0 : 1.0;
  vec4 r = texEdge(here() - R * p_kirmiziOfse * k, m), g = texEdge(here() - R * p_yesilOfse * k, m), b = texEdge(here() - R * p_maviOfse * k, m);
  float a = p_alfayiBirl > 0.5 ? max(r.a, max(g.a, b.a)) : texPx(here()).a;
  o = vec4(r.r, g.g, b.b, a);
}
