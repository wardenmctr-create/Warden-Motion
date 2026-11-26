// subsurface
uniform sampler2D s_kalinlikHari; uniform vec3 c_icRenk; uniform float p_kalinlikHariOn, p_sacilma, p_isikAcis, p_guc;
// İçe saçılma: kenardan uzaklıkla üstel sönen renkli ışık; ışığa bakan kenarda güçlü
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 p = here(); float S = max(p_sacilma * u_s, 1.0); float d = innerDist(p, S * 3.0);
  float a = radians(p_isikAcis); vec2 L = vec2(cos(a), sin(a)); vec2 g = alphaGrad(p + L * d, 1.5); float face = length(g) > 1e-4 ? clamp(dot(-normalize(g), L) * 0.5 + 0.5, 0.0, 1.0) : 0.6;
  float thick = p_kalinlikHariOn > 0.5 ? 1.0 - luma(texture(s_kalinlikHari, boxUV(p)).rgb) : 0.5; float sc = exp(-d / S) * (0.4 + 0.6 * face) * (0.5 + thick) * p_guc / 100.0;
  o = pre(unpre(s) + c_icRenk * sc * 0.8, s.a); }
