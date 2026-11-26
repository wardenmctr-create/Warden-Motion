// graticule
uniform float p_projeksi, p_dereceAral, p_etiketle;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 xy = (b - 0.5) * vec2(2.0, -1.0); float lon, lat; bool ok = true;
  if (p_projeksi < 0.5) { lon = xy.x * PI; lat = xy.y * PI; } else if (p_projeksi < 1.5) { lon = xy.x * PI; lat = atan(sinh(xy.y * PI)); } else if (p_projeksi < 2.5) { lat = xy.y * PI * 0.97; lon = xy.x * PI / (0.8487 + 0.15 * cos(lat * 1.2)) * 0.85; ok = abs(lon) <= PI; }
  else { vec2 p = vec2(xy.x * 2.0, xy.y * 4.0); float r = length(p); ok = r <= 1.0; float c = asin(clamp(r, 0.0, 1.0)); lat = r < 1e-5 ? 0.0 : asin(clamp(p.y * sin(c) / r, -1.0, 1.0)); lon = atan(p.x * sin(c), r * cos(c)); }
  if (!ok) { o = s; return; } vec2 ll = degrees(vec2(lon, lat)) / max(p_dereceAral, 1.0); vec2 fw = fwidth(ll); vec2 d = abs(fract(ll - 0.5) - 0.5) / max(fw, vec2(1e-4)); float line = 1.0 - min(min(d.x, d.y), 1.0);
  o = overPre(vec4(1.0, 1.0, 1.0, 1.0) * line * 0.7, s); }
