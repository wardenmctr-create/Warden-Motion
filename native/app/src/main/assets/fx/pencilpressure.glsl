// pencilpressure
uniform sampler2D s_cizgiYolu; uniform vec3 c_renk; uniform float p_cizgiYoluOn, p_tane, p_yogunluk;
// Yol (kaynak katman alfası ya da katmanın kendi koyu çizgileri) renk kalemiyle: kâğıt tanesi tepeleri dolar, basınç yol boyunca değişir
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float m = p_cizgiYoluOn > 0.5 ? texture(s_cizgiYolu, b).a : (s.a > 0.5 && luma(unpre(s)) < 0.45 ? 1.0 : 0.0); if (m <= 0.0) { o = s; return; }
  float press = 0.45 + 0.55 * sin(clamp((u_box.z >= u_box.w ? b.x : b.y), 0.0, 1.0) * 3.14159); float tooth = fbm(here() / max(p_tane * u_s * 0.6, 1.0), 3.0) * 0.5 + 0.5;
  float cov = smoothstep(1.0 - press * p_yogunluk / 100.0 - 0.1, 1.0 - press * p_yogunluk / 100.0 + 0.1, tooth) * m;
  vec4 bg = p_cizgiYoluOn > 0.5 ? s : vec4(vec3(0.97, 0.96, 0.92) * s.a, s.a); // kendi çizgisinde: çizgi kâğıt rengine açılır, kalem tanesi üstüne
  o = overPre(vec4(c_renk, 1.0) * cov, bg); }
