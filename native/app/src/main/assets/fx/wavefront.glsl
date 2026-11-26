// wavefront
uniform vec2 p_merkez; uniform vec3 c_renk; uniform float p_yaricap, p_cepheGeni, p_artciSure;
// Tek enerji cephesi: yarıçapta parlak halka, içeride sönen artçı iz; geçtiği yüzeyler aydınlanır
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float r = length(q - p_merkez); float R = p_yaricap; float w = max(p_cepheGeni, 0.5);
  float front = exp(-pow((r - R) / w, 2.0)); float trail = r < R ? exp(-(R - r) / max(w * 2.0 + p_artciSure * 120.0, 1.0)) * 0.45 : 0.0;
  float k = front + trail; vec3 lit = s.rgb + c_renk * k * (s.a * 0.9 + 0.35); o = vec4(lit, max(s.a, clamp(front * 0.85 + trail * 0.25, 0.0, 1.0))); }
