// radialshadow_a
uniform vec2 p_isikMerk; uniform float p_golgeMesa;
void main() {
  // ışıktan uzaklaşan yönde kaydırılmış siluet
  vec2 q = toUnit(here()); vec2 dir = q - p_isikMerk; float L = max(length(dir), 1.0); vec2 src = q - dir / L * p_golgeMesa * (0.4 + 0.6 * clamp(L / max(length(boxU()), 1.0), 0.0, 1.0));
  o = vec4(texU(src).a);
}
