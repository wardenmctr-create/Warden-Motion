// channelalign
uniform vec2 p_kirmiziKaym, p_maviKaym;
void main() { vec4 s = texture(u_tex, v_uv); vec4 r = texPx(here() - p_kirmiziKaym * u_s), b = texPx(here() - p_maviKaym * u_s); o = vec4(r.r, s.g, b.b, max(s.a, max(r.a, b.a))); }
