# Natural Earth ülkelerinden kimlik haritası: her pikselde ISO 3166 sayısal kodu (R = kod >> 8, G = kod & 255), kenar yumuşatması yok
import json, sys, os
from PIL import Image, ImageDraw
SRC = sys.argv[1]; OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../app/src/main/assets/fx/tex/world_id.png")
W, H = 2048, 1024
def xy(lon, lat): return ((lon + 180) / 360 * W, (90 - lat) / 180 * H)
def polys(g):
    if g["type"] == "Polygon": yield g["coordinates"]
    elif g["type"] == "MultiPolygon": yield from g["coordinates"]
cn = json.load(open(os.path.join(SRC, "ne_50m_admin_0_countries.geojson")))
im = Image.new("RGB", (W, H), (0, 0, 0)); d = ImageDraw.Draw(im); n = 0
for f in cn["features"]:
    p = f["properties"]; code = p.get("ISO_N3") or p.get("ISO_N3_EH") or "-99"
    try: code = int(code)
    except: code = -99
    if code <= 0: code = 900 + (n % 99)
    for poly in polys(f["geometry"]):
        for ri, ring in enumerate(poly):
            pts = [xy(*q[:2]) for q in ring]
            if len(pts) >= 3: d.polygon(pts, fill=((code >> 8) & 255, code & 255, 255) if ri == 0 else (0, 0, 0))
    n += 1
im.save(OUT, optimize=True); print(n, "ülke", os.path.getsize(OUT))
