// neonsign
uniform vec3 c_col; uniform float p_width; uniform float p_glow; uniform float p_flick;
const vec2 D16[16] = vec2[16](vec2(1,0),vec2(0.924,0.383),vec2(0.707,0.707),vec2(0.383,0.924),vec2(0,1),vec2(-0.383,0.924),vec2(-0.707,0.707),vec2(-0.924,0.383),vec2(-1,0),vec2(-0.924,-0.383),vec2(-0.707,-0.707),vec2(-0.383,-0.924),vec2(0,-1),vec2(0.383,-0.924),vec2(0.707,-0.707),vec2(0.924,-0.383));
float edgeA(vec2 uv, float r) { return abs(tex(uv + vec2(r, 0) / u_res).a - tex(uv - vec2(r, 0) / u_res).a) + abs(tex(uv + vec2(0, r) / u_res).a - tex(uv - vec2(0, r) / u_res).a); }
void main() {
  float w = p_width * u_s; float core = smoothstep(0.3, 0.8, edgeA(v_uv, w));
  float halo = 0.0; float R = 14.0 * u_s; for (int i = 0; i < 16; i++) for (int k = 1; k <= 3; k++) halo += smoothstep(0.3, 0.8, edgeA(v_uv + D16[i] * R * float(k) / 3.0 / u_res, w)) / float(k);
  halo = halo / 26.0 * p_glow / 100.0; float fl = 1.0 - p_flick / 100.0 * step(0.92, hash1(vec2(floor(u_t * 14.0), 2.0)));
  vec4 s = texture(u_tex, v_uv); vec4 back = s * 0.12;
  vec3 col = (mix(c_col, vec3(1.0), 0.65) * core + c_col * halo * 1.6) * fl; float a = clamp(core + halo, 0.0, 1.0);
  o = vec4(min(col, vec3(1.0)), 1.0) * a + back * (1.0 - a);
}
