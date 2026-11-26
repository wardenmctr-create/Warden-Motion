// lens
uniform vec2 p_mercekMerk; uniform float p_yaricap, p_kirilma, p_buyutme, p_kenarGeci, p_renkSaca;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_mercekMerk; float R = max(p_yaricap, 1.0); float x = length(r) / R;
  if (x >= 1.0) { o = texU(q); return; }
  float z = sqrt(1.0 - x * x); float k = mix(1.0, z, clamp((p_kirilma - 1.0) / 2.0, 0.0, 1.0));
  vec2 s = r * k / max(p_buyutme, 0.05);
  float ca = p_renkSaca * x;
  vec4 c = vec4(texU(p_mercekMerk + s * (1.0 + ca / R)).r, texU(p_mercekMerk + s).g, texU(p_mercekMerk + s * (1.0 - ca / R)).b, texU(p_mercekMerk + s).a);
  float w = 1.0 - smoothstep(R - max(p_kenarGeci, 0.5), R, length(r));
  o = mix(texU(q), c, w);
}
