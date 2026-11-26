// plotfunc
uniform vec4 p_dv4[33]; float dvAt(int i) { return i < 0 || i >= 132 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_dvN, p_xOlce, p_ilerleme, p_teget;
// Motor: ifadenin 128 örneği (x ∈ [−2π·ölçek, 2π·ölçek]) ve en büyük |f|; eksenler, ilerlemeye kadar eğri, uçta teğet
float fy(float u) { if (p_dvN > 1.5) { float f = clamp(u, 0.0, 1.0) * 127.0; int i = int(floor(f)); return mix(dvAt(i), dvAt(min(i + 1, 127)), fract(f)) / max(dvAt(128), 1e-6); } float x = (u * 2.0 - 1.0) * 6.2832 * p_xOlce; return sin(x); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 g = vec2(b.x, 0.5 - b.y) ; float aa = 1.5 / u_box.w; vec4 res = s;
  float axes = (1.0 - smoothstep(0.0, aa, abs(g.y))) + (1.0 - smoothstep(0.0, aa * u_box.w / u_box.z, abs(b.x - 0.5))); res = overPre(vec4(vec3(0.7), 1.0) * clamp(axes, 0.0, 1.0) * 0.6, res);
  float lim = p_ilerleme / 100.0; float y = fy(b.x) * 0.42; float du = 1.0 / u_box.z; float sl = (fy(b.x + du) - fy(b.x - du)) * 0.42 / (2.0 * du) * u_box.z / u_box.w; float d = abs(g.y - y) / sqrt(1.0 + sl * sl);
  float c = (1.0 - smoothstep(aa, aa * 2.5, d)) * step(b.x, lim); res = overPre(vec4(1.0, 0.75, 0.3, 1.0) * c, res);
  if (p_teget > 0.5 && lim > 0.0) { float y0 = fy(lim) * 0.42; float s0 = (fy(lim + du) - fy(lim - du)) * 0.42 / (2.0 * du); float ly = y0 + s0 * (b.x - lim); float td = abs(g.y - ly) / sqrt(1.0 + s0 * s0 * u_box.z * u_box.z / (u_box.w * u_box.w));
    res = overPre(vec4(0.4, 0.8, 1.0, 1.0) * (1.0 - smoothstep(aa * 0.6, aa * 1.6, td)) * step(abs(b.x - lim), 0.15), res); res = overPre(vec4(1.0) * (1.0 - smoothstep(aa * 2.0, aa * 3.5, length((vec2(b.x, g.y) - vec2(lim, y0)) * vec2(u_box.z / u_box.w, 1.0)))), res); }
  o = res; }
