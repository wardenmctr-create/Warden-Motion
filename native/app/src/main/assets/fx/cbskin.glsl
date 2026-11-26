// cbskin
uniform sampler2D s_bayrakKatm, s_govdeMask; uniform float p_bayrakKatmOn, p_govdeMaskOn; uniform float p_yerlesim, p_olcek, p_aci, p_kureBuku, p_golge, p_konturuKoru; uniform vec2 p_kayma;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float mask = p_govdeMaskOn > 0.5 ? texture(s_govdeMask, clamp(b, 0.0, 1.0)).a : s.a; if (mask <= 0.0) { o = s; return; }
  vec2 r = b - 0.5; float d = length(r) * 2.0; vec2 bulged = r * mix(1.0, 0.75 + 0.25 * sqrt(max(0.0, 1.0 - d * d)), p_kureBuku / 100.0 * 2.0);
  vec2 fb = rot2(-p_aci) * (bulged - p_kayma / boxU()) / max(p_olcek / 100.0, 0.01) + 0.5; vec4 f = p_bayrakKatmOn > 0.5 ? texture(s_bayrakKatm, clamp(fb, 0.0, 1.0)) : s;
  vec3 c = f.a > 0.0 ? f.rgb / f.a : unpre(s); c *= 1.0 - smoothstep(0.5, 1.0, d) * p_golge / 100.0; vec4 res = pre(c, mask);
  if (p_konturuKoru > 0.5) { float dark = 1.0 - smoothstep(0.05, 0.25, luma(unpre(s))); res = mix(res, s, dark * s.a); } o = res; }
