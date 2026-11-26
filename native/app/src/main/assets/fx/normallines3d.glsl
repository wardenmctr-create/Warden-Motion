// normallines3d
uniform vec3 c_renk; uniform float p_okBoyu, p_atlama, p_tur;
// Normaller ok olarak: silüet kenarında dışa (yan yüz normali), ön yüzde izleyiciye bakan normaller nokta-halka işaretiyle
float seg(vec2 p, vec2 a, vec2 b) { vec2 ab = b - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float sp = max(p_atlama * (p_tur < 0.5 ? 6.0 : 3.0), 2.0) * u_s; vec2 id0 = floor(p / sp); float v = 0.0; float L = p_okBoyu * u_s;
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 c = (id0 + vec2(i, j) + 0.5) * sp; float a = texPx(c).a; vec2 g = alphaGrad(c, 1.5);
    if (a > 0.5 && length(g) > 0.15) { vec2 n = -normalize(g); v = max(v, 1.0 - smoothstep(0.6, 1.4, seg(p, c, c + n * L))); vec2 tip = c + n * L; v = max(v, 1.0 - smoothstep(1.5, 2.5, length(p - tip))); }
    else if (a > 0.5 && i == 0 && j == 0) { float d = length(p - c); v = max(v, (1.0 - smoothstep(0.8, 1.6, abs(d - L * 0.15))) + (1.0 - smoothstep(0.8, 1.6, d))); } }
  o = overPre(vec4(c_renk, 1.0) * clamp(v, 0.0, 1.0), s); }
