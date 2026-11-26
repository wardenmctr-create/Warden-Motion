// magnify
uniform vec2 p_merkez; uniform float p_yaricap, p_buyutme, p_kenarYumu, p_cerceve, p_cerceveKali; uniform vec3 c_cerceveReng;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float d = length(r); float R = max(p_yaricap, 1.0);
  vec4 orig = texU(q), mag = texU(p_merkez + r / max(p_buyutme, 0.05));
  float w = 1.0 - smoothstep(R - max(p_kenarYumu, 0.5), R, d);
  vec4 c = mix(orig, mag, w);
  if (p_cerceve > 0.5) { float ring = smoothstep(R - 0.6, R + 0.2, d) * (1.0 - smoothstep(R + p_cerceveKali - 0.2, R + p_cerceveKali + 0.6, d)); c = mix(c, vec4(c_cerceveReng, 1.0), ring); }
  o = c;
}
