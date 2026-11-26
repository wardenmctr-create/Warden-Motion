// scalewipe
uniform vec2 p_sabitNokt; uniform float p_ilerleme, p_aci, p_olcek, p_yumusatm, p_ters;
void main() { vec2 q = toUnit(here()); float pr = p_ilerleme / 100.0; if (p_ters > 0.5) pr = 1.0 - pr; vec2 d = vec2(cos(radians(p_aci)), sin(radians(p_aci))); vec2 r = q - p_sabitNokt;
  float s = 1.0 + (p_olcek / 100.0 - 1.0) * pr; float along = dot(r, d); vec2 src = p_sabitNokt + r - d * along + d * along / s; o = texU(src) * (1.0 - smoothstep(0.7, 1.0, pr)); }
