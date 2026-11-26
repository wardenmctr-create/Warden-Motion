# 1000 rehberi (803–1000): spec4.json'dan ayarlar ve hazır şablonlar. Shader/motoru hazır olanlar ready4.txt'te; olmayanlar kataloğa girmez.
_SP4 = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "spec4.json"), encoding="utf-8"))
_R4 = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ready4.txt")
READY4 = (set(open(_R4).read().split()) if os.path.exists(_R4) else set()) | READY  # GPU efektleri: shader paketi hazır listesi
N10 = {}  # n: (tür, kategori, kind, etiketler, ped)
def N10A(rows):
    for r in rows: N10[r[0]] = r[1:]
HIDE10 = {}
def _c10(p):
    q = {k: v for k, v in p.items() if k not in ("code", "extra")}
    if q.get("two") and q.get("unit") in ("%", "") and (_POS.search(q["l"]) or _re.search(r"^(ışık|ışık kaynağı|kaynak|giriş|çıkış)$", q["l"], _re.I)) and max(q.get("def_", 0), q.get("defY") or 0) >= 10: q["unit"] = "box%"; q["min"], q["max"] = -100, 200
    if q["kind"] in ("button", "curve"): q["hideUi"] = True
    if q["kind"] == "source" and q["k"] in ("uclar", "kopyaGrub", "katmanla", "parcalar", "iskelet", "bolgeler", "kaynakla", "kamerala", "seriler", "hedefler", "destekNokt", "rig", "ifadeSeki", "yuzParc", "grup", "pozlar", "sekiller", "balonlar", "etiketle", "islemKoll", "odakKatm", "haritaSuru"): q["multi"] = True  # işlemi motorda otomatik yapılan düğmeler ve sabit eğri gösterilmez
    return q
TRANS10 = set()
PFIX10 = {}  # tür: ayar listesini düzelten işlev (birleşik kontrolleri ayırma, aralık düzeltme)
def _J10(k, l, d, mn, mx, unit="", g=None, st=None): return dict(k=k, l=l, kind="jog", min=mn, max=mx, def_=d, step=st or (1 if unit in ("Hz", "ms") else 0.1), jog=st or (1 if unit in ("Hz", "ms") else 0.1), unit=unit, anim="yes", g=g)
exec(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "map_1000.py")).read())
_OLD10 = {e["type"] for e in E}  # 1000 rehberi öncesi türler: yeni bir tür eski bir efektin yerini alamaz (eski projeler bozulur)
for n, (t, cat, kind, tags, pad) in sorted(N10.items()):
    assert t not in _OLD10, f"tür adı çakışması: {n} {t}"
    if t not in READY4: continue
    s = _SP4[str(n)]
    if t in _BY: E.remove(_BY[t])
    ps = [_c10(p) for p in s["params"]]
    if t in PFIX10: ps = PFIX10[t](ps)
    fx(t, s["name"], "", _C[cat], kind, s["desc"] or s["name"], tags, ps, pad=pad, heavy=kind == "3d")
    e = E[-1]; e["n"] = n; _BY[t] = e; e["ready"] = True
    keys = {p["k"] for p in e["params"]}
    e["presets"] = [dict(code=p["code"], name=p["name"], vals={k: v for k, v in p["vals"].items() if k in keys}, keys={}, cols={k: v for k, v in p["cols"].items() if k in keys}, at="start")
                    for p in s.get("presets", []) if p["vals"] or p["cols"]]
    if kind == "3d":
        have = {p["k"] for p in e["params"]}; e["params"] += [copy.deepcopy(p) for p in _BASE3D if p["k"] not in have]
    for p in e["params"]:
        if p["k"] in HIDE10.get(t, []): p["hideUi"] = True
    if t in TRANS10: # geçişler: ilerleme yoksa eklenir; Giriş / Çıkış / Animasyonlu şablonları
        if not any(p["k"] == "ilerleme" for p in e["params"]): e["params"].append(dict(k="ilerleme", l="İlerleme", kind="jog", min=0, max=100, def_=0, step=0.1, jog=0.1, unit="%", anim="yes"))
        G3 = lambda c, nm, keys, at="start": dict(code=c, name=nm, vals={}, keys=keys, cols={}, at=at)
        e["presets"] = [G3("GR", "Giriş", {"ilerleme": [[0, 100], [0.7, 0]]}), G3("CK", "Çıkış", {"ilerleme": [[-0.7, 0], [0, 100]]}, "end"), G3("AN", "Animasyonlu", {"ilerleme": [[0, 0], [1, 100], [2, 0]]})] + e["presets"]
# 801 Savrulan Glitch ve 802 Yönlü Yırtılma (güncelleme dosyası, spec5.json); 801'e kullanıcının istediği "Yayılım" eklendi
_SP5 = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "spec5.json"), encoding="utf-8"))
for _n, _t, _cat, _tags, _pad in ((801, "scatterglitch", "Bükme ve Bozulma", ["Glitch", "Rüzgâr", "Blok"], {"k": "azamiUzak"}), (802, "directionaltear", "Maske ve Anahtar", ["Yırtılma", "Kenar", "Alfa"], None)):
    assert _t not in _OLD10, _t
    if _t not in READY4: continue
    _s = _SP5[str(_n)]; _ps = [_c10(p) for p in _s["params"]]
    if _t == "scatterglitch":
        _i = next(i for i, p in enumerate(_ps) if p["k"] == "azamiUzak") + 1
        _ps.insert(_i, dict(k="yayilim", l="Yayılım", kind="jog", min=0, max=100, def_=50, step=0.1, jog=0.1, unit="%", anim="yes",
                            hint="Parçaların Azami uzaklık içinde ne kadar dağılacağı: %0 hepsi aynı mesafeye gider, %100 her parça 0 ile Azami uzaklık arasında farklı bir yere gider."))
    fx(_t, _s["name"], "", _C[_cat], "pixel", _s["name"], _tags, _ps, pad=_pad)
    _e = E[-1]; _e["n"] = _n; _e["ready"] = True
    for _p in _e["params"]:
        if _p["kind"] == "curve": _p["hideUi"] = True
    _P = lambda c, nm, vals: dict(code=c, name=nm, vals=vals, keys={}, cols={}, at="start")
    if _t == "scatterglitch":
        _e["presets"] = [_P("IT", "İnce glitch tozu", {"blokBoyu": 4, "yogunluk": 70, "dogumSikl": 40, "azamiUzak": 120, "yayilim": 80}),
                         _P("BS", "Büyük blok sıçraması", {"blokBoyu": 40, "yogunluk": 30, "savrulmaBici": 0, "isinlanmAdim": 60, "azamiUzak": 400, "yayilim": 30}),
                         _P("RG", "Akıcı RGB rüzgârı", {"savrulmaBici": 1, "rgbDagi": 1, "rgbKanaUzak": 10, "hiz": 300, "yayilim": 60})]
    else:
        _e["presets"] = [_P("ED", "Enerji akımına direnme", {"mod": 0, "sekliKoru": 85, "hareketHizi": 3}), _P("RK", "Rüzgârlı kenar", {"mod": 0, "kalinlik": 5, "uzunluk": 50, "duzenlil": 10}),
                         _P("AY", "Açılı yırtık", {"mod": 1, "ilerleme": 60, "ucSapm": 35}), _P("TP", "Toparlanma", {"mod": 2, "ilerleme": 30})]
