// particleworld
uniform vec2 p_yayiciKonu; uniform float p_derinlik, p_uretimHizi, p_hiz, p_omur, p_yercekim, p_yayilim, p_parcacikBoyu, p_kameraAcis, p_tohum, p_derinlikSira; uniform vec3 c_baslangiReng, c_bitisReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec3 acc = vec3(0.0); float al = 0.0; float life = max(p_omur, 0.05); int N = int(clamp(p_uretimHizi * life * 0.5, 1.0, 128.0)); float F = 800.0;
  for (int i = 0; i < 128; i++) { if (i >= N) break; vec3 h = vec3(hash2(vec2(float(i), seedf(p_tohum))), hash1(vec2(float(i), 7.0))); float lt = mod(u_t + h.x * life, life);
    float a1 = (h.y - 0.5) * radians(p_yayilim), a2 = (h.z - 0.5) * radians(p_yayilim); vec3 v = vec3(sin(a1), -cos(a1) * cos(a2), sin(a2)) * p_hiz;
    vec3 p = vec3(p_yayiciKonu, p_derinlik) + v * lt + vec3(0.0, 0.5 * p_yercekim * lt * lt, 0.0); float ca = radians(p_kameraAcis + u_t * 0.0); p.xz = mat2(cos(ca), -sin(ca), sin(ca), cos(ca)) * p.xz;
    float sc = F / max(F + p.z, 50.0); vec2 sp = p.xy * sc; float k = lt / life; float r = p_parcacikBoyu * 0.5 * sc; float m = (1.0 - smoothstep(r * 0.3, r, length(q - sp))) * (1.0 - k);
    acc += mix(c_baslangiReng, c_bitisReng, k) * m * (p_derinlikSira > 0.5 ? mix(0.5, 1.0, sc) : 1.0); al = max(al, m); }
  o = vec4(min(s.rgb * (1.0 - al) + acc, vec3(1.0)), max(s.a, al)); }
