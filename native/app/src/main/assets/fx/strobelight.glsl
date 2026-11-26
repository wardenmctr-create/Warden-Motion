// strobelight
uniform vec3 c_renk; uniform float p_guc, p_frekans, p_acikKalm, p_faz, p_yumusakGeci, p_kareyiKapl;
void main() { vec4 s = texture(u_tex, v_uv); float ph = fract(u_t * p_frekans + p_faz / 360.0); float d = p_acikKalm / 100.0;
  float k = p_yumusakGeci > 0.5 ? (ph < d ? sin(ph / max(d, 1e-3) * PI) : 0.0) : step(ph, d); k *= p_guc / 100.0;
  if (p_kareyiKapl > 0.5) { o = overPre(vec4(c_renk, 1.0) * k, s); return; } o = pre(mix(unpre(s), c_renk, k), s.a); }
