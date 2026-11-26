// threads
uniform float p_iplikGeni, p_aralik, p_aci, p_dokumaDeri, p_yatayDikeBagl; uniform vec3 c_renk1, c_renk2;
void main() {
  vec2 p = rot2(-p_aci) * toUnit(here()); float per = max(p_iplikGeni + p_aralik, 1.0); vec2 f = mod(p, per); vec2 id = floor(p / per);
  float h = 1.0 - smoothstep(p_iplikGeni - 0.7, p_iplikGeni, f.y), v = 1.0 - smoothstep(p_iplikGeni - 0.7, p_iplikGeni, f.x);
  bool over = mod(id.x + id.y, 2.0) < 0.5;
  float sh = p_dokumaDeri / 100.0;
  vec3 hc = c_renk1 * (1.0 - sh * 0.6 * pow(abs(f.y / max(p_iplikGeni, 0.1) - 0.5) * 2.0, 2.0)) * (over ? 1.0 : 1.0 - sh * 0.4);
  vec3 vc = c_renk2 * (1.0 - sh * 0.6 * pow(abs(f.x / max(p_iplikGeni, 0.1) - 0.5) * 2.0, 2.0)) * (over ? 1.0 - sh * 0.4 : 1.0);
  vec4 c = vec4(0.0); if (over) { c = mix(c, vec4(vc, 1.0), v); c = mix(c, vec4(hc, 1.0), h); } else { c = mix(c, vec4(hc, 1.0), h); c = mix(c, vec4(vc, 1.0), v); }
  o = genOver(c);
}
