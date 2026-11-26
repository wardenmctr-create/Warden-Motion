// doorwings
uniform float p_kanatAcis, p_derinlik, p_golge, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; vec2 b = boxUV(here()); bool left = b.x < 0.5; float a = radians(p_kanatAcis) * p; float x = left ? b.x * 2.0 : (1.0 - b.x) * 2.0; float w = cos(a); float persp = 1.0 + sin(a) * x * p_derinlik / 400.0;
  float u = x / max(w, 0.01); if (u > 1.0 || w <= 0.01) { o = vec4(0.0); return; } float y = (b.y - 0.5) * persp + 0.5; if (y < 0.0 || y > 1.0) { o = vec4(0.0); return; } vec2 src = vec2(left ? u * 0.5 : 1.0 - u * 0.5, y);
  vec4 c = texPx(boxPx(src)); c.rgb *= 1.0 - sin(a) * p_golge / 100.0; o = c; }
