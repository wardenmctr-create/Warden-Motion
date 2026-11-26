# 1000 rehberi güncelleme dosyası: 801, 802 ve güncellenen efektlerin (361, 203) ayar tabloları → spec5.json
import re, json, os
H = os.path.dirname(os.path.abspath(__file__))
exec(open(os.path.join(H, "spec3.py")).read().split("def parse(")[0])
t = open(os.path.join(H, "guides/1000/Mevcut-Efekt-Guncellemeleri-801-802.md"), encoding="utf-8").read()
out = {}
for chunk in re.split(r"\n(?=## \d+\. )", t):
    mm = re.match(r"## (\d+)\. (.+?)(?: — .*)?\n", chunk)
    if not mm: continue
    n = int(mm.group(1)); used = set(); ps = []
    for row in re.findall(r"^\| (?!Ayar \|)(?!Yeni ayar \|)(?!---)(.+?) \|$", chunk, re.M):
        c = [x.strip() for x in row.split(" | ")]
        if len(c) < 4 or c[1] not in KIND: continue
        lab, code, dv, rg = c[:4]; rest = c[4] if len(c) > 4 else ""
        if code == "S": rg = " / ".join(o.strip() for o in rg.split("/"))
        p = mk(code, lab, f"{dv} [{rg}]" if rg and rg not in ("Özel", "RGBA") else dv, rest, used, None); p["hint"] = rest; ps.append(p)
    out[n] = dict(name=mm.group(2).strip(), params=ps)
json.dump(out, open(os.path.join(H, "spec5.json"), "w"), ensure_ascii=False, indent=0)
for n, s in out.items(): print(n, s["name"], len(s["params"]), [p["k"] for p in s["params"]])
