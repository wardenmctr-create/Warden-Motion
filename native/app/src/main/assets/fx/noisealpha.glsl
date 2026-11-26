// noisealpha
uniform float p_gurultuOlce, p_esik, p_yumusakl, p_evrim, p_tohum, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); float n = fbm(toUnit(here()) / max(p_gurultuOlce, 0.5) * 0.25 + seedf(p_tohum) + vec2(cos(radians(p_evrim)), sin(radians(p_evrim))) * 0.6, 3.0) * 0.5 + 0.5;
  float w = p_yumusakl / 200.0 + 0.005; float k = smoothstep(p_esik / 100.0 - w, p_esik / 100.0 + w, n); if (p_ters > 0.5) k = 1.0 - k; o = s * k; }
