// cbsweat
uniform vec2 p_baslangi, p_bitis; uniform float p_boyut, p_kontur, p_ilerleme, p_sure, p_otomatik, p_parlakNokt; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float pr = p_otomatik > 0.5 ? fract(u_t / max(p_sure, 0.05)) : p_ilerleme / 100.0; vec2 c = mix(p_baslangi, p_bitis, pr * pr);
  vec2 p = (q - c) / max(p_boyut, 1.0); p.y = -p.y; float d = length(p - vec2(0.0, -0.1)) - 0.3; float tip = max(abs(p.x) - (0.3 - (p.y + 0.1) * 0.5), p.y - 0.45); d = min(d, max(tip, -p.y - 0.1)); d *= p_boyut;
  float fill = 1.0 - smoothstep(-0.6, 0.6, d); float ring = 1.0 - smoothstep(p_kontur - 0.6, p_kontur + 0.6, d); float fade = 1.0 - smoothstep(0.8, 1.0, pr);
  vec4 col = vec4(0.07, 0.1, 0.2, 1.0) * ring; col = mix(col, vec4(c_renk, 1.0), fill); if (p_parlakNokt > 0.5) col = mix(col, vec4(1.0), (1.0 - smoothstep(0.0, 0.08, length(p - vec2(-0.1, 0.0)))) * fill);
  o = overPre(col * fade, s); }
