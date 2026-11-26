// lincolorkey
uniform vec3 c_anahtarReng; uniform float p_benzerli, p_karisim, p_islem, p_alfaOniz;
void main() { vec4 s = texture(u_tex, v_uv); float d = distance(unpre(s), c_anahtarReng); float t = p_benzerli / 100.0 * 0.8; float m = 1.0 - smoothstep(t, t + p_karisim / 100.0 * 0.5 + 0.001, d);
  float a = p_islem < 0.5 ? s.a * (1.0 - m) : s.a * m; if (p_alfaOniz > 0.5) { o = vec4(vec3(a), 1.0); return; } o = pre(unpre(s), a); }
