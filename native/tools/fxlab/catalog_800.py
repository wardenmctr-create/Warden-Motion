# 800 rehberi (551–800): spec3.json'dan ayarlar ve hazır şablonlar. Shader/motoru hazır olanlar ready3.txt'te; olmayanlar kataloğa girmez.
_SP3 = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "spec3.json"), encoding="utf-8"))
_R3 = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ready3.txt")
READY3 = set(open(_R3).read().split()) if os.path.exists(_R3) else set()
N8 = {}  # n: (tür, kategori, kind, etiketler, ped)
def N8A(rows):
    for r in rows: N8[r[0]] = r[1:]
HIDE8 = {}
def _c8(p):
    q = {k: v for k, v in p.items() if k not in ("code", "extra")}
    if q.get("two") and q.get("unit") in ("%", "") and _POS.search(q["l"]): q["unit"] = "box%"; q["min"], q["max"] = -100, 200
    if q["kind"] in ("button", "curve"): q["hideUi"] = True
    if q["kind"] == "source" and q["k"] in ("uclar", "kopyaGrub", "katmanla", "parcalar", "iskelet", "kaynakla", "kamerala", "bolgeler", "seriler"): q["multi"] = True  # işlemi motorda otomatik yapılan düğmeler ve sabit eğri gösterilmez
    return q
TRANS8 = set()
PFIX = {}  # tür: ayar listesini düzelten işlev (birleşik kontrolleri ayırma, aralık düzeltme)
def _J8(k, l, d, mn, mx, unit="", g=None, st=None): return dict(k=k, l=l, kind="jog", min=mn, max=mx, def_=d, step=st or (1 if unit in ("Hz", "ms") else 0.1), jog=st or (1 if unit in ("Hz", "ms") else 0.1), unit=unit, anim="yes", g=g)
exec(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "map_800.py")).read())
for n, (t, cat, kind, tags, pad) in sorted(N8.items()):
    if t not in READY3: continue
    s = _SP3[str(n)]
    if t in _BY: E.remove(_BY[t])
    ps = [_c8(p) for p in s["params"]]
    if t in PFIX: ps = PFIX[t](ps)
    fx(t, s["name"], "", _C[cat], kind, s["desc"] or s["name"], tags, ps, pad=pad, heavy=kind == "3d")
    e = E[-1]; e["n"] = n; _BY[t] = e; e["ready"] = True
    keys = {p["k"] for p in e["params"]}
    e["presets"] = [dict(code=p["code"], name=p["name"], vals={k: v for k, v in p["vals"].items() if k in keys}, keys={}, cols={k: v for k, v in p["cols"].items() if k in keys}, at="start")
                    for p in s["presets"] if p["vals"] or p["cols"]]
    if kind == "3d":
        have = {p["k"] for p in e["params"]}; e["params"] += [copy.deepcopy(p) for p in _BASE3D if p["k"] not in have]
    for p in e["params"]:
        if p["k"] in HIDE8.get(t, []): p["hideUi"] = True
    if t in TRANS8: # geçişler: ilerleme yoksa eklenir; Giriş / Çıkış / Animasyonlu şablonları
        if not any(p["k"] == "ilerleme" for p in e["params"]): e["params"].append(dict(k="ilerleme", l="İlerleme", kind="jog", min=0, max=100, def_=0, step=0.1, jog=0.1, unit="%", anim="yes"))
        G3 = lambda c, nm, keys, at="start": dict(code=c, name=nm, vals={}, keys=keys, cols={}, at=at)
        e["presets"] = [G3("GR", "Giriş", {"ilerleme": [[0, 100], [0.7, 0]]}), G3("CK", "Çıkış", {"ilerleme": [[-0.7, 0], [0, 100]]}, "end"), G3("AN", "Animasyonlu", {"ilerleme": [[0, 0], [1, 100], [2, 0]]})] + e["presets"]
# Okyanus yüzeyi yukarıdan eğik bakışla başlar
for _p in _BY.get("ocean3d", {}).get("params", []):
    if _p["k"] == "yonelimXY": _p["def_"] = -40
