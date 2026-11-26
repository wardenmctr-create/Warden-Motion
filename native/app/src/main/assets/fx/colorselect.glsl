// colorselect
uniform float p_tolerans, p_renkUzay; uniform vec3 c_ornekRenk;
vec3 lab(vec3 c) { vec3 l = srgb2lin(c); vec3 xyz = mat3(0.4124, 0.2126, 0.0193, 0.3576, 0.7152, 0.1192, 0.1805, 0.0722, 0.9505) * l; xyz /= vec3(0.9505, 1.0, 1.089); vec3 f = mix(pow(xyz, vec3(1.0 / 3.0)), xyz * 7.787 + 16.0 / 116.0, step(xyz, vec3(0.008856)));
  return vec3(116.0 * f.y - 16.0, 500.0 * (f.x - f.y), 200.0 * (f.y - f.z)); }
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float d; if (p_renkUzay < 0.5) d = length(lab(c) - lab(c_ornekRenk)) / 100.0; else if (p_renkUzay < 1.5) { vec3 a = rgb2hsv(c), b = rgb2hsv(c_ornekRenk); float dh = abs(a.x - b.x); dh = min(dh, 1.0 - dh); d = length(vec3(dh * 2.0, a.y - b.y, (a.z - b.z) * 0.5)); } else d = length(c - c_ornekRenk) / 1.732;
  float m = 1.0 - smoothstep(p_tolerans / 100.0 * 0.8, p_tolerans / 100.0 * 1.2 + 0.01, d); o = pre(c, s.a * m); }
