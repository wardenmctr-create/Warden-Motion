# After Effects'ten esinlenen ek efektler + kendi eklemelerimiz (catalog.py içinden çalıştırılır)
# Yeni kategoriler: 12 Simülasyon, 13 Geçiş, 14 Zaman
CATS += ["Simülasyon", "Geçiş", "Zaman"]
SIM, TRN, TIM = 12, 13, 14
# Var olanları yeni kategorilere taşı (After Effects düzeni)
MOVE = {"snow": SIM, "rain": SIM, "bubbles": SIM, "confetti": SIM, "fire": SIM,
        "linwipe": TRN, "radwipe": TRN, "iris": TRN, "blinds": TRN, "blockdissolve": TRN, "dissolve": TRN,
        "posterizetime": TIM, "echo": TIM}
for e in E:
    if e["type"] in MOVE: e["cat"] = MOVE[e["type"]]

# ---------- Renk ve Işık ----------
c = 0
fx("curves", "Eğriler", "Curves", c, "pixel", "Tonları yumuşak bir eğriyle yeniden dağıtır (S eğrisi: daha canlı).", ["Renk", "Fotoğraf"],
   [J("shadow", "Gölgeler", -100, 100, -15, 1, 0.5), J("mid", "Orta tonlar", -100, 100, 0, 1, 0.5), J("light", "Açık tonlar", -100, 100, 15, 1, 0.5), CH("ch", "Kanal", ["Hepsi", "Kırmızı", "Yeşil", "Mavi"])])
fx("chanmix", "Kanal Karıştırıcı", "Channel Mixer", c, "pixel", "Her renk kanalını öbür kanallardan yeniden oluşturur.", ["Renk", "Kanal"],
   [J("rr", "Kırmızı ← kırmızı", -200, 200, 100, 1, 0.5), J("rg", "Kırmızı ← yeşil", -200, 200, 0, 1, 0.5), J("rb", "Kırmızı ← mavi", -200, 200, 0, 1, 0.5),
    J("gr", "Yeşil ← kırmızı", -200, 200, 0, 1, 0.5), J("gg", "Yeşil ← yeşil", -200, 200, 100, 1, 0.5), J("gb", "Yeşil ← mavi", -200, 200, 0, 1, 0.5),
    J("br", "Mavi ← kırmızı", -200, 200, 0, 1, 0.5), J("bg", "Mavi ← yeşil", -200, 200, 0, 1, 0.5), J("bb", "Mavi ← mavi", -200, 200, 100, 1, 0.5), T("mono", "Tek renk", 0)],
   [P("KD", "Kanal değiş tokuşu", {"rr": 0, "rb": 100, "bb": 0, "br": 100})])
fx("tritone", "Üç Ton", "Tritone", c, "pixel", "Gölgeleri, orta tonları ve açıkları üç renge eşler.", ["Renk", "Retro"],
   [C("c1", "Gölge", "#0B1430"), C("c2", "Orta", "#8F7CF0"), C("c3", "Açık", "#FFE6A8"), MIX()])
fx("photofilter", "Fotoğraf Filtresi", "Photo Filter", c, "pixel", "Objektifin önüne renkli filtre takılmış gibi.", ["Renk", "Fotoğraf"],
   [CH("filt", "Filtre", ["Sıcak (85)", "Soğuk (80)", "Kırmızı", "Turuncu", "Sarı", "Yeşil", "Camgöbeği", "Mavi", "Mor", "Sepya"], 0), PCT("dens", "Yoğunluk", 35), T("keep", "Parlaklığı koru", 1)])
fx("selcolor", "Seçici Renk", "Selective Color", c, "pixel", "Yalnız seçtiğin renk grubundaki tonları değiştirir.", ["Renk"],
   [CH("grp", "Renk grubu", ["Kırmızılar", "Sarılar", "Yeşiller", "Camgöbekleri", "Maviler", "Morlar"]), A("hue", "Ton", 0), J("sat", "Doygunluk", -100, 100, 30, 1, 0.5), J("lit", "Işık", -100, 100, 0, 1, 0.5)])
fx("colorbal", "Renk Dengesi", "Color Balance", c, "pixel", "Gölge, orta ve açık tonlara ayrı renk kayması verir.", ["Renk", "Sinema"],
   [C("shc", "Gölge rengi", "#2F7BF6"), C("hic", "Açık rengi", "#F2C230"), PCT("str", "Güç", 40)], [P("TO", "Turkuaz-turuncu sinema", cols={"shc": "#008B8B", "hic": "#FF8C33"}, vals={"str": 45})])
fx("autolevels", "Otomatik Seviye", "Auto Levels", c, "pixel", "Tonları kendiliğinden siyah-beyaz arasına yayar.", ["Renk", "Fotoğraf", "Otomatik"], [PCT("amount", "Güç", 100), J("clip", "Kırpma", 0, 20, 2, 0.1, 0.05)])
fx("colorama", "Renk Çemberi", "Colorama", c, "pixel", "Parlaklığı dönen bir renk çemberine eşler; akan renk efektleri için.", ["Renk", "Psikedelik"],
   [J("phase", "Evre", -10, 10, 0, 0.01, 0.005), J("speed", "Dönme hızı", -5, 5, 0.3, 0.01, 0.01), CH("pal", "Çember", ["Gökkuşağı", "Ateş", "Okyanus", "Turkuaz-Mor"]), MIX()])
fx("chanshift", "Kanal Kaydır", "Shift Channels", c, "pixel", "Kırmızı, yeşil ve mavi kanallarını birbirinin yerine koyar.", ["Renk", "Kanal"],
   [CH("r", "Kırmızı ←", ["Kırmızı", "Yeşil", "Mavi", "Parlaklık", "Yok"], 2), CH("g", "Yeşil ←", ["Kırmızı", "Yeşil", "Mavi", "Parlaklık", "Yok"], 0), CH("b", "Mavi ←", ["Kırmızı", "Yeşil", "Mavi", "Parlaklık", "Yok"], 1)])
