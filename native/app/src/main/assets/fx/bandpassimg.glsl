// bandpassimg
uniform float p_altOlce, p_ustOlce, p_kazanc;
vec3 bl(float r) { vec3 a = vec3(0.0); float ws = 0.0; for (int i = 0; i < 16; i++) { float an = float(i) * 2.39996; float rr = r * sqrt((float(i) + 0.5) / 16.0); float w = exp(-rr * rr / (r * r)); a += unpre(texPx(here() + vec2(cos(an), sin(an)) * rr)) * w; ws += w; } return a / ws; }
void main() { vec4 s = texture(u_tex, v_uv); vec3 b = bl(max(p_altOlce, 0.5) * u_s) - bl(max(p_ustOlce, p_altOlce + 0.5) * u_s); o = pre(clamp(0.5 + b * p_kazanc / 100.0 * 2.0, 0.0, 1.0), s.a); }
