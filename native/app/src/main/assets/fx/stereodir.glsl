// stereodir
uniform vec4 p_dv4[32]; float dvAt(int i) { return i < 0 || i >= 128 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_dvN, p_bant, p_yumusatm, p_altFrek, p_ustFrek;
// Yatay: sol–sağ dengesi, dikey: frekans bandı (altta bas); her bant enerjisiyle parlayan, frekans renginde bir leke
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); int N = int(clamp(p_bant, 8.0, 64.0)); vec4 res = overPre(vec4(0.04, 0.05, 0.08, 0.75), s); res = overPre(vec4(vec3(1.0), 1.0) * (1.0 - smoothstep(0.0, 1.2 / u_box.z, abs(b.x - 0.5))) * 0.25, res);
  for (int k = 0; k < 64; k++) { if (k >= N) break; float bal = p_dvN > 0.5 ? dvAt(k * 2) : sin(u_t * 1.1 + float(k) * 0.4) * 0.6; float en = p_dvN > 0.5 ? dvAt(k * 2 + 1) : 0.4 + 0.4 * sin(u_t * 2.0 + float(k)); float y = 1.0 - (float(k) + 0.5) / float(N);
    vec2 c = vec2(0.5 + bal * 0.45, y); float d = length((b - c) * u_box.zw); float r = (2.0 + en * 6.0) * u_s; res = overPre(vec4(hsv2rgb(vec3(float(k) / float(N) * 0.8, 0.7, 1.0)), 1.0) * (1.0 - smoothstep(r * 0.5, r, d)) * clamp(en, 0.0, 1.0), res); }
  o = res; }
