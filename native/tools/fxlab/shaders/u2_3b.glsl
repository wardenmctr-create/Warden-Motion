// Güncelleme: Kalınlık Ver (237)
//== extrude
INCLUDE(_3d)
uniform float p_derinlik, p_pah, p_kaynakDokuYanl, p_onYuz, p_kalinYon, p_yanRenkGuc, p_derinGecis, p_gecisGuc, p_pahSegment, p_inceKoru, p_siluetYumu, p_alfaYorum, p_alfaEsik, p_sekilGuncel;
uniform vec3 c_yanYuzReng, c_arkaYuzReng, c_derinSonRenk;
float aRaw(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; return texPx(boxPx(b)).a; }
float aAt(vec2 xy) { float a = aRaw(xy); if (p_siluetYumu > 0.0) { float r = p_siluetYumu; a = (a * 2.0 + aRaw(xy + vec2(r, 0.0)) + aRaw(xy - vec2(r, 0.0)) + aRaw(xy + vec2(0.0, r)) + aRaw(xy - vec2(0.0, r))) / 6.0; }
  if (p_alfaYorum < 0.5) return step(0.5, a); if (p_alfaYorum < 1.5) return a; if (p_alfaYorum < 2.5) return smoothstep(0.08, 0.6, a); return step(p_alfaEsik / 100.0, a); }
vec2 zRange() { float D = max(p_derinlik, 1.0); return p_kalinYon < 0.5 ? vec2(-D * 0.5, D * 0.5) : p_kalinYon < 1.5 ? vec2(0.0, D) : vec2(-D, 0.0); }
float sdf(vec3 p) { float a = aAt(p.xy); float d2 = (0.5 - a) * (p_inceKoru > 0.5 ? 4.0 : 6.0); vec2 zr = zRange(); float c = (zr.x + zr.y) * 0.5, h = (zr.y - zr.x) * 0.5;
  vec2 w = vec2(d2 + p_pah * 0.3, abs(p.z - c) - h + p_pah * 0.3); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - p_pah * 0.3; }
vec4 surf(vec3 p, vec3 n) { vec2 b = vec2(p.x, -p.y) / boxU() + 0.5; vec4 c = layerAt(b); vec3 col = c.a > 0.0 ? c.rgb : c_yanYuzReng;
  if (n.z > 0.7) return vec4(p_onYuz > 0.5 ? col : c_yanYuzReng, 1.0); if (n.z < -0.7) return vec4(c_arkaYuzReng, 1.0);
  vec3 side = mix(col * 0.8, c_yanYuzReng, p_kaynakDokuYanl > 0.5 ? 0.0 : p_yanRenkGuc / 100.0);
  if (p_derinGecis > 0.5) { vec2 zr = zRange(); float k = clamp((zr.y - p.z) / max(zr.y - zr.x, 1.0), 0.0, 1.0); side = mix(side, c_derinSonRenk, k * p_gecisGuc / 100.0); }
  if (p_pahSegment > 1.5) side *= 0.9 + 0.1 * floor(abs(n.z) * p_pahSegment) / p_pahSegment;
  return vec4(side, 1.0); }
void main() { o = render3d(vec3(0.0)); }
