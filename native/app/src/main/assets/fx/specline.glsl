// specline
uniform sampler2D s_normalHari; uniform vec3 c_renk; uniform float p_normalHariOn, p_isikAcis, p_parlakBant, p_yogunluk;
// Speküler çizgi normal haritasıyla bükülür; çizgi zamanla yüzeyde kayar (normal haritası yoksa parlaklıktan tahmin)
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 b = boxUV(here()); vec3 n = p_normalHariOn > 0.5 ? texture(s_normalHari, b).rgb * 2.0 - 1.0 : normalize(vec3(-lumGrad(here(), 2.0) * 6.0, 1.0));
  float a = radians(p_isikAcis); vec2 d = vec2(cos(a), sin(a)); float pr = dot(b - 0.5, d) + dot(n.xy, d) * 0.25; float pos = fract(u_t * 0.35) * 1.6 - 0.8;
  float h = exp(-pow((pr - pos) / max(p_parlakBant * 0.25, 0.005), 2.0)) * (p_yogunluk / 100.0); o = vec4(s.rgb + c_renk * h * s.a, s.a); }
