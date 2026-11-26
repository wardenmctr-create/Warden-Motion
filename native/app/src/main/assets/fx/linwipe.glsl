// linwipe
uniform float p_ilerleme, p_aci, p_yumusatm, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 d = vec2(cos(radians(p_aci)), sin(radians(p_aci))); vec2 B = boxU(); float span = abs(d.x) * B.x + abs(d.y) * B.y + p_yumusatm * 2.0;
  float x = dot(toUnit(here()), d) / span + 0.5; float e = (p_ilerleme / 100.0) * (1.0 + 0.0); float w = p_yumusatm / span; float k = smoothstep(e - w, e + w * 0.0 + 1e-4, x - w * 0.5 + w * 0.5);
  k = smoothstep(e - w * 0.5, e + w * 0.5 + 1e-4, x); if (p_ters > 0.5) k = 1.0 - k; o = s * k; }
