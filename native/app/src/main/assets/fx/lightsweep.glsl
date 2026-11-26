// lightsweep
uniform vec2 p_merkez; uniform float p_aci, p_seritGeni, p_isikGucu, p_kenarVurg, p_seritBici; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float a = radians(p_aci); vec2 n = vec2(cos(a), sin(a)); float d = abs(dot(toUnit(here()) - p_merkez, n)); float w = max(p_seritGeni * 0.5, 0.5);
  float k = p_seritBici < 0.5 ? exp(-d * d / (w * w) * 2.0) : 1.0 - smoothstep(w - 0.8, w + 0.8, d);
  float ed = clamp(length(alphaGrad(here(), 1.5)) * 3.0, 0.0, 1.0) * p_kenarVurg / 100.0;
  vec3 c = unpre(s) + c_renk * k * (p_isikGucu / 100.0) * (0.8 + ed * 2.0);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
