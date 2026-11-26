// onsetdetect
INCLUDE(_chart)
uniform float p_dvN, p_duyarlil, p_enAzAral, p_mod;
// Her başlangıç darbesi merkezden yayılan bir halka (yaşla büyür ve söner); altta son 3 saniyenin olay çizgisi
float A(int i) { if (p_dvN > 0.5) return dvAt(i); float per = 0.45; return mod(u_t - float(i) * per, per * 8.0) + float(i) * per * 0.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 b = boxUV(here()); float R = min(boxU().x, boxU().y) * 0.45; vec4 res = s;
  for (int i = 0; i < 8; i++) { float age = A(i); if (age > 3.0) continue; float rr = R * clamp(age / 0.8, 0.0, 1.2); float a = exp(-age * 2.5); res = overPre(vec4(1.0, 0.85, 0.4, 1.0) * (1.0 - smoothstep(1.0, 3.0, abs(length(q) - rr) * u_s)) * a, res);
    float x = 1.0 - age / 3.0; if (b.y > 0.9) res = overPre(vec4(1.0, 0.6, 0.3, 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.z, abs(b.x - x))), res); }
  if (b.y > 0.9) res = overPre(vec4(0.05, 0.06, 0.1, 0.5), res); o = res; }
