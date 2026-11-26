// deblock
uniform float p_blokBoyu, p_guc, p_sinirEsig, p_renkOnar, p_ayrintiKoru, p_gecisSayi; uniform vec2 p_izgaraBasl;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float B = p_blokBoyu < 0.5 ? 8.0 : p_blokBoyu < 1.5 ? 4.0 : p_blokBoyu < 2.5 ? 8.0 : p_blokBoyu < 3.5 ? 16.0 : p_blokBoyu < 4.5 ? 32.0 : 64.0; B *= u_s;
  vec2 m = mod(here() - p_izgaraBasl * u_s, B); vec2 dist = min(m, B - m); float near = 1.0 - smoothstep(0.0, B * 0.35, min(dist.x, dist.y)); vec3 acc = c0; float ws = 1.0;
  int P = int(clamp(p_gecisSayi, 1.0, 4.0));
  for (int k = 1; k <= 4; k++) { if (k > P) break; for (int i = 0; i < 4; i++) { vec2 o2 = (i == 0 ? vec2(1, 0) : i == 1 ? vec2(-1, 0) : i == 2 ? vec2(0, 1) : vec2(0, -1)) * float(k) * B * 0.25; vec3 c = unpre(texPx(here() + o2));
    float w = 1.0 - smoothstep(p_sinirEsig / 100.0 * 0.5, p_sinirEsig / 100.0, length(c - c0)); acc += c * w; ws += w; } }
  vec3 sm = acc / ws; float det = smoothstep(0.1, 0.3, sobel(here(), u_s)) * p_ayrintiKoru / 100.0; vec3 r = mix(c0, sm, near * p_guc / 100.0 * (1.0 - det));
  vec3 chroma = (sm - luma(sm)); r = mix(r, luma(r) + chroma, p_renkOnar / 100.0 * 0.6); o = pre(clamp(r, 0.0, 1.0), s.a); }
