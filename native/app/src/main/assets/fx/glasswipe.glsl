// glasswipe
uniform vec2 p_merkez; uniform float p_ilerleme, p_parcaSayi, p_dagilma, p_kirilma, p_kenarParl, p_tohum, p_ters;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); float pr = p_ilerleme / 100.0; if (p_ters > 0.5) pr = 1.0 - pr; float cs = sqrt(B.x * B.y / max(p_parcaSayi, 2.0));
  vec4 v = voronoi(q / cs + seedf(p_tohum)); vec2 cid = v.zw; float h = hash1(cid); float d = length((cid - seedf(p_tohum)) * cs - p_merkez) / length(B);
  float pp = clamp(pr * 1.8 - d - h * 0.3, 0.0, 1.0); vec2 off = (hash2(cid) - 0.5) * p_dagilma * pp + vec2(0.0, p_dagilma * pp * pp); vec4 c = texU(q - off + (hash2(cid + 3.0) - 0.5) * p_kirilma);
  float edge = 1.0 - smoothstep(0.0, 0.08, v.y - v.x); c.rgb += edge * p_kenarParl / 100.0 * c.a * (1.0 - pp); o = c * (1.0 - pp); }
