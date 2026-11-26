// depthparallax
uniform sampler2D s_derinlikHari, s_derinlikKatm; uniform float p_derinlikHariOn, p_derinlikKatmOn;
uniform float p_derinlikKayn, p_derinligTersCevi, p_derinlikGucu, p_derinlikYumu, p_derinlikKatmSayi, p_yakinlas, p_paralaksGucu, p_bosluklaDold, p_boslukDold, p_kenarlarKoru; uniform vec2 p_kameraKaym; uniform vec3 p_kameraDonu;
float depthAt(vec2 px) { vec2 b = clamp(boxUV(px), 0.0, 1.0); float d;
  if (p_derinlikKayn < 0.5 && p_derinlikHariOn > 0.5) d = luma(unpre(texture(s_derinlikHari, b))); else if (p_derinlikKayn > 0.5 && p_derinlikKayn < 1.5 && p_derinlikKatmOn > 0.5) d = luma(unpre(texture(s_derinlikKatm, b)));
  else if (p_derinlikKayn > 1.5 && p_derinlikKayn < 2.5) d = 1.0 - b.y; else d = luma(unpre(texPx(px)));
  if (p_derinligTersCevi > 0.5) d = 1.0 - d; float L = max(p_derinlikKatmSayi, 1.0); if (L < 63.5) d = floor(d * L + 0.5) / L; return d * p_derinlikGucu / 100.0; }
void main() { vec2 cam = p_kameraKaym * p_paralaksGucu / 100.0; float zoom = max(p_yakinlas / 100.0, 0.1); vec2 q = toUnit(here()); vec2 cur = q; float d = 0.0;
  for (int i = 0; i < 6; i++) { float blur = p_derinlikYumu * u_s; d = (depthAt(fromUnit(cur)) + depthAt(fromUnit(cur) + vec2(blur, 0.0)) + depthAt(fromUnit(cur) - vec2(0.0, blur))) / 3.0;
    vec2 tilt = vec2(p_kameraDonu.y, -p_kameraDonu.x) * 2.0; cur = (q - (cam + tilt) * d) / mix(1.0, zoom, d) ; }
  vec4 c = texU(cur); vec2 b = boxUV(fromUnit(cur)); bool out_ = any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)));
  if (out_ && p_bosluklaDold > 0.5) { if (p_boslukDold < 0.5) c = texEdge(fromUnit(cur), 3.0); else if (p_boslukDold < 1.5) { vec2 m = abs(mod(b, 2.0)); m = mix(m, 2.0 - m, step(1.0, m)); c = texture(u_tex, mix(v_uv, v_uv, 0.0)) * 0.0 + texPx(boxPx(m)); } else c = vec4(0.0); }
  o = c; }
