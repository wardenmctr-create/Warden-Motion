// stroke
uniform float p_width; uniform vec3 c_col; uniform float p_pos;
const vec2 D16[16] = vec2[16](vec2(1,0),vec2(0.924,0.383),vec2(0.707,0.707),vec2(0.383,0.924),vec2(0,1),vec2(-0.383,0.924),vec2(-0.707,0.707),vec2(-0.924,0.383),vec2(-1,0),vec2(-0.924,-0.383),vec2(-0.707,-0.707),vec2(-0.383,-0.924),vec2(0,-1),vec2(0.383,-0.924),vec2(0.707,-0.707),vec2(0.924,-0.383));
float dilate(vec2 uv, float r) { float m = tex(uv).a; if (r <= 0.0) return m; for (int k = 1; k <= 4; k++) { float rr = r * float(k) / 4.0; for (int i = 0; i < 16; i++) m = max(m, tex(uv + D16[i] * rr / u_res).a); } return m; }
float erode(vec2 uv, float r) { float m = tex(uv).a; if (r <= 0.0) return m; for (int k = 1; k <= 4; k++) { float rr = r * float(k) / 4.0; for (int i = 0; i < 16; i++) m = min(m, tex(uv + D16[i] * rr / u_res).a); } return m; }
void main() {
  vec4 s = texture(u_tex, v_uv); float w = p_width * u_s; int pos = int(p_pos + 0.5);
  vec4 col = vec4(c_col, 1.0);
  if (pos == 0) { o = s + col * dilate(v_uv, w) * (1.0 - s.a); return; }
  float inner = clamp(s.a - erode(v_uv, pos == 2 ? w * 0.5 : w), 0.0, 1.0);
  vec4 r = vec4(mix(unpre(s), c_col, s.a > 0.0 ? clamp(inner / s.a, 0.0, 1.0) : 0.0), 1.0) * s.a;
  if (pos == 2) r = r + col * dilate(v_uv, w * 0.5) * (1.0 - s.a);
  o = r;
}
