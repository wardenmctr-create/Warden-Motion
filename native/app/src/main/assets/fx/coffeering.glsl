// coffeering
uniform float p_halkaGeni, p_pigment, p_kuruma, p_kenarPuru;
// Kuruyan boya lekesi: renk alanının kenarına doğru biriken koyu pigment halkası; kenar pürüzlü
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 p = here(); float W = max(p_halkaGeni * u_s, 0.5); float rough = (fbm(p / (10.0 * u_s), 3.0)) * p_kenarPuru / 100.0 * W;
  float d = innerDist(p, W * 4.0) + rough; vec3 c = unpre(s); float l0 = luma(c); float edgeC = 0.0;
  for (int i = 0; i < 8; i++) { float a = float(i) / 8.0 * TAU; vec3 n = unpre(texPx(p + vec2(cos(a), sin(a)) * W)); edgeC = max(edgeC, length(n - c)); }
  float ring = max(exp(-max(d, 0.0) / W), smoothstep(0.15, 0.4, edgeC) * 0.8); float k = ring * p_pigment / 100.0 * p_kuruma / 100.0 * 1.6; o = pre(c * (1.0 - k * 0.7) * mix(vec3(1.0), c * 1.2 + 0.1, k * 0.3), s.a); }
