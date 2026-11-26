// scratchreveal
uniform sampler2D s_altKatm, s_kaziMask; uniform float p_altKatmOn, p_kaziMaskOn, p_kaziGeni, p_kalinti;
// Kazıma maskesi (kaynak ya da zamanla çoğalan rastgele çizikler) üst boyayı kaldırır, alt katman görünür; kenarlarda kalıntı
float scratches(vec2 q) { float m = 0.0; for (int i = 0; i < 10; i++) { float t0 = float(i) * 0.35; if (u_t < t0) break; vec2 h = hash2(vec2(float(i), 3.7)); vec2 a = (h - 0.5) * boxU(); float ang = h.x * 6.28; vec2 d = vec2(cos(ang), sin(ang));
    float len = min((u_t - t0) / 0.3, 1.0) * boxU().x * 0.6; vec2 ap = q - a; float tt = clamp(dot(ap, d), 0.0, len); m = max(m, 1.0 - smoothstep(p_kaziGeni * 0.4, p_kaziGeni * 0.5 + 1.0, length(ap - d * tt))); } return m; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float m = p_kaziMaskOn > 0.5 ? texture(s_kaziMask, b).a : scratches(toUnit(here()));
  float res = hash1(floor(here() / max(2.0 * u_s, 1.0))) < p_kalinti / 100.0 ? 0.6 : 0.0; m *= 1.0 - res; vec4 under = p_altKatmOn > 0.5 ? texture(s_altKatm, b) : vec4(vec3(0.95, 0.85, 0.3) * s.a, s.a);
  o = mix(s, under, m); }
