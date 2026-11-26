// inkwipe
uniform vec2 p_merkez; uniform float p_ilerleme, p_lekeBoyu, p_kenarPuru, p_dallanma, p_yumusatm, p_tohum, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 r = q - p_merkez; float d = length(r) / (length(boxU()) * 0.6); float a = atan(r.y, r.x);
  float n = fbm(vec2(a * 2.0, seedf(p_tohum)) + d * 2.0, 4.0) * p_kenarPuru / 100.0 * 0.6 + fbm(q / max(p_lekeBoyu, 1.0) * 2.0, 3.0) * p_dallanma / 100.0 * 0.4;
  float pr = p_ilerleme / 100.0 * 1.3; float w = p_yumusatm / 100.0 * 0.2 + 0.005; float k = 1.0 - smoothstep(pr - w, pr + w, d + n); if (p_ters > 0.5) k = 1.0 - k; o = s * k; }
