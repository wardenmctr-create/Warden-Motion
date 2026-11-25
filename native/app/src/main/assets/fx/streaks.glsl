// streaks
uniform float p_len; uniform float p_ang; uniform float p_count; uniform float p_thr;
void main() { vec4 s = texture(u_tex, v_uv); vec3 acc = vec3(0.0); int n = int(p_count + 0.5);
  for (int k = 0; k < 4; k++) { if (k >= n) break; float a = radians(p_ang + float(k) * 180.0 / float(n)); vec2 d = vec2(cos(a), sin(a)) * p_len * u_s / u_res;
    for (int i = 1; i <= 24; i++) { float t = float(i) / 24.0; float w = pow(1.0 - t, 2.0); for (int sg = -1; sg <= 1; sg += 2) { vec4 q = tex(v_uv + d * t * float(sg)); vec3 c = q.rgb; acc += c * smoothstep(p_thr / 100.0, 1.0, luma(unpre(q))) * w; } } }
  acc /= 12.0; o = s + vec4(acc, max(acc.r, max(acc.g, acc.b))) * (1.0 - s.a * 0.3); }
