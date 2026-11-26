// treemap
INCLUDE(_chart)
uniform float p_bosluk; uniform vec3 c_renkPale;
void main() { vec2 b = boxUV(here()); float R = dR(); float tot = 0.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; tot += max(dat(float(r), 0.0), 0.0); }
  vec4 rect = vec4(0.0, 0.0, 1.0, 1.0); float rem = tot; int pick = -1; vec4 pr = rect;
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; float v = max(dat(float(r), 0.0), 0.0); float k = v / max(rem, 1e-6); bool vert = (rect.z - rect.x) * boxU().x >= (rect.w - rect.y) * boxU().y; vec4 cell = rect;
    if (vert) { cell.z = rect.x + (rect.z - rect.x) * k; rect.x = cell.z; } else { cell.w = rect.y + (rect.w - rect.y) * k; rect.y = cell.w; } rem -= v;
    if (b.x >= cell.x && b.x < cell.z && b.y >= cell.y && b.y < cell.w) { pick = r; pr = cell; } }
  if (pick < 0) { o = vec4(0.0); return; } vec2 gap = p_bosluk / boxU() * 0.5; bool in_ = b.x > pr.x + gap.x && b.x < pr.z - gap.x && b.y > pr.y + gap.y && b.y < pr.w - gap.y;
  vec3 c = serCol(float(pick), c_renkPale); vec2 lp = (b - (pr.xy + pr.zw) * 0.5) * boxU() / 9.0; float n = numAt(lp, dat(float(pick), 0.0)); o = in_ ? vec4(mix(c, vec3(1.0), n), 1.0) : vec4(0.0); }
