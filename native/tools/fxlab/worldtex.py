# Natural Earth (kamu malı) verisinden eşdikdörtgen Dünya dokuları üretir: assets/fx/tex/world_a.png, world_b.png
# world_a: RGB = siyasi renk (MAPCOLOR7), A = kara. world_b: R = ülke sınırı çizgisi, G = şehir ışıkları, B = göl
import json, sys, os
from PIL import Image, ImageDraw, ImageFilter
SRC = sys.argv[1]; OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../app/src/main/assets/fx/tex"); os.makedirs(OUT, exist_ok=True)
W, H = 2048, 1024; S = 2  # süper örnekleme
def xy(lon, lat): return ((lon + 180) / 360 * W * S, (90 - lat) / 180 * H * S)
def polys(geom):
    if geom["type"] == "Polygon": yield geom["coordinates"]
    elif geom["type"] == "MultiPolygon": yield from geom["coordinates"]
PAL = [(0,0,0), (232,93,93), (243,180,76), (247,226,107), (126,201,122), (91,166,224), (167,126,214), (240,140,190)]
cn = json.load(open(os.path.join(SRC, "ne_50m_admin_0_countries.geojson")))
pol = Image.new("RGBA", (W * S, H * S), (0, 0, 0, 0)); dp = ImageDraw.Draw(pol)
bnd = Image.new("L", (W * S, H * S), 0); db = ImageDraw.Draw(bnd)
for f in cn["features"]:
    c = PAL[int(f["properties"].get("MAPCOLOR7") or 1) % 8 or 1]
    for poly in polys(f["geometry"]):
        for ri, ring in enumerate(poly):
            pts = [xy(*p[:2]) for p in ring]
            if len(pts) < 3: continue
            dp.polygon(pts, fill=c + (255,) if ri == 0 else (0, 0, 0, 0))
            db.line(pts + [pts[0]], fill=255, width=S)
lk = json.load(open(os.path.join(SRC, "ne_50m_lakes.geojson")))
lake = Image.new("L", (W * S, H * S), 0); dl = ImageDraw.Draw(lake)
for f in lk["features"]:
    for poly in polys(f["geometry"]): dl.polygon([xy(*p[:2]) for p in poly[0]], fill=255)
city = Image.new("L", (W * S, H * S), 0); dc = ImageDraw.Draw(city)
pp = json.load(open(os.path.join(SRC, "ne_10m_populated_places_simple.geojson")))
for f in pp["features"]:
    pr = f["properties"]; x, y = xy(f["geometry"]["coordinates"][0], f["geometry"]["coordinates"][1])
    r = S * (0.8 + min(5, (max(1e4, pr.get("pop_max") or 1e4) / 3e6) ** 0.5 * 2)); dc.ellipse([x - r, y - r, x + r, y + r], fill=255)
city = city.filter(ImageFilter.GaussianBlur(S * 2))
pol = pol.resize((W, H), Image.LANCZOS)
b = Image.merge("RGB", (bnd.resize((W, H), Image.LANCZOS), city.resize((W, H), Image.LANCZOS), lake.resize((W, H), Image.LANCZOS)))
pol.save(os.path.join(OUT, "world_a.png"), optimize=True); b.save(os.path.join(OUT, "world_b.png"), optimize=True)
print("tamam", os.path.getsize(os.path.join(OUT, "world_a.png")), os.path.getsize(os.path.join(OUT, "world_b.png")))
