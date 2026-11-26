// chromolitho
uniform float p_renkPlak, p_kenarKaym, p_murekkepOrtu;
void main() { vec4 s = texture(u_tex, v_uv); float k = max(floor(pow(max(p_renkPlak, 2.0), 1.0 / 2.0)), 2.0); vec3 res = vec3(0.98, 0.96, 0.9); float N = max(p_renkPlak, 2.0);
  for (int i = 0; i < 3; i++) { vec2 off = vec2(cos(float(i) * 2.1), sin(float(i) * 2.1)) * p_kenarKaym * u_s; vec3 c = unpre(texPx(here() + off)); float ch = c[i]; float q = floor(ch * N / 3.0 + 0.5) / (N / 3.0);
    vec3 ink = i == 0 ? vec3(0.0, 1.0, 1.0) : i == 1 ? vec3(1.0, 0.0, 1.0) : vec3(1.0, 1.0, 0.0); res *= mix(vec3(1.0), ink, (1.0 - q) * (0.7 + p_murekkepOrtu / 300.0) * texPx(here() + off).a); }
  o = pre(clamp(res, 0.0, 1.0), s.a); }