fx("equalize", "Eşitle", "Equalize", c, "pixel", "Parlaklığı daha dengeli dağıtır; soluk görüntüyü canlandırır.", ["Renk", "Otomatik"], [PCT("amount", "Güç", 70)])
fx("nightvision", "Gece Görüşü", "Night Vision", c, "pixel", "Gece görüş dürbünü: yeşil, parlak ve karlı.", ["Renk", "Film", "Bilim"], [PCT("gain", "Kazanç", 160, 50, 400), PCT("noise", "Kar", 30), T("scope", "Dürbün çerçevesi", 1)])
fx("xray", "Röntgen", "X-Ray", c, "pixel", "Röntgen filmi gibi ters ve mavimsi.", ["Renk", "Bilim"], [PCT("amount", "Güç", 100), C("tint", "Ton", "#BFE6FF")])
fx("underwater", "Su Altı", "Underwater", c, "pixel", "Su altında gibi: mavi-yeşil ton, dalgalanan ışık.", ["Renk", "Su", "Doğa"], [PCT("depth", "Derinlik", 60), PCT("caust", "Işık oyunu", 50), J("speed", "Hız", 0, 5, 1, 0.05, 0.02)])
fx("bleach", "Ağartma Atlatma", "Bleach Bypass", c, "pixel", "Sinemadaki gümüş tonlu, sert ve soluk görünüm.", ["Renk", "Sinema"], [PCT("amount", "Güç", 70)])
fx("crossprocess", "Çapraz İşlem", "Cross Process", c, "pixel", "Yanlış banyo edilmiş film gibi canlı, kaymış renkler.", ["Renk", "Retro", "Film"], [PCT("amount", "Güç", 80)])
fx("lomo", "Lomo", "Lomo", c, "pixel", "Oyuncak kamera: doygun renkler ve koyu kenarlar.", ["Renk", "Retro", "Fotoğraf"], [PCT("amount", "Güç", 80), PCT("vign", "Kenar", 60)])
fx("cinematic", "Sinematik", "Cinematic Teal & Orange", c, "pixel", "Film afişleri gibi turkuaz gölgeler, turuncu ten tonları.", ["Renk", "Sinema"], [PCT("amount", "Güç", 70), T("bars", "Sinema şeritleri", 0)])
fx("infrared", "Kızılötesi", "Infrared", c, "pixel", "Kızılötesi fotoğraf: yapraklar beyaz, gök koyu.", ["Renk", "Fotoğraf", "Bilim"], [PCT("amount", "Güç", 100), T("color", "Renkli", 0)])

# ---------- Çizim ve Kenar ----------
c = 1
fx("brushstrokes", "Fırça Darbeleri", "Brush Strokes", c, "pixel", "Fırçayla boyanmış gibi görünür.", ["Sanat", "Boya"], [J("size", "Fırça boyu", 1, 40, 6, 0.1, 0.05), A("ang", "Açı", 45), PCT("len", "Darbe uzunluğu", 60), PCT("rand", "Rastgelelik", 40)])
fx("glass", "Cam", "Glass", c, "pixel", "Buzlu, dalgalı camın arkasından bakılıyor gibi.", ["Doku", "Bükme"], [J("amount", "Kırılma", 0, 60, 8, 0.5, 0.2), J("size", "Desen", 2, 200, 22, 0.5, 0.2), CH("tex", "Doku", ["Buzlu", "Dalgalı", "Kareli", "Damla"]), PCT("shine", "Parlaklık", 30)])
fx("plastic", "Plastik", "Plastic", c, "pixel", "Yüzeyi parlak, dökme plastik gibi yapar.", ["Doku", "Işık"], [J("height", "Kabartı", 0, 20, 4, 0.1, 0.05), A("ang", "Işık açısı", 135), PCT("gloss", "Parlaklık", 70), PCT("soft", "Yumuşaklık", 50)], pad={"add": 2})
fx("coloremboss", "Renkli Kabartma", "Color Emboss", c, "pixel", "Renkleri koruyarak kabartma verir.", ["Doku", "Kenar"], [A("ang", "Işık açısı", 135), J("height", "Yükseklik", 0, 20, 3, 0.1, 0.05), PCT("amount", "Güç", 100, 0, 300)])
fx("texturize", "Dokulandır", "Texturize", c, "pixel", "Tuval, kâğıt, tuğla gibi bir doku basar.", ["Doku", "Sanat"], [CH("tex", "Doku", ["Tuval", "Kâğıt", "Tuğla", "Kumaş", "Beton"]), PCT("amount", "Güç", 60), J("scale", "Ölçek", 10, 400, 100, 1, 0.5)])
fx("bevelalpha", "Kenar Pahı", "Bevel Alpha", c, "pixel", "Şeklin kenarlarına 3B pah (kabarık kenar) verir.", ["3B", "Kenar", "Işık"], [J("width", "Genişlik", 0, 40, 6, 0.1, 0.05), A("ang", "Işık açısı", 135), PCT("light", "Işık", 70)])
fx("beveledges", "Kutu Pahı", "Bevel Edges", c, "pixel", "Katmanın kutusunun kenarlarını düğme gibi kabartır.", ["3B", "Kenar", "Düğme"], [J("width", "Genişlik", 0, 100, 10, 0.5, 0.2), A("ang", "Işık açısı", 135), PCT("light", "Işık", 60)])
fx("spotlight", "Spot Işığı", "Spotlight", c, "pixel", "Sahneye bir spot ışığı tutar, çevreyi karartır.", ["Işık", "Sahne"], [XY("pos", "Konum", 0, 0), J("rad", "Yarıçap", 5, 2000, 90, 1, 0.5), PCT("soft", "Yumuşaklık", 40), PCT("dark", "Karartma", 80), C("col", "Işık rengi", "#FFF2CC")], [P("GZ", "Gezen ışık", keys={"posX": [[0, -100], [1, 100], [2, -100]]})])
fx("anaglyph", "Anaglif 3B", "3D Glasses (Anaglyph)", c, "pixel", "Kırmızı-mavi 3B gözlük görünümü.", ["3B", "Retro"], [J("amount", "Derinlik", 0, 50, 6, 0.1, 0.05)], pad={"k": "amount", "mul": 1})
fx("lightsweep", "Işık Süpürme", "Light Sweep", c, "pixel", "Yüzeyden geçen parlak bir ışık şeridi (logo parlaması).", ["Işık", "Parlama", "Logo"], [PCT("pos", "Konum", 50, -50, 150), A("ang", "Açı", 30), J("width", "Genişlik", 1, 500, 40, 0.5, 0.2), C("col", "Renk", "#FFFFFF"), PCT("str", "Güç", 80, 0, 300)],
   [P("PA", "Parıltı geçişi", keys={"pos": [[0, -30], [0.8, 130]]})])
