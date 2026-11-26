// infmirror
uniform vec2 p_merkez, p_kopyaKonuFark; uniform float p_yansimaSayi, p_kuculmeOran, p_derinlikAral, p_kopyaDonu, p_opaklikKayb, p_yatayAyna, p_dikeyAyna, p_renkGeci, p_uzakKopyBula, p_derinlikHare; uniform vec3 c_uzakKopyReng;
void main() { vec2 q = toUnit(here()); vec4 res = texU(q); int N = int(clamp(p_yansimaSayi, 1.0, 40.0)); float k = clamp(p_kuculmeOran / 100.0, 0.1, 0.98);
  float ph = fract(u_t * p_derinlikHare / 100.0);
  for (int i = 1; i <= 40; i++) { if (i > N) break; float fi = float(i) - ph; float sc = pow(k, fi); vec2 l = rot2(-p_kopyaDonu * fi) * (q - p_merkez - p_kopyaKonuFark * fi) / sc + p_merkez;
    if (mod(float(i), 2.0) > 0.5) { if (p_yatayAyna > 0.5) l.x = -l.x; if (p_dikeyAyna > 0.5) l.y = -l.y; }
    vec4 c = texU(l); float fade = clamp(1.0 - p_opaklikKayb / 100.0 * fi, 0.0, 1.0); if (p_renkGeci > 0.5 && c.a > 0.0) c.rgb = mix(c.rgb, c_uzakKopyReng * c.a, clamp(fi / float(N), 0.0, 1.0));
    res = overPre(c * fade, res); } // her küçük kopya bir öncekinin önünde: sonsuz tünel
  o = res; }
