// galaxy
GRADIENT(renkGeci)
uniform vec2 p_merkez; uniform float p_kolSayi, p_donus, p_hiz, p_yaricap, p_yildizYogu, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 r = toUnit(here()) - p_merkez; float R = max(p_yaricap, 1.0); float d = length(r) / R;
  float a = atan(r.y, r.x) - radians(p_donus) - u_t * p_hiz * TAU; float arms = max(1.0, floor(p_kolSayi));
  float spiral = 0.5 + 0.5 * cos(arms * (a + log(d + 0.02) * 2.6)); float n = fbm(r / R * 6.0 + seedf(p_tohum), 3.0) * 0.5 + 0.5;
  float dens = pow(spiral, 2.0) * exp(-d * 2.2) * (0.6 + 0.6 * n) + exp(-d * 9.0) * 1.2;
  vec2 g = floor(here() / max(u_s * 1.5, 1.0)); float st = step(1.0 - p_yildizYogu / 100.0 * 0.04, hash1(g + seedf(p_tohum))) * (0.5 + hash1(g + 3.0));
  vec3 c = grad_renkGeci(clamp(d, 0.0, 1.0)) * dens + vec3(st) * exp(-d * 1.2);
  o = vec4(min(s.rgb + c, vec3(1.0)), max(s.a, clamp(max(c.r, max(c.g, c.b)), 0.0, 1.0)));
}
