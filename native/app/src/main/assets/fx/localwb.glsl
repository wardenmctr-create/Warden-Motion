// localwb
uniform sampler2D s_bolgeMask; uniform float p_bolgeMaskOn, p_gecis; uniform vec3 c_notrOrne;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); vec3 n = max(c_notrOrne, vec3(0.02)); vec3 g = vec3(luma(n)) / n; g /= max(max(g.r, max(g.g, g.b)), 1e-3) * 0.0 + 1.0;
  float m = 1.0; if (p_bolgeMaskOn > 0.5) { m = 0.0; float R = max(p_gecis, 0.5) * u_s; for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; m += texture(s_bolgeMask, clamp(boxUV(here() + vec2(cos(a), sin(a)) * R * fract(float(i) * 0.618 + 0.2)), 0.0, 1.0)).a; } m /= 12.0; }
  o = pre(clamp(mix(c, c * g, m), 0.0, 1.0), s.a); }
