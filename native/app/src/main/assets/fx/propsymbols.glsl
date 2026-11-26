// propsymbols
INCLUDE(_chart)
uniform float p_enKucuSimg, p_enBuyu, p_olcek, p_cakismayOnle;
// Satır: x %, y %, değer → orantılı daire (alan ya da yarıçap); küçükler üstte
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float M = 1e-6; int N = int(min(dR(), 64.0)); for (int r = 0; r < 64; r++) { if (r >= N) break; M = max(M, abs(dat(float(r), 2.0))); }
  vec4 res = s; float bestR = 1e9; for (int r = 0; r < 64; r++) { if (r >= N) break; vec2 c = vec2(dat(float(r), 0.0), dat(float(r), 1.0)) / 100.0; float k = abs(dat(float(r), 2.0)) / M; k = p_olcek < 0.5 ? sqrt(k) : k;
    float R = mix(p_enKucuSimg, p_enBuyu, k) * u_s; float d = length((b - c) * u_box.zw); if (d > R + 1.5) continue; if (p_cakismayOnle > 0.5 && R > bestR) continue; bestR = R;
    float a = 1.0 - smoothstep(R - 1.0, R + 0.5, d); float rim = 1.0 - smoothstep(0.8, 2.0, abs(d - R + 1.0)); res = overPre(vec4(mix(vec3(1.0, 0.45, 0.25) * 0.75, vec3(1.0), rim), 1.0) * max(a * 0.75, rim), res); }
  o = res; }
