// volclouds
uniform float p_bulutYogu, p_olcek, p_yuksekli, p_ruzgarHizi, p_isikYonu, p_derinlikOrne, p_tohum, p_ortamIsig, p_yonluIsikGucu, p_gorusAcis; uniform vec3 c_isikReng, c_ortamReng; uniform vec3 p_yonelimXY;
float dens(vec3 p) { float n = fbm(p.xy + vec2(p.z * 0.7, p.z * 0.4), 4.0) * 0.5 + 0.5; return clamp((n - (1.0 - p_bulutYogu / 100.0)) * 2.5, 0.0, 1.0); }
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) / max(p_olcek, 1.0) + seedf(p_tohum) + vec2(u_t * p_ruzgarHizi / max(p_olcek, 1.0), 0.0);
  q = rot2(p_yonelimXY.z) * q;
  float T = 1.0; vec3 col = vec3(0.0); int N = int(clamp(p_derinlikOrne, 8.0, 32.0)); float la = radians(p_isikYonu); vec2 ld = vec2(cos(la), sin(la)) * 0.08;
  for (int i = 0; i < 32; i++) { if (i >= N) break; float z = float(i) / float(N) * p_yuksekli / 100.0 * 2.0; float d = dens(vec3(q, z)) * 0.35;
    if (d > 0.001) { float sh = dens(vec3(q + ld, z + 0.08)); vec3 L = mix(c_ortamReng * p_ortamIsig / 100.0 * 1.5, c_isikReng, exp(-sh * 2.0) * p_yonluIsikGucu / 100.0 * 1.2);
      col += T * d * L; T *= 1.0 - d; if (T < 0.02) break; } }
  float a = 1.0 - T;
  o = overPre(vec4(col, a), s);
}
