// cbskin
uniform sampler2D s_bayrakKatm, s_govdeMask; uniform float p_bayrakKatmOn, p_govdeMaskOn;
uniform float p_yerlesim, p_olcek, p_aci, p_kureBuku, p_golge, p_konturuKoru, p_esleme, p_kureDonus, p_dikeyDonus, p_yuzeySabit, p_sekilTakip, p_yuzeyKabar, p_aksesuarKoru; uniform vec2 p_kayma;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float mask = p_govdeMaskOn > 0.5 ? texture(s_govdeMask, clamp(b, 0.0, 1.0)).a : s.a; if (mask <= 0.0) { o = s; return; }
  vec2 r = b - 0.5; float d = length(r) * 2.0; vec2 uv;
  if (p_esleme < 0.5) uv = r;
  else { vec2 rr = r * 2.0; if (p_esleme > 1.5) rr.y *= 1.15; float z = sqrt(max(0.0, 1.0 - dot(rr, rr))); vec3 n = vec3(rr, z);
    float a = radians(p_kureDonus), e = radians(p_dikeyDonus); n.xz = mat2(cos(a), -sin(a), sin(a), cos(a)) * n.xz; n.yz = mat2(cos(e), -sin(e), sin(e), cos(e)) * n.yz;
    uv = mix(r, vec2(atan(n.x, n.z) / PI * 0.5, asin(clamp(n.y, -1.0, 1.0)) / PI * 0.5) * 1.1, p_kureBuku / 100.0 * 2.0 > 1.0 ? 1.0 : p_kureBuku / 50.0 + 0.0); }
  vec2 fb = rot2(-p_aci) * (uv - p_kayma / boxU()) / max(p_olcek / 100.0, 0.01) + 0.5;
  vec4 f = p_bayrakKatmOn > 0.5 ? texture(s_bayrakKatm, clamp(fb, 0.0, 1.0)) : s; vec3 c = f.a > 0.0 ? f.rgb / f.a : unpre(s);
  c *= 1.0 - smoothstep(0.5, 1.0, d) * p_golge / 100.0; if (p_yuzeyKabar > 0.0) c *= 1.0 + (0.5 - d) * p_yuzeyKabar / 100.0 * 0.5;
  vec4 res = pre(c, mask);
  if (p_konturuKoru > 0.5 || p_aksesuarKoru > 0.5) { vec3 sc = unpre(s); float dark = 1.0 - smoothstep(0.05, 0.25, luma(sc)); float white = smoothstep(0.85, 0.97, min(sc.r, min(sc.g, sc.b)));
    float keep = (p_konturuKoru > 0.5 ? dark : 0.0) + (p_aksesuarKoru > 0.5 ? white * 0.0 : 0.0); res = mix(res, s, clamp(keep, 0.0, 1.0) * s.a); }
  o = res;
}
