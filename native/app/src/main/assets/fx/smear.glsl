// smear
uniform vec2 p_baslangi, p_bitis; uniform float p_fircaYari, p_suruklem, p_yumusakl;
void main() {
  vec2 q = toUnit(here()); vec2 A = p_baslangi, Bp = p_bitis; vec2 ab = Bp - A; float L2 = max(dot(ab, ab), 1.0);
  float t = clamp(dot(q - A, ab) / L2, 0.0, 1.0); float dist = length(q - (A + ab * t));
  float R = max(p_fircaYari, 1.0); float w = 1.0 - smoothstep(R * (1.0 - p_yumusakl / 100.0) - 0.5, R, dist);
  o = texU(q - ab * t * w * p_suruklem / 100.0);
}
