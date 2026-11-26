// multiscale
uniform float p_olcekSayi, p_herBantKaza, p_kenarKoru;
vec3 blurR(float r) { vec3 a = vec3(0.0); for (int i = 0; i < 12; i++) { float an = float(i) * 0.5236; a += unpre(texPx(here() + vec2(cos(an), sin(an)) * r * u_s)); } return a / 12.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); vec3 prev = c; vec3 res = c; int N = int(clamp(p_olcekSayi, 1.0, 8.0)); float g = p_herBantKaza / 100.0 - 1.0;
  for (int k = 0; k < 8; k++) { if (k >= N) break; vec3 b = blurR(pow(2.0, float(k))); vec3 band = prev - b; float m = p_kenarKoru > 0.5 ? 1.0 - smoothstep(0.1, 0.3, length(band)) : 1.0; res += band * g * m; prev = b; }
  o = pre(clamp(res, 0.0, 1.0), s.a); }
