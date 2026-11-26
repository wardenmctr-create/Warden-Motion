// lightcurtain
uniform vec2 p_merkez; uniform vec3 c_renk; uniform float p_genislik, p_dalga, p_akis;
// Dalgalanan enerji perdesi: dikey bant, katlı kıvrımlar (kıvrım eğimi parlak), arka planı hafif kırar
void main() { vec2 q = toUnit(here()); float y = q.y; float t = u_t * p_akis;
  float off = sin(y * 0.012 + t * 2.1) * p_dalga + sin(y * 0.031 - t * 3.3) * p_dalga * 0.35; float x = q.x - p_merkez.x - off; float hw = max(p_genislik * 0.5, 1.0);
  float band = smoothstep(hw, hw * 0.6, abs(x)); float folds = 0.5 + 0.5 * sin(x / hw * 9.0 + sin(y * 0.02 + t) * 2.0 + t * 1.7); float slope = abs(cos(y * 0.012 + t * 2.1)) * 0.5 + 0.5;
  float vfade = smoothstep(-boxU().y * 0.5, -boxU().y * 0.2, y) * (0.6 + 0.4 * smoothstep(boxU().y * 0.5, boxU().y * 0.1, y));
  float a = band * (0.18 + 0.55 * pow(folds, 3.0) * slope) * vfade; vec4 s = texU(q + vec2(sin(y * 0.05 + t * 3.0), 0.0) * band * 3.0);
  o = vec4(s.rgb + c_renk * a, max(s.a, a)); }