fx("vegas", "Işıklı Çerçeve", "Vegas", c, "pixel", "Kenar boyunca dönen, parlayan ışık noktaları (Las Vegas tabelası).", ["Işık", "Kenar", "Neon"], [J("count", "Işık sayısı", 2, 80, 24, 1, 0.1), J("width", "Kalınlık", 0.5, 20, 3, 0.1, 0.05), J("speed", "Hız", -5, 5, 0.5, 0.01, 0.01), C("col", "Renk", "#F2C230"), CH("on", "Nerede", ["Şeklin kenarı", "Kutunun kenarı"])], pad={"k": "width", "mul": 3, "add": 6})
fx("scribble", "Karalama", "Scribble", c, "pixel", "Şeklin içini elle karalanmış çizgilerle doldurur.", ["Çizim", "Sanat"], [J("width", "Çizgi", 0.5, 20, 2, 0.1, 0.05), J("space", "Aralık", 1, 50, 6, 0.1, 0.05), A("ang", "Açı", 30), J("wiggle", "Titreme", 0, 10, 2, 0.1, 0.05), C("col", "Renk", "#0B1430"), T("keep", "Altı görünsün", 0)])
fx("watercolor", "Suluboya", "Watercolor", c, "pixel", "Suluboya resim: yumuşak lekeler ve kâğıt dokusu.", ["Sanat", "Boya"], [PCT("amount", "Güç", 80), J("size", "Leke", 1, 30, 6, 0.1, 0.05)])
fx("oilpaint", "Yağlı Boya", "Oil Paint", c, "pixel", "Kalın fırçayla yağlı boya tablo gibi.", ["Sanat", "Boya"], [J("size", "Fırça", 1, 20, 4, 0.1, 0.05), PCT("shine", "Parlaklık", 40)])
fx("comic", "Çizgi Roman", "Comic Book", c, "pixel", "Çizgi roman baskısı: koyu kenarlar, düz renkler, nokta tram.", ["Sanat", "Retro", "Baskı"], [J("dot", "Nokta boyu", 2, 30, 6, 0.1, 0.05), PCT("edge", "Kenar", 100, 0, 300), J("levels", "Ton", 2, 8, 4, 1, 0.1)])
fx("stipple", "Noktacılık", "Stipple", c, "pixel", "Görüntüyü binlerce küçük nokta ile çizer.", ["Sanat", "Çizim"], [J("size", "Nokta", 1, 20, 3, 0.1, 0.05), C("col", "Mürekkep", "#0B1430"), C("bg", "Kâğıt", "#F7F8FA")])
fx("neonsign", "Neon Tabela", "Neon Sign", c, "pixel", "Şekli titreyen neon tüp tabelaya çevirir.", ["Neon", "Işık", "Gece"], [C("col", "Renk", "#FF3DCB"), J("width", "Tüp", 0.5, 20, 3, 0.1, 0.05), PCT("glow", "Parlama", 150, 0, 400), PCT("flick", "Titreme", 20)], pad={"add": 30})
fx("hologram", "Hologram", "Hologram", c, "pixel", "Bilim kurgu hologramı: mavi, çizgili ve titrek.", ["Bilim", "Neon", "Glitch"], [C("col", "Renk", "#3FD0F0"), PCT("lines", "Çizgiler", 60), PCT("flick", "Titreme", 30), J("speed", "Hız", 0, 10, 1, 0.05, 0.02)])

# ---------- Bulanıklık ----------
c = 2
fx("bilateral", "Yüzey Yumuşatma", "Bilateral Blur", c, "pixel", "Kenarları koruyarak yüzeyleri pürüzsüzleştirir (cilt yumuşatma).", ["Bulanık", "Fotoğraf", "Güzellik"], [J("amount", "Yarıçap", 0, 30, 6, 0.1, 0.05), PCT("thr", "Kenar koruma", 30)])
fx("chanblur", "Kanal Bulanıklığı", "Channel Blur", c, "pixel", "Kırmızı, yeşil ve mavi kanalları ayrı ayrı bulanıklaştırır.", ["Bulanık", "Kanal"], [J("r", "Kırmızı", 0, 40, 8, 0.5, 0.2), J("g", "Yeşil", 0, 40, 0, 0.5, 0.2), J("b", "Mavi", 0, 40, 3, 0.5, 0.2)], pad={"add": 40})
fx("crossblur", "Çapraz Bulanıklık", "Cross Blur", c, "pixel", "Yatay ve dikey bulanıklığı ayrı ayarlar.", ["Bulanık"], [J("h", "Yatay", 0, 100, 20, 0.5, 0.2), J("v", "Dikey", 0, 100, 0, 0.5, 0.2)], pad={"add": 40},
   passes=[{"fs": "crossblur", "set": {"u_dir": [1, 0]}, "out": "A"}, {"fs": "crossblur", "in": "A", "set": {"u_dir": [0, 1]}}])
fx("vectorblur", "Akış Bulanıklığı", "Vector Blur", c, "pixel", "Görüntünün kendi kenar yönlerinde akan bulanıklık; boyalı görünüm.", ["Bulanık", "Sanat"], [J("amount", "Miktar", 0, 60, 10, 0.5, 0.2), A("ang", "Açı kayması", 90)])
fx("median", "Ortanca Filtre", "Median", c, "pixel", "Küçük ayrıntıları ve gürültüyü siler, sulu boya gibi düzleştirir.", ["Bulanık", "Gürültü"], [J("rad", "Yarıçap", 0, 8, 2, 1, 0.1)])
fx("dustscratch", "Toz ve Çizik Temizle", "Dust & Scratches", c, "pixel", "Küçük lekeleri ve çizikleri temizler.", ["Gürültü", "Fotoğraf"], [J("rad", "Yarıçap", 0, 8, 2, 1, 0.1), PCT("thr", "Eşik", 20)])

