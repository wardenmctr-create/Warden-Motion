// rgbsplit
uniform vec2 p_kirmiziOfse, p_yesilOfse, p_maviOfse, p_radMerkez; uniform float p_ayrim, p_aci, p_kenarModu, p_alfayiBirl, p_ayrBicim, p_uzakAyr, p_rOpak, p_gOpak, p_bOpak, p_alfaSinir;
void main() {
  mat2 R = rot2(p_aci); float k = p_ayrim * u_s; float m = p_kenarModu < 0.5 ? 0.0 : p_kenarModu < 1.5 ? 3.0 : 1.0;
  vec2 dr = R * p_kirmiziOfse * k, dg = R * p_yesilOfse * k, db = R * p_maviOfse * k;
  if (p_ayrBicim > 0.5) { vec2 rel = here() - fromUnit(p_radMerkez); float L = length(boxU() * u_s) * 0.5; float f = clamp(length(rel) / max(L, 1.0), 0.0, 2.0) * p_uzakAyr / 100.0; vec2 dir = length(rel) > 0.01 ? normalize(rel) : vec2(0.0);
    if (p_ayrBicim > 1.5) dir = vec2(-dir.y, dir.x); dr = dir * p_kirmiziOfse.x * k * f; dg = dir * p_yesilOfse.x * k * f; db = dir * p_maviOfse.x * k * f; }
  vec4 r = texEdge(here() - dr, m), g = texEdge(here() - dg, m), b = texEdge(here() - db, m); vec4 s = texPx(here());
  vec3 rgb = vec3(r.r * p_rOpak, g.g * p_gOpak, b.b * p_bOpak) / 100.0;
  float a = p_alfayiBirl > 0.5 ? max(r.a * p_rOpak, max(g.a * p_gOpak, b.a * p_bOpak)) / 100.0 : s.a; if (p_alfaSinir > 0.5) a = s.a;
  o = vec4(min(rgb, vec3(a)), a);
}
