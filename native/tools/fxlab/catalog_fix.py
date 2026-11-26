# Motoru sonradan yazılan eski efektler: tür düzeltmesi ve hazır işareti
_BYF = {e["type"]: e for e in E}
for _t, _k in {"flash": "pixel", "timediff": "pixel", "timedisplace": "pixel", "diffmatte": "pixel", "matchgrain": "pixel", "audiospec": "gen", "audiowave": "gen"}.items():
    if _t in _BYF: _BYF[_t]["kind"] = _k; _BYF[_t]["ready"] = _t in READY
# Kotlin motorlu olanlar (şekil, hareket, sahne düzeyi CB efektleri)
for _t in ("drawpath", "stroketaper", "morphpath", "cbtrail", "cbborder", "elastic", "cbshadow", "cbcam", "cbbadge", "cbbeat"):
    if _t in _BYF: _BYF[_t]["ready"] = True
# Ses görselleştiriciler projedeki sesi kullanır: kaynak boşsa ilk ses katmanı
for _t in ("audiospec", "audiowave"):
    for _p in _BYF.get(_t, {}).get("params", []):
        if _p["k"] == "sesKayn": _p["hint"] = "Boş bırakılırsa projedeki ilk ses katmanı kullanılır."
# Kotlin motorlu eski efektler (hareket, opaklık, metin, zaman): motorları çalışıyor, hazır bayrağı eksikti
for _e in E:
    if not _e.get("hidden") and not _e.get("mergedInto") and _e["kind"] not in ("pixel", "gen", "3d", "repeat"): _e["ready"] = True
