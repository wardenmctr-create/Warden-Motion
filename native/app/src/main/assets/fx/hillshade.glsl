// hillshade
uniform sampler2D s_yuksekli; uniform float p_yuksekliOn, p_isikAcis, p_yuksekliAbar;
float hAt(vec2 px) { return p_yuksekliOn > 0.5 ? luma(unpre(texture(s_yuksekli, clamp(boxUV(px), 0.0, 1.0)))) : luma(unpre(texPx(px))); }
void main() { vec4 s = texture(u_tex, v_uv); float e = u_s; vec3 n = normalize(vec3(-(hAt(here() + vec2(e, 0.0)) - hAt(here() - vec2(e, 0.0))) * 20.0 * p_yuksekliAbar, -(hAt(here() + vec2(0.0, e)) - hAt(here() - vec2(0.0, e))) * 20.0 * p_yuksekliAbar, 1.0));
  float az = radians(p_isikAcis); vec3 L = normalize(vec3(cos(az), -sin(az), 0.8)); float sh = max(dot(n, L), 0.0); o = vec4(unpre(s) * (0.25 + sh * 0.9), max(s.a, p_yuksekliOn)); }
