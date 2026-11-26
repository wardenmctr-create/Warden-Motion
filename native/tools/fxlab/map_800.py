# 551–800 tür adları ve kategoriler
N8A([
 (551, "localcontrast", "Renk ve Işık", "pixel", ["Kontrast", "Ayrıntı"], None), (552, "clahe", "Renk ve Işık", "pixel", ["Histogram", "Ton"], None),
 (553, "satlimit", "Renk ve Işık", "pixel", ["Doygunluk", "Sınır"], None), (554, "chromasharpen", "Çizim ve Kenar", "pixel", ["Keskinlik", "Renk"], None),
 (555, "chromadenoise", "Renk ve Işık", "pixel", ["Gürültü", "Renk"], None), (556, "gamutwarn", "Diğer", "pixel", ["Ölçer", "Renk", "Uyarı"], None),
 (557, "exposurezones", "Diğer", "pixel", ["Ölçer", "Pozlama"], None), (558, "histogram2", "Diğer", "pixel", ["Ölçer", "Histogram"], None),
 (559, "waveform", "Diğer", "pixel", ["Ölçer", "Dalga"], None), (560, "vectorscope", "Diğer", "pixel", ["Ölçer", "Renk"], None),
 (561, "avgcolor", "Renk ve Işık", "pixel", ["Renk", "Ortalama", "Örnek"], None), (562, "channelalign", "Renk ve Işık", "pixel", ["Kanal", "Hizalama"], {"max": ["kirmiziKaymX", "maviKaymX", "kirmiziKaymY", "maviKaymY"]}),
 (563, "localwb", "Renk ve Işık", "pixel", ["Beyaz dengesi", "Maske"], None), (564, "highlightrecover", "Renk ve Işık", "pixel", ["Onarım", "Parlak"], None),
 (565, "darkframe", "Diğer", "pixel", ["Kalibrasyon", "Onarım"], None), (566, "flatfield", "Diğer", "pixel", ["Kalibrasyon", "Onarım"], None),
 (567, "bandclean", "Diğer", "pixel", ["Onarım", "Şerit"], None), (568, "fftnotch", "Diğer", "pixel", ["Onarım", "Desen", "Frekans"], None),
 (569, "anisodiff", "Bulanıklık", "pixel", ["Yumuşatma", "Kenar"], None), (570, "nlmeans", "Bulanıklık", "pixel", ["Gürültü", "Onarım"], None),
 (572, "multiscale", "Çizim ve Kenar", "pixel", ["Ayrıntı", "Frekans"], None), (573, "texsimilar", "Diğer", "pixel", ["Analiz", "Doku"], None),
 (574, "vignettefix", "Renk ve Işık", "pixel", ["Mercek", "Vinyet"], None), (575, "focusmap", "Diğer", "pixel", ["Ölçer", "Odak"], None),
])
HIDE8.update({"avgcolor": ["yumusatm"], "channelalign": ["otomatikHiza"]})
N8A([
 (576, "alphadist", "Maske ve Anahtar", "pixel", ["Alfa", "Mesafe"], None), (577, "alphaskel", "Maske ve Anahtar", "pixel", ["Alfa", "İskelet"], None),
 (578, "maskcombine", "Maske ve Anahtar", "pixel", ["Maske", "Birleştirme"], None), (579, "condblend", "Maske ve Anahtar", "pixel", ["Birleştirme", "Koşul"], None),
 (580, "colorselect", "Maske ve Anahtar", "pixel", ["Renk", "Seçim"], None), (585, "edgedirmatte", "Maske ve Anahtar", "pixel", ["Kenar", "Yön", "Maske"], None),
 (588, "alphaholes", "Maske ve Anahtar", "pixel", ["Alfa", "Delik"], None), (589, "compisolate", "Maske ve Anahtar", "pixel", ["Alfa", "Parça"], None),
 (590, "edgeband", "Maske ve Anahtar", "pixel", ["Kenar", "Kuşak"], {"max": ["disGeni"]}), (591, "edgeextend", "Maske ve Anahtar", "pixel", ["Kenar", "Renk"], {"k": "uzatma"}),
 (592, "matte2img", "Maske ve Anahtar", "pixel", ["Mat", "Alfa"], None), (593, "depthpriority", "Maske ve Anahtar", "pixel", ["Derinlik", "Birleştirme"], None),
 (594, "colorbounce", "Renk ve Işık", "pixel", ["Işık", "Yansıma"], None), (596, "depthview", "Maske ve Anahtar", "pixel", ["Derinlik", "Harita"], None),
 (597, "normalselect", "Maske ve Anahtar", "pixel", ["Normal", "Yön", "Maske"], None), (599, "fresnelmatte", "Maske ve Anahtar", "pixel", ["Yansıma", "Fresnel"], None),
 (600, "diffmap", "Diğer", "pixel", ["Fark", "Analiz"], None),
])
N8A([
 (601, "kernelfilter", "Bulanıklık", "pixel", ["Çekirdek", "Matris", "Filtre"], {"k": "matrisBoyu", "mul": 0.5}), (602, "bandpassimg", "Çizim ve Kenar", "pixel", ["Frekans", "Bant"], None),
 (603, "gabor", "Çizim ve Kenar", "pixel", ["Yön", "Frekans", "Ayrıntı"], None), (604, "spatialdiffuse", "Bulanıklık", "pixel", ["Yayılım", "Işık"], {"k": "yayilim"}),
 (605, "freelens", "Bulanıklık", "pixel", ["Mercek", "Odak", "Eğim"], None), (606, "anamorphic", "Renk ve Işık", "pixel", ["Mercek", "Işık izi"], None),
 (607, "lensbreathe", "Bükme ve Bozulma", "pixel", ["Mercek", "Odak"], None), (608, "lightleak", "Renk ve Işık", "pixel", ["Işık", "Film"], None),
 (609, "starfilter", "Renk ve Işık", "pixel", ["Işık", "Yıldız"], {"k": "sivriUzun"}), (610, "prismfx", "Bükme ve Bozulma", "pixel", ["Prizma", "Kırılma"], None),
 (611, "insecteye", "Bükme ve Bozulma", "pixel", ["Mercek", "Petek"], None), (612, "warpfield", "Bükme ve Bozulma", "pixel", ["Bükme", "Kontrol"], None),
 (613, "flowwarp", "Bükme ve Bozulma", "pixel", ["Akış", "Bükme"], None),
 (616, "feedbackloop", "Zaman", "pixel", ["Zaman", "Geri besleme"], {"box": 0.3}), (617, "frameshuffle", "Zaman", "pixel", ["Zaman", "Kare"], None),
 (618, "temporalmedian", "Zaman", "pixel", ["Zaman", "Gürültü"], None), (619, "brightaccum", "Zaman", "pixel", ["Zaman", "Işık izi"], {"box": 0.5}),
 (620, "darkaccum", "Zaman", "pixel", ["Zaman", "Birikim"], {"box": 0.5}), (621, "timemosaic", "Zaman", "pixel", ["Zaman", "Izgara"], None),
 (622, "timemap", "Zaman", "pixel", ["Zaman", "Harita"], None), (623, "motioncomposite", "Zaman", "pixel", ["Zaman", "Strob"], {"box": 1.0}),
 (624, "temporalfreq", "Zaman", "pixel", ["Zaman", "Analiz"], None), (625, "colortrail", "Zaman", "pixel", ["Zaman", "İz", "Renk"], {"box": 0.6}),
])
HIDE8.update({"warpfield": ["kontrolEkle", "seciliKontSil"], "feedbackloop": ["onbellekSifi"]})
N8A([
 (626, "linocut", "Çizim ve Kenar", "pixel", ["Baskı", "Oyma"], None), (627, "risograph", "Çizim ve Kenar", "pixel", ["Baskı", "Tram"], None),
 (628, "cyanotype", "Renk ve Işık", "pixel", ["Baskı", "Mavi"], None), (629, "chromolitho", "Çizim ve Kenar", "pixel", ["Baskı", "Plaka"], None),
 (630, "drypastel", "Çizim ve Kenar", "pixel", ["Pastel", "Boya"], None), (631, "waxcrayon", "Çizim ve Kenar", "pixel", ["Mum boya", "Çocuk"], None),
 (632, "inkwash", "Çizim ve Kenar", "pixel", ["Mürekkep", "Sulu"], {"k": "yayilma"}), (633, "paintdrip", "Çizim ve Kenar", "pixel", ["Boya", "Akış"], {"box": 0.5}),
 (634, "marbling", "Prosedürel", "pixel", ["Ebru", "Desen"], None), (635, "batik", "Prosedürel", "pixel", ["Batik", "Kumaş"], None),
 (636, "applique", "Çizim ve Kenar", "pixel", ["Kumaş", "Dikiş"], None), (637, "stainedglass", "Çizim ve Kenar", "pixel", ["Vitray", "Cam"], None),
 (638, "ceramicglaze", "Çizim ve Kenar", "pixel", ["Seramik", "Sır"], None), (639, "mosaicgrout", "Çizim ve Kenar", "pixel", ["Mozaik", "Taş"], None),
 (640, "sequins", "Çizim ve Kenar", "pixel", ["Pul", "Parıltı"], None), (641, "beadwork", "Çizim ve Kenar", "pixel", ["Boncuk"], None),
 (642, "knitting", "Çizim ve Kenar", "pixel", ["Örgü", "İplik"], None), (643, "papiermache", "Çizim ve Kenar", "pixel", ["Kâğıt", "Kabartma"], None),
 (644, "waxseal", "Çizim ve Kenar", "pixel", ["Mühür", "Mum"], {"k": "kenarTasm", "add": 6}), (645, "sandcarve", "Çizim ve Kenar", "pixel", ["Kum", "Kazıma"], None),
 (646, "lenticular", "Geçiş", "pixel", ["Lentiküler", "Bakış"], None), (647, "moireprint", "Çizim ve Kenar", "pixel", ["Hare", "Tram"], None),
 (648, "linedensity", "Çizim ve Kenar", "pixel", ["Çizgi", "Ton"], None), (649, "chipcollage", "Çizim ve Kenar", "pixel", ["Kolaj", "Parça"], None),
 (650, "shadowtheater", "Renk ve Işık", "pixel", ["Gölge", "Perde"], None),
])
N8A([
 (651, "spirograph", "Prosedürel", "gen", ["Eğri", "Spirograf"], None), (652, "lissajous", "Prosedürel", "gen", ["Eğri", "Lissajous"], None),
 (653, "cycloid", "Prosedürel", "gen", ["Eğri", "Sikloid"], None), (654, "complexmap", "Prosedürel", "pixel", ["Matematik", "Karmaşık"], None),
 (655, "apollonian", "Prosedürel", "pixel", ["Fraktal", "Çember"], None), (656, "penrose", "Prosedürel", "pixel", ["Döşeme", "Penrose"], None),
 (657, "wangtiles", "Prosedürel", "pixel", ["Karo", "Desen"], None), (658, "powervoronoi", "Prosedürel", "pixel", ["Hücre", "Ağırlık"], None),
 (659, "delaunay", "Prosedürel", "gen", ["Ağ", "Üçgen"], None), (660, "poissondots", "Prosedürel", "gen", ["Nokta", "Dağılım"], None),
 (661, "crescents", "Prosedürel", "pixel", ["Hilal", "Döşeme"], None), (662, "illusiongrid", "Prosedürel", "pixel", ["Yanılsama", "Izgara"], None),
 (663, "ribbonflow", "Prosedürel", "pixel", ["Şerit", "Akış"], None), (664, "turingmaze", "Prosedürel", "pixel", ["Turing", "Labirent"], None),
 (665, "cellauto", "Prosedürel", "pixel", ["Hücresel", "Otomat"], None), (666, "selfavoid", "Prosedürel", "gen", ["Yol", "Rastgele"], None),
 (667, "dla", "Prosedürel", "gen", ["Büyüme", "Dallanma"], None), (668, "rootnet", "Prosedürel", "gen", ["Kök", "Dal"], None),
 (669, "mossgrow", "Prosedürel", "pixel", ["Yosun", "Büyüme"], None), (670, "duneripples", "Prosedürel", "pixel", ["Kum", "Dalga"], None),
 (671, "mudcrack", "Prosedürel", "pixel", ["Çamur", "Çatlak"], None), (672, "strata", "Prosedürel", "pixel", ["Taş", "Katman"], None),
 (673, "treerings", "Prosedürel", "pixel", ["Ağaç", "Halka"], None), (674, "foamcells", "Prosedürel", "gen", ["Köpük", "Hücre"], None),
 (675, "flowerrosette", "Prosedürel", "gen", ["Çiçek", "Rozet"], {"box": 0.3}),
])
N8A([
 (676, "lookat", "Taşı ve Dönüştür", "xform", ["Hedef", "Dönüş"], None), (677, "seek", "Taşı ve Dönüştür", "xform", ["Hedef", "Takip"], None),
 (678, "flee", "Taşı ve Dönüştür", "xform", ["Hedef", "Kaçma"], None), (679, "keepbounds", "Taşı ve Dönüştür", "xform", ["Sınır", "Alan"], None),
 (680, "velorient", "Taşı ve Dönüştür", "xform", ["Yön", "Hız"], None), (681, "velscale", "Taşı ve Dönüştür", "xform", ["Ölçek", "Hız"], None),
 (682, "draginertia", "Taşı ve Dönüştür", "xform", ["Atalet", "Fizik"], None), (683, "motiondamp", "Taşı ve Dönüştür", "xform", ["Sönüm", "Yumuşatma"], None),
 (684, "quantmotion", "Taşı ve Dönüştür", "xform", ["Basamak", "Hareket"], None), (685, "fitpath", "Taşı ve Dönüştür", "xform", ["Yol", "Alan"], None),
 (687, "paramseq", "Taşı ve Dönüştür", "rig", ["Sıra", "Gecikme", "Grup"], None), (689, "loopblend", "Taşı ve Dönüştür", "xform", ["Döngü", "Birleştirme"], None),
 (691, "eyelid", "Countryball", "pixel", ["Göz", "Kapak"], None), (692, "poseblend", "Countryball", "pixel", ["Göz", "İfade"], None),
 (693, "partorder", "Countryball", "special", ["Sıra", "Aksesuar"], None), (694, "slideon", "Taşı ve Dönüştür", "xform", ["Yüzey", "Kayma"], None),
 (695, "attach", "Taşı ve Dönüştür", "xform", ["Yapışma", "Bağlantı"], None), (696, "elasticline", "Diğer", "gen", ["Çizgi", "Elastik"], {"box": 1.0}),
 (697, "jigglejoint", "Taşı ve Dönüştür", "xform", ["Eklem", "Sallanma"], None), (698, "dragchain", "Taşı ve Dönüştür", "rig", ["Sürükleme", "Grup"], None),
 (699, "lattice", "Bükme ve Bozulma", "pixel", ["Kafes", "Deformasyon"], None), (700, "snapcurve", "Taşı ve Dönüştür", "xform", ["Eğri", "Yapışma"], None),
])
HIDE8.update({"lattice": ["kafesiSifi"]})
N8A([
 (701, "wordhighlight", "Metin", "text", ["Metin", "Vurgu"], None), (702, "verticaltext", "Metin", "text", ["Metin", "Dikey"], None),
 (706, "linereveal", "Metin", "text", ["Metin", "Satır", "Giriş"], None), (707, "rollcounter", "Metin", "text", ["Metin", "Sayaç"], None),
 (708, "stackarea", "Diğer", "gen", ["Grafik", "Alan"], None), (710, "treemap", "Diğer", "gen", ["Grafik", "Ağaç haritası"], None),
 (711, "scatterplot", "Diğer", "gen", ["Grafik", "Dağılım"], None), (712, "radarchart", "Diğer", "gen", ["Grafik", "Radar"], None),
 (713, "heatmapchart", "Diğer", "gen", ["Grafik", "Isı"], None), (714, "barrace", "Diğer", "gen", ["Grafik", "Sıralama", "Yarış"], None),
 (715, "netdiagram", "Diğer", "gen", ["Grafik", "Ağ"], None), (716, "geoheat", "Countryball", "gen", ["Harita", "Isı"], None),
 (718, "contourmap", "Countryball", "pixel", ["Harita", "Eş yükselti"], None), (719, "slopemap", "Countryball", "pixel", ["Harita", "Eğim"], None),
 (720, "hillshade", "Countryball", "pixel", ["Harita", "Kabartma"], None), (721, "graticule", "Countryball", "pixel", ["Harita", "Izgara"], None),
 (722, "scalebar", "Countryball", "gen", ["Harita", "Ölçek"], None), (723, "compass", "Countryball", "gen", ["Harita", "Pusula"], None),
 (725, "minimap", "Countryball", "gen", ["Harita", "Küçük harita"], None),
])
N8A([
 (729, "thicken3d", "3B", "3d", ["3B", "Kalınlık"], {"box": 0.45}), (733, "spikes3d", "3B", "3d", ["3B", "İğne"], {"box": 0.6}),
 (734, "explodefaces", "3B", "3d", ["3B", "Parça"], {"box": 0.8}), (735, "facethick", "3B", "3d", ["3B", "Yüz"], {"box": 0.45}),
 (738, "mirror3d", "3B", "3d", ["3B", "Ayna"], {"box": 0.8}), (740, "spherify", "3B", "3d", ["3B", "Küre"], {"box": 0.45}),
 (741, "twist3d", "3B", "3d", ["3B", "Burgu"], {"box": 0.45}), (742, "taper3d", "3B", "3d", ["3B", "Büzülme"], {"box": 0.45}),
 (744, "buildorder", "3B", "3d", ["3B", "Yapım", "Giriş"], {"box": 0.6}), (745, "voxelize", "3B", "3d", ["3B", "Voksel"], {"box": 0.45}),
 (748, "ocean3d", "3B", "3d", ["3B", "Okyanus", "Su"], {"box": 0.6}), (750, "depthclip3d", "3B", "3d", ["3B", "Kamera", "Kesme"], {"box": 0.45}),
])
HIDE8.update({"thicken3d": ["normalleYeniHesa"], "voxelize": ["azamiVoxeButc"], "facethick": ["yuzSeci"], "mirror3d": ["dikisiBirl"]})
def _rep(ps, k, new):
    i = next(i for i, p in enumerate(ps) if p["k"] == k); return ps[:i] + new + ps[i + 1:]
