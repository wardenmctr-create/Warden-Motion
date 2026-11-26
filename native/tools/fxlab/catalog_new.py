# Yeni efektler: Bölüm C (433–462) ve 550 rehberi (463–550). spec2.json'dan ayarlar okunur; shader'ı hazır olmayanlar gizli kalır.
_SP2 = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "spec2.json"), encoding="utf-8"))
_C = {c: i for i, c in enumerate(CATS)}
NEW = {  # n: (tür, kategori, tür(kind), etiketler, ped)
 433: ("globe3d", "3B", "3d", ["Dünya", "Harita", "Gezegen"], {"box": 0.45}), 434: ("planet3d", "3B", "3d", ["Gezegen", "Uzay"], {"box": 0.45}),
 435: ("ringplanet", "3B", "3d", ["Gezegen", "Halka", "Uzay"], {"box": 0.8}), 436: ("flagpole3d", "3B", "3d", ["Bayrak", "Direk", "Rüzgâr"], {"box": 0.6}),
 437: ("book3d", "3B", "3d", ["Kitap", "Sayfa"], {"box": 0.6}), 438: ("dice3d", "3B", "3d", ["Zar", "Oyun"], {"box": 0.45}),
 439: ("gear3d", "3B", "3d", ["Dişli", "Mekanik"], {"box": 0.45}), 440: ("chain3d", "3B", "3d", ["Zincir", "Metal"], {"box": 0.6}),
 441: ("coin3d", "3B", "3d", ["Para", "Rozet"], {"box": 0.45}), 442: ("pipe3d", "3B", "3d", ["Boru", "Tüp"], {"box": 0.6}),
 443: ("meteors", "Simülasyon", "gen", ["Uzay", "Gökyüzü", "Parçacık"], None), 444: ("blackhole", "Simülasyon", "pixel", ["Uzay", "Bükme", "Mercek"], {"box": 0.3}),
 445: ("nebula", "Prosedürel", "gen", ["Uzay", "Bulut", "Renk"], None), 446: ("sunsurface", "Prosedürel", "gen", ["Güneş", "Yıldız", "Uzay"], {"box": 0.4}),
 447: ("tornado", "Simülasyon", "gen", ["Fırtına", "Girdap", "Hava"], None), 448: ("sandstorm", "Simülasyon", "pixel", ["Kum", "Toz", "Rüzgâr"], None),
 449: ("leaffall", "Simülasyon", "gen", ["Yaprak", "Mevsim", "Parçacık"], None), 450: ("droplets", "Simülasyon", "pixel", ["Su", "Damla", "Cam"], None),
 451: ("frostglass", "Simülasyon", "pixel", ["Buz", "Kırağı", "Cam"], None), 452: ("wetsurface", "Renk ve Işık", "pixel", ["Su", "Yansıma", "Islak"], None),
 453: ("perspgrid", "Prosedürel", "gen", ["Izgara", "Retro", "Zemin"], None), 454: ("infmirror", "Tekrar", "repeat", ["Ayna", "Tünel", "Sonsuz"], None),
 455: ("depthparallax", "Bükme ve Bozulma", "pixel", ["Derinlik", "Paralaks", "Kamera"], {"k": "kameraKaym", "mul": 0.5, "add": 10}),
 456: ("ambientocc", "Renk ve Işık", "pixel", ["Gölge", "Derinlik", "Hacim"], {"k": "golgeYari", "mul": 1.0}),
 457: ("volumelight", "Renk ve Işık", "pixel", ["Işık", "Sis", "Huzme"], None), 458: ("inkdraw", "Çizim ve Kenar", "pixel", ["Mürekkep", "Çizim", "Eskiz"], None),
 459: ("embroidery", "Çizim ve Kenar", "pixel", ["Nakış", "İplik", "Kumaş"], {"add": 6}), 460: ("pencilhatch", "Çizim ve Kenar", "pixel", ["Kalem", "Tarama", "Eskiz"], None),
 461: ("photocopy", "Renk ve Işık", "pixel", ["Fotokopi", "Baskı", "Eski"], None), 462: ("datacorrupt", "Bükme ve Bozulma", "pixel", ["Bozulma", "Dijital", "Glitch"], None),
}
READY2 = set(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "ready2.txt")).read().split()) if os.path.exists(os.path.join(os.path.dirname(os.path.abspath(__file__)), "ready2.txt")) else set()
_POS = _re.compile(r"(merkez|konum|ufuk|nokta)", _re.I)
_BASE3D = [copy.deepcopy(p) for p in _BY["cube"]["params"] if p.get("g") in ("3B Dönüşüm", "Kamera", "Işık ve Gölge", "Malzeme")]
def _conv(p):
    q = {k: v for k, v in p.items() if k not in ("code",)}
    if q.get("two") and q.get("unit") in ("%", "") and _POS.search(q["l"]): q["unit"] = "box%"; q["min"], q["max"] = -100, 200
    if q["kind"] in ("toggle", "choice"): q["anim"] = "step"
    if q["kind"] in ("source", "button", "text", "info"): q["anim"] = "no"
    if q["kind"] == "button" and not q.get("reset"): q["hideUi"] = True  # işlevi tanımlı olmayan eylem düğmeleri gösterilmez
    return q
for n, (t, cat, kind, tags, pad) in NEW.items():
    s = _SP2[str(n)]
    if t in _BY:  # aynı tür daha önce tanımlıysa (ör. motorun beklediği kara delik) yeni tanım onun yerine geçer
        E.remove(_BY[t])
    fx(t, s["name"], "", _C[cat], kind, s["desc"] or s["name"], tags, [_conv(p) for p in s["params"]], pad=pad, heavy=kind == "3d")
    e = E[-1]; e["n"] = n; _BY[t] = e
    if kind == "3d":
        have = {p["k"] for p in e["params"]}; e["params"] += [copy.deepcopy(p) for p in _BASE3D if p["k"] not in have]
    if s.get("teach"): e["teach"] = s["teach"]
    e["ready"] = t in READY2
    e["hidden"] = not e["ready"]
    e["presets"] = []
NP = {}
