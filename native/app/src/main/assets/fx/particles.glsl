// particles
uniform vec2 p_yayici; uniform float p_uretimHizi, p_hiz, p_yon, p_yayilim, p_yercekim, p_omur, p_boyut, p_tohum, p_tekSefe; uniform vec3 c_baslangiReng, c_bitisReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec3 acc = vec3(0.0); float al = 0.0; float life = max(p_omur, 0.05); int N = int(clamp(p_uretimHizi * life, 1.0, 128.0));
  for (int i = 0; i < 128; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum))); float born = p_tekSefe > 0.5 ? 0.0 : h.x * life; float lt = p_tekSefe > 0.5 ? u_t : mod(u_t - born, life);
    if (lt > life) continue; float a = radians(p_yon + (h.y - 0.5) * p_yayilim); vec2 v = vec2(cos(a), sin(a)) * p_hiz * (0.6 + 0.8 * fract(h.x * 7.3));
    vec2 pos = p_yayici + v * lt + vec2(0.0, 0.5 * p_yercekim * lt * lt); float k = lt / life; float r = p_boyut * 0.5 * (1.0 - k * 0.6); float d = length(q - pos);
    float m = (1.0 - smoothstep(r * 0.3, r, d)) * (1.0 - k); acc += mix(c_baslangiReng, c_bitisReng, k) * m; al = max(al, m); }
  o = vec4(min(s.rgb * (1.0 - al) + acc, vec3(1.0)), max(s.a, al));
}
