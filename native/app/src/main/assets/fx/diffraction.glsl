// diffraction
uniform vec3 c_isik; uniform float p_aciklik, p_aralik, p_desenOlce;
// Fraunhofer kırınımı: tek yarık sinc², çift yarık cos²·sinc², ızgara keskin tepeler; R/G/B ayrı dalga boyu → spektral bantlar
float pat(float x, float lam) { float a = p_aralik * 0.35; float k = 3.14159 * x / lam / max(p_desenOlce, 0.1) * 0.02; float b = k * a; float sinc = abs(b) < 1e-4 ? 1.0 : sin(b) / b; float I = sinc * sinc;
  if (p_aciklik > 0.5 && p_aciklik < 1.5) I *= pow(cos(k * p_aralik), 2.0); else if (p_aciklik >= 1.5) { float N = 6.0; float g = k * p_aralik; float d = sin(g); float r = abs(d) < 1e-3 ? N : sin(N * g) / d; I *= r * r / (N * N); } return I; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec3 I = vec3(pat(q.x, 0.65), pat(q.x, 0.53), pat(q.x, 0.45)); float vy = exp(-q.y * q.y / pow(boxU().y * 0.12, 2.0));
  vec3 c = I * c_isik * vy * 1.4; o = vec4(s.rgb + c * (1.0 - s.a * 0.3), max(s.a, max(c.r, max(c.g, c.b)))); }
