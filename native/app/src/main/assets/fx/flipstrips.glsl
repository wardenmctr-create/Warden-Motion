// flipstrips
uniform sampler2D s_on, s_arka; uniform float p_onOn, p_arkaOn, p_bakisAcis, p_serit, p_gecisYumu;
// Lentiküler şeritler: bakış açısı her şeritte ön/arka görüntünün payını belirler
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec4 A = p_onOn > 0.5 ? texture(s_on, b) : s; vec4 B = p_arkaOn > 0.5 ? texture(s_arka, b) : vec4(hueRotate(unpre(s), 160.0) * s.a, s.a);
  float st = fract(here().x / max(p_serit * u_s, 1.0)); float k = clamp(0.5 + p_bakisAcis / 90.0, 0.0, 1.0); float sw = max(p_gecisYumu / 100.0 * 0.25, 0.01);
  float m = smoothstep(k - sw, k + sw, st); float ridge = 0.92 + 0.08 * cos(st * 6.28318); o = mix(A, B, m) * vec4(vec3(ridge), 1.0); }
