// curtain
uniform float p_toplanma, p_kivrim, p_yon, p_ilerleme;
void main() { float p = p_ilerleme / 100.0 * p_toplanma / 100.0; vec2 b = boxUV(here()); float x = p_yon < 0.5 ? b.x : p_yon < 1.5 ? 1.0 - b.x : p_yon < 2.5 ? abs(b.x - 0.5) * 2.0 : 1.0 - b.y;
  float open_ = p; if (x < open_) { o = vec4(0.0); return; } float u = (x - open_) / max(1.0 - open_, 1e-3); float folds = sin(u * (8.0 + p_kivrim / 5.0) * (1.0 + p * 3.0)) * 0.5 + 0.5; vec2 src = b;
  if (p_yon < 0.5) src.x = open_ + u * (1.0 - open_) * 0.0 + b.x * 0.0 + mix(b.x, u, p); else if (p_yon < 1.5) src.x = 1.0 - mix(1.0 - b.x, u, p); else if (p_yon < 2.5) src.x = 0.5 + sign(b.x - 0.5) * 0.5 * mix(abs(b.x - 0.5) * 2.0, u, p); else src.y = 1.0 - mix(1.0 - b.y, u, p);
  vec4 c = texPx(boxPx(clamp(src, 0.0, 1.0))); c.rgb *= 1.0 - folds * p * p_kivrim / 100.0 * 0.6; o = c; }
