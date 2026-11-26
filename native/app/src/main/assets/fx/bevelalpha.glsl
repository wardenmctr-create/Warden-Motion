// bevelalpha
uniform float p_pahGeni, p_pahDeri, p_isikAcis, p_guc, p_icPah; uniform vec3 c_acikRenk, c_koyuRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0 && p_icPah > 0.5) { o = s; return; }
  float W = max(p_pahGeni * u_s, 1.0); float st = W * 0.35;
  vec2 g = alphaGrad(here(), st) * st; float d = innerDist(here(), W) / W;
  float band = 1.0 - smoothstep(0.6, 1.0, d);
  float a = radians(p_isikAcis); float lit = dot(normalize(g + 1e-5), -vec2(cos(a), sin(a))) * min(1.0, length(g) * 4.0) * band * (p_pahDeri / max(p_pahGeni, 0.1));
  vec3 c = unpre(s); c = lit > 0.0 ? mix(c, c_acikRenk, clamp(lit, 0.0, 1.0) * p_guc / 100.0) : mix(c, c_koyuRenk, clamp(-lit, 0.0, 1.0) * p_guc / 100.0);
  o = pre(c, s.a);
}
