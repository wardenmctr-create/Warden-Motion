// areameter
INCLUDE(_chart)
uniform vec3 c_etiket; uniform float p_alfaEsig, p_olcu, p_izCizg;
// 32×32 örnekle alan (%), çevre (kenar hücre sayısı) ve ağırlık merkezi; sayaç kutunun sol üstünde, merkez artı işaretiyle
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float th = p_alfaEsig / 100.0; float area = 0.0, per = 0.0; vec2 cen = vec2(0.0);
  for (int j = 0; j < 32; j++) for (int i = 0; i < 32; i++) { vec2 u = (vec2(i, j) + 0.5) / 32.0; float a = step(th, texPx(boxPx(u)).a); area += a; cen += u * a;
    if (a > 0.5) { float nb = step(th, texPx(boxPx(u + vec2(1.0 / 32.0, 0.0))).a) * step(th, texPx(boxPx(u - vec2(1.0 / 32.0, 0.0))).a) * step(th, texPx(boxPx(u + vec2(0.0, 1.0 / 32.0))).a) * step(th, texPx(boxPx(u - vec2(0.0, 1.0 / 32.0))).a); per += 1.0 - nb; } }
  cen /= max(area, 1.0); float val = p_olcu < 0.5 ? area / 1024.0 * 100.0 : (p_olcu < 1.5 ? per * (u_box.z / u_s) / 32.0 : cen.x * 100.0);
  vec4 res = s; vec2 lp = (b - vec2(0.12, 0.08)) / vec2(0.035, 0.045); float nm = numAt(lp, val); res = overPre(vec4(c_etiket, 1.0) * nm, res);
  vec2 d = abs((b - cen) * u_box.zw); float cross2 = (d.x < 1.2 && d.y < 8.0) || (d.y < 1.2 && d.x < 8.0) ? 1.0 : 0.0; if (area > 0.0) res = overPre(vec4(c_etiket, 1.0) * cross2, res); o = res; }
