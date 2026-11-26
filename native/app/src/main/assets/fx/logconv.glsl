// logconv
uniform float p_logProf, p_pozlama, p_cikisProf, p_acikTonYumu;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 lin;
  if (p_logProf < 0.5) lin = mix((c - 0.0928641) / 5.367655, pow(vec3(10.0), (c * 1023.0 - 420.0) / 261.5) * 0.19 - 0.01, step(171.2102946929 / 1023.0, c));
  else if (p_logProf < 1.5) lin = (pow(vec3(10.0), (c - 0.12512248) / 0.36726845) - 1.0) / 14.98325;
  else if (p_logProf < 2.5) lin = mix((c - 0.125) / 5.6, pow(vec3(10.0), (c - 0.598206) / 0.241514) - 0.00873, step(0.181, c));
  else lin = mix((c - 0.092809) / 5.367655, (pow(vec3(10.0), (c - 0.385537) / 0.247190) - 0.052272) / 5.555556, step(0.1496582, c));
  lin = max(lin, 0.0) * exp2(p_pozlama);
  lin = lin / (1.0 + lin * p_acikTonYumu / 100.0 * 0.5);
  o = pre(clamp(lin2srgb(lin), 0.0, 1.0), s.a);
}
