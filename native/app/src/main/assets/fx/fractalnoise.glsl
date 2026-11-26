// fractalnoise
uniform float p_fraktalTuru, p_olcek, p_kontrast, p_parlakli, p_karmasik, p_evrim, p_tohum, p_ters, p_orantili, p_altOlcek, p_altEtki, p_altDonus, p_evrimHiz, p_dongu, p_donguSure, p_gorunum;
uniform vec2 p_kayma, p_olcekXY, p_altKayma; uniform vec3 c_koyuRenk, c_acikRenk;
void main() {
  vec2 so = max(p_olcekXY, vec2(1.0)) / 100.0; if (p_orantili > 0.5) so = vec2(so.x);
  vec2 p = (toUnit(here()) + p_kayma) / (max(p_olcek, 1.0) * so) + seedf(p_tohum); float ev = radians(p_evrim + p_evrimHiz * u_t);
  if (p_dongu > 0.5) ev = TAU * fract(u_t / max(p_donguSure, 0.1)) + radians(p_evrim);
  vec2 evv = vec2(cos(ev), sin(ev)) * 0.8; float s = 0.0, a = 0.5, n = 0.0; vec2 q = p; float sub = max(p_altOlcek, 1.0) / 100.0; float inf = p_altEtki / 100.0 * 2.0;
  for (int i = 0; i < 10; i++) { if (float(i) >= p_karmasik) break; float v;
    if (p_gorunum < 0.5 && p_fraktalTuru < 0.5) v = pnoise(q + evv * float(i + 1)) * 0.5 + 0.5; else if (p_gorunum > 2.5 && p_gorunum < 3.5 || p_fraktalTuru > 1.5) v = pow(1.0 - abs(pnoise(q + evv)), 3.0);
    else if (p_gorunum > 1.5 && p_gorunum < 2.5) v = hash1(floor(q * 2.0) + float(i)); else if (p_gorunum > 3.5) v = voronoi(q + evv).x; else v = abs(pnoise(q + evv * float(i + 1)));
    if (p_gorunum > 0.5 && p_gorunum < 1.5) v = smoothstep(0.35, 0.65, v);
    s += v * a; n += a; q = rot2(p_altDonus) * q / sub + 7.7 + p_altKayma * 0.01; a *= 0.5 * inf; }
  float v = s / max(n, 1e-4); v = (v - 0.5) * p_kontrast / 100.0 + 0.5 + p_parlakli / 100.0; v = clamp(v, 0.0, 1.0); if (p_ters > 0.5) v = 1.0 - v;
  o = genOver(vec4(mix(c_koyuRenk, c_acikRenk, v), 1.0));
}
