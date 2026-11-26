// colorrange
uniform float p_altTon, p_ustTon, p_altDoyg, p_ustDoyg, p_altParl, p_ustParl, p_yumusakl, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec3 h = rgb2hsv(unpre(s)); float hue = h.x * 360.0; float lo = mod(p_altTon, 360.0), hi = mod(p_ustTon, 360.0);
  float inH = lo <= hi ? step(lo, hue) * step(hue, hi) : max(step(lo, hue), step(hue, hi)); float w = p_yumusakl / 100.0 * 0.2 + 0.001;
  float inS = smoothstep(p_altDoyg / 100.0 - w, p_altDoyg / 100.0, h.y) * (1.0 - smoothstep(p_ustDoyg / 100.0, p_ustDoyg / 100.0 + w, h.y));
  float inV = smoothstep(p_altParl / 100.0 - w, p_altParl / 100.0, h.z) * (1.0 - smoothstep(p_ustParl / 100.0, p_ustParl / 100.0 + w, h.z));
  float m = inH * inS * inV; if (p_ters > 0.5) m = 1.0 - m; o = s * (1.0 - m); }
