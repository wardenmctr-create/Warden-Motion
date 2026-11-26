# Warden Motion 1000 — mevcut efekt güncellemeleri ve 801–802

**Numara kararı:** 801 Savrulan Glitch ve 802 Yönlü Yırtılma yeni efekt olarak kalır. Önce ayrı düşünülen Toz Dağılması, zaten bulunan 361 Toz Olup Savrul'un güncellemesidir. 803 numarası yeni araştırma kataloğuna devredilir. 361'in kimliği ve eski projeleri korunur. Aramada “Toz Dağılması”, “Tozlaşma” ve “Külleşme” eşanlamlı/alt mod olarak görünür. Aşağıdaki değerler tasarım önerisidir; gerçek motorla test edilmelidir.

## 361. Toz Olup Savrul — büyük güncelleme

**Amaç:** Bir nesne veya çizgi film karakterinin seçili bölgesindeki görünür pikselleri toz, kül veya başka zerre görünümünde geçici ya da kalıcı olarak dağıtmak. Dışarı giden zerreler, kaynak alfası ve yeniden oluşma birbirinden ayrı kontrol edilir. Sürekli direnme/çözülme ve yeniden oluşma davranışı aynı efekt içindedir. Külleşme seçimi, hayalî sinematik sahnelerde daha yassı, düzensiz ve mat zerreler üretir; gerçekçi yaralanma görünümü amaçlanmaz.

### Mevcut kontroller (silme, yeniden adlandırma veya eski varsayılanları değiştirme yok)

| Ayar | Kontrol | Varsayılan | Aralık |
|---|---|---|---|
| İlerleme | K | %0 | %0–100 |
| Parça boyutu | K | 3 px | 0–500 px (hesapta en az 0.1 px) |
| Rüzgâr yönü | K | 0° | −360–360° |
| Savrulma | K | 200 px | 0–800 px |
| Türbülans | K | %60 | %0–100 |
| Kenar geçişi | K | %20 | %0–100 |
| Tohum | N | 1 | 0–999999 |
| Otomatik | A | Kapalı | Açık/Kapalı |
| Süre | K | 1 sn | 0–60 sn |

### Yeni davranış paneli

| Ayar | Kontrol | Önerilen varsayılan | Aralık | İşlev |
|---|---|---|---|---|
| Çalışma modu | S | Dağılma | Dağılma/Direnme/Toparlanma/Döngü | Dağılma ilerlemeye bağlı kalıcı görünüm; direnme sürekli yerel açılıp kapanma; toparlanma tersine birleşme; döngü ileri-geri aşama. |
| Zerre görünümü | S | Toz | Toz/Kül/Kum/Işık zerresi/Özel | Külleşme aynı motorun özel malzeme modudur. |
| Etkilenen bölge | S | Tüm nesne | Tüm nesne/Yönlü kenar/Maske | Direnmede önerilen yönlü kenar. |
| Etki yönü uzayı | S | Katman | Katman/Sahne | Nesne dönerken etkinin hangi eksene bağlı kalacağını seçer. |
| Etki genişliği | K | %20 | %0–100 | Seçilen kenardan içeri etki alanı. |
| Yoğunluk | K | %50 | %0–100 | Birim alan başına üretilen zerre sayısı. |
| Doğum sıklığı | K | 12/sn | 0–120/sn | Yeni grupların zaman aralığı. |
| Ömür | K | 0.8 sn | 0.05–10 sn | Bir zerre görünür kalma süresi. |
| Hız | K | 120 px/sn | 0–2000 px/sn | Zerrelerin yer değiştirme hızı. |
| Boyut değişkenliği | K | %60 | %0–100 | Ortalama boyut çevresindeki farklılık. |
| Şekil koruma | K | %80 | %0–100 | Direnmede ana silüetin korunacak miktarı. |
| Toparlanma hızı | K | 0.5 sn | 0.05–10 sn | Kaynak bölgenin yeniden oluşma süresi. |
| Toparlanma gecikmesi | K | 0.15 sn | 0–5 sn | Açılan alanın kapanmadan önce beklemesi. |
| Toparlanma biçimi | S | Kaynağı yeniden göster | Kaynağı yeniden göster/Zerreleri geri çağır/Karma | İlk modda eski zerreler giderken kaynak görünür olur; ikinci modda zerreler güncel yerel konumlarına döner. |
| Geri çağırma eğrisi | E | Yumuşak | Özel | Geri dönüş konum interpolasyonu. |
| Hareket sapması | K | 20° | 0–180° | Rüzgârın etrafındaki açısal rastgelelik. |
| Yerçekimi | K | 0 px/sn² | −1500–1500 | Görsel zerrelerin düşey ivmesi; kül modunda hafif düşme. |
| Hava direnci | K | %25 | %0–100 | Zerre hızının zamanla azalması. |
| Hareket bulanıklığı | K | %10 | %0–100 | Hareketli zerrelerin izi. |
| Opaklık eğrisi | E | Yumuşak solma | Özel | Ömür boyunca alfa. |
| Kaynak rengi karışımı | K | %100 | %0–100 | Orijinal piksel rengi ile malzeme renginin karışımı. |
| Malzeme rengi | R | #808080 | RGBA | Renk karışımı %100 altında kullanılır. |
| Renk rastgeleliği | K | %10 | %0–100 | Zerre başına kararlı renk farklılığı. |
| Dıştan içe alfa gradyanı | A | Kapalı | Açık/Kapalı | Gerçek alfa; renkli örtü değildir. |
| Gradyan mesafesi | K | 20 px | 0–1000 px | Kenardan içe geçiş. |
| Gradyan gücü | K | %50 | %0–100 | Kısmi silinme derinliği. |
| Gradyan eğrisi | E | Yumuşak | Özel | Alfa geçiş profili. |
| Maskeyi takip et | A | Açık | Açık/Kapalı | Kaynak her kare hareket ederken etki alanı güncellenir. |

