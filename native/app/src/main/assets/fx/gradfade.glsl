// gradfade
uniform vec2 p_baslangi, p_bitis; uniform float p_baslangiOpak, p_bitisOpak, p_bicim, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 ab = p_bitis - p_baslangi; float t;
  if (p_bicim < 0.5) t = clamp(dot(q - p_baslangi, ab) / max(dot(ab, ab), 1.0), 0.0, 1.0); else t = clamp(length(q - p_baslangi) / max(length(ab), 1.0), 0.0, 1.0);
  if (p_ters > 0.5) t = 1.0 - t; float k = mix(p_baslangiOpak, p_bitisOpak, smoothstep(0.0, 1.0, t)) / 100.0; o = s * k; }
