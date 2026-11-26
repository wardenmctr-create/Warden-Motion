// edgeflow
uniform sampler2D s_sinir; uniform float p_sinirOn, p_akis, p_dogum, p_omur, p_kenarOfse;
// Zerreler silüet sınırında (ofsetli bant) yakalanır ve kenar boyunca akar; doğum/ömür ile parıldar
float A(vec2 px) { return p_sinirOn > 0.5 ? texture(s_sinir, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float off = p_kenarOfse * u_s; float R = 6.0 * u_s; float inside = step(0.5, A(p));
  float d = inside > 0.5 ? -innerDist(p, R * 4.0) : outerDist(p, R * 4.0); if (p_sinirOn > 0.5) d = (inside > 0.5 ? -1.0 : 1.0) * 2.0; float band = 1.0 - smoothstep(1.0, 2.5 * u_s, abs(d - off));
  if (band <= 0.0) { o = s; return; } vec2 q = toUnit(p); float ang = atan(q.y, q.x); float rad = length(q); float arc = ang * max(rad, 1.0); float N = max(p_dogum, 1.0);
  float v = 0.0; for (int i = 0; i < 3; i++) { float sp = arc - u_t * p_akis * (0.8 + 0.2 * float(i)); float cellL = 6.2832 * max(rad, 1.0) / N * 3.0; float id = floor(sp / cellL + float(i) * 0.37);
    float life = fract(u_t / max(p_omur, 0.1) + hash1(vec2(id, float(i)))); float x = fract(sp / cellL + float(i) * 0.37); v = max(v, (1.0 - smoothstep(0.0, 0.08, abs(x - 0.5))) * sin(life * 3.14159)); }
  o = overPre(vec4(vec3(1.0, 0.95, 0.7) * v * band, v * band), s); }
