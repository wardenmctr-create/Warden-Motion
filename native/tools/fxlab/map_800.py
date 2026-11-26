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
