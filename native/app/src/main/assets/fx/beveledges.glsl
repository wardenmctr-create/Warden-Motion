// beveledges
uniform float p_genislik, p_derinlik, p_isikAcis, p_koseBici; uniform vec3 c_acikRenk, c_koyuRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 q = toUnit(here()); vec2 B = boxU() * 0.5; vec2 e = B - abs(q); float W = max(p_genislik, 0.5);
  float dx = e.x, dy = e.y; float m = min(dx, dy); if (m > W) { o = s; return; }
  vec2 n = dx < dy ? vec2(sign(q.x), 0.0) : vec2(0.0, sign(q.y));
  if (p_koseBici > 0.5) { vec2 k = max(W - e, 0.0); if (k.x > 0.0 && k.y > 0.0) n = normalize(k * sign(q)); }
  float a = radians(p_isikAcis); float lit = dot(n, -vec2(cos(a), sin(a))) * (p_derinlik / max(W, 0.1)) * (1.0 - m / W * 0.5);
  vec3 c = unpre(s); c = lit > 0.0 ? mix(c, c_acikRenk, clamp(lit, 0.0, 0.85)) : mix(c, c_koyuRenk, clamp(-lit, 0.0, 0.85));
  o = pre(c, s.a);
}
