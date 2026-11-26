// morphparticles3d
uniform sampler2D s_kaynak, s_hedef; uniform float p_kaynakOn, p_hedefOn, p_parcacik, p_ilerleme, p_dagilim;
// Parçacıklar kaynak silüetten (katmanın kendisi ya da kaynak) hedef silüete yer değiştirir; ortada derinlikte saçılır (perspektifle boyutlanır)
vec2 pick(int k, bool tgt) { for (int i = 0; i < 6; i++) { vec2 u = hash2(vec2(float(k) * 1.37 + float(i) * 7.1, tgt ? 31.7 : 3.3)); float a = tgt ? (p_hedefOn > 0.5 ? texture(s_hedef, u).a : step(length(u - 0.5), 0.35)) : (p_kaynakOn > 0.5 ? texture(s_kaynak, u).a : texPx(boxPx(u)).a); if (a > 0.5) return u; } return vec2(0.5); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float pr = smoothstep(0.0, 1.0, p_ilerleme / 100.0); int N = int(clamp(p_parcacik / 4.0, 16.0, 256.0)); vec3 acc = vec3(0.0); float al = 0.0;
  for (int k = 0; k < 256; k++) { if (k >= N) break; vec2 a = pick(k, false), c = pick(k, true); float z = sin(pr * 3.14159) * (hash1(vec2(float(k), 9.0)) - 0.3) * p_dagilim / 100.0; vec2 pos = mix(a, c, pr) + (hash2(vec2(float(k), 4.0)) - 0.5) * sin(pr * 3.14159) * p_dagilim / 200.0;
    float R = (1.6 + z * 3.0) * u_s / min(u_box.z, u_box.w); float d = length((b - pos) * vec2(u_box.z / u_box.w, 1.0)); float v = 1.0 - smoothstep(R * 0.6, R, d); if (v <= 0.0) continue;
    vec4 col = p_kaynakOn > 0.5 ? texture(s_kaynak, a) : texPx(boxPx(a)); acc += mix(unpre(col), vec3(1.0), 0.15) * v; al = max(al, v); }
  vec4 fade = s * (1.0 - smoothstep(0.0, 0.15, pr)); o = overPre(vec4(acc, al), fade); }
