// paperfold
uniform sampler2D s_katCizg; uniform float p_katCizgOn, p_katAcis, p_kirisikl, p_isikAcis;
// Kat çizgileri (kaynak ya da dikey orta + köşegen): her kat iki yanı farklı eğimle ışık alır; kırışıklık gürültülü normal
float side(vec2 b) { if (p_katCizgOn > 0.5) { float a = 0.0; for (int k = 1; k <= 24; k++) { if (texture(s_katCizg, vec2(b.x - float(k) / 24.0, b.y)).a > 0.5) { a = mod(a + 1.0, 2.0); } } return a; }
  return step(0.5, b.x) + step(b.y, 0.35 + b.x * 0.3) * 2.0; }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 b = boxUV(here()); float sd = side(b); float tilt = radians(p_katAcis) * (mod(sd, 2.0) < 0.5 ? 1.0 : -1.0);
  vec3 n = normalize(vec3(sin(tilt), sd > 1.5 ? sin(tilt) * 0.5 : 0.0, cos(tilt))); vec2 cr = vec2(fbm(here() / max(14.0 * u_s, 1.0), 3.0), fbm(here() / max(14.0 * u_s, 1.0) + 9.0, 3.0)) * p_kirisikl * 0.03; n = normalize(n + vec3(cr, 0.0));
  float la = radians(p_isikAcis); vec3 L = normalize(vec3(cos(la), -sin(la), 1.2)); float sh = clamp(dot(n, L), 0.0, 1.0) / dot(vec3(0.0, 0.0, 1.0), L);
  vec2 gx = vec2(1.0 / u_box.z, 0.0); float crease = abs(side(b + gx * 2.0) - side(b - gx * 2.0)) > 0.0 ? 0.75 : 1.0; o = pre(unpre(s) * clamp(sh, 0.55, 1.25) * crease, s.a); }
