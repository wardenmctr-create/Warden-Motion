// darkframe
uniform sampler2D s_karanlik; uniform float p_karanlikOn, p_cikarmaMikt, p_negatiflSini;
void main() { vec4 s = texture(u_tex, v_uv); if (p_karanlikOn < 0.5) { o = s; return; } vec3 d = unpre(texture(s_karanlik, clamp(boxUV(here()), 0.0, 1.0))); vec3 r = unpre(s) - d * p_cikarmaMikt / 100.0; if (p_negatiflSini > 0.5) r = max(r, 0.0); o = pre(clamp(r, 0.0, 1.0), s.a); }
