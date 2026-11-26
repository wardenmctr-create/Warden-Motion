// 800 rehberi, bölüm 6: karakter parçaları (691, 692, 696, 699)
//== eyelid
uniform sampler2D s_gozMask; uniform float p_gozMaskOn, p_ustAltKapa, p_kavis;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float k = p_ustAltKapa / 100.0; float bend = (p_kavis / 100.0) * 0.35 * (1.0 - pow(2.0 * b.x - 1.0, 2.0));
  float top = k * 0.5 + bend * k; float bot = 1.0 - k * 0.5 - bend * k * 0.6; float open_ = smoothstep(top - 0.01, top + 0.01, b.y) * smoothstep(bot + 0.01, bot - 0.01, b.y);
  if (p_gozMaskOn > 0.5) open_ = mix(1.0, open_, texture(s_gozMask, clamp(b, 0.0, 1.0)).a); o = s * open_; }
//== poseblend
uniform sampler2D s_ikiPoz; uniform float p_ikiPozOn, p_karisim, p_simetri;
void main() { vec4 s = texture(u_tex, v_uv); if (p_ikiPozOn < 0.5) { o = s; return; } vec2 b = clamp(boxUV(here()), 0.0, 1.0); vec4 c = texture(s_ikiPoz, b); if (p_simetri > 0.5) c = mix(c, texture(s_ikiPoz, vec2(1.0 - b.x, b.y)), 0.5 * step(0.5, b.x) * 0.0); o = mix(s, c, p_karisim / 100.0); }
//== elasticline
uniform float p_gerilim, p_sarkma, p_dvN; uniform float p_dv[8];
void main() { vec4 s = texture(u_tex, v_uv); vec2 A = p_dvN >= 4.0 ? vec2(p_dv[0], p_dv[1]) : vec2(-boxU().x * 0.4, 0.0), B = p_dvN >= 4.0 ? vec2(p_dv[2], p_dv[3]) : vec2(boxU().x * 0.4, 0.0); vec2 q = toUnit(here());
  float span = length(B - A); float sag = p_sarkma * (1.0 - p_gerilim / 100.0) * (1.0 + 0.1 * sin(u_t * 3.0) * (1.0 - p_gerilim / 100.0)); float best = 1e9; vec2 prev = A;
  for (int i = 1; i <= 32; i++) { float t = float(i) / 32.0; vec2 pp = mix(A, B, t) + vec2(0.0, 4.0 * t * (1.0 - t) * sag); vec2 ab = pp - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); best = min(best, length(q - prev - ab * u)); prev = pp; }
  float w = mix(3.0, 1.5, clamp(span / 600.0, 0.0, 1.0)); o = overPre(vec4(0.95, 0.85, 0.7, 1.0) * (1.0 - smoothstep(w, w + 1.0, best)), s); }
//== lattice
uniform float p_satirSutu, p_esneklik; uniform vec2 p_kafesNokt;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); float N = max(floor(p_satirSutu), 2.0); vec2 b = boxUV(here()); vec2 g = b * (N - 1.0); vec2 c = vec2((N - 1.0) * 0.5);
  float w = exp(-dot(g - c, g - c) / max(N * N * 0.08 * (0.3 + p_esneklik / 100.0), 0.01)); o = texU(q - p_kafesNokt * w); }
