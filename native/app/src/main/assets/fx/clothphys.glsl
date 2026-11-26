// clothphys
uniform float p_agCozu, p_sabitKena, p_sertlik, p_bukulmeDire, p_sonum, p_yercekim, p_ciftTaraGost, p_golgelen; uniform vec2 p_ruzgar;
void main() { vec2 q = toUnit(here()); vec2 b = boxUV(here()); vec2 B = boxU(); float u = p_sabitKena < 0.5 ? b.x : p_sabitKena < 1.5 ? 1.0 - b.x : p_sabitKena < 2.5 ? b.y : 1.0 - b.y; vec2 fdir = p_sabitKena < 0.5 ? vec2(1, 0) : p_sabitKena < 1.5 ? vec2(-1, 0) : p_sabitKena < 2.5 ? vec2(0, 1) : vec2(0, -1);
  float stiff = mix(1.6, 0.7, p_sertlik / 100.0); float w = pow(u, stiff); float wind = length(p_ruzgar); vec2 wd = wind > 0.0 ? p_ruzgar / wind : vec2(1.0, 0.0);
  float ph = q.y * 0.02 * (1.0 + p_bukulmeDire / 50.0) + q.x * 0.01 - u_t * (1.0 + wind / 150.0) * 2.0; float res = max(p_agCozu, 4.0) / 24.0;
  float h = (sin(ph * TAU / res) + 0.4 * sin(ph * TAU * 1.7 / res + 1.3)) * wind / 150.0 * 14.0 * w * (1.0 + 0.3 * exp(-u_t * p_sonum / 50.0));
  vec2 sag = vec2(0.0, p_yercekim / 100.0 * 12.0 * w * w); vec2 sq = q - vec2(-fdir.y, fdir.x) * h - sag - wd * w * wind * 0.02; vec4 c = texU(sq);
  float slope = cos(ph * TAU / res); if (p_golgelen > 0.5) c.rgb *= 1.0 + slope * w * 0.25 * min(wind / 150.0, 1.5); if (p_ciftTaraGost > 0.5 && slope * w < -0.7) c.rgb *= 0.75; o = c; }