# ---------- Bükme ve Bozulma ----------
c = 3
fx("bezierwarp", "Bezier Bükme", "Bezier Warp", c, "pixel", "Katmanın kenarlarını yumuşak eğrilerle büker.", ["Bükme"], [J("top", "Üst kenar", -300, 300, 30, 1, 0.5), J("bottom", "Alt kenar", -300, 300, -30, 1, 0.5), J("left", "Sol kenar", -300, 300, 0, 1, 0.5), J("right", "Sağ kenar", -300, 300, 0, 1, 0.5)], pad={"add": 80})
fx("cornerpin", "Köşe Sabitle", "Corner Pin", c, "pixel", "Katmanın dört köşesini istediğin yere çeker (perspektif).", ["Bükme", "Perspektif"], [XY("tl", "Sol üst", -20, -10), XY("tr", "Sağ üst", 20, 10), XY("bl", "Sol alt", 0, 0), XY("br", "Sağ alt", 0, 0)], pad={"add": 120})
fx("bendit", "Bük", "Bend It", c, "pixel", "Katmanı bir uçtan öbürüne doğru kemer gibi büker.", ["Bükme"], [A("amount", "Bükülme", 40), CH("dir", "Yön", ["Yatay", "Dikey"])], pad={"add": 60})
fx("blobby", "Damlalaştır", "Blobbylize", c, "pixel", "Katmanı yumuşak, eriyen damlalar gibi yapar.", ["Bükme", "Akışkan"], [J("amount", "Miktar", 0, 100, 30, 0.5, 0.2), J("size", "Damla", 4, 300, 40, 0.5, 0.2), J("speed", "Hız", 0, 5, 0.5, 0.01, 0.01)], pad={"add": 20})
fx("flomotion", "Çekim Noktası", "Flo Motion", c, "pixel", "Görüntüyü bir noktaya doğru çeker ya da iter.", ["Bükme"], [XY("pos", "Nokta", 0, 0), J("amount", "Güç", -100, 100, 40, 0.5, 0.2), J("rad", "Yarıçap", 5, 2000, 120, 1, 0.5)])
fx("griddler", "Izgara Parçala", "Griddler", c, "pixel", "Katmanı kare parçalara böler; her parça döner ya da kayar.", ["Geometrik", "Glitch"], [J("size", "Parça", 4, 300, 30, 0.5, 0.2), A("rot", "Dönme", 15), PCT("scl", "Ölçek", 100, 10, 200), J("gap", "Aralık", 0, 20, 1, 0.1, 0.05)])
fx("lens", "Mercek", "Lens", c, "pixel", "Yuvarlak bir merceğin arkasından bakılıyor gibi büyütür.", ["Mercek", "Bükme"], [XY("pos", "Merkez", 0, 0), J("rad", "Yarıçap", 5, 2000, 90, 1, 0.5), J("conv", "Bombelik", -100, 100, 60, 1, 0.5)])
fx("pageturn", "Sayfa Çevir", "Page Turn", c, "pixel", "Kitap sayfası gibi köşeden kıvrılarak açılır.", ["Geçiş", "Kâğıt"], [PCT("prog", "İlerleme", 40), A("ang", "Yön", 30), J("rad", "Kıvrım", 5, 300, 30, 0.5, 0.2), C("back", "Arka yüz", "#E3E9F2")], [P("CV", "Sayfayı çevir", keys={"prog": [[-0.9, 0], [0, 100]]}, at="end")], pad={"add": 40})
fx("ripplepulse", "Halka Nabzı", "Ripple Pulse", c, "pixel", "Merkezden tek tek yayılan halka dalgaları.", ["Bükme", "Su"], [XY("center", "Merkez", 0, 0), J("amp", "Yükseklik", 0, 100, 14, 0.5, 0.2), J("width", "Halka", 2, 300, 30, 0.5, 0.2), J("speed", "Hız", 0, 2000, 160, 1, 0.5), J("rate", "Sıklık", 0.1, 10, 1, 0.05, 0.02)])
fx("slant", "Yatık Kutu", "Slant", c, "pixel", "Katmanı paralelkenar gibi yatırır, istersen kenara gölge koyar.", ["Dönüştür", "3B"], [J("amount", "Eğim", -89, 89, 20, 0.5, 0.2), PCT("height", "Yükseklik", 100, 10, 200), C("floor", "Taban rengi", "#1B2A55"), T("floorOn", "Taban", 0)], pad={"add": 80})
fx("smear", "Sürükle Bulaştır", "Smear", c, "pixel", "Bir bölgeyi tutup sürüklemiş gibi bulaştırır.", ["Bükme", "Akışkan"], [XY("from", "Başlangıç", 0, 0), XY("to", "Bitiş", 60, 0), J("rad", "Yarıçap", 5, 1000, 70, 1, 0.5)], pad={"add": 40})
fx("split", "Yırt", "Split", c, "pixel", "Katmanı bir çizgi boyunca yırtıp iki yana açar.", ["Geçiş", "Bükme"], [XY("a", "Uç 1", 0, -200), XY("b", "Uç 2", 0, 200), J("amount", "Açıklık", 0, 500, 60, 0.5, 0.2)], [P("AC", "Yırtılarak açıl", keys={"amount": [[0, 0], [0.8, 300]]})])
fx("tiler", "Küçült ve Döşe", "Tiler", c, "repeat", "Katmanı küçültüp boşluğu kopyalarıyla doldurur.", ["Tekrar", "Döşeme"], [PCT("scl", "Ölçek", 33, 5, 100), XY("center", "Merkez", 0, 0)])
fx("dispmap", "Yer Değiştirme Haritası", "Displacement Map", c, "pixel", "Katmanı kendi parlaklığına (ya da kanallarına) göre kaydırır.", ["Bükme"], [J("x", "Yatay kaydırma", -200, 200, 20, 0.5, 0.2), J("y", "Dikey kaydırma", -200, 200, 20, 0.5, 0.2), CH("src", "Kaynak", ["Parlaklık", "Kırmızı", "Yeşil", "Mavi", "Kendi bulanığı"])], pad={"add": 30})
fx("spherize", "Küreleştir", "Spherize", c, "pixel", "Bir bölgeyi küre yüzeyine sarılmış gibi şişirir.", ["Bükme", "Mercek"], [XY("center", "Merkez", 0, 0), J("rad", "Yarıçap", 5, 2000, 100, 1, 0.5), PCT("amount", "Miktar", 100, -100, 100)])
fx("warpstyle", "Stil Bükme", "Warp (Styles)", c, "pixel", "Hazır biçimlerle büker: yay, kemer, bayrak, balık, şişkin, dalga, burgu…", ["Bükme", "Metin"],
   [CH("style", "Stil", ["Yay", "Kemer", "Şişkin", "Bayrak", "Dalga", "Balık", "Yükselen", "Balık gözü", "Şişir", "Sıkıştır", "Burgu"]), J("bend", "Bükülme", -100, 100, 40, 1, 0.5), J("hd", "Yatay bozulma", -100, 100, 0, 1, 0.5), J("vd", "Dikey bozulma", -100, 100, 0, 1, 0.5)], pad={"add": 80})
fx("heatwave", "Isı Dalgası", "Heat Haze", c, "pixel", "Sıcak asfalt üstündeki gibi titreşen hava.", ["Bükme", "Akışkan", "Doğa"], [J("amount", "Miktar", 0, 30, 4, 0.1, 0.05), J("size", "Ölçek", 5, 500, 40, 0.5, 0.2), J("speed", "Hız", 0, 10, 2, 0.05, 0.02)], pad={"k": "amount", "mul": 1})

