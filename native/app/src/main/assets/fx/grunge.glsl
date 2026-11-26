// grunge
uniform sampler2D s_dokuDosy; uniform float p_dokuDosyOn; uniform float p_doku, p_olcek, p_yogunluk, p_kontrast, p_lekeBoyu, p_tohum, p_karistir;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 p = toUnit(here()) / max(p_olcek / 100.0, 0.01) + seedf(p_tohum); float g;
  if (p_dokuDosyOn > 0.5 || p_doku > 3.5) g = luma(unpre(texture(s_dokuDosy, fract(p / 200.0))));
  else if (p_doku < 0.5) g = 0.75 + fbm(p / max(p_lekeBoyu, 1.0), 4.0) * 0.4 + (hash1(floor(p)) - 0.5) * 0.08;
  else if (p_doku < 1.5) g = 0.7 + fbm(p / 6.0, 3.0) * 0.25 - step(0.93, hash1(floor(p / 3.0))) * 0.35 + fbm(p / max(p_lekeBoyu, 1.0), 2.0) * 0.2;
  else if (p_doku < 2.5) { float n = fbm(p / max(p_lekeBoyu, 1.0), 5.0); g = 0.75 + n * 0.5; vec3 rust = vec3(0.55, 0.25, 0.08); vec3 c = unpre(s); c = mix(c, c * rust * 1.8, smoothstep(0.1, 0.5, n) * p_yogunluk / 100.0); o = pre(c, s.a); return; }
  else { vec2 q = rot2(17.0) * p; float sc = 1.0 - step(0.985, vnoise(vec2(q.x * 0.02, q.y * 2.0))) * 0.6; g = 0.85 * sc + fbm(p / 30.0, 2.0) * 0.15; }
  g = clamp((g - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5, 0.0, 1.0); vec3 c = unpre(s); vec3 t = vec3(g);
  vec3 r = p_karistir < 0.5 ? c * t : p_karistir < 1.5 ? overlayB(c, t) : t;
  o = pre(mix(c, r, p_yogunluk / 100.0), s.a);
}
