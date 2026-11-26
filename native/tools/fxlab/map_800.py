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
