// circlefx
uniform vec2 p_merkez; uniform float p_yaricap, p_konturKali, p_kenarGeci, p_yalnizHalk; uniform vec3 c_dolgu, c_kontur;
void main() {
  vec4 s = texture(u_tex, v_uv); float d = length(toUnit(here()) - p_merkez) - p_yaricap; float w = max(p_kenarGeci, 0.6 / u_s);
  float fill = 1.0 - smoothstep(-w, w, d); float ring = (1.0 - smoothstep(p_konturKali - w, p_konturKali + w, abs(d + p_konturKali * 0.5))) * step(0.01, p_konturKali);
  vec4 c = p_yalnizHalk > 0.5 ? vec4(0.0) : vec4(c_dolgu, 1.0) * fill; c = mix(c, vec4(c_kontur, 1.0), ring);
  o = overPre(c, s);
}
