// settleparticles
uniform sampler2D s_yuzey; uniform float p_yuzeyOn, p_uretim, p_yapisma, p_birikimTava, p_temizlen;
// Düşen zerreler; yüzeyin üst kenarlarında zamanla kalınlaşan tortu tabakası (yapışma × süre, tavan ile sınırlı)
float surf(vec2 px) { return p_yuzeyOn > 0.5 ? texture(s_yuzey, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float rate = p_uretim / 50.0; float depth = min(u_t * rate * p_yapisma / 100.0 * 6.0, p_birikimTava / 100.0 * 14.0) * u_s * max(0.0, 1.0 - p_temizlen / 100.0 * u_t * 0.3);
  float cov = 0.0; if (surf(p) < 0.5) for (int k = 1; k <= 8; k++) { float r = float(k) / 8.0 * depth; if (surf(p + vec2(0.0, r)) > 0.5) { cov = 1.0 - float(k - 1) / 8.0 * 0.3; break; } }
  float grain = 0.75 + 0.25 * hash1(floor(p / max(u_s, 1.0))); vec4 dep = vec4(vec3(0.93, 0.92, 0.88) * grain, 1.0) * cov;
  vec2 q = toUnit(p); float cell = 14.0 / sqrt(max(rate, 0.05)); vec2 g = (q + vec2(0.0, -u_t * 60.0)) / cell; vec2 id = floor(g); vec2 h = hash2(id); vec2 pos = (id + h) * cell + vec2(0.0, u_t * 60.0);
  float fall = (1.0 - smoothstep(1.0, 1.8, length(q - pos))) * step(surf(fromUnit(pos)), 0.5) * step(hash1(id + 5.0), min(rate * 0.5, 1.0)); o = overPre(vec4(0.95) * fall, overPre(dep, s)); }
