// blinds
uniform float p_ilerleme, p_seritGeni, p_aci, p_yumusatm, p_yon, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = rot2(-p_aci) * toUnit(here()); float w = max(p_seritGeni, 1.0); float f = fract(p.y / w);
  if (p_yon > 0.5) f = abs(f - 0.5) * 2.0; float e = p_ilerleme / 100.0; float sw = p_yumusatm / w + 1e-4; float k = smoothstep(e - sw, e + sw, f); if (p_ters > 0.5) k = 1.0 - k; o = s * k; }
