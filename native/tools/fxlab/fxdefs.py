# Rehbere göre yazılmış efektlerin geçişleri (passes) ve kenar boşlukları (pad).
# pad: {"k": ayar, "mul": çarpan, "add": sabit} (katman birimi) ya da {"box": k} = katmanın büyük kenarının k katı
BL = lambda k, mul=1.0: {"blur": "src", "r": {"k": k, "mul": mul}, "out": "B"}
FXDEF = {
    # Bükme ve Bozulma
    "fractal": dict(pad={"k": "bukmeMikt", "mul": 1, "add": 2}),
    "wave": dict(pad={"k": "dalgaYuks", "mul": 1, "add": 2}),
    "ripple": dict(pad={"k": "genlik", "mul": 1, "add": 2}),
    "ripplepulse": dict(pad={"k": "genlik", "mul": 1, "add": 2}),
    "tiles": dict(pad={"box": 1.0}), "hextile": dict(pad={"box": 1.0}), "tiler": dict(pad={"box": 1.0}),
    "displace": dict(pad={"k": "miktar", "mul": 1, "add": 2}),
    "shear": dict(pad={"box": 0.6}), "slant": dict(pad={"box": 0.45}), "warpstyle": dict(pad={"box": 0.35}),
    "bendit": dict(pad={"box": 0.9}), "bender": dict(pad={"box": 0.9}), "cornerpin": dict(pad={"box": 1.0}),
    "glitch": dict(pad={"k": "kayma", "mul": 1.2, "add": 2}), "rgbsplit": dict(pad={"k": "ayrim", "mul": 1.5, "add": 2}),
    "split": dict(pad={"k": "ayrilma", "mul": 0.6, "add": 6}), "squeeze": dict(pad={"k": "esneme", "mul": 1, "add": 2}),
    "liquify": dict(pad={"k": "fircaBoyu", "mul": 0.6}), "griddler": dict(pad={"k": "parcaKaym", "mul": 1, "add": 2}),
    "blobby": dict(pad={"k": "damlalas", "mul": 1.2, "add": 2}, passes=[BL("damlalas", 0.5), {"fs": "blobby_c", "aux": {"u_aux": "B"}}]),
    "pageturn": dict(pad={"k": "yaricap", "mul": 1.0}), "curl": dict(pad={"k": "kivrimYari", "mul": 1.0}),
}

# ---- Renk ve Işık ----
FXDEF.update({
    "highshadow": dict(passes=[BL("yaricap", 0.5), {"fs": "highshadow_c", "aux": {"u_aux": "B"}}]),
    "longshadow": dict(pad={"k": "uzunluk", "mul": 1, "add": 2}),
    "radialshadow": dict(pad={"k": "golgeMesa", "mul": 1, "add": 30}, passes=[{"fs": "radialshadow_a", "out": "A"}, {"blur": "A", "r": {"k": "yumusakl", "mul": 0.5}, "out": "B"}, {"fs": "radialshadow_c", "aux": {"u_aux": "B"}}]),
    "lightrays": dict(pad={"k": "uzunluk", "mul": 0.5}),
    "darkglow": dict(pad={"k": "yayilma", "mul": 1}, passes=[{"fs": "darkglow_a", "out": "A"}, {"blur": "A", "r": {"k": "yayilma", "mul": 0.5}, "out": "B"}, {"fs": "darkglow_c", "aux": {"u_aux": "B"}}]),
    "lightglow": dict(pad={"k": "yayilma", "mul": 1}, passes=[{"fs": "lightglow_a", "out": "A"}, {"blur": "A", "r": {"k": "yayilma", "mul": 0.5}, "out": "B"}, {"fs": "lightglow_c", "aux": {"u_aux": "B"}}]),
    "softglow": dict(pad={"k": "yumusakl", "mul": 0.8}, passes=[BL("yumusakl", 0.5), {"fs": "softglow_c", "aux": {"u_aux": "B"}}]),
})

