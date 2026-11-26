// colorslice
uniform float p_uzay, p_eksen, p_kesit, p_kaynakNoktGost;
// Kutunun içi bir renk uzayı dilimi: iki serbest eksen x-y, üçüncü eksen = kesit; kaynak pikselleri dilime yakınsa nokta
vec3 fromSpace(vec3 v) { if (p_uzay < 0.5) { float L = v.x * 100.0, A = (v.y - 0.5) * 200.0, B = (v.z - 0.5) * 200.0; float fy = (L + 16.0) / 116.0, fx = fy + A / 500.0, fz = fy - B / 200.0;
    vec3 f = vec3(fx, fy, fz); vec3 r = mix((f - 16.0 / 116.0) / 7.787, f * f * f, step(0.2069, f)); vec3 xyz = r * vec3(0.9505, 1.0, 1.089);
    vec3 lin = mat3(3.2406, -0.9689, 0.0557, -1.5372, 1.8758, -0.2040, -0.4986, 0.0415, 1.0570) * xyz; return clamp(lin2srgb(lin), 0.0, 1.0); }
  if (p_uzay < 1.5) return hsv2rgb(v); return v; }
vec3 toSpace(vec3 c) { if (p_uzay < 0.5) { vec3 lin = srgb2lin(c); vec3 xyz = mat3(0.4124, 0.2126, 0.0193, 0.3576, 0.7152, 0.1192, 0.1805, 0.0722, 0.9505) * lin / vec3(0.9505, 1.0, 1.089);
    vec3 f = mix(7.787 * xyz + 16.0 / 116.0, pow(max(xyz, 1e-6), vec3(1.0 / 3.0)), step(0.008856, xyz)); return vec3((116.0 * f.y - 16.0) / 100.0, (500.0 * (f.x - f.y)) / 200.0 + 0.5, (200.0 * (f.y - f.z)) / 200.0 + 0.5); }
  if (p_uzay < 1.5) return rgb2hsv(c); return c; }
vec3 compose(vec2 xy, float z) { int e = int(p_eksen + 0.5); return e == 0 ? vec3(z, xy) : (e == 1 ? vec3(xy.x, z, xy.y) : vec3(xy, z)); }
vec2 project(vec3 v, out float z) { int e = int(p_eksen + 0.5); if (e == 0) { z = v.x; return v.yz; } if (e == 1) { z = v.y; return v.xz; } z = v.z; return v.xy; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = s; return; }
  vec2 xy = vec2(b.x, 1.0 - b.y); vec3 c = fromSpace(compose(xy, p_kesit / 100.0)); vec4 res = vec4(c, 1.0);
  if (p_kaynakNoktGost > 0.5) for (int j = 0; j < 14; j++) for (int i = 0; i < 14; i++) { vec4 q = texPx(boxPx((vec2(i, j) + 0.5) / 14.0)); if (q.a < 0.3) continue; float z; vec2 pp = project(toSpace(unpre(q)), z);
    if (abs(z - p_kesit / 100.0) > 0.12) continue; float d = length((pp - xy) * u_box.zw); res = mix(res, vec4(1.0), (1.0 - smoothstep(2.0, 3.5, d)) * 0.9); }
  o = res; }
