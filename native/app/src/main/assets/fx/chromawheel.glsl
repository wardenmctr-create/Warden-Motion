// chromawheel
INCLUDE(_chart)
uniform float p_dvN, p_pencere, p_cikti, p_yumusatm;
// 12 nota sınıfı çember üzerinde: dilim parlaklığı ve boyu enerjiyle; akor etiketinde kök nota numarası (0 = Do) ortada
float C(int i) { if (p_dvN > 0.5) return dvAt(i); return 0.3 + 0.7 * pow(0.5 + 0.5 * sin(u_t * 1.7 + float(i) * 0.9), 3.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R = min(boxU().x, boxU().y) * 0.45; float r = length(q); float a = mod(atan(q.x, -q.y) + 6.2832, 6.2832); int i = int(floor(a / 6.2832 * 12.0)) % 12;
  float e = clamp(C(i), 0.0, 1.0); vec4 res = s; float outer = R * (0.55 + 0.45 * e); if (r > R * 0.3 && r < outer && fract(a / 6.2832 * 12.0) > 0.04) res = overPre(vec4(hsv2rgb(vec3(float(i * 7 % 12) / 12.0, 0.75, 0.35 + 0.65 * e)), 0.9), res);
  if (p_cikti > 0.5) { vec2 lp = q / (R * 0.12); float root = p_dvN > 0.5 ? dvAt(12) : floor(mod(u_t, 12.0)); res = overPre(vec4(1.0) * numAt(lp, root), res); if (p_dvN > 0.5 && dvAt(13) > 0.5) res = overPre(vec4(0.6, 0.8, 1.0, 1.0) * (1.0 - smoothstep(R * 0.02, R * 0.03, abs(r - R * 0.25))), res); } o = res; }
