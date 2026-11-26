// starfilter
uniform float p_kanatSayi, p_sivriUzun, p_esik, p_aci;
void main() { vec4 s = texture(u_tex, v_uv); vec3 acc = vec3(0.0); int K = int(clamp(p_kanatSayi, 3.0, 16.0)); float L = p_sivriUzun * u_s;
  for (int k = 0; k < 16; k++) { if (k >= K) break; float a = radians(p_aci) + float(k) * PI / float(K) * 2.0; vec2 d = vec2(cos(a), sin(a));
    for (int i = 1; i <= 12; i++) { float t = L * float(i) / 12.0; vec4 n = texPx(here() - d * t); float b = smoothstep(p_esik / 100.0, 1.0, luma(unpre(n))) * n.a; acc += unpre(n) * b * (1.0 - float(i) / 13.0) / 6.0; } }
  o = vec4(clamp(s.rgb + acc, 0.0, 1.0), max(s.a, min(1.0, luma(acc)))); }