# ---------- Prosedürel ----------
c = 4
fx("beam", "Işın", "Beam", c, "gen", "İki nokta arasında parlayan bir lazer ışını.", ["Işık", "Enerji", "Neon"], [XY("a", "Başlangıç", -150, 0), XY("b", "Bitiş", 150, 0), J("width", "Kalınlık", 0.5, 60, 6, 0.1, 0.05), C("core", "Çekirdek", "#FFFFFF"), C("col", "Hale", "#22D3C5"), PCT("glow", "Parlama", 120, 0, 400), PCT("len", "Uzunluk", 100)])
fx("lightburst", "Işık Patlaması", "Light Burst", c, "pixel", "Parlak yerlerden merkezden dışarı ışık saçar.", ["Işık", "Parlama"], [XY("center", "Merkez", 0, 0), J("len", "Uzunluk", 0, 100, 40, 1, 0.5), PCT("amount", "Güç", 100, 0, 300)], pad={"add": 40}, heavy=True)
fx("radiowaves", "Radyo Dalgaları", "Radio Waves", c, "gen", "Bir merkezden yayılan halkalar (sinyal, sonar).", ["Desen", "Bilim", "Sinyal"], [XY("center", "Merkez", 0, 0), J("speed", "Hız", 0, 2000, 120, 1, 0.5), J("rate", "Sıklık", 0.1, 20, 2, 0.05, 0.02), J("width", "Kalınlık", 0.5, 40, 4, 0.1, 0.05), C("col", "Renk", "#22D3C5"), PCT("fade", "Solma", 70), CH("shape", "Şekil", ["Daire", "Kare", "Altıgen", "Yıldız"])])
fx("circlefx", "Daire", "Circle", c, "gen", "Katmanın üstüne dolu ya da halka biçiminde daire çizer.", ["Şekil"], [XY("pos", "Merkez", 0, 0), J("rad", "Yarıçap", 0, 2000, 70, 1, 0.5), J("ring", "Halka kalınlığı", 0, 500, 0, 0.5, 0.2), J("feather", "Yumuşaklık", 0, 100, 1, 0.1, 0.05), C("col", "Renk", "#F7F8FA"), CH("mode", "Kullanım", ["Üstüne çiz", "Katmanı kes", "Katmanı göster"])])
fx("ellipsefx", "Elips Halka", "Ellipse", c, "gen", "Parlak kenarlı bir elips halka çizer.", ["Şekil", "Işık"], [J("w", "Genişlik", 1, 3000, 200, 1, 0.5), J("h", "Yükseklik", 1, 3000, 120, 1, 0.5), J("thick", "Kalınlık", 0.5, 100, 6, 0.1, 0.05), PCT("soft", "Yumuşaklık", 50), C("in", "İç renk", "#FFFFFF"), C("out", "Dış renk", "#3FD0F0")])
fx("audiospec", "Ses Spektrumu", "Audio Spectrum", c, "audio", "Projedeki sese göre zıplayan çubuklar (ekolayzer).", ["Ses", "Müzik", "Ekolayzer"], [J("bars", "Çubuk", 4, 128, 32, 1, 0.1), J("height", "Yükseklik", 0, 1000, 160, 1, 0.5), J("thick", "Kalınlık", 0.5, 60, 6, 0.1, 0.05), C("c1", "Renk 1", "#22D3C5"), C("c2", "Renk 2", "#8F7CF0"), CH("shape", "Biçim", ["Çubuklar", "Daire", "Noktalar"]), T("mirror", "Simetrik", 1)], info="Projedeki ses katmanlarına göre hareket eder.")
fx("audiowave", "Ses Dalgası", "Audio Waveform", c, "audio", "Projedeki sesin dalga çizgisi.", ["Ses", "Müzik"], [J("height", "Yükseklik", 0, 1000, 120, 1, 0.5), J("thick", "Kalınlık", 0.5, 30, 3, 0.1, 0.05), J("win", "Süre (sn)", 0.02, 2, 0.25, 0.01, 0.005), C("col", "Renk", "#22D3C5"), PCT("glow", "Parlama", 80, 0, 300)], info="Projedeki ses katmanlarına göre hareket eder.")
fx("threads", "İplik Dokuma", "Threads", c, "gen", "Katmanın üstüne dokuma kumaş deseni örer.", ["Doku", "Desen"], [J("size", "İplik", 2, 100, 10, 0.5, 0.2), PCT("cover", "Kaplama", 60), PCT("shade", "Gölge", 50), A("ang", "Açı", 0)])
fx("fireworks", "Havai Fişek", "Fireworks", c, "gen", "Gökyüzünde patlayan renkli havai fişekler.", ["Kutlama", "Parçacık", "Işık"], [PCT("density", "Sıklık", 50), J("size", "Boyut", 10, 1000, 160, 1, 0.5), J("speed", "Hız", 0.1, 5, 1, 0.05, 0.02), T("trail", "İz", 1)])
fx("heartrain", "Kalp Yağmuru", "Heart Rain", c, "gen", "Yağan ya da yükselen kalpler.", ["Sevgi", "Parçacık", "Kutlama"], [PCT("density", "Yoğunluk", 40), J("speed", "Hız", -10, 10, 1, 0.05, 0.02), PCT("size", "Boyut", 100, 10, 400), C("col", "Renk", "#E8333F")])
fx("bokeh", "Bokeh Işıkları", "Bokeh Lights", c, "gen", "Odak dışı, süzülen yuvarlak ışıklar.", ["Işık", "Parçacık", "Fotoğraf"], [PCT("density", "Yoğunluk", 40), PCT("size", "Boyut", 100, 10, 400), J("speed", "Hız", 0, 5, 0.4, 0.01, 0.01), C("c1", "Renk 1", "#F2C230"), C("c2", "Renk 2", "#3FD0F0")])
fx("smoke", "Renkli Duman", "Colored Smoke", c, "gen", "Yükselen, kıvrılan renkli duman.", ["Duman", "Akışkan"], [J("scale", "Ölçek", 10, 1000, 140, 1, 0.5), J("speed", "Hız", 0, 5, 0.6, 0.01, 0.01), C("col", "Renk", "#8F7CF0"), PCT("dens", "Yoğunluk", 70)])
fx("aurora", "Kutup Işıkları", "Aurora", c, "gen", "Gökte dalgalanan kutup ışıkları.", ["Işık", "Doğa", "Gece"], [J("speed", "Hız", 0, 5, 0.5, 0.01, 0.01), C("c1", "Renk 1", "#22D3C5"), C("c2", "Renk 2", "#8F7CF0"), PCT("str", "Güç", 100, 0, 300)])
fx("galaxy", "Galaksi", "Galaxy", c, "gen", "Dönen sarmal galaksi ve yıldızlar.", ["Uzay", "Işık"], [J("speed", "Dönme", -5, 5, 0.3, 0.01, 0.01), J("arms", "Kol", 1, 8, 3, 1, 0.1), C("col", "Renk", "#8F7CF0"), PCT("stars", "Yıldızlar", 60)])
fx("coderain", "Kod Yağmuru", "Code Rain", c, "gen", "Yukarıdan akan yeşil karakterler (hacker ekranı).", ["Hacker", "Bilim", "Retro"], [J("size", "Karakter", 4, 60, 12, 0.5, 0.2), J("speed", "Hız", 0, 10, 2, 0.05, 0.02), C("col", "Renk", "#22FF88")])

# ---------- 3B ----------
c = 5
fx("tetra", "Dörtyüzlü", "Tetrahedron", c, "3d", "Dört üçgen yüzlü şekil.", ["3B", "Şekil"], R3(20, 20, 0, 40))
fx("icosa", "Yirmiyüzlü", "Icosahedron", c, "3d", "Yirmi yüzlü, top gibi çokyüzlü.", ["3B", "Şekil", "Zar"], R3(20, 20, 0, 40))
fx("fold3d", "3B Katla", "Fold (3D)", c, "3d", "Katmanı ortasından kâğıt gibi katlar.", ["3B", "Kâğıt", "Geçiş"], [A("ang", "Katlama açısı", 60), CH("axis", "Eksen", ["Dikey", "Yatay"]), J("count", "Kat sayısı", 1, 12, 1, 1, 0.1), PCT("persp", "Perspektif", 50), PCT("light", "Işık", 60)], [P("AC", "Katlanarak açıl", keys={"ang": [[0, 170], [0.8, 0]]})])

