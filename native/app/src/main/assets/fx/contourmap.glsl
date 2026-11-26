// contourmap
uniform sampler2D s_yuksekli; uniform float p_yuksekliOn, p_egriAral, p_anaCizgSikl;
float hAt(vec2 px) { return (p_yuksekliOn > 0.5 ? luma(unpre(texture(s_yuksekli, clamp(boxUV(px), 0.0, 1.0)))) : luma(unpre(texPx(px)))) * 5000.0; }
void main() { vec4 s = texture(u_tex, v_uv); float h = hAt(here()); float g = length(vec2(hAt(here() + vec2(1.0, 0.0)) - h, hAt(here() + vec2(0.0, 1.0)) - h)) + 1e-4; float iv = max(p_egriAral, 1.0);
  float d = abs(fract(h / iv + 0.5) - 0.5) * iv / g; float major = step(0.5, 1.0 - abs(fract(h / (iv * max(p_anaCizgSikl, 1.0)) + 0.5) - 0.5) * 2.0 * 0.0) * 0.0; float isMajor = abs(fract(h / (iv * max(p_anaCizgSikl, 1.0)) + 0.5) - 0.5) * iv * max(p_anaCizgSikl, 1.0) / g;
  float line = 1.0 - smoothstep(0.5, 1.2, d); float mline = 1.0 - smoothstep(1.0, 1.8, isMajor); vec3 base = mix(vec3(0.85, 0.9, 0.75), vec3(0.75, 0.6, 0.45), h / 5000.0);
  o = vec4(mix(base, vec3(0.45, 0.3, 0.15), max(line * 0.6, mline)), 1.0); }
