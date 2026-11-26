// focustrack
uniform sampler2D s_derinlik; uniform vec4 p_dv4[1]; float dvAt(int i) { return i < 0 || i >= 4 ? 0.0 : p_dv4[0][i]; }
uniform float p_derinlikOn, p_dvN, p_tepki, p_oncelik;
// Odak düzlemi hedefin bulunduğu noktadaki derinlik (motor: hedef konumu); derinlik farkı kadar disk bulanıklığı
float D(vec2 px) { return p_derinlikOn > 0.5 ? luma(texture(s_derinlik, boxUV(px)).rgb) : lumAt(px); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 tg = p_dvN > 1.5 ? fromUnit(vec2(dvAt(0), dvAt(1))) : boxPx(vec2(0.5 + 0.3 * sin(u_t * 0.7), 0.5)); float fd = D(tg); float dd = abs(D(here()) - fd);
  float R = dd * 14.0 * u_s * p_oncelik / 100.0; if (R < 0.6) { o = s; return; } vec4 acc = vec4(0.0); for (int i = 0; i < 16; i++) { float a = float(i) * 2.39996; float r = sqrt((float(i) + 0.5) / 16.0) * R; acc += texPx(here() + vec2(cos(a), sin(a)) * r); } o = acc / 16.0; }
