// spotlight
uniform vec2 p_merkez; uniform float p_isikYari, p_kenarYumu, p_isikYogu, p_ortamIsig, p_elipsOran; uniform vec3 c_isikReng;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 r = toUnit(here()) - p_merkez; r.x /= max(p_elipsOran, 0.05); float R = max(p_isikYari, 1.0);
  float l = 1.0 - smoothstep(R * (1.0 - p_kenarYumu / 100.0), R, length(r));
  vec3 k = mix(vec3(p_ortamIsig / 100.0), c_isikReng * (0.6 + 0.6 * p_isikYogu / 100.0), l);
  o = pre(clamp(unpre(s) * k, 0.0, 1.0), s.a);
}
