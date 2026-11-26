// halftone
uniform float p_noktaBoyu, p_aci, p_kontrast, p_tur, p_saydamArkaPlan; uniform vec3 c_murekkep, c_kagit;
float dotAt(vec2 px, float ang, float l, float shape) {
  float sz = max(p_noktaBoyu * u_s, 2.0); vec2 p = rot2(-ang) * (px - u_box.xy); vec2 c = (floor(p / sz) + 0.5) * sz; vec2 f = (p - c) / sz;
  float d = shape < 0.5 ? length(f) * 2.0 : shape < 1.5 ? max(abs(f.x), abs(f.y)) * 2.0 : (abs(f.x) + abs(f.y)) * 1.42;
  float r = sqrt(1.0 - l) * 1.15; return 1.0 - smoothstep(r - 0.08, r + 0.08, d);
}
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = conAdj(unpre(s), 1.0 + p_kontrast / 100.0, 0.5); c = clamp(c, 0.0, 1.0);
  vec3 r;
  if (p_tur > 2.5) { vec3 cmy = 1.0 - c; float k = min(cmy.r, min(cmy.g, cmy.b));
    float dc = dotAt(here(), radians(15.0), 1.0 - cmy.r, 0.0), dm = dotAt(here(), radians(75.0), 1.0 - cmy.g, 0.0), dy = dotAt(here(), 0.0, 1.0 - cmy.b, 0.0), dk = dotAt(here(), radians(45.0), 1.0 - k, 0.0);
    r = c_kagit * (1.0 - vec3(dc, 0.0, 0.0)) * (1.0 - vec3(0.0, dm, 0.0)) * (1.0 - vec3(0.0, 0.0, dy)) * (1.0 - dk); }
  else { float d = dotAt(here(), radians(p_aci), luma(c), p_tur); r = mix(c_kagit, c_murekkep, d);
    if (p_saydamArkaPlan > 0.5) { o = vec4(c_murekkep, 1.0) * d * s.a; return; } }
  o = pre(r, s.a);
}
