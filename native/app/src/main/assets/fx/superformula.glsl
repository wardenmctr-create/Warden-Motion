// superformula
uniform float p_simetri, p_yuvarlak, p_koseUssu, p_yaricap, p_dolgu;
// Gielis süperformülü r(φ) = (|cos(mφ/4)|^n2 + |sin(mφ/4)|^n3)^(−1/n1); dolgu açıkken katman şeklin içinde görünür, kapalıyken kontur
float sf(float ph) { float m = p_simetri; float n1 = max(p_yuvarlak, 0.05), n2 = max(p_koseUssu, 0.05); float a = pow(abs(cos(m * ph / 4.0)), n2) + pow(abs(sin(m * ph / 4.0)), n2); return pow(max(a, 1e-6), -1.0 / n1); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float ph = atan(q.y, q.x); float mx = 0.0; for (int i = 0; i < 32; i++) mx = max(mx, sf(float(i) / 32.0 * 6.2832)); float R = sf(ph) / max(mx, 1e-4) * p_yaricap;
  float d = length(q) - R; float aa = 1.0 / u_s; vec4 inside = s.a > 0.0 ? s : vec4(0.2, 0.55, 1.0, 1.0);
  if (p_dolgu > 0.5) o = inside * (1.0 - smoothstep(-aa, aa, d)); else o = vec4(1.0) * (1.0 - smoothstep(1.0, 1.0 + aa * 2.0, abs(d))); }
