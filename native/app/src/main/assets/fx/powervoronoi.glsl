// powervoronoi
uniform float p_merkez, p_agirlikDagi, p_sinir;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cs = sqrt(boxU().x * boxU().y / max(p_merkez, 2.0)); vec2 g = floor(q / cs); float b1 = 1e9, b2 = 1e9; vec2 bid = vec2(0.0);
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 id = g + vec2(i, j); vec2 p = (id + hash2(id)) * cs; float wgt = (hash1(id + 5.0) - 0.5) * p_agirlikDagi / 100.0 * cs * cs; float d = dot(q - p, q - p) - wgt;
    if (d < b1) { b2 = b1; b1 = d; bid = id; } else if (d < b2) b2 = d; }
  float edge = 1.0 - smoothstep(p_sinir * cs * 0.5, p_sinir * cs * 0.5 + cs * 0.4, b2 - b1); vec3 c = unpre(texU((bid + 0.5) * cs)) * 0.9 + hsv2rgb(vec3(hash1(bid), 0.4, 0.5)) * 0.1; o = pre(mix(c, vec3(0.05), edge * step(0.01, p_sinir)), s.a); }
