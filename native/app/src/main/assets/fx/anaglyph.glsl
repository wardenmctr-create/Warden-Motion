// anaglyph
uniform float p_amount;
void main() { vec2 d = vec2(p_amount * u_s, 0.0) / u_res; vec4 l = tex(v_uv - d), r = tex(v_uv + d); vec3 cl = unpre(l), cr = unpre(r);
  float a = max(l.a, r.a); vec3 c = vec3(luma(cl) * l.a, luma(cr) * r.a, luma(cr) * r.a); o = vec4(c, a); }
