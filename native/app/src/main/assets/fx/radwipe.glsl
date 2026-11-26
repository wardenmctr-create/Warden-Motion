// radwipe
uniform vec2 p_merkez; uniform float p_ilerleme, p_baslangiAcis, p_yumusatm, p_yon;
void main() { vec4 s = texture(u_tex, v_uv); vec2 r = toUnit(here()) - p_merkez; float a = degrees(atan(r.y, r.x)) - p_baslangiAcis; a = mod(a + 720.0, 360.0);
  if (p_yon > 0.5 && p_yon < 1.5) a = 360.0 - a; float pr = p_ilerleme / 100.0 * 360.0; float w = max(abs(p_yumusatm), 0.01);
  float k = p_yon > 1.5 ? smoothstep(pr * 0.5 - w, pr * 0.5 + w, min(a, 360.0 - a)) : smoothstep(pr - w, pr + w, a); o = s * k; }
