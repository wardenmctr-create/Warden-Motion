// lightwipe
uniform float p_ilerleme, p_aci, p_isikGeni, p_parlama, p_yumusatm, p_ters; uniform vec3 c_isikReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 d = vec2(cos(radians(p_aci)), sin(radians(p_aci))); vec2 B = boxU(); float span = abs(d.x) * B.x + abs(d.y) * B.y + p_isikGeni * 2.0;
  float x = dot(toUnit(here()), d) + span * 0.5; float e = p_ilerleme / 100.0 * span; float k = smoothstep(e - p_yumusatm * 0.5, e + p_yumusatm * 0.5 + 1e-3, x); if (p_ters > 0.5) k = 1.0 - k;
  float band = exp(-pow((x - e) / max(p_isikGeni * 0.5, 0.5), 2.0)) * step(0.001, p_ilerleme) * step(p_ilerleme, 99.9); vec4 c = s * k; c.rgb += c_isikReng * band * p_parlama / 100.0 * s.a; c.a = max(c.a, band * s.a * p_parlama / 100.0); o = c; }
