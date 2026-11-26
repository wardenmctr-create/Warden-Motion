// gabor
uniform float p_yon, p_frekans, p_bantGeni;
void main() { vec4 s = texture(u_tex, v_uv); vec2 d = vec2(cos(radians(p_yon)), sin(radians(p_yon))); float f = p_frekans / max(u_s, 0.1); float sig = p_bantGeni / max(f, 1e-3) * 0.4; float re = 0.0, im = 0.0;
  for (int j = -5; j <= 5; j++) for (int i = -5; i <= 5; i++) { vec2 o2 = vec2(i, j) * sig / 2.5; float g = exp(-dot(o2, o2) / (2.0 * sig * sig)); float l = luma(unpre(texPx(here() + o2))); float ph = TAU * f * dot(o2, d); re += l * g * cos(ph); im += l * g * sin(ph); }
  float e = sqrt(re * re + im * im) / 20.0; o = pre(vec3(clamp(e * 4.0, 0.0, 1.0)), s.a); }
