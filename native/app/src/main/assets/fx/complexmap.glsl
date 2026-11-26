// complexmap
uniform float p_fonksiyo, p_olcek, p_renkCevr;
vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 z = toUnit(here()) / max(p_olcek, 1.0) * 2.0; vec2 w;
  if (p_fonksiyo < 0.5) w = cmul(z, z); else if (p_fonksiyo < 1.5) w = vec2(z.x, -z.y) / max(dot(z, z), 1e-6); else if (p_fonksiyo < 2.5) w = vec2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y)); else w = exp(z.x) * vec2(cos(z.y), sin(z.y));
  float hue = fract(atan(w.y, w.x) / TAU + p_renkCevr / 360.0); float m = log(length(w) + 1e-6); float rings = 0.75 + 0.25 * fract(m); vec3 c = hsv2rgb(vec3(hue, 0.85, rings));
  vec2 g = fract(w) ; c *= 0.85 + 0.15 * smoothstep(0.0, 0.05, min(g.x, g.y)); o = pre(c, s.a); }
