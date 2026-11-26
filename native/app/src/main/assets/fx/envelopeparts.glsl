// envelopeparts
uniform vec4 p_dv4[32]; float dvAt(int i) { return i < 0 || i >= 128 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_dvN, p_baslangiTepk, p_kuyrukTepk, p_cikti;
// Son 2 saniyenin giriş (başlangıç) ve çıkış (kuyruk) zarfları ayrı eğriler
float E(int i, bool rel) { if (p_dvN > 0.5) return dvAt(i + (rel ? 64 : 0)); float x = float(i) / 63.0 * 6.0 + u_t * 3.0; float ph = fract(x / 1.5); return rel ? exp(-ph * 3.0) * 0.6 * step(0.1, ph) : exp(-ph * 18.0) * 0.9; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float f = clamp(b.x, 0.0, 1.0) * 63.0; int i = int(floor(f)); vec4 res = overPre(vec4(0.05, 0.06, 0.1, 0.55), s);
  float mx = 1e-4; for (int k = 0; k < 64; k++) mx = max(mx, max(E(k, false), E(k, true)));
  if (p_cikti != 1.0) { float v = mix(E(i, false), E(min(i + 1, 63), false), fract(f)) / mx; float y = 0.95 - v * 0.85; res = overPre(vec4(1.0, 0.75, 0.3, 1.0) * (1.0 - smoothstep(1.2, 2.5, abs(b.y - y) * u_box.w)), res); }
  if (p_cikti != 0.0) { float v = mix(E(i, true), E(min(i + 1, 63), true), fract(f)) / mx; float y = 0.95 - v * 0.85; res = overPre(vec4(0.4, 0.8, 1.0, 1.0) * (1.0 - smoothstep(1.2, 2.5, abs(b.y - y) * u_box.w)), res); }
  o = res; }
