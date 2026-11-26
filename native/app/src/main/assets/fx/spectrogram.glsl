// spectrogram
uniform sampler2D s_anl; uniform float p_anlOn; uniform vec3 c_palet;
void main() { vec2 b = boxUV(here()); if (p_anlOn < 0.5) { float v = 0.5 + 0.5 * sin(b.x * 30.0 + u_t * 3.0) * (1.0 - b.y); o = vec4(mix(c_palet, vec3(1.0, 0.8, 0.2), v * (1.0 - b.y)), 1.0); return; }
  float g = texture(s_anl, b).r; vec3 c = g < 0.5 ? mix(c_palet, vec3(0.7, 0.1, 0.6), g * 2.0) : mix(vec3(0.7, 0.1, 0.6), vec3(1.0, 0.9, 0.3), g * 2.0 - 1.0); o = vec4(c, 1.0); }
