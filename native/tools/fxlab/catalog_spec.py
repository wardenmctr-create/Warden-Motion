# Rehberdeki (spec.json) ayar tablolarını kataloğa uygular + 30 Countryball efekti (catalog.py içinden çalıştırılır)
import copy
_SP = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "spec.json"), encoding="utf-8"))
CATS += ["Countryball"]
CB = 16
CAT_ORDER = [16, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 12, 11]

# Shader'ı rehberdeki ayarlarla yeniden yazılmış efektler (her kategori bitince listeye eklenir)
READY = set(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "ready.txt")).read().split()) \
    if os.path.exists(os.path.join(os.path.dirname(os.path.abspath(__file__)), "ready.txt")) else set()

CBK = {401: ("flagwave", "pixel", ["Bayrak", "Rüzgâr", "Dalga"]), 402: ("cbshade", "pixel", ["Gölge", "Işık", "Hacim"]),
       403: ("cbeyes", "rig", ["Göz", "Rig"]), 404: ("cbblink", "rig", ["Göz", "Rig", "Animasyon"]),
       405: ("cbbrow", "rig", ["Kaş", "Duygu", "Rig"]), 406: ("cbtalk", "rig", ["Konuşma", "Ses", "Rig"]),
       407: ("cbhop", "xform", ["Zıplama", "Tepki", "Animasyon"]), 408: ("cbblush", "pixel", ["Yanak", "Duygu"]),
       409: ("cbsurprise", "pixel", ["Tepki", "Simge", "Komedi"]), 410: ("cbsweat", "pixel", ["Ter", "Komedi"]),
       411: ("cbshadow", "special", ["Gölge", "Zıplama"]), 412: ("cbcam", "special", ["Kamera", "Komedi"]),
       413: ("cbskin", "pixel", ["Bayrak", "Kaplama"]), 414: ("cboutline", "pixel", ["Kontur", "Vurgu"]),
       415: ("cbbubble", "text", ["Konuşma", "Balon", "Metin"]), 416: ("cbmaphl", "pixel", ["Harita", "Vurgu"]),
       417: ("cbborder", "shape", ["Harita", "Sınır", "Çizgi"]), 418: ("cbtrail", "shape", ["Harita", "Rota", "Çizgi"]),
       419: ("cbbadge", "special", ["Rozet", "Giriş"]), 420: ("cbhold", "time", ["Komedi", "Zaman", "Yakınlaşma"]),
       421: ("cbspeed", "pixel", ["Hız", "Çizgi film"]), 422: ("cbdust", "pixel", ["Toz", "Zıplama"]),
       423: ("cblabel", "text", ["Harita", "Etiket", "Metin"]), 424: ("cbflagtrans", "pixel", ["Bayrak", "Geçiş"]),
       425: ("cbbeat", "audio", ["Ritim", "Ses", "Müzik"]), 426: ("cbexpr", "rig", ["Yüz", "İfade", "Rig"]),
       427: ("cbrig", "rig", ["Rig", "Gövde"]), 428: ("cbsticker", "pixel", ["Çıkartma", "Kontur"]),
       429: ("cbmaplock", "rig", ["Harita", "Kamera", "Etiket"]), 430: ("cbcaption", "text", ["Altyazı", "Metin"])}

def _neutral(p):
    if p.get("unit") == "%" and p["min"] < 0: return 0
    if p.get("unit") in ("°",) or p["min"] < 0 < p["max"]: return 0
    return p["min"]

def _main(ps):
    for p in ps:
        if p["kind"] == "jog" and not p.get("two") and not p.get("three") and p.get("anim") == "yes" and p.get("unit") in ("%", "px", "°", ""): return p
    return None

def _round(v, p):
    st = p.get("step", 0.01)
    return round(round(v / st) * st, 4) if st else v

def auto_presets(e):
    m = _main(e["params"])
    if not m: return []
    d, lo, hi, nz = m["def_"], m["min"], m["max"], _neutral(m)
    if d != nz:
        light, strong = nz + (d - nz) * 0.5, nz + (d - nz) * 1.8
    else:
        span = hi - nz if hi > nz else nz - lo
        light, strong = nz + span * 0.2, nz + span * 0.55
    clamp = lambda v: _round(min(hi, max(lo, v)), m)
    k = m["k"]
    return [dict(code="HF", name="Hafif", vals={k: clamp(light)}, keys={}, cols={}, at="start", auto=True),
            dict(code="GÇ", name="Güçlü", vals={k: clamp(strong)}, keys={}, cols={}, at="start", auto=True),
            dict(code="AN", name="Animasyonlu", vals={}, keys={k: [[0, clamp(nz)], [0.5, clamp(strong)], [1, clamp(d if d != nz else light)]]}, cols={}, at="start", auto=True)]

