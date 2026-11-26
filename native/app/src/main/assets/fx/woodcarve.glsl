// woodcarve
uniform vec3 c_ahsap; uniform float p_oyukDeri, p_cizgiAral, p_keskiUcu, p_isikAcis;
// Koyu tonlar geniş oyuk kanalları olur; V/U keski profili yanlardan ışık alır; ahşap damarı yüzeyde
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 p = here(); float sp = max(p_cizgiAral * u_s, 2.0); float l = luma(unpre(s));
  float v = p.y + fbm(p / (sp * 6.0), 2.0) * sp * 1.5; float f = fract(v / sp); float hw = (1.0 - l) * 0.5; float x = (f - 0.5) / max(hw, 0.02);
  float inG = step(abs(x), 1.0); float prof = p_keskiUcu < 0.5 ? x : sign(x) * x * x; float la = radians(p_isikAcis); float slope = -sin(la) * prof * p_oyukDeri * 0.06;
  float grain = 0.88 + 0.12 * sin(p.x / (4.0 * u_s) + fbm(p / (40.0 * u_s), 3.0) * 8.0); vec3 wood = c_ahsap * grain;
  vec3 c = inG > 0.5 ? wood * (0.45 + slope - abs(prof) * 0.1) : wood * 1.05; o = pre(clamp(c, 0.0, 1.0), s.a); }
