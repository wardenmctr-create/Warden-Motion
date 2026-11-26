// cboutline
uniform float p_temelKali, p_tepeKali, p_frekans, p_faz, p_yumusakl, p_yalnizDisKena; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); float k = 0.5 + 0.5 * sin(u_t * p_frekans * TAU + radians(p_faz)); k = mix(step(0.5, k), k, p_yumusakl / 100.0);
  float w = mix(p_temelKali, p_tepeKali, k) * u_s; float ring = p_yalnizDisKena > 0.5 ? clamp(dilateA(here(), w) - s.a, 0.0, 1.0) : clamp(dilateA(here(), w * 0.5) - erodeA(here(), w * 0.5), 0.0, 1.0);
  o = overPre(s * (p_yalnizDisKena > 0.5 ? 1.0 : 1.0 - ring), vec4(c_renk, 1.0) * ring); if (p_yalnizDisKena > 0.5) o = overPre(s, vec4(c_renk, 1.0) * ring); }
