// texsegment
uniform float p_bolgeHede, p_dokuAgir;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float m = 0.0, m2 = 0.0; vec2 g = vec2(0.0); for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; vec2 o2 = vec2(cos(a), sin(a)) * 6.0 * u_s; float l = luma(unpre(texPx(here() + o2))); m += l; m2 += l * l; g += abs(lumGrad(here() + o2, u_s)); }
  m /= 12.0; float var_ = sqrt(max(m2 / 12.0 - m * m, 0.0)); vec2 gd = g / 12.0; float k = max(2.0, pow(p_bolgeHede, 1.0 / 3.0)); vec3 f = vec3(mix(luma(c), var_ * 4.0, p_dokuAgir / 100.0), mix(rgb2hsv(c).x, gd.x * 6.0, p_dokuAgir / 100.0), mix(rgb2hsv(c).y, gd.y * 6.0, p_dokuAgir / 100.0));
  vec3 id = floor(clamp(f, 0.0, 0.999) * k); vec3 col = hsv2rgb(vec3(hash1(id.xy + id.z * 7.0), 0.55, 0.55 + 0.4 * hash1(id.zy + 3.0))); o = pre(col, s.a); }
