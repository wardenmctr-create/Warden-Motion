// wangtiles
uniform float p_karoTuru, p_boyut, p_tohum;
float edgeCol(vec2 e) { return floor(hash1(e + seedf(p_tohum)) * 2.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) / max(p_boyut, 2.0); vec2 id = floor(q); vec2 f = fract(q) - 0.5;
  float n = edgeCol(vec2(id.x, id.y + 0.5) * 3.1), so = edgeCol(vec2(id.x, id.y - 0.5) * 3.1), e = edgeCol(vec2(id.x + 0.5, id.y) * 7.3), w = edgeCol(vec2(id.x - 0.5, id.y) * 7.3);
  float v = 0.0; v += n * smoothstep(0.35, 0.0, length(f - vec2(0.0, 0.5))); v += so * smoothstep(0.35, 0.0, length(f + vec2(0.0, 0.5))); v += e * smoothstep(0.35, 0.0, length(f - vec2(0.5, 0.0))); v += w * smoothstep(0.35, 0.0, length(f + vec2(0.5, 0.0)));
  float lines = step(0.5, fract(v * max(p_karoTuru, 2.0) * 0.25)); vec3 c = mix(vec3(0.08, 0.12, 0.25), vec3(0.3, 0.7, 1.0), clamp(v, 0.0, 1.0)); c = mix(c, c * 0.7, lines * 0.4); o = pre(c, s.a); }
