# 803–1000 tür adları ve kategoriler
N10A([
 (803, "holefill", "Maske ve Anahtar", "pixel", ["Alfa", "Delik", "Onarım"], None), (804, "convexhull", "Maske ve Anahtar", "pixel", ["Silüet", "Zarf"], None),
 (805, "geodesiccolor", "Renk ve Işık", "pixel", ["Renk", "Geçiş"], None), (806, "linebridge", "Çizim ve Kenar", "pixel", ["Çizgi", "Onarım"], None),
 (807, "linejunction", "Diğer", "pixel", ["Analiz", "Çizgi"], None), (808, "curvaturemap", "Diğer", "pixel", ["Analiz", "Eğrilik"], None),
 (809, "repeatdetect", "Diğer", "pixel", ["Analiz", "Motif"], None), (810, "illumsplit", "Renk ve Işık", "pixel", ["Işık", "Ayrıştırma"], None),
 (811, "paletteextract", "Renk ve Işık", "pixel", ["Palet", "Analiz"], None), (812, "gradpath", "Renk ve Işık", "pixel", ["Geçiş", "Ölçüm"], None),
 (813, "edgedirextend", "Çizim ve Kenar", "pixel", ["Kenar", "Renk", "Uzatma"], {"k": "uzama"}), (814, "medianbg", "Zaman", "pixel", ["Arka plan", "Medyan"], None),
 (815, "ssimmap", "Diğer", "pixel", ["Analiz", "Benzerlik"], None), (816, "satlumplane", "Diğer", "pixel", ["Ölçer", "Doygunluk"], None),
 (817, "colorslice", "Diğer", "pixel", ["Renk uzayı", "Eğitim"], None), (818, "curvmatte", "Maske ve Anahtar", "pixel", ["Mat", "Eğrilik"], None),
 (819, "areameter", "Diğer", "pixel", ["Ölçer", "Alan"], None), (820, "flowconfidence", "Diğer", "pixel", ["Analiz", "Hareket"], None),
 (821, "lightfieldfix", "Renk ve Işık", "pixel", ["Işık", "Düzeltme"], None), (822, "chanalpha", "Maske ve Anahtar", "pixel", ["Kanal", "Mat"], None),
 (823, "thicknessmap", "Diğer", "pixel", ["Analiz", "Kalınlık"], None), (824, "roughmeter", "Diğer", "pixel", ["Analiz", "Doku"], None),
])
HIDE10.update({"geodesiccolor": ["renkEgri"], "areameter": ["izCizg"], "medianbg": ["sonucuOnbe"]})
N10A([
 (825, "lightcurtain", "Prosedürel", "gen", ["Işık", "Perde", "Enerji"], {"box": 0.1}), (826, "diffraction", "Renk ve Işık", "gen", ["Işık", "Kırınım", "Spektrum"], None),
 (827, "focusstack", "Bulanıklık", "pixel", ["Odak", "Birleştirme"], None), (828, "birefringence", "Bükme ve Bozulma", "pixel", ["Kristal", "Kırılma"], {"k": "ayrilma", "mul": 0.5}),
 (829, "specline", "Renk ve Işık", "pixel", ["Yansıma", "Işık"], None), (830, "glintstretch", "Renk ve Işık", "pixel", ["Parlama", "Yansıma"], {"k": "uzunluk"}),
 (831, "fresnelrim", "Renk ve Işık", "pixel", ["Kenar", "Işık"], None), (832, "subsurface", "Renk ve Işık", "pixel", ["Işık", "Malzeme"], None),
 (833, "goboshadow", "Renk ve Işık", "pixel", ["Gölge", "Işık"], None), (834, "heathaze", "Bükme ve Bozulma", "pixel", ["Isı", "Kırılma"], {"k": "kirilma"}),
 (835, "marinesnow", "Simülasyon", "gen", ["Su altı", "Parçacık"], None), (836, "wavefront", "Prosedürel", "gen", ["Dalga", "Enerji"], None),
 (837, "fluidtrail", "Zaman", "pixel", ["İz", "Akış"], {"k": "akis"}), (838, "massflow", "Simülasyon", "pixel", ["Akış", "Yoğunluk"], None),
 (839, "settleparticles", "Simülasyon", "gen", ["Parçacık", "Birikim"], {"add": 12}), (840, "edgeflow", "Simülasyon", "gen", ["Parçacık", "Kenar"], {"max": ["kenarOfse"]}),
 (841, "plexus", "Prosedürel", "gen", ["Parçacık", "Ağ"], None), (842, "tailribbon", "Taşı ve Dönüştür", "gen", ["İz", "Kuyruk"], {"box": 0.6}),
 (843, "slitlight", "Renk ve Işık", "pixel", ["Işık", "Gölge"], None), (844, "dustinlight", "Simülasyon", "gen", ["Toz", "Işık"], None),
 (845, "depthrim", "Renk ve Işık", "pixel", ["Derinlik", "Parlama"], {"k": "hale"}), (846, "lightocclusion", "Renk ve Işık", "pixel", ["Işık", "Gölge", "Maske"], None),
])
HIDE10.update({"focusstack": ["otomatikHiza"], "tailribbon": ["kuyrukProf"]})