exec(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "fxdefs.py")).read())
import re as _re
_OFS = _re.compile(r"(ofset|kayma|yer değiştirme|ızgara konumu)", _re.I)
LEGACY = {}
_byname = {e["name"].lower(): e for e in E if not e.get("hidden")}
for n, s in _SP.items():
    n = int(n)
    if n <= 400:
        e = _byname[s["name"].lower()]
    else:
        t, kind, tags = CBK[n]
        fx(t, s["name"], s["en"], CB, kind, s["desc"], ["Countryball"] + tags, [])
        e = E[-1]
    LEGACY[e["type"]] = dict(params=copy.deepcopy(e["params"]), presets=copy.deepcopy(e["presets"]))
    e["n"] = n
    e["params"] = copy.deepcopy(s["params"])
    for p in e["params"]:
        # Kaydırma/ofset türü X/Y ayarları konum değil, kutunun yüzdesi olarak vektördür (0,0 = kayma yok)
        if p.get("two") and p.get("unit") == "box%" and _OFS.search(p["l"]): p["unit"] = "%v"
    if s.get("desc") and n <= 400 and len(s["desc"]) > len(e["desc"]): e["desc"] = s["desc"]
    if s.get("teach"): e["teach"] = s["teach"]
    if s.get("notes"): e["notes"] = s["notes"]
    if s.get("inner"): e["inner"] = s["inner"]
    keys = {p["k"] for p in e["params"]}
    keep = []
    for pr in e["presets"]:
        if pr.get("alias"): keep.append(pr); continue
        if set(pr["vals"]) | set(pr["keys"]) | set(pr["cols"]) <= keys and (pr["vals"] or pr["keys"] or pr["cols"]): keep.append(pr)
    TRANS = e["cat"] == 13 or e["type"] in ("shatter", "pixelpolly", "scatterize", "dissolve", "blockdissolve", "blinds", "linwipe", "radwipe", "iris")
    if TRANS and any(p["k"] == "ilerleme" for p in e["params"]):
        P3 = lambda code, name, keys, at="start": dict(code=code, name=name, vals={}, keys=keys, cols={}, at=at, auto=True)
        inv = e["type"] in ("iris",)  # iris: 0 = kapalı
        a, b = (0, 100) if inv else (100, 0)
        e["presets"] = [P3("GR", "Giriş", {"ilerleme": [[0, a], [0.7, b]]}), P3("CK", "Çıkış", {"ilerleme": [[-0.7, b], [0, a]]}, "end"),
                        P3("AN", "Animasyonlu", {"ilerleme": [[0, 0], [0.5, 100], [1, 0]]})] + keep
    elif any(p["k"] == "yonelimXY" for p in e["params"]):
        P3 = lambda code, name, vals=None, keys=None: dict(code=code, name=name, vals=vals or {}, keys=keys or {}, cols={}, at="start", auto=True)
        e["presets"] = [P3("DN", "Dönen", {"yonelimXYX": 18, "surekliDonuXY": 90}), P3("EG", "Eğik Duruş", {"yonelimXYX": 25, "yonelimXYY": 35}),
                        P3("AN", "Animasyonlu", {"yonelimXYX": 15}, {"yonelimXYY": [[0, -40], [0.5, 40], [1, -40]]})] + keep
    else:
        e["presets"] = auto_presets(e) + keep
    e["ready"] = e["type"] in READY
    if e["ready"]:
        d = FXDEF.get(e["type"], {})
        e["pad"] = d.get("pad"); e["passes"] = d.get("passes")
        if "heavy" in d: e["heavy"] = d["heavy"]

# Gizli (birleşmiş) efektlerin eski ayarları lab için saklanır
for e in E:
    if e.get("hidden"): LEGACY.setdefault(e["type"], dict(params=copy.deepcopy(e["params"]), presets=copy.deepcopy(e["presets"])))

# Sonradan eklenen tanımlar (Karton Kukla, Kesim Altlığı, güncel Dokulandır)
exec(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "catalog_extra.py")).read())
exec(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "catalog_upd.py")).read())
for _e in E:
    if _e["type"] in ("cutback", "cardpuppet", "texturize"): _e["ready"] = _e["type"] in READY
