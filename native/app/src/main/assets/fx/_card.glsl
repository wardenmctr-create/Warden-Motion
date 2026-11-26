// Katman kartı (alfa siluetinden kalınlık verilmiş levha) — 800 rehberi 3B deformasyonları bunun üzerinde çalışır
float cardA(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; return texPx(boxPx(b)).a; }
float cardD(vec3 p, float th) { float d2 = (0.5 - cardA(p.xy)) * 6.0; vec2 w = vec2(d2, abs(p.z) - th * 0.5); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); }
vec4 cardSurf(vec3 p, vec3 n) { vec2 b = vec2(p.x, -p.y) / boxU() + 0.5; vec4 c = layerAt(clamp(b, 0.0, 1.0)); vec3 col = c.a > 0.0 ? c.rgb : c_tabanRenk; return vec4(abs(n.z) > 0.6 ? col : col * 0.7, 1.0); }
