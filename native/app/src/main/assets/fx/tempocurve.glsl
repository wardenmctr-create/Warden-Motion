// tempocurve
INCLUDE(_chart)
uniform float p_dvN, p_minBpm, p_maxBpm, p_pencere, p_elleDuze;
// BPM eğrisi parça boyunca; dikey çizgi şimdiki konum; şimdiki tempo sayı olarak
float B(int i) { if (p_dvN > 0.5) return dvAt(i); return 110.0 + 20.0 * sin(float(i) * 0.15) + 8.0 * sin(float(i) * 0.6); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float lo = p_minBpm, hi = max(p_maxBpm, lo + 1.0); vec4 res = overPre(vec4(0.05, 0.06, 0.1, 0.7), s);
  for (int k = 1; k < 4; k++) { float y = float(k) / 4.0; res = overPre(vec4(vec3(1.0), 1.0) * (1.0 - smoothstep(0.0, 1.2 / u_box.w, abs(b.y - y))) * 0.15, res); }
  float f = clamp(b.x, 0.0, 1.0) * 63.0; int i = int(floor(f)); float v = mix(B(i), B(min(i + 1, 63)), fract(f)); float y = 1.0 - (v - lo) / (hi - lo); res = overPre(vec4(0.4, 0.85, 1.0, 1.0) * (1.0 - smoothstep(1.2, 2.5, abs(b.y - y) * u_box.w)), res);
  float pos = p_dvN > 0.5 ? dvAt(64) : fract(u_t * 0.1); res = overPre(vec4(1.0, 0.4, 0.3, 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.z, abs(b.x - pos))), res);
  vec2 lp = (b - vec2(0.85, 0.1)) / vec2(0.035, 0.05); res = overPre(vec4(1.0) * numAt(lp, B(int(pos * 63.0))), res); o = res; }
