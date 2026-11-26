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
