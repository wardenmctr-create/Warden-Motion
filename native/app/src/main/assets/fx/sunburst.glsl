// sunburst
INCLUDE(_chart)
uniform float p_icYari, p_derinlik, p_bosluk, p_etiket;
// İçten dışa halkalar: halka d = veri sütunu d; satırların değerleri açıyı böler; renk satırdan, dışa doğru açılır
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R0 = p_icYari; float Rm = min(boxU().x, boxU().y) * 0.46; int D = int(min(min(dC(), p_derinlik), 12.0)); float th = (Rm - R0) / float(max(D, 1)); float r = length(q);
  if (r < R0 || r > Rm) { o = s; return; } int d = int(floor((r - R0) / th)); if (d >= D) { o = s; return; } float ang = mod(atan(q.y, q.x) + 6.2832, 6.2832); int N = int(min(dR(), 32.0)); float tot = 0.0;
  for (int i = 0; i < 32; i++) { if (i >= N) break; tot += abs(dat(float(i), float(d))); } float acc = 0.0; int hit = -1; float a0 = 0.0, a1 = 0.0;
  for (int i = 0; i < 32; i++) { if (i >= N) break; float w = abs(dat(float(i), float(d))) / max(tot, 1e-6) * 6.2832; if (ang >= acc && ang < acc + w) { hit = i; a0 = acc; a1 = acc + w; } acc += w; }
  if (hit < 0) { o = s; return; } float gap = radians(p_bosluk) * 0.5; float rgap = 1.0 / u_s; if (ang < a0 + gap || ang > a1 - gap || fract((r - R0) / th) * th < rgap) { o = s; return; }
  vec3 c = serCol(float(hit), vec3(0.25, 0.55, 1.0)); c = mix(c, vec3(1.0), float(d) / float(max(D, 1)) * 0.45); vec4 res = vec4(c, 1.0);
  if (p_etiket > 0.5 && d == 0) { float am = (a0 + a1) * 0.5; vec2 lp = (q - vec2(cos(am), sin(am)) * (R0 + th * 0.5)) / (th * 0.18); res = overPre(vec4(1.0) * numAt(lp, (a1 - a0) / 6.2832 * 100.0), res); } o = res; }
