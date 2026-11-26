// vignette
uniform vec2 p_merkez; uniform float p_yaricap, p_yumusakl, p_guc, p_bicim, p_enBoy, p_ters; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 r = (toUnit(here()) - p_merkez) / (boxU() * 0.5); float d;
  if (p_bicim < 0.5) d = length(r); else if (p_bicim < 1.5) d = length(r * vec2(boxU().x / boxU().y, 1.0) * vec2(1.0 / max(p_enBoy, 0.1), 1.0)); else d = max(abs(r.x), abs(r.y));
  float R = p_yaricap / 100.0 * 1.2; float k = smoothstep(R * (1.0 - p_yumusakl / 100.0), R + 0.05, d); if (p_ters > 0.5) k = 1.0 - k;
  o = pre(mix(unpre(s), c_renk, k * p_guc / 100.0), s.a);
}
