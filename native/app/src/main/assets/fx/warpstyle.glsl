// warpstyle
uniform float p_stil, p_bukme, p_yatayBozu, p_dikeyBozu, p_yon; uniform vec2 p_merkez;
void main() {
  vec2 B = boxU(); vec2 p = (toUnit(here()) - p_merkez) / (B * 0.5);
  if (p_yon > 0.5) p = p.yx;
  float b = p_bukme / 100.0; float x = p.x, y = p.y; vec2 s = p;
  if (p_stil < 0.5) s.y = y + b * (1.0 - x * x) * 0.6;
  else if (p_stil < 1.5) s.y = y + b * (1.0 - x * x) * 0.6 * (1.0 - (y + 1.0) * 0.5);
  else if (p_stil < 2.5) s.y = y + b * 0.35 * sin(x * PI);
  else if (p_stil < 3.5) s.y = y / max(0.1, 1.0 + b * (1.0 - x * x) * 0.6);
  else if (p_stil < 4.5) { float r = length(p); s = p * (1.0 - b * 0.5 * max(0.0, 1.0 - r * r)); }
  else if (p_stil < 5.5) s.y = y + b * 0.3 * sin(x * TAU);
  else { float r = length(p); float a = b * PI * max(0.0, 1.0 - r); s = mat2(cos(a), sin(a), -sin(a), cos(a)) * p; }
  s.y /= max(0.1, 1.0 + p_yatayBozu / 100.0 * x * 0.6); s.x /= max(0.1, 1.0 + p_dikeyBozu / 100.0 * y * 0.6);
  if (p_yon > 0.5) s = s.yx;
  o = texU(p_merkez + s * B * 0.5);
}
