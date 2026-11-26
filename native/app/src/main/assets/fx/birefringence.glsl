// birefringence
uniform float p_kristalAcis, p_ayrilma, p_ikinciGoru, p_kenarYumu;
// Çift kırılma: aynı görüntünün iki tam renkli kopyası, kristal ekseni doğrultusunda ayrık; ikinci görüntü opaklığı ayarlı
vec4 soft(vec2 px) { float r = p_kenarYumu * u_s; if (r < 0.5) return texPx(px); vec4 a = vec4(0.0); for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) a += texPx(px + vec2(i, j) * r * 0.5); return a / 9.0; }
void main() { float a = radians(p_kristalAcis); vec2 d = vec2(cos(a), sin(a)) * p_ayrilma * u_s * 0.5; vec4 o1 = soft(here() - d), o2 = soft(here() + d); float k = p_ikinciGoru / 100.0;
  o = o1 * (1.0 - k * 0.5) + o2 * k * 0.5 + o1 * 0.0; o = vec4(o1.rgb * (1.0 - k * 0.5) + o2.rgb * k * 0.5 * (1.0 + 0.0), max(o1.a, o2.a * k)); o.rgb = min(o.rgb, vec3(o.a)); }
