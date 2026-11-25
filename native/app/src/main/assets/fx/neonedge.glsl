// neonedge
uniform vec3 c_col; uniform float p_width; uniform float p_glow;
float lumAt(vec2 uv) { vec4 t = tex(uv); return luma(t.rgb) + (1.0 - t.a) * 0.0; }
vec2 sobel(vec2 uv, float r) { vec2 px = r / u_res;
  float tl = lumAt(uv + px * vec2(-1, -1)), t = lumAt(uv + px * vec2(0, -1)), tr = lumAt(uv + px * vec2(1, -1));
  float l = lumAt(uv + px * vec2(-1, 0)), rr = lumAt(uv + px * vec2(1, 0));
  float bl = lumAt(uv + px * vec2(-1, 1)), b = lumAt(uv + px * vec2(0, 1)), br = lumAt(uv + px * vec2(1, 1));
  return vec2(tr + 2.0 * rr + br - tl - 2.0 * l - bl, bl + 2.0 * b + br - tl - 2.0 * t - tr); }
float alphaEdge(vec2 uv, float r) { vec2 px = r / u_res; return abs(tex(uv + vec2(px.x, 0)).a - tex(uv - vec2(px.x, 0)).a) + abs(tex(uv + vec2(0, px.y)).a - tex(uv - vec2(0, px.y)).a); }
const vec2 D16[16] = vec2[16](vec2(1,0),vec2(0.924,0.383),vec2(0.707,0.707),vec2(0.383,0.924),vec2(0,1),vec2(-0.383,0.924),vec2(-0.707,0.707),vec2(-0.924,0.383),vec2(-1,0),vec2(-0.924,-0.383),vec2(-0.707,-0.707),vec2(-0.383,-0.924),vec2(0,-1),vec2(0.383,-0.924),vec2(0.707,-0.707),vec2(0.924,-0.383));
void main() {
  vec2 uv = v_uv; float e = 0.0;
  for (int k = 0; k < 3; k++) { float r = (float(k) + 1.0) * p_width * u_s * 0.5; e = max(e, alphaEdge(uv, r) * 0.6 + length(sobel(uv, r)) * 0.4); }
  float core = smoothstep(0.25, 0.6, e);
  float halo = 0.0; float R = 10.0 * u_s;
  for (int i = 0; i < 16; i++) { for (int k = 1; k <= 3; k++) { vec2 q = uv + D16[i] * R * float(k) / 3.0 / u_res; halo += smoothstep(0.25, 0.6, alphaEdge(q, p_width * u_s) * 0.6 + length(sobel(q, p_width * u_s)) * 0.4) / float(k); } }
  halo = halo / 28.0 * p_glow / 100.0;
  vec3 col = c_col * halo * 1.8 + mix(c_col, vec3(1.0), 0.6) * core;
  float a = clamp(core + halo, 0.0, 1.0); o = vec4(col * a, a) ;
  o = vec4(min(col, vec3(1.0)) , 1.0) * a;
}
