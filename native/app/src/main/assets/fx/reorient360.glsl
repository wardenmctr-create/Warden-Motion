// reorient360
uniform float p_yaw, p_pitch, p_roll, p_girdi, p_kutupFilt;
void main() { vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = vec4(0.0); return; }
  float lon = (b.x - 0.5) * TAU, lat = (0.5 - b.y) * PI; vec3 d = vec3(cos(lat) * sin(lon), sin(lat), cos(lat) * cos(lon));
  float ro = radians(p_roll), pi_ = radians(p_pitch), ya = radians(p_yaw); d.xy = mat2(cos(ro), sin(ro), -sin(ro), cos(ro)) * d.xy; d.yz = mat2(cos(pi_), sin(pi_), -sin(pi_), cos(pi_)) * d.yz; d.xz = mat2(cos(ya), -sin(ya), sin(ya), cos(ya)) * d.xz;
  vec2 s = vec2(fract(atan(d.x, d.z) / TAU + 0.5), 0.5 - asin(clamp(d.y, -1.0, 1.0)) / PI); o = texPx(boxPx(clamp(s, 0.001, 0.999))); }
