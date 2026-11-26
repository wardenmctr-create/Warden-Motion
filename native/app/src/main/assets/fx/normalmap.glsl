// normalmap
uniform float p_yuksekliKayn, p_yuksekliTersCevi, p_yukseltiGucu, p_ornekAral, p_yumusatm, p_normalBici, p_alfayiKoru, p_onizleme;
float hAt(vec2 px) { vec4 c = texPx(px); vec3 u = unpre(c); float v = p_yuksekliKayn < 0.5 ? luma(u) : p_yuksekliKayn < 1.5 ? c.a : p_yuksekliKayn < 2.5 ? u.r : p_yuksekliKayn < 3.5 ? u.g : u.b; return p_yuksekliTersCevi > 0.5 ? 1.0 - v : v; }
float hS(vec2 px) { float r = p_yumusatm * u_s; if (r < 0.5) return hAt(px); return (hAt(px) * 2.0 + hAt(px + vec2(r, 0.0)) + hAt(px - vec2(r, 0.0)) + hAt(px + vec2(0.0, r)) + hAt(px - vec2(0.0, r))) / 6.0; }
void main() { vec4 s = texture(u_tex, v_uv); float e = max(p_ornekAral, 0.5) * u_s; float k = p_yukseltiGucu / 10.0; float dx = (hS(here() + vec2(e, 0.0)) - hS(here() - vec2(e, 0.0))) * k; float dy = (hS(here() + vec2(0.0, e)) - hS(here() - vec2(0.0, e))) * k;
  vec3 n = normalize(vec3(-dx, p_normalBici < 0.5 ? dy : -dy, 1.0)); float a = p_alfayiKoru > 0.5 ? s.a : 1.0;
  if (p_onizleme > 0.5) { float l = max(dot(n, normalize(vec3(-0.5, 0.5, 0.8))), 0.0); o = pre(unpre(s) * (0.3 + l), a); return; } o = pre(n * 0.5 + 0.5, a); }