# ---------- Taşı ve Dönüştür ----------
c = 6
fx("transformfx", "Dönüştür", "Transform", c, "xform", "Ek konum, ölçek (yatay/dikey ayrı), eğme ve dönme; başka efektlerden sonra uygulanır.", ["Dönüştür"], [XY("pos", "Konum", 0, 0), PCT("sx", "Yatay ölçek", 100, -500, 500), PCT("sy", "Dikey ölçek", 100, -500, 500), J("skew", "Eğme", -80, 80, 0, 0.5, 0.2), A("rot", "Dönme", 0), PCT("op", "Opaklık", 100)])
fx("elastic", "Elastik Yaylanma", "Elastic Overshoot", c, "xform", "Katman keyframe'lerde durunca yay gibi salınarak durur.", ["Hareket", "Animasyon"], [PCT("amount", "Yaylanma", 40), J("freq", "Sıklık", 0.5, 10, 3, 0.05, 0.02), J("decay", "Sönme", 0.5, 20, 6, 0.1, 0.05)], info="Taşı ve Çevir keyframe'leriyle birlikte kullan.")
fx("drift", "Sürüklen", "Drift", c, "xform", "Sabit hızla bir yöne kayar ve döner.", ["Hareket"], [XY("vel", "Hız (birim/sn)", 40, 0), J("spin", "Dönme (°/sn)", -720, 720, 0, 1, 0.5)])
fx("spiralpath", "Sarmal Yol", "Spiral Path", c, "xform", "Merkezden açılan bir sarmal üzerinde döner.", ["Hareket", "Döndür"], [J("rad", "Son yarıçap", 0, 2000, 160, 1, 0.5), J("turns", "Tur", 0.1, 20, 2, 0.05, 0.02), T("inward", "İçe doğru", 0)])

# ---------- Tekrar ----------
c = 7
fx("motiontile", "Hareketli Döşeme", "Motion Tile", c, "repeat", "Katmanın kenarlarını kopyalarla doldurur; kayınca boşluk kalmaz.", ["Tekrar", "Döşeme"], [PCT("outw", "Çıktı genişliği", 300, 100, 1000), PCT("outh", "Çıktı yüksekliği", 300, 100, 1000), T("mirror", "Aynalı kenar", 1), XY("off", "Kaydır", 0, 0)], pad={"add": 0})

# ---------- Maske ve Anahtar ----------
c = 8
fx("colorrange", "Renk Aralığı Anahtarı", "Color Range Key", c, "pixel", "Belirli bir renk aralığını (ton ve parlaklık) saydam yapar.", ["Maske", "Anahtar"], [C("key", "Renk", "#2F7BF6"), PCT("hue", "Ton aralığı", 15), PCT("sat", "Doygunluk aralığı", 50), PCT("soft", "Yumuşaklık", 10)])
fx("lincolorkey", "Doğrusal Renk Anahtarı", "Linear Color Key", c, "pixel", "Seçtiğin renge benzerliğe göre yumuşak saydamlık.", ["Maske", "Anahtar"], [C("key", "Renk", "#FFFFFF"), PCT("tol", "Tolerans", 20), PCT("soft", "Yumuşaklık", 20), T("keep", "Sadece bu rengi tut", 0)])
fx("spill", "Renk Taşması Gider", "Spill Suppressor", c, "pixel", "Yeşil perdeden kalan yeşil/mavi yansımaları temizler.", ["Maske", "Anahtar", "Video"], [C("key", "Perde rengi", "#22B14C"), PCT("amount", "Güç", 80)])
fx("noisealpha", "Saydamlık Gürültüsü", "Noise Alpha", c, "pixel", "Saydamlığı gürültüyle bozar (toz, kumlu çözülme).", ["Maske", "Gürültü", "Geçiş"], [PCT("amount", "Miktar", 50), J("size", "Tane", 1, 200, 10, 0.5, 0.2), J("speed", "Hız", 0, 10, 0.5, 0.05, 0.02), PCT("soft", "Yumuşaklık", 30)])

# ---------- Opaklık ve Görünürlük ----------
c = 9
fx("strobelight", "Renkli Flaş", "Strobe Light", c, "pixel", "Belli aralıklarla renkli flaş patlatır.", ["Işık", "Parti"], [C("col", "Renk", "#FFFFFF"), J("period", "Aralık (sn)", 0.05, 5, 0.4, 0.01, 0.01), J("len", "Süre (sn)", 0.01, 2, 0.08, 0.005, 0.002), CH("mode", "Tür", ["Rengi kapla", "Katmanı gizle", "Ters çevir"])])
fx("flash", "Flaş Geçişi", "Flash", c, "opacity", "Katmanın başında beyaz bir flaşla belirir.", ["Işık", "Geçiş", "Giriş"], [J("dur", "Süre", 0.05, 3, 0.4, 0.01, 0.01), C("col", "Renk", "#FFFFFF")])

# ---------- Metin ----------
c = 10
fx("timecode", "Zaman Kodu", "Timecode", c, "text", "Yazının yerine geçen süreyi saat:dakika:saniye:kare olarak gösterir.", ["Metin", "Zaman", "Sayı"], [CH("fmt", "Biçim", ["SS:DD:SN:KR", "DD:SN", "Saniye", "Kare"]), J("start", "Başlangıç (sn)", -1e5, 1e5, 0, 1, 0.5)], info=TI)
fx("textglitch", "Bozuk Yazı", "Glitch Text", c, "text", "Harfler arada bir bozulup kayar ve renk ayrışır.", ["Metin", "Glitch"], [PCT("amount", "Miktar", 50), J("speed", "Hız", 0, 30, 8, 0.1, 0.05)], info=TI)
fx("textreveal", "Maskeli Yazı Açılışı", "Mask Reveal Text", c, "text", "Harfler bir çizginin altından kayarak ortaya çıkar.", ["Metin", "Animasyon", "Giriş"], [J("dur", "Süre", 0.05, 5, 0.6, 0.01, 0.01), J("stag", "Gecikme", 0, 1, 0.05, 0.005, 0.002), CH("dir", "Yön", ["Aşağıdan", "Yukarıdan"])], info=TI)

