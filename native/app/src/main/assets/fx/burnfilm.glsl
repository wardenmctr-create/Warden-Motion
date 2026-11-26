// burnfilm
uniform float p_yanmaIler, p_kenarGeni, p_puruz, p_tohum, p_delikAc; uniform vec2 p_merkez; uniform vec3 c_yanikReng, c_isikReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU();
  float d = length((q - p_merkez) / (length(B) * 0.5)); float n = fbm(q / 40.0 + seedf(p_tohum), 4.0) * p_puruz / 100.0;
  float front = p_yanmaIler / 100.0 * 1.6 - d * 0.7 + n; // >0 yanmış
  float w = max(p_kenarGeni, 1.0) / (length(B) * 0.5);
  float hole = smoothstep(0.0, 0.02, front); float glow = exp(-abs(front) / (w * 0.4)); float char_ = smoothstep(-w, 0.0, front);
  vec3 c = unpre(s); c = mix(c, c_yanikReng, char_ * 0.9); c += c_isikReng * glow * 1.2;
  float a = s.a * (p_delikAc > 0.5 ? 1.0 - hole : 1.0);
  o = pre(clamp(c, 0.0, 1.0), a);
}
