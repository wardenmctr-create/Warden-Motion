// chanblur
uniform float p_r; uniform float p_g; uniform float p_b;
vec4 blurAt(float r) { if (r < 0.3) return texture(u_tex, v_uv); vec4 acc = vec4(0.0); for (int i = 0; i < 32; i++) { float f = float(i) + 0.5; float a = f * 2.39996; vec2 q = vec2(cos(a), sin(a)) * sqrt(f / 32.0) * r * u_s; acc += tex(v_uv + q / u_res); } return acc / 32.0; }
void main() { vec4 R = blurAt(p_r), G = blurAt(p_g), B = blurAt(p_b); o = vec4(R.r, G.g, B.b, max(R.a, max(G.a, B.a))); }
