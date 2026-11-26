// mirror
uniform float p_yatayAyna, p_dikeyAyna; uniform vec2 p_aynaMerk;
void main() {
  vec2 q = toUnit(here());
  if (p_yatayAyna > 0.5) q.x = 2.0 * p_aynaMerk.x - q.x;
  if (p_dikeyAyna > 0.5) q.y = 2.0 * p_aynaMerk.y - q.y;
  o = texU(q);
}
