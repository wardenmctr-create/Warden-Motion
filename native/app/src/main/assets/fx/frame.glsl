// frame
uniform float p_cerceveKali, p_icBosl, p_koseYari, p_opaklik, p_konum; uniform vec3 c_renk;
float rbox(vec2 p, vec2 b, float r) { vec2 q = abs(p) - b + r; return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r; }
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU() * 0.5;
  float w = p_cerceveKali; vec2 bb = p_konum < 0.5 ? B - p_icBosl - w : p_konum < 1.5 ? B + p_icBosl : B - w * 0.5;
  float d = rbox(q, bb, min(p_koseYari, min(bb.x, bb.y)));
  float ring = smoothstep(-0.6, 0.6, d) * (1.0 - smoothstep(w - 0.6, w + 0.6, d));
  o = overPre(vec4(c_renk, 1.0) * ring * p_opaklik / 100.0, s);
}
