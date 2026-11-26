// hexarray
uniform float p_altigenBoyu, p_aralik, p_aci, p_konturKali, p_yalnizKont; uniform vec2 p_ofset; uniform vec3 c_dolgu, c_kontur;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_aci) * toUnit(here()) + p_ofset / 100.0 * boxU(); float sz = max(p_altigenBoyu, 2.0);
  vec4 h = hexGrid(q, sz); float d = hexDist((q - h.xy) / sz) * sz; float edge = sz * 0.5 - p_aralik * 0.5; float px = 0.7 / u_s;
  float inside = 1.0 - smoothstep(edge - px, edge + px, d); float ring = inside * smoothstep(edge - p_konturKali - px, edge - p_konturKali + px, d);
  float cov = texU(rot2(p_aci) * (h.xy - p_ofset / 100.0 * boxU())).a; // hücre merkezi doluysa
  vec4 c = vec4(0.0); if (p_yalnizKont < 0.5) c = vec4(c_dolgu, 1.0) * inside; c = mix(c, vec4(c_kontur, 1.0), ring * step(0.01, p_konturKali));
  o = c * step(0.5, cov) + vec4(0.0);
}
