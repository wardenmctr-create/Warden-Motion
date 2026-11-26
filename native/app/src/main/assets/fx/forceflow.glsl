// forceflow
uniform vec2 p_kaynak, p_hedef; uniform float p_guc, p_akisNokt, p_hiz;
// Kaynak–kuyu potansiyel akışı: akım fonksiyonu ψ = θ1 − θ2 (akım çizgileri), potansiyel φ = ln(r1/r2); noktalar φ boyunca akar
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 d1 = q - p_kaynak, d2 = q - p_hedef; float psi = atan(d1.y, d1.x) - atan(d2.y, d2.x); float phi = log(max(length(d1), 0.5) / max(length(d2), 0.5)) * sign(p_guc + 1e-6);
  float N = clamp(p_akisNokt / 6.0, 2.0, 120.0); float lane = psi / 6.2832 * N; float ln = abs(fract(lane) - 0.5); float spd = p_hiz * abs(p_guc) * 0.01;
  float pos = fract(phi * 2.0 - u_t * spd + hash1(vec2(floor(lane), 1.0))); float dotv = (1.0 - smoothstep(0.06, 0.12, ln)) * (1.0 - smoothstep(0.04, 0.12, abs(pos - 0.5)));
  float guide = (1.0 - smoothstep(0.02, 0.05, ln)) * 0.18; float src = 1.0 - smoothstep(3.0, 4.0, min(length(d1), length(d2)));
  o = overPre(vec4(vec3(0.6, 0.85, 1.0), 1.0) * clamp(dotv + guide + src, 0.0, 1.0), s); }
