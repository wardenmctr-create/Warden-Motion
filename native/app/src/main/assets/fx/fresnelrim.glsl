// fresnelrim
uniform sampler2D s_normalHari; uniform vec3 c_renk; uniform float p_normalHariOn, p_fresnelKuvv, p_guc;
// Normal haritası yoksa silüetten küre benzeri normal: kenara yakın nz küçük; Fresnel = (1−nz)^kuvvet
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float nz;
  if (p_normalHariOn > 0.5) nz = clamp(texture(s_normalHari, boxUV(here())).b * 2.0 - 1.0, 0.0, 1.0);
  else { float R = min(u_box.z, u_box.w) * 0.25; float d = innerDist(here(), R) / R; nz = sqrt(clamp(1.0 - pow(1.0 - d, 2.0), 0.0, 1.0)); }
  float f = pow(1.0 - nz, p_fresnelKuvv) * p_guc / 100.0; o = vec4(s.rgb + c_renk * f * s.a, s.a); }
