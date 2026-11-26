// rollingfix
uniform float p_okumaYonu, p_guc, p_satirYumu, p_elleYataEgim, p_elleDikeEgim, p_kenarDold;
void main() { vec2 b = boxUV(here()); float pos = p_okumaYonu < 0.5 ? b.y : p_okumaYonu < 1.5 ? 1.0 - b.y : p_okumaYonu < 2.5 ? b.x : 1.0 - b.x; float k = (pos - 0.5) * p_guc / 100.0;
  pos = mix(pos, smoothstep(0.0, 1.0, pos), p_satirYumu / 100.0); k = (pos - 0.5) * p_guc / 100.0;
  vec2 off = (p_okumaYonu < 1.5 ? vec2(tan(radians(p_elleYataEgim)) * boxU().y, -(p_elleDikeEgim / 100.0) * boxU().y) : vec2(-(p_elleDikeEgim / 100.0) * boxU().x, tan(radians(p_elleYataEgim)) * boxU().x)) * k;
  vec2 q = toUnit(here()) - off; vec2 bb = boxUV(fromUnit(q)); bool outB = any(lessThan(bb, vec2(0.0))) || any(greaterThan(bb, vec2(1.0)));
  vec4 c = texU(q); if (outB) c = p_kenarDold < 0.5 ? vec4(0.0) : texEdge(fromUnit(q), 3.0); if (p_kenarDold > 1.5) { vec2 m = abs(off) / boxU() * 1.05; vec2 cb = boxUV(here()); if (any(lessThan(cb, m)) || any(greaterThan(cb, 1.0 - m))) c = vec4(0.0); }
  o = c; }