### Külleşme alt paneli (Zerre görünümü = Kül)

| Ayar | Kontrol | Varsayılan | Aralık | İşlev |
|---|---|---|---|---|
| Pul biçimi | S | Düzensiz | Düzensiz/İnce yassı/Karma | Düz yuvarlak nokta yerine organik pul silüeti. |
| Pul yassılığı | K | %65 | %0–100 | Külün kâğıtsı/yassı görünümü. |
| Kenar kırçıllığı | K | %50 | %0–100 | Mat, düzensiz pul kenarı. |
| Parça dönüşü | K | 90°/sn | −720–720°/sn | Havada takla etkisi. |
| Kül tonu | R | #777A80 | RGBA | Varsayılan gri; değiştirilebilir. |
| Koyu-açık farkı | K | %30 | %0–100 | Pul renginin farklılığı. |
| Kaynak rengi katkısı | K | %20 | %0–100 | Külleşirken kaynak renginin korunması. |
| Parlaklık/ışıma | K | %0 | %0–200 | Varsayılan mat kül; isteğe bağlı stilize ışık. |
| Yükselme/düşme dengesi | K | −15 px/sn | −300–300 px/sn | Hafif süzülme, yön işareti açıkça belirtilir. |
| Ufalanma | K | %20 | %0–100 | Büyük pulların küçük zerrelere dönüşme oranı; rastgele tohumla belirlenir. |

**Önerilen hazır şablonlar:** İnce Toz (1–3 px, yüksek yoğunluk, kaynak rengi); Mat Kül (2–8 px, düzensiz pul, gri tonlar, düşük parlaklık); Direnen Silüet (yönlü kenar, şekil koruma %85, toparlanma 0.4 sn, alfa gradyanı); Yeniden Oluşma (geri çağırma); Sinematik Kül Dağılması (yönlü veya tüm nesne, yavaş savrulma). Bunlar ayrı efekt olarak sayılmaz.

