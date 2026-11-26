// eyelid
uniform sampler2D s_gozMask; uniform float p_gozMaskOn, p_ustAltKapa, p_kavis;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float k = p_ustAltKapa / 100.0; float bend = (p_kavis / 100.0) * 0.35 * (1.0 - pow(2.0 * b.x - 1.0, 2.0));
  float top = k * 0.5 + bend * k; float bot = 1.0 - k * 0.5 - bend * k * 0.6; float open_ = smoothstep(top - 0.01, top + 0.01, b.y) * smoothstep(bot + 0.01, bot - 0.01, b.y);
  if (p_gozMaskOn > 0.5) open_ = mix(1.0, open_, texture(s_gozMask, clamp(b, 0.0, 1.0)).a); o = s * open_; }
