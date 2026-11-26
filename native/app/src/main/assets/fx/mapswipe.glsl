// mapswipe
uniform sampler2D s_haritaSuru, s_haritaSuru_1, s_haritaSuru_2; uniform float p_haritaSuruOn, p_haritaSuru_1On, p_haritaSuru_2On, p_kesit, p_sinirCizg, p_koordinaKili;
// Aynı koordinattaki harita sürümleri dikey kesitlerle yan yana: katmanın kendisi ilk sürüm, seçilenler sonrakiler
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float n = 1.0 + p_haritaSuruOn + p_haritaSuru_1On + p_haritaSuru_2On; if (n < 1.5) { o = s; return; }
  float k = p_kesit / 100.0; float x = n < 2.5 ? (b.x < k ? 0.0 : 1.0) : floor(clamp(b.x + (k - 0.5) / n, 0.0, 0.999) * n); vec4 c = s;
  if (x > 0.5 && x < 1.5) c = texture(s_haritaSuru, b); else if (x > 1.5 && x < 2.5) c = texture(s_haritaSuru_1, b); else if (x > 2.5) c = texture(s_haritaSuru_2, b);
  float bx = n < 2.5 ? abs(b.x - k) : abs(fract(b.x * n + (k - 0.5)) - 0.0) / n; float line = 1.0 - smoothstep(p_sinirCizg * u_s * 0.5 / u_box.z, p_sinirCizg * u_s * 0.5 / u_box.z + 1.0 / u_box.z, bx); o = overPre(vec4(1.0) * line * step(0.1, p_sinirCizg), c); }
