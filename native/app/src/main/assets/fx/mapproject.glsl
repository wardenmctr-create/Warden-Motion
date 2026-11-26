// mapproject
uniform float p_kaynakProj, p_hedefProj, p_merkezBoyl, p_merkezEnle, p_olcek, p_gecersizAlanSayd, p_enlemBoylCizg, p_izgaraAral; uniform vec3 c_izgaraReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 xy = (b - 0.5) * vec2(2.0, -1.0) / max(p_olcek / 100.0, 0.05); float lon, lat; bool ok = true; // xy: x ∈ [-1,1]·π, y ∈ [-0.5,0.5]·π
  if (p_hedefProj < 0.5) { lon = xy.x * PI; lat = atan(sinh(xy.y * PI)); }
  else if (p_hedefProj < 1.5) { lon = xy.x * PI; lat = xy.y * PI; }
  else if (p_hedefProj < 2.5) { vec2 p = vec2(xy.x * 2.0, xy.y * 2.0 * 2.0); float r = length(p); if (r > 1.0) ok = false; float c = asin(clamp(r, 0.0, 1.0)); lat = r < 1e-5 ? 0.0 : asin(clamp(p.y * sin(c) / r, -1.0, 1.0)); lon = atan(p.x * sin(c), r * cos(c)); }
  else if (p_hedefProj < 3.5) { float X = xy.x * 2.0 * 1.4142, Y = xy.y * 2.0 * 1.4142; float th = asin(clamp(Y / 1.4142, -1.0, 1.0)); lon = PI * X / (2.0 * 1.4142 * cos(th)); lat = asin(clamp((2.0 * th + sin(2.0 * th)) / PI, -1.0, 1.0)); if (abs(lon) > PI) ok = false; }
  else { lat = xy.y * PI * 0.97; lon = xy.x * PI / (0.8487 + 0.15 * cos(lat * 1.2)) * 0.85; if (abs(lon) > PI) ok = false; }
  lon += radians(p_merkezBoyl); lat += radians(p_merkezEnle); lon = mod(lon + PI, TAU) - PI; lat = clamp(lat, -PI * 0.5, PI * 0.5);
  vec2 src = p_kaynakProj < 0.5 ? vec2(lon / TAU + 0.5, 0.5 - lat / PI) : vec2(lon / TAU + 0.5, 0.5 - log(tan(PI * 0.25 + clamp(lat, -1.48, 1.48) * 0.5)) / TAU);
  vec4 c = ok ? texPx(boxPx(src)) : (p_gecersizAlanSayd > 0.5 ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0));
  if (p_enlemBoylCizg > 0.5 && ok) { float g = radians(max(p_izgaraAral, 1.0)); vec2 ll = vec2(lon, lat) / g; vec2 fw = fwidth(ll); vec2 d = abs(fract(ll - 0.5) - 0.5) / max(fw, vec2(1e-4)); c = overPre(vec4(c_izgaraReng, 1.0) * (1.0 - min(min(d.x, d.y), 1.0)) * 0.7, c); }
  o = c; }
