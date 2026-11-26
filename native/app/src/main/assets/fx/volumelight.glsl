// volumelight
uniform sampler2D s_engelleyKatm; uniform float p_engelleyKatmOn;
uniform vec2 p_isikKonu; uniform float p_isikTuru, p_isikYonu, p_isinUzun, p_isinGeni, p_koniAcis, p_isikGucu, p_yumusakl, p_sisYogu, p_isikSaci, p_havadakiTozl, p_tozYogu, p_katmanlaIsigEnge; uniform vec3 c_isikReng;
float occAt(vec2 u) { if (p_katmanlaIsigEnge < 0.5) return 0.0; if (p_engelleyKatmOn > 0.5) return texture(s_engelleyKatm, clamp(boxUV(fromUnit(u)), 0.0, 1.0)).a; return texU(u).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 L = p_isikKonu; vec2 d = q - L; float r = length(d); vec2 dir = vec2(cos(radians(p_isikYonu)), sin(radians(p_isikYonu)));
  float cone; if (p_isikTuru < 0.5 || p_isikTuru > 2.5) { float ang = acos(clamp(dot(normalize(d + 1e-4), dir), -1.0, 1.0)); float half_ = radians(p_isikTuru > 2.5 ? p_koniAcis : p_koniAcis * 0.7); cone = 1.0 - smoothstep(half_ * (1.0 - p_yumusakl / 200.0), half_ * (1.0 + p_yumusakl / 200.0), ang); }
  else if (p_isikTuru < 1.5) { float px = abs(dot(d, vec2(-dir.y, dir.x))); cone = (1.0 - smoothstep(p_isinGeni * 0.4, p_isinGeni * 0.5 + p_yumusakl, px)) * step(0.0, dot(d, dir)); }
  else cone = 1.0;
  float fall = exp(-r / max(p_isinUzun, 1.0) * 2.0); float shaft = 1.0;
  if (p_katmanlaIsigEnge > 0.5) { float occ = 0.0; for (int i = 1; i <= 16; i++) { occ = max(occ, occAt(L + d * float(i) / 17.0)); } shaft = 1.0 - occ; }
  float fog = 0.35 + 0.65 * fbm01(q * 0.01 + u_t * 0.05, 3.0) * p_sisYogu / 100.0 * 2.0; float rays = mix(1.0, 0.6 + 0.4 * fbm01(vec2(atan(d.y, d.x) * 8.0, u_t * 0.1), 2.0), p_isikSaci / 100.0);
  float I = cone * fall * shaft * fog * rays * p_isikGucu / 100.0; float dust = 0.0;
  if (p_havadakiTozl > 0.5) { vec2 g = (q + vec2(u_t * 4.0, -u_t * 6.0)) / 7.0; vec2 id = floor(g); float hh = hash1(id); dust = step(1.0 - p_tozYogu / 100.0 * 0.3, hh) * (1.0 - smoothstep(0.03, 0.12, length(fract(g) - 0.5 - (hash2(id) - 0.5) * 0.6))) * cone * fall; }
  o = overPre(vec4(c_isikReng, 1.0) * clamp(I * 0.8 + dust, 0.0, 1.0), s); }
