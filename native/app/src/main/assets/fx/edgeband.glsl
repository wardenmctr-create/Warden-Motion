// edgeband
uniform float p_icGeni, p_disGeni, p_yumusatm;
void main() { vec4 s = texture(u_tex, v_uv); float R = max(max(p_icGeni, p_disGeni), 1.0) * u_s + 2.0; float a = s.a; float m;
  if (a > 0.5) { float d = innerDist(here(), R) / u_s; m = 1.0 - smoothstep(p_icGeni, p_icGeni + max(p_yumusatm, 0.01), d); } else { float d = outerDist(here(), R) / u_s; m = 1.0 - smoothstep(p_disGeni, p_disGeni + max(p_yumusatm, 0.01), d); }
  vec3 c = a > 0.0 ? s.rgb / a : vec3(1.0); if (a <= 0.0) { for (int i = 0; i < 8; i++) { float an = float(i) * 0.785; vec4 n = texPx(here() + vec2(cos(an), sin(an)) * R); if (n.a > 0.0) { c = n.rgb / n.a; break; } } } o = pre(c, m); }
