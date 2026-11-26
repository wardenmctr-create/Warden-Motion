// fftnotch
uniform vec2 p_frekansMerk; uniform float p_yaricap, p_azaltma, p_simetrikCent;
void main() { vec4 s = texture(u_tex, v_uv); vec2 f = p_frekansMerk / max(u_s, 0.1); vec2 px = here(); float W = clamp(1.0 / max(p_yaricap, 0.001), 4.0, 60.0);
  vec3 I = vec3(0.0), Q = vec3(0.0); float ws = 0.0; for (int j = -6; j <= 6; j++) for (int i = -6; i <= 6; i++) { vec2 o2 = vec2(i, j) * W / 6.0; float w = exp(-dot(o2, o2) / (W * W) * 2.0); vec3 c = unpre(texPx(px + o2)); float ph = TAU * dot(px + o2, f); I += c * cos(ph) * w; Q += c * sin(ph) * w; ws += w; }
  I *= 2.0 / ws; Q *= 2.0 / ws; float ph0 = TAU * dot(px, f); vec3 wave = I * cos(ph0) + Q * sin(ph0); o = pre(clamp(unpre(s) - wave * p_azaltma / 100.0, 0.0, 1.0), s.a); }
