// ripple
uniform vec2 p_merkez; uniform float p_yaricap, p_aci, p_halkaAral, p_genlik, p_faz, p_hiz, p_azalma;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float d = length(r); float R = max(p_yaricap, 1.0);
  float w = sin(TAU * (d / max(p_halkaAral, 1.0) - p_hiz * u_t) + p_faz * TAU / 100.0);
  float amp = p_genlik * exp(-d / R * p_azalma / 100.0 * 3.0) * (1.0 - smoothstep(R * 0.85, R, d));
  vec2 dir = d > 0.001 ? rot2(p_aci) * (r / d) : vec2(0.0);
  o = texU(q - dir * w * amp);
}