# ---------- Simülasyon ----------
c = SIM
fx("shatter", "Parçalanma", "Shatter", c, "3d", "Katman cam gibi kırılıp parçaları savrulur.", ["Simülasyon", "Kırılma", "Geçiş"], [PCT("prog", "İlerleme", 40), J("size", "Parça", 4, 300, 36, 0.5, 0.2), XY("center", "Darbe noktası", 0, 0), J("force", "Kuvvet", 0, 2000, 300, 1, 0.5), J("grav", "Yerçekimi", -2000, 2000, 400, 1, 0.5), CH("shape", "Parça", ["Cam", "Tuğla", "Altıgen", "Üçgen"])],
   [P("KR", "Kırılarak kaybol", keys={"prog": [[-1, 0], [0, 100]]}, at="end")], pad={"add": 0})
fx("pixelpolly", "Paramparça Üçgenler", "Pixel Polly", c, "3d", "Katman üçgenlere ayrılıp dönerek dağılır.", ["Simülasyon", "Geçiş"], [PCT("prog", "İlerleme", 40), J("size", "Üçgen", 4, 300, 24, 0.5, 0.2), J("force", "Kuvvet", 0, 2000, 300, 1, 0.5), J("grav", "Yerçekimi", -2000, 2000, 300, 1, 0.5), A("spin", "Dönme", 360)], [P("DA", "Dağılarak kaybol", keys={"prog": [[-1, 0], [0, 100]]}, at="end")], pad={"add": 0})
fx("carddance", "Kart Dansı", "Card Dance", c, "3d", "Katman kartlara bölünür, kartlar dalga gibi döner.", ["Simülasyon", "3B", "Geometrik"], [J("rows", "Satır", 1, 60, 10, 1, 0.1), J("cols", "Sütun", 1, 60, 10, 1, 0.1), A("rot", "Dönme", 180), J("speed", "Hız", 0, 5, 0.8, 0.01, 0.01), J("depth", "Derinlik", 0, 500, 40, 0.5, 0.2)], pad={"add": 0})
fx("caustics", "Su Işığı", "Caustics", c, "pixel", "Su dibine vuran dalgalı ışık desenleri.", ["Simülasyon", "Su", "Işık"], [J("scale", "Ölçek", 10, 1000, 80, 1, 0.5), J("speed", "Hız", 0, 5, 0.6, 0.01, 0.01), PCT("str", "Güç", 70, 0, 300), C("col", "Renk", "#BFF4FF")])
fx("waveworld", "Su Yüzeyi", "Wave World", c, "pixel", "Katmanı dalgalanan su yüzeyinin altından bakılıyor gibi büker.", ["Simülasyon", "Su", "Bükme"], [J("amount", "Kırılma", 0, 60, 10, 0.5, 0.2), J("scale", "Dalga", 10, 1000, 90, 1, 0.5), J("speed", "Hız", 0, 5, 1, 0.01, 0.01), PCT("shine", "Işıltı", 50)])
fx("mercury", "Cıva", "Mr. Mercury", c, "pixel", "Katman sıvı metal damlalara dönüşüp akar.", ["Simülasyon", "Akışkan", "Metal"], [PCT("prog", "İlerleme", 50), J("size", "Damla", 4, 200, 30, 0.5, 0.2), J("grav", "Yerçekimi", -500, 500, 120, 1, 0.5)], pad={"add": 60})
fx("foam", "Köpük", "Foam", c, "gen", "Yükselen, birbirine değen köpük kabarcıkları.", ["Simülasyon", "Su", "Parçacık"], [PCT("density", "Yoğunluk", 60), PCT("size", "Boyut", 100, 10, 400), J("speed", "Hız", 0, 10, 1, 0.05, 0.02), PCT("wobble", "Sallanma", 40)])
fx("particles", "Parçacık Patlaması", "Particle Systems", c, "gen", "Bir noktadan fışkıran, yerçekimiyle düşen parlak parçacıklar.", ["Simülasyon", "Parçacık", "Işık"], [XY("pos", "Kaynak", 0, 0), PCT("rate", "Sıklık", 60), J("vel", "Hız", 0, 2000, 300, 1, 0.5), J("grav", "Yerçekimi", -2000, 2000, 400, 1, 0.5), J("life", "Ömür (sn)", 0.1, 10, 1.4, 0.05, 0.02), C("c1", "Doğum rengi", "#FFF2A8"), C("c2", "Ölüm rengi", "#E8333F"), PCT("size", "Boyut", 100, 10, 500)])
fx("scatterize", "Toz Olup Savrul", "Scatterize", c, "pixel", "Katman toz zerrelerine ayrılıp rüzgârla savrulur.", ["Simülasyon", "Geçiş", "Parçacık"], [PCT("prog", "İlerleme", 50), A("ang", "Rüzgâr yönü", 0), J("dist", "Mesafe", 0, 2000, 300, 1, 0.5), J("grain", "Tane", 1, 20, 2, 0.1, 0.05)], [P("SV", "Savrularak kaybol", keys={"prog": [[-1.2, 0], [0, 100]]}, at="end")], pad={"k": "dist", "mul": 1})
fx("drizzle", "Çisenti", "Drizzle", c, "pixel", "Suya düşen yağmur damlalarının halkaları.", ["Simülasyon", "Su", "Yağmur"], [PCT("rate", "Sıklık", 50), J("size", "Halka", 2, 300, 40, 0.5, 0.2), J("amp", "Bükülme", 0, 50, 6, 0.1, 0.05), J("life", "Ömür (sn)", 0.2, 5, 1.2, 0.05, 0.02)])
fx("hair", "Tüy", "Hair", c, "pixel", "Katmanın kenarından tüy ya da çim gibi kıllar çıkar.", ["Simülasyon", "Doku", "Doğa"], [J("len", "Uzunluk", 0, 200, 16, 0.5, 0.2), PCT("density", "Sıklık", 60), A("ang", "Yön", -90), J("wave", "Rüzgâr", 0, 10, 2, 0.05, 0.02)], pad={"k": "len", "mul": 1})
fx("ballaction", "Top Dizisi", "Ball Action", c, "pixel", "Katman ızgarada küçük toplara bölünür; toplar dağılıp birleşir.", ["Simülasyon", "Geometrik", "Geçiş"], [J("size", "Top", 2, 100, 10, 0.5, 0.2), PCT("scatter", "Dağılma", 0, 0, 300), A("twist", "Burgu", 0), PCT("ball", "Top boyu", 90)], [P("DG", "Dağılarak kaybol", keys={"scatter": [[-1, 0], [0, 200]]}, at="end")], pad={"add": 60})
fx("starburst", "Yıldız Patlaması", "Star Burst", c, "gen", "Merkezden ekrana doğru uçan yıldızlar (warp hızı).", ["Simülasyon", "Uzay", "Hız"], [J("speed", "Hız", 0, 20, 3, 0.05, 0.02), PCT("density", "Yoğunluk", 50), PCT("size", "Boyut", 100, 10, 400), T("streak", "Çizgi iz", 1)])
fx("brokenglass", "Kırık Cam", "Broken Glass", c, "pixel", "Katmanın önünde çatlamış bir cam varmış gibi.", ["Simülasyon", "Kırılma", "Cam"], [XY("center", "Darbe noktası", 0, 0), J("size", "Parça", 4, 300, 40, 0.5, 0.2), J("offset", "Kayma", 0, 40, 6, 0.1, 0.05), PCT("cracks", "Çatlak", 80)])

