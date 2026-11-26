// pageturn
uniform sampler2D s_arkaYuzKatm; uniform float p_arkaYuzKatmOn;
uniform vec2 p_kivrilmaNokt; uniform float p_kivrimAcis, p_yaricap, p_golge, p_arkaYuzuGost; uniform vec3 c_arkaYuzReng;
vec4 backFace(vec2 src, float shade) { vec4 s = texU(src); if (s.a < 0.01) return vec4(0.0);
  vec3 col = p_arkaYuzKatmOn > 0.5 ? unpre(texture(s_arkaYuzKatm, clamp(boxUV(fromUnit(src)), 0.0, 1.0))) : c_arkaYuzReng;
  if (p_arkaYuzuGost < 0.5) col = unpre(s); return pre(col * shade, s.a); }
void main() {
  vec2 q = toUnit(here()); float a = radians(p_kivrimAcis); vec2 dir = vec2(cos(a), sin(a));
  float R = max(p_yaricap, 1.0); float d = dot(q - p_kivrilmaNokt, dir);
  vec4 front = vec4(0.0); vec4 back = vec4(0.0);
  if (d < 0.0) {
    front = texU(q);
    back = backFace(q + dir * (PI * R - 2.0 * d), 0.92);
    float sh = p_golge / 100.0 * (1.0 - smoothstep(0.0, R * 0.8, -d)) * 0.5;
    front.rgb *= 1.0 - sh;
  } else if (d < R) {
    float d1 = R * asin(d / R), d2 = R * (PI - asin(d / R));
    front = texU(q + dir * (d1 - d)); front.rgb *= mix(1.0, 0.75, d / R * p_golge / 100.0);
    back = backFace(q + dir * (d2 - d), mix(0.7, 1.0, d / R));
  }
  o = back.a > 0.01 ? overPre(back, front * (1.0 - back.a)) : front;
}