# ---- Çizim ve Kenar ----
def GL3(a, k, mul=0.5): return [{"fs": a + "_a", "out": "A"}, {"blur": "A", "r": {"k": k, "mul": mul}, "out": "B"}, {"fs": a + "_c", "aux": {"u_aux": "B"}}]
FXDEF.update({
    "glow": dict(pad={"k": "yaricap", "mul": 1.3, "add": 2}, passes=GL3("glow", "yaricap")),
    "shadow": dict(pad={"sum": ["mesafe", "bulanikl", "yayilma"], "mul": 1.2, "add": 4}, passes=GL3("shadow", "bulanikl")),
    "stroke": dict(pad={"k": "kalinlik", "mul": 1, "add": 2}),
    "neonedge": dict(pad={"k": "hale", "mul": 1, "add": 2}), "neonsign": dict(pad={"sum": ["tupKali", "hale"], "mul": 1, "add": 2}),
    "vegas": dict(pad={"sum": ["noktaBoyu", "hale"], "mul": 1, "add": 2}), "electricedges": dict(pad={"sum": ["dalgalan", "hale", "cizgiKali"], "mul": 1, "add": 2}),
    "glowscan": dict(pad={"k": "yaricap", "mul": 1, "add": 2}, passes=GL3("glowscan", "yaricap")),
    "repetile": dict(pad={"max": ["solUzat", "sagUzat", "ustUzat", "altUzat"]}),
    "contourlines": dict(pad={"k": "aralik", "mul": 6, "add": 4}), "contourgrad": dict(pad={"k": "kenarMesa", "mul": 1, "add": 2}),
    "roughen": dict(pad={"k": "kenarMikt", "mul": 1, "add": 2}), "frame": dict(pad={"sum": ["cerceveKali", "icBosl"], "mul": 1, "add": 2}),
    "scatterpx": dict(pad={"k": "sacilmaMesa", "mul": 1}), "brushstrokes": dict(pad={"k": "fircaBoyu", "mul": 1}),
    "glass": dict(pad={"k": "kirilma", "mul": 1}), "watercolor": dict(pad={"sum": ["renkYayi", "lekeBoyu"], "mul": 0.8}),
    "anaglyph": dict(pad={"k": "ayrisma", "mul": 0.6}),
})

# ---- Bulanıklık ----
HV = lambda a: [{"fs": a + "_h", "out": "A"}, {"fs": a + "_v", "in": "A"}]
FXDEF.update({
    "blur": dict(pad={"k": "yaricap", "mul": 1.5, "add": 2}, passes=HV("blur")),
    "boxblur": dict(pad={"k": "yaricap", "mul": 1, "add": 2}), "dirblur": dict(pad={"k": "uzunluk", "mul": 0.5, "add": 2}),
    "chanblur": dict(pad={"max": ["kirmiziYari", "yesilYari", "maviYari", "alfaYari"]}, passes=HV("chanblur")),
    "crossblur": dict(pad={"max": ["yatayYari", "dikeyYari"]}, passes=HV("crossblur")),
    "tiltshift": dict(passes=[BL("bulanikl", 0.5), {"fs": "tiltshift_c", "aux": {"u_aux": "B"}}]),
    "lensblur": dict(pad={"k": "yaricap", "mul": 0.6}, heavy=True), "streaks": dict(pad={"k": "uzunluk", "mul": 1}),
    "zoomblur": dict(pad={"box": 0.15}), "chromzoom": dict(pad={"box": 0.15}), "spinblur": dict(pad={"box": 0.2}), "chromvortex": dict(pad={"box": 0.2}),
    "linstreaks": dict(pad={"k": "izUzun", "mul": 1}), "zoomstreaks": dict(pad={"k": "izUzun", "mul": 1}), "spinstreaks": dict(pad={"box": 0.2}),
    "maskblur": dict(pad={"k": "yaricap", "mul": 0.8}), "compoundblur": dict(pad={"k": "maksimumYari", "mul": 0.8}),
    "streakstrips": dict(pad={"k": "azamiIz", "mul": 1}), "warpblur": dict(pad={"sum": ["bukmeMikt", "bulaniklUzun"], "mul": 0.8}),
    "depthblur": dict(heavy=True), "bilateral": dict(heavy=True),
})

