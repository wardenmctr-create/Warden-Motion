// cbflagtrans
uniform sampler2D s_hedefBayr; uniform float p_hedefBayrOn; uniform float p_ilerleme, p_bicim, p_aci, p_yumusatm, p_govdeMaskKoru, p_konturuKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec4 tg = p_hedefBayrOn > 0.5 ? texture(s_hedefBayr, clamp(b, 0.0, 1.0)) : vec4(1.0 - unpre(s), 1.0) * s.a; if (p_govdeMaskKoru > 0.5) tg = pre(tg.a > 0.0 ? tg.rgb / tg.a : vec3(0.0), s.a);
  float pr = p_ilerleme / 100.0; float x; vec2 r = b - 0.5; if (p_bicim < 0.5) x = dot(rot2(p_aci) * r, normalize(vec2(1.0, 1.0))) * 0.7071 + 0.5; else if (p_bicim < 1.5) x = dot(rot2(p_aci) * r, vec2(1.0, 0.0)) + 0.5; else if (p_bicim < 2.5) x = 0.5; else x = length(r) * 1.42;
  float w = p_yumusatm / max(boxU().x, 1.0) + 1e-3; float k = p_bicim > 1.5 && p_bicim < 2.5 ? pr : 1.0 - smoothstep(pr * (1.0 + w * 2.0) - w * 2.0, pr * (1.0 + w * 2.0), x);
  vec4 c = mix(s, tg, k); if (p_konturuKoru > 0.5) { float dark = 1.0 - smoothstep(0.05, 0.2, luma(unpre(s))); c = mix(c, s, dark * s.a * step(0.5, s.a)); } o = c; }
