// lensblur
uniform float p_amount; uniform float p_bright;
void main() { float r = p_amount * u_s; if (r < 0.5) { o = texture(u_tex, v_uv); return; } vec4 acc = vec4(0.0); float wsum = 0.0;
  for (int i = 0; i < 96; i++) { float f = float(i) + 0.5; float ang = f * 2.39996; float rad = sqrt(f / 96.0) * r; vec4 t = tex(v_uv + vec2(cos(ang), sin(ang)) * rad / u_res);
    float w = 1.0 + pow(luma(t.rgb), 4.0) * p_bright / 100.0 * 12.0; acc += t * w; wsum += w; } o = acc / wsum; }
