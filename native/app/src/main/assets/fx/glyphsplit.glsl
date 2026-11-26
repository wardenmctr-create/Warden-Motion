// glyphsplit
uniform sampler2D s_palet; uniform float p_paletOn, p_bolme, p_aci, p_bolmeBosl;
// Harfler açılı iç çizgilerle şeritlere bölünür; her şerit paletten (ya da ton döngüsünden) renk alır; şerit arası boşluk saydam
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float a = radians(p_aci); vec2 d = vec2(cos(a), sin(a)); float H = u_box.w / max(p_bolme, 2.0); float x = dot(here() - boxCenter(), d) / H;
  float k = floor(x); float f = fract(x); float N = max(p_bolme, 2.0); float idx = mod(k, N); vec3 c = p_paletOn > 0.5 ? texture(s_palet, vec2((idx + 0.5) / N, 0.5)).rgb : hsv2rgb(vec3(idx / N * 0.8 + 0.55, 0.65, 1.0));
  float gap = p_bolmeBosl * u_s / H; float m = gap > 0.0 ? smoothstep(0.0, 0.02, f - gap * 0.5) * smoothstep(0.0, 0.02, 1.0 - gap * 0.5 - f) : 1.0; o = vec4(c * s.a, s.a) * m; }
