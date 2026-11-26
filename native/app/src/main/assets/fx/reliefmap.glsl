// reliefmap
uniform sampler2D s_yuksekliDosy, s_renkHari; uniform float p_yuksekliDosyOn, p_renkHariOn;
uniform float p_yuksekliTersCevi, p_yukselti, p_yumusatm, p_isikYonu, p_isikYuks, p_yuksekliReng;
float hAt(vec2 px) { vec2 b = clamp(boxUV(px), 0.0, 1.0); float h = p_yuksekliDosyOn > 0.5 ? luma(unpre(texture(s_yuksekliDosy, b))) : luma(unpre(texPx(px))); return p_yuksekliTersCevi > 0.5 ? 1.0 - h : h; }
void main() { vec4 s = texture(u_tex, v_uv); float e = max(p_yumusatm, 0.5) * u_s; float dx = hAt(here() + vec2(e, 0.0)) - hAt(here() - vec2(e, 0.0)), dy = hAt(here() + vec2(0.0, e)) - hAt(here() - vec2(0.0, e));
  vec3 n = normalize(vec3(-dx * p_yukselti / 5.0, -dy * p_yukselti / 5.0, 1.0)); float az = radians(p_isikYonu), el = radians(p_isikYuks); vec3 L = vec3(cos(az) * cos(el), -sin(az) * cos(el), sin(el));
  float sh = max(dot(n, L), 0.0); float h = hAt(here()); vec3 base = p_renkHariOn > 0.5 ? unpre(texture(s_renkHari, clamp(boxUV(here()), 0.0, 1.0))) : p_yuksekliReng > 0.5 ? mix(mix(vec3(0.15, 0.45, 0.2), vec3(0.6, 0.5, 0.3), smoothstep(0.2, 0.6, h)), vec3(0.95), smoothstep(0.75, 0.9, h)) : unpre(s);
  o = pre(clamp(base * (0.35 + sh * 0.9), 0.0, 1.0), max(s.a, p_yuksekliDosyOn)); }