**Motor davranışı:** Kaynak RGBA örneklerinden yerel koordinat ve tohumla belirlenmiş zerre kimliği üret. Doğum anındaki renk/şekil korunmalı; mevcut kaynak maskesi her karede güncellenmeli. Dağılma modunda görünürlük alanı ilerleme ile monoton değişebilir; direnmede sınırlı bir geçici alfa maskesi kullan ve açılan bölgeleri yeniden doldur. Toparlanma modunda ters maskeyle kaynak geri gelir; geri çağırma açıksa parçalar güncel katman dönüşümündeki doğum konumuna döner. Çerçeve atlama/geri sarma aynı zamandaki aynı sonucu üretmeli. Eski projelerde eski algoritma ve varsayılanlar korunmalı. WardenCB Öğret: tek bir yuvarlak PNG, arka planda mavi enerji ışığı; modlar ve kül görünümü sırayla denenir. Lite: zerre bütçesi, kenar örneklemesi ve önizleme çözünürlüğü düşürülebilir, dışa aktarım kaynak parametreleriyle hesaplanır.

## 801. Savrulan Glitch — yeni

**İşlev:** Nesneden kare/dikdörtgen görüntü blokları, seçilen yöne dijital rüzgârla taşınıyor gibi görünür. Kaynak görüntü dokusu blok içinde kalır. Renk ayrışması isteğe bağlıdır. #155 sinyal bozulması, #462 veri bozulması ve #361 organik zerrelerden ayrılır; yönlü, piksel kaynaklı blok akışı ve sıçrama davranışı ana işlevidir.

| Ayar | Tip | Varsayılan | Aralık / seçenek |
|---|---|---|---|
| Yön | K | 0° | 0–360° |
| Yön uzayı | S | Sahne | Sahne/Katman |
| Hız | K | 200 px/sn | 0–3000 |
| Blok boyutu | K | 12 px | 1–500 |
| Boyut rastgeleliği | K | %40 | 0–100 |
| Yoğunluk | K | %40 | 0–100 |
| Doğum sıklığı | K | 12/sn | 0–120 |
| Ömür | K | 0.4 sn | 0.02–10 |
| Azami uzaklık | K | 200 px | 0–3000 |
| Savrulma biçimi | S | Işınlanma | Işınlanma/Kayma/Karma |
| Işınlanma sıklığı | K | 15/sn | 0–120 |
| Işınlanma adımı | K | 20 px | 0–500 |
| Kayma ivmesi | K | 0 px/sn² | −3000–3000 |
| Karma kayma oranı | K | %50 | 0–100 |
| Hareket sapması | K | 12° | 0–180 |
| Dönüş | K | 0°/sn | −720–720 |
| Hareket bulanıklığı | K | %0 | 0–100 |
| Etki bölgesi | S | Yönlü kenar | Tüm/Yönlü kenar/Maske |
| Etki genişliği | K | %30 | 0–100 |
| Kaynak şekli koruma | K | %80 | 0–100 |
| Kaynakta kopuk alfa | A | Açık | Açık/Kapalı |
| Kaynak toparlanması | K | 0.25 sn | 0–5 |
| Parça solma eğrisi | E | Yumuşak | Özel |
| RGB dağılması | A | Kapalı | Açık/Kapalı |
| RGB kanal uzaklığı | K | 4 px | 0–200 |
| RGB yönü | K | 0° | 0–360 |
| Parazit | K | %0 | 0–100 |
| Blok oranı | K | 1 | 0.1–10 |
| Tohum | N | 1 | 0–999999 |

**Uygulama:** Yoğunluk birim alandaki blok sayısını, boyut blok geometrisini, sıklık doğum zamanını belirler; birbirine kilitlenmez. Işınlanma konumu kesikli örnekler, kayma konumu sürekli interpolasyonla hesaplanır. Karma mod her blok için tohumla kararlı seçim yapar. Şekli koruma ile görünür kaynağı sınırlı geçici maske üzerinden güncelle. Renk ayrışması sadece bloklarda veya isteğe bağlı kaynak etki bandında uygulanır. Şablonlar: İnce glitch tozu, büyük blok sıçraması, akıcı RGB rüzgârı. Lite: blok sayısı ve RGB örnekleme azaltılır. Öğret: yoğunluğu artırıp boyutu küçültme ve tersinin farkını göster; ışınlanma ve kayma karşılaştırması.

## 802. Yönlü Yırtılma — yeni

