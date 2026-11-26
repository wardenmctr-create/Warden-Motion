// lomo
uniform float p_doygunlu, p_kontrast, p_vinyet, p_vinyetYari, p_renkKaym; uniform vec2 p_merkez;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); c = satAdj(c, 1.0 + p_doygunlu / 100.0); c = conAdj(c, 1.0 + p_kontrast / 100.0, 0.5);
  c.r += p_renkKaym / 100.0 * 0.1; c.b -= p_renkKaym / 100.0 * 0.1;
  vec2 r = (toUnit(here()) - p_merkez) / (boxU() * 0.5); float d = length(r);
  float R = p_vinyetYari / 100.0 * 1.2; c *= 1.0 - p_vinyet / 100.0 * smoothstep(R * 0.5, R + 0.4, d);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