# ---------- Geçiş ----------
c = TRN
TP = lambda: [P("GR", "Giriş", keys={"prog": [[0, 100], [0.8, 0]]}), P("CK", "Çıkış", keys={"prog": [[-0.8, 0], [0, 100]]}, at="end")]
fx("cardwipe", "Kart Silme", "Card Wipe", c, "3d", "Katman kartlara bölünüp kartlar sırayla dönerek gizlenir.", ["Geçiş", "3B"], [PCT("prog", "İlerleme", 50), J("rows", "Satır", 1, 60, 8, 1, 0.1), J("cols", "Sütun", 1, 60, 8, 1, 0.1), CH("axis", "Dönme ekseni", ["Y", "X"]), PCT("width", "Geçiş genişliği", 40)], TP(), pad={"add": 0})
fx("glasswipe", "Cam Silme", "Glass Wipe", c, "pixel", "Cam gibi kırılarak eriyen silme geçişi.", ["Geçiş", "Bükme"], [PCT("prog", "İlerleme", 50), J("soft", "Yumuşaklık", 0, 300, 40, 0.5, 0.2), J("amount", "Kırılma", 0, 100, 20, 0.5, 0.2)], TP())
fx("gridwipe", "Izgara Silme", "Grid Wipe", c, "pixel", "Kareler küçülerek ya da dönerek katmanı siler.", ["Geçiş", "Geometrik"], [PCT("prog", "İlerleme", 50), J("size", "Kare", 4, 500, 40, 0.5, 0.2), A("rot", "Dönme", 45), CH("order", "Sıra", ["Soldan", "Merkezden", "Rastgele"])], TP())
fx("jaws", "Diş Silme", "Jaws", c, "pixel", "Testere dişli bir çizgiyle ikiye ayrılır.", ["Geçiş"], [PCT("prog", "İlerleme", 50), A("ang", "Açı", 0), J("height", "Diş yüksekliği", 0, 300, 30, 0.5, 0.2), J("width", "Diş genişliği", 2, 300, 40, 0.5, 0.2), CH("shape", "Diş", ["Testere", "Dalga", "Kare"])], TP())
fx("lightwipe", "Işıklı Silme", "Light Wipe", c, "pixel", "Ön ucu parlayan bir ışıkla silme geçişi.", ["Geçiş", "Işık"], [PCT("prog", "İlerleme", 50), A("ang", "Açı", 30), J("width", "Işık genişliği", 1, 500, 40, 0.5, 0.2), C("col", "Işık rengi", "#3FD0F0"), CH("shape", "Biçim", ["Düz", "Daire", "Kare"])], TP())
fx("linesweep", "Çizgi Süpürme", "Line Sweep", c, "pixel", "İnce çizgiler hâlinde süpürerek açılır.", ["Geçiş", "Çizgi"], [PCT("prog", "İlerleme", 50), A("ang", "Açı", 45), J("thick", "Çizgi", 1, 200, 12, 0.5, 0.2), PCT("slant", "Eğim", 50)], TP())
fx("radscalewipe", "Dairesel Büyüme Silme", "Radial Scale Wipe", c, "pixel", "Ortadan açılan delikle; kenarlar büyüyerek dışarı itilir.", ["Geçiş", "Mercek"], [PCT("prog", "İlerleme", 50), XY("center", "Merkez", 0, 0)], TP())
fx("scalewipe", "Esneyerek Silme", "Scale Wipe", c, "pixel", "Katman bir yöne doğru uzayıp esneyerek kaybolur.", ["Geçiş", "Bükme"], [PCT("prog", "İlerleme", 50), A("ang", "Yön", 0), XY("center", "Merkez", 0, 0)], TP())
fx("twister", "Bükülerek Geçiş", "Twister", c, "pixel", "Katman şerit gibi bükülüp arka yüzünü göstererek döner.", ["Geçiş", "3B"], [PCT("prog", "İlerleme", 50), A("ang", "Eksen açısı", 0), C("back", "Arka yüz", "#2F7BF6")], TP())
fx("warpomatic", "Bükülerek Erime", "WarpoMatic", c, "pixel", "Akışkan bir bükülmeyle eriyerek kaybolur.", ["Geçiş", "Akışkan"], [PCT("prog", "İlerleme", 50), J("amount", "Bükülme", 0, 200, 50, 0.5, 0.2), J("scale", "Ölçek", 10, 1000, 100, 1, 0.5)], TP())
fx("gradwipe", "Geçişli Silme", "Gradient Wipe", c, "pixel", "Katmanın kendi parlaklığına (ya da bulut desenine) göre silinir.", ["Geçiş"], [PCT("prog", "İlerleme", 50), J("soft", "Yumuşaklık", 0, 100, 20, 0.5, 0.2), CH("src", "Sıra", ["Koyudan açığa", "Açıktan koyuya", "Bulut deseni"])], TP())
fx("inkwipe", "Mürekkep Yayılması", "Ink Spread", c, "pixel", "Suya damlayan mürekkep gibi yayılarak açılır.", ["Geçiş", "Akışkan", "Sanat"], [PCT("prog", "İlerleme", 50), XY("center", "Merkez", 0, 0), J("rough", "Pürüz", 0, 100, 40, 0.5, 0.2), J("scale", "Ölçek", 10, 1000, 80, 1, 0.5)], [P("GR", "Mürekkeple gel", keys={"prog": [[0, 0], [1, 100]]})])

# ---------- Zaman ----------
c = TIM
fx("widetime", "Geniş Zaman", "Wide Time", c, "echo", "Önceki ve sonraki anları birlikte gösterir (uzun pozlama).", ["Zaman", "İz"], [J("fwd", "İleri kare", 0, 20, 3, 1, 0.1), J("back", "Geri kare", 0, 20, 3, 1, 0.1)], info="Hareketli katmanlarda görünür.")
fx("pixelmb", "Piksel Hareket Bulanıklığı", "Pixel Motion Blur", c, "special", "Katmanın içindeki hareketi de (video, efekt) bulanıklaştırır.", ["Zaman", "Bulanık", "Hız"], [J("samples", "Örnek", 2, 32, 8, 1, 0.1), PCT("shutter", "Deklanşör", 50, 0, 100)], heavy=True)
fx("timedisplace", "Zaman Kayması", "Time Displacement", c, "special", "Her satırı biraz farklı zamandan gösterir (slit-scan).", ["Zaman", "Glitch", "Sanat"], [J("max", "En çok (sn)", 0, 5, 0.5, 0.01, 0.01), CH("src", "Göre", ["Yukarıdan aşağı", "Soldan sağa", "Merkezden"])], heavy=True)