**İşlev:** Seçilen taraftaki alfa silüetinde hareketli, dar veya geniş, düzenli/düzensiz üçgensi girintiler oluşturur. İstenirse dıştan içe alfa geçişi eklenir. Sadece yok olma değil, sürekli görsel direnme ve toparlanma da mümkün. #171 Yırt bir çizgi boyunca iki parçayı ayırır; bu tek yönlü, canlı kenar girintileri oluşturur.

| Ayar | Tip | Varsayılan | Aralık / seçenek |
|---|---|---|---|
| Yön | K | 180° | 0–360° |
| Yön uzayı | S | Sahne | Sahne/Katman |
| Yoğunluk | K | %40 | 0–100 |
| Sıklık | K | 6/sn | 0–60 |
| Kalınlık | K | 8 px | 0.5–500 |
| Uzunluk | K | 30 px | 0–1000 |
| Uzunluk değişkenliği | K | %50 | 0–100 |
| Düzenlilik | K | %30 | 0–100 |
| Uç sapması | K | 10° | 0–90 |
| Hareket hızı | K | 1.5 Hz | 0–20 |
| Hareket miktarı | K | 4 px | 0–200 |
| Kenar yumuşaklığı | K | 0.5 px | 0–40 |
| Mod | S | Direnme | Direnme/Parçalanma/Toparlanma |
| İlerleme | K | %0 | 0–100 |
| Şekli koru | K | %85 | 0–100 |
| Yenilenme/kapanma | K | 0.25 sn | 0.02–5 |
| Kenar dalgalanması | K | 2 px | 0–100 |
| Alfa gradyanı | A | Kapalı | Açık/Kapalı |
| Gradyan kaynağı | S | Yırtıklar | Yırtıklar/Yönlü kenar/Her ikisi |
| Gradyan mesafesi | K | 20 px | 0–1000 |
| Gradyan gücü | K | %50 | 0–100 |
| Gradyan eğrisi | E | Yumuşak | Özel |
| Tohum | N | 1 | 0–999999 |

**Uygulama:** Kaynak silüetinin seçilen yöne bakan sınır örneklerinden üçgenimsi maske şekilleri kur, bunları zamanla kararlı biçimde hareket ettir. Direnmede ilerlemeyi birikimli kullanma; maskeler sürekli kapanıp açılmalı ve silüet korunmalı. Parçalanma modunda ilerleme kontrollü genişleme, toparlanmada ters davranış. Gerçek alfa maskeleme uygula; arka katmanlar görünür kalsın. Sahne uzayı seçiliyse katman dönse de yön sahneye göre sabit kalsın. Şablonlar: Enerji akımına direnme, rüzgârlı kenar, açılı yırtık, toparlanma. Lite: kenar örnekleme bütçesini düşür. Öğret: hareketli çizgi film PNG'si üzerinde gradyan açık/kapalı ve üç mod göster.

## 203. Işın — görsel lazer güncellemesi

Eski iki uç, baş/son kalınlığı, çekirdek/dış renk, yumuşaklık, uzunluk, yalnız ışın kontrolleri korunur. Yeni biçimler, yalnız ekrandaki kurgusal ışık animasyonu içindir.

| Yeni ayar | Tip | Varsayılan | Aralık |
|---|---|---|---|
| Biçim | S | Düz | Düz/Anime düzensiz/Yıldırım dallı |
| Fiziksel titreme | K | 0 px | 0–100 px |
| Titreme hızı | K | 8 Hz | 0–30 Hz |
| Işık titreşimi | K | %5 | 0–100 |
| Işık titreşimi hızı | K | 3 Hz | 0–30 Hz |
| İç enerji çizgileri | A | Kapalı | Açık/Kapalı |
| İç çizgi hızı | K | 800 px/sn | 0–5000 |
| İç çizgi yoğunluğu | K | %35 | 0–100 |
| İç çizgi boyu | K | 40 px | 1–500 |
| İç çizgi eni | K | 1 px | 0.2–100 |
| İç çizgi rengi | R | #FFFFFF | RGBA |
| Düzensizlik | K | %20 | 0–100 |
| Dallanma | K | %25 | 0–100 |
| Dal boyu | K | 60 px | 0–1000 |
| Dal eni | K | %20 | 0–100 |
| Hale | K | %100 | 0–500 |
| Hale genişliği | K | 12 px | 0–500 |
| Tohum | N | 1 | 0–999999 |

