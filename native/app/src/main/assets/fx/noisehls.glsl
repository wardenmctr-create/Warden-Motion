// noisehls
uniform float p_tonGuru, p_aciklikGuru, p_doygunluGuru, p_tohum, p_animasyo, p_tekRenk;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 g = floor(here() / max(u_s, 1.0)); float tk = p_animasyo > 0.5 ? floor(u_t * 24.0) : 0.0; float sd = seedf(p_tohum);
  vec3 h = rgb2hsl(unpre(s)); float n1 = hash1(g + sd + tk) - 0.5, n2 = (p_tekRenk > 0.5 ? n1 : hash1(g + sd + tk + 17.0) - 0.5), n3 = (p_tekRenk > 0.5 ? n1 : hash1(g + sd + tk + 41.0) - 0.5);
  h.x = fract(h.x + n1 * p_tonGuru / 100.0); h.z = clamp(h.z + n2 * p_aciklikGuru / 100.0, 0.0, 1.0); h.y = clamp(h.y + n3 * p_doygunluGuru / 100.0, 0.0, 1.0); o = pre(hsl2rgb(h), s.a); }