# ---- Prosedürel ----
FXDEF.update({
    "fractalset": dict(heavy=True), "volclouds": dict(heavy=True), "fireworks": dict(heavy=True),
    "lightning": dict(pad={"k": "hale", "mul": 1}), "lensflare": dict(pad={"box": 0.1}),
})

# ---- 3B ----
for _t in ["cube", "sphere", "cylinder", "cone", "pyramid", "octahedron", "hexprism", "torus", "heart3d", "starprism", "capsule", "extrude", "tetra", "icosa",
           "box3d", "ellipsoid", "hollowbox", "ring3d", "starpoly", "cross3", "triprism", "flip3d", "fold3d"]:
    FXDEF[_t] = dict(pad={"box": 0.45}, heavy=True)
FXDEF["tunnel"] = dict(heavy=True)

# ---- Maske / Opaklık / Diğer ----
FXDEF.update({
    "choke": dict(pad={"k": "kenarDegi", "mul": 2, "add": 2}), "feather": dict(pad={"k": "yaricap", "mul": 0.5, "add": 1}),
    "vhs": dict(pad={"k": "yatayBozu", "mul": 3}), "oldfilm": dict(pad={"k": "kareTitr", "mul": 1}), "chromaber": dict(pad={"k": "siddet", "mul": 2}),
    "pixelsort": dict(pad={"k": "maksimumIz", "mul": 1}), "denoise": dict(heavy=True), "keylight": dict(heavy=True),
})

# ---- Simülasyon / Geçiş ----
FXDEF.update({
    "shatter": dict(pad={"box": 0.6}, heavy=True), "pixelpolly": dict(pad={"box": 0.5}, heavy=True), "scatterize": dict(pad={"k": "savrulma", "mul": 1}),
    "glasswipe": dict(pad={"k": "dagilma", "mul": 1.5}), "hair": dict(pad={"k": "uzunluk", "mul": 1}), "fire": dict(pad={"box": 0.3}),
    "waveworld": dict(pad={"k": "dalgaYuks", "mul": 1}), "drizzle": dict(pad={"k": "dalgaYuks", "mul": 1}), "mercury": dict(pad={"box": 0.4}),
    "particles": dict(pad={"box": 0.6}), "particleworld": dict(pad={"box": 0.6}), "carddance": dict(pad={"box": 0.15}), "ballaction": dict(pad={"k": "dagilma", "mul": 1}),
    "brokenglass": dict(pad={"k": "kirilma", "mul": 1}), "radscalewipe": dict(), "twister": dict(pad={"box": 0.1}),
})

# ---- Tekrar / parça / Countryball ----
FXDEF.update({
    "gridrepeat": dict(pad={"box": 1.5}), "linrepeat": dict(pad={"box": 1.5}), "radrepeat": dict(pad={"box": 1.2}), "scatter": dict(pad={"max": ["alanX", "alanY"]}),
    "spiral": dict(pad={"k": "disYari", "mul": 1}), "mirrorrepeat": dict(pad={"box": 1.0}), "repeatpath": dict(pad={"max": ["boyutX", "boyutY"]}), "scatterfield": dict(pad={"box": 1.0}),
    "shakeparts": dict(pad={"k": "konumSidd", "mul": 1}), "flagwave": dict(pad={"k": "dalgaYuks", "mul": 1.3, "add": 2}),
    "cboutline": dict(pad={"k": "tepeKali", "mul": 1}), "cbsticker": dict(pad={"sum": ["icKont", "disKont", "golgeUzak"], "mul": 1, "add": 2}),
    "cbmaphl": dict(pad={"k": "parlama", "mul": 1}), "cbspeed": dict(pad={"k": "uzunluk", "mul": 1.5}), "cbdust": dict(pad={"k": "yayilma", "mul": 1}),
    "cbsurprise": dict(pad={"box": 0.3}), "cbsweat": dict(pad={"box": 0.2}),
})