Işık parlaklığının hafif, yumuşak dalgalanması varsayılan olsun; eski projelerde titreşim kapalı. İç enerji çizgileri ışının sınır maskesini aşmaz. Dallı mod #197 ortak görsel dal üreticisini kullanabilir. Hızlı veya yüksek kontrastlı titreşimlerde önizleme uyarısı ve yumuşak sınırlama sun; bu ayarları varsayılan yapma.

## Araştırmadan gelen diğer güncellemeler (yeni efekt sayılmaz)

| Mevcut ID | Güncelleme | Önerilen kontroller ve fark |
|---|---|---|
| 195 Yanardöner | İnce film optik girişimi | Mod: eski/ince film; kalınlık haritası L; ortalama 400 nm (50–1500); değişim 150 nm (0–1000); karışım %60. Sabun/yağ filmi rengini ayrı efekt sayma. |
| 196 Mercek Parlaması | Optik halka yansımaları | Halka sayısı 4 (1–16); odak 50 mm (10–200); saçılma %40; renk, kaynak konumu ve halkanın ışık kaynağına bağlı yerleşimi. Ayrı mercek halkası efekti açma. |
| 108 Mercek Bulanıklığı | Diyafram şekli ve bokeh | 3–16 yaprak; yuvarlaklık %0–100; dönüş 0–360°; bokeh parlaklık tavanı; anamorfik oran 0.1–4. Eski yuvarlak görünüm korunur. |
| 173 Yer Değiştirme Haritası | UV/ST haritası modu | Girdi RG koordinatları veya eski ofset modu; koordinat normalizasyonu; kenar sarma/kırpma; örnekleme. 490 UV eşleme geometri malzemesi olarak kalır. |
| 289 Kenar Daralt/Genişlet | Gerçek alfa morfolojisi | Açma/kapama (küçük çıkıntı veya küçük boşluk), kernel şekli ve boyutu, alfa eşiği; tüm kapalı delikleri ayrı alan sınırıyla dolduran yeni 803'ten farklı. |
| 259 Ez ve Esnet | Alan koruma | %0–100 alan telafisi, eksen ve telafi gecikmesi. Ayrı efekt olarak sayma. |
| 665 Hücresel Otomat | Tek boyutlu zaman şeridi | 1B/2B modu; 0–255 kural; başlangıç şekli; adım sayısı. |
| 622 Kare İçinde Zaman Haritası | Hareketli geometrik cephe | Harita kaynağı olarak dış katman veya yönlü hareketli cephe; gecikme süresi, cephe hızı ve merkez. |
| 161 Köşe Sabitle | Hassas yüzey eşleme | Dört noktanın kaynak ve hedef tuvalde ayrı seçimi, piksel ızgarasına kilit ve düzgün örnekleme. |
| 76 Dokulandır / 431 Kesim Altlığı | Ortak materyal kitaplığı | Kâğıt/karton/kumaş/metal/özel doku, ölçek, açı ve UV sabitleme ortak veri. Kül görünümü ise 361 zerre malzemesidir. |
| 336 Gürültü Azalt | Ortak denoise altyapısı | 555, 570, 571 gibi farklı işlevler için ortak çekirdek; algoritma aynıysa ayrı kimlik yerine mod veya eski kimlik alias'ı. |
| 197 Şimşek | Ortak dal çizimi motoru | 203 dallı ışınla görsel geometri üretimini paylaş; eski şimşek kullanıcı panelini koru. |

**Birleştirme ilkesi:** Özellik farklılığı yalnız renk, doku, şekil şablonu veya aynı algoritmada yeni parametreyse ayrı efekt sayılmaz. Eski projelerde ID'ler değişmez; alias veya sürüm geçişiyle aynı motor çağrılabilir. Yukarıdaki 361, 203 ve 12 diğer güncelleme toplamda 14 mevcut efekt/güncelleme satırıdır (76/431 ve 336'nın ilişkili ID'leri ortak altyapıdır). 801 ve 802 dışında yeni numara üretmez.
