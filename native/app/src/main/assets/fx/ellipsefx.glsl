// ellipsefx
uniform vec2 p_merkez; uniform float p_yatayYari, p_dikeyYari, p_aci, p_kalinlik, p_hale, p_kesikYay, p_yayUzun; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 r = rot2(-p_aci) * (toUnit(here()) - p_merkez); vec2 R = vec2(max(p_yatayYari, 1.0), max(p_dikeyYari, 1.0));
  float k = length(r / R); float d = abs(k - 1.0) * min(R.x, R.y);
  float core = 1.0 - smoothstep(p_kalinlik * 0.5 - 0.7, p_kalinlik * 0.5 + 0.7, d); float glow = exp(-d / max(p_hale * 0.5, 0.5)) * 0.7;
  if (p_kesikYay > 0.5) { float a = degrees(atan(r.y / R.y, r.x / R.x)); a = mod(a + 360.0, 360.0); if (a > abs(p_yayUzun)) { core = 0.0; glow = 0.0; } }
  float a2 = clamp(core + glow, 0.0, 1.0);
  o = vec4(min(s.rgb + mix(c_renk, vec3(1.0), core * 0.4) * a2, vec3(1.0)), max(s.a, a2));
}