def _rng(ps, k, mn=None, mx=None, d=None):
    for p in ps:
        if p["k"] == k:
            if mn is not None: p["min"] = mn
            if mx is not None: p["max"] = mx
            if d is not None: p["def_"] = d
    return ps
PFIX.update({
 "notchfilter": lambda ps: _rng(ps, "merkez", 20, 20000, 50),
 "dynamiceq": lambda ps: _rng(ps, "merkez", 20, 20000, 3000),
 "multibandcomp": lambda ps: _rep(_rep(_rep(ps, "ayirma", [_J8("ayirma1", "Alt ayırma frekansı", 200, 20, 20000, "Hz"), _J8("ayirma2", "Üst ayırma frekansı", 2500, 20, 20000, "Hz")]),
     "esikOran", [_J8("esik", "Eşik", -18, -60, 0, "dB"), _J8("oran", "Oran", 3, 1, 20, "", st=0.1)]), "bantSaldBira", [_J8("saldiri", "Saldırı", 10, 1, 500, "ms"), _J8("birakma", "Bırakma", 100, 10, 2000, "ms")]),
 "expander": lambda ps: _rep(ps, "saldiriBira", [_J8("saldiri", "Saldırı", 10, 1, 500, "ms"), _J8("birakma", "Bırakma", 120, 10, 2000, "ms")]),
 "speechrate": lambda ps: _rep(ps, "hedefSure", [_J8("hizOran", "Hız oranı", 1.0, 0.25, 4.0, "×", st=0.01)]),
})
N8A([
 (751, "loudnorm", "Ses", "audio-fx", ["Ses", "Gürlük"], None), (752, "peaknorm", "Ses", "audio-fx", ["Ses", "Tepe"], None), (753, "dcremove", "Ses", "audio-fx", ["Ses", "Onarım"], None),
 (754, "declick", "Ses", "audio-fx", ["Ses", "Onarım", "Çıtırtı"], None), (755, "declip", "Ses", "audio-fx", ["Ses", "Onarım", "Kırpılma"], None), (756, "dropoutfix", "Ses", "audio-fx", ["Ses", "Onarım"], None),
 (757, "notchfilter", "Ses", "audio-fx", ["Ses", "Filtre"], None), (758, "dynamiceq", "Ses", "audio-fx", ["Ses", "Ekolayzer"], None), (759, "multibandcomp", "Ses", "audio-fx", ["Ses", "Dinamik"], None),
 (760, "expander", "Ses", "audio-fx", ["Ses", "Dinamik"], None), (761, "transient", "Ses", "audio-fx", ["Ses", "Dinamik", "Vuruş"], None), (762, "phaseinvert", "Ses", "audio-fx", ["Ses", "Faz"], None),
 (763, "chandelay", "Ses", "audio-fx", ["Ses", "Stereo"], None), (764, "phaser", "Ses", "audio-fx", ["Ses", "Modülasyon"], None), (765, "rotary", "Ses", "audio-fx", ["Ses", "Modülasyon"], None),
 (766, "convreverb", "Ses", "audio-fx", ["Ses", "Mekân", "Yankı"], None), (767, "specfreeze", "Ses", "audio-fx", ["Ses", "Spektral"], None), (768, "granular", "Ses", "audio-fx", ["Ses", "Tanecik"], None),
 (769, "speechrate", "Ses", "audio-fx", ["Ses", "Hız"], None), (770, "autocrossfade", "Ses", "audio-fx", ["Ses", "Geçiş"], None), (771, "autopan", "Ses", "audio-fx", ["Ses", "Konum"], None),
 (772, "distancefx", "Ses", "audio-fx", ["Ses", "Mesafe"], None),
 (773, "spectrogram", "Ses", "gen", ["Ses", "Görselleştirici"], None), (774, "phasescope", "Ses", "gen", ["Ses", "Görselleştirici", "Stereo"], None), (775, "loudmeter", "Ses", "gen", ["Ses", "Ölçer"], None),
])
HIDE8.update({"loudnorm": ["analizEt"], "peaknorm": ["analiz"], "dcremove": ["olc"], "declip": ["onizle"]})
N8A([
 (776, "swishpan", "Geçiş", "pixel", ["Geçiş", "Kaydırma"], {"box": 0.2}), (777, "filmroll", "Geçiş", "pixel", ["Geçiş", "Film"], {"box": 0.2}),
 (778, "focuspull", "Geçiş", "pixel", ["Geçiş", "Odak"], {"k": "azamiBoke"}), (779, "parallaxstrips", "Geçiş", "pixel", ["Geçiş", "Şerit"], None),
 (780, "cubeface", "Geçiş", "pixel", ["Geçiş", "Küp", "3B"], None), (781, "pageturn2", "Geçiş", "pixel", ["Geçiş", "Sayfa"], None),
 (782, "doorwings", "Geçiş", "pixel", ["Geçiş", "Kapı"], None), (783, "irisblades", "Geçiş", "pixel", ["Geçiş", "Diyafram"], None),
 (784, "foldpanels", "Geçiş", "pixel", ["Geçiş", "Katlama"], None), (785, "curtain", "Geçiş", "pixel", ["Geçiş", "Perde"], None),
 (786, "ringcross", "Geçiş", "pixel", ["Geçiş", "Halka"], None), (787, "colormatchtrans", "Geçiş", "pixel", ["Geçiş", "Renk"], None),
 (788, "shapematchtrans", "Geçiş", "pixel", ["Geçiş", "Şekil"], None), (789, "peel", "Geçiş", "pixel", ["Geçiş", "Soyma"], None),
 (790, "liquidmerge", "Geçiş", "pixel", ["Geçiş", "Sıvı"], None), (791, "paperhole", "Geçiş", "pixel", ["Geçiş", "Kâğıt"], None),
 (792, "plateseparate", "Geçiş", "pixel", ["Geçiş", "Renk plakası"], {"k": "kayma"}), (793, "timeslice", "Geçiş", "pixel", ["Geçiş", "Zaman"], None),
 (794, "multicam", "Diğer", "pixel", ["Kamera", "Pencere"], None), (795, "smartframe", "Diğer", "pixel", ["Kadraj", "Takip"], None),
 (796, "twotargetzoom", "Diğer", "pixel", ["Yakınlaşma", "Takip"], None), (797, "dollyzoom", "Bükme ve Bozulma", "pixel", ["Kamera", "Perspektif"], None),
 (798, "comparesplit", "Diğer", "pixel", ["Karşılaştırma", "Bölme"], None), (799, "magnifier", "Diğer", "pixel", ["Büyüteç", "Pencere"], None),
 (800, "popout", "Maske ve Anahtar", "pixel", ["Çerçeve", "Taşma"], {"box": 0.2}),
])
HIDE8.update({"shapematchtrans": ["noktaCiftEkle"], "multicam": ["senkronOfse"], "smartframe": ["yumusatm"]})
TRANS8.update({"swishpan", "filmroll", "focuspull", "parallaxstrips", "cubeface", "doorwings", "foldpanels", "curtain", "ringcross", "plateseparate", "pageturn2", "irisblades", "colormatchtrans", "shapematchtrans", "liquidmerge", "timeslice"})
N8A([
 (571, "temporaldenoise", "Zaman", "pixel", ["Zaman", "Gürültü"], None), (583, "movingmatte", "Maske ve Anahtar", "pixel", ["Hareket", "Mat", "Zaman"], None),
 (584, "motiondirmatte", "Maske ve Anahtar", "pixel", ["Hareket", "Yön", "Mat"], None), (686, "paramlink", "Taşı ve Dönüştür", "xform", ["Bağlantı", "Parametre"], None),
 (688, "softlimit", "Taşı ve Dönüştür", "xform", ["Sınır", "Parametre"], None), (705, "livetext", "Metin", "text", ["Metin", "Değişken"], None),
 (709, "sankey", "Diğer", "gen", ["Grafik", "Akış"], None), (739, "bumpcard", "3B", "3d", ["3B", "Kabartı"], {"box": 0.45}),
])
PROPS = ["Konum X", "Konum Y", "Dönüş", "Ölçek (%)", "Opaklık (%)"]
def _ch8(k, l, opts, d=0): return dict(k=k, l=l, kind="choice", min=0, max=len(opts) - 1, def_=d, step=1, jog=1, opts=list(opts), anim="step")
PFIX.update({
 "paramlink": lambda ps: [_ch8("kaynakOzellik", "Kaynak özellik", PROPS)] + _rep(ps, "hedefPara", [_ch8("hedefPara", "Hedef özellik", PROPS)]),
 "softlimit": lambda ps: _rep(_rep(ps, "altUstSini", [_J8("altSinir", "Alt sınır", 0, -10000, 10000), _J8("ustSinir", "Üst sınır", 1000, -10000, 10000)]), "hedefPara", [_ch8("hedefPara", "Hedef özellik", PROPS)]),
 "livetext": lambda ps: ps[:1] + [_ch8("ozellik", "Okunan özellik", PROPS)] + ps[1:],
})
