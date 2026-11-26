// shapematchtrans
uniform vec2 p_esNokt; uniform float p_hizalama, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; float e = p * p * (3.0 - 2.0 * p); vec2 q = toUnit(here()); vec2 c = p_esNokt * p_hizalama / 100.0; float sc = mix(1.0, 0.05, e); vec4 col = texU((q - c * e) / sc + c * 0.0); o = col * (1.0 - smoothstep(0.85, 1.0, p)); }
