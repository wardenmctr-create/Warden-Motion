# Warden Motion 1000 — son 198 efekt adayı ve güncellemeler

## Sayım ve durum
- Önceki geliştirme hedefi: 800.
- 801 Savrulan Glitch ve 802 Yönlü Yırtılma: iki yeni özgün efekt.
- Toz Dağılması ayrı 803 değildir. 361 Toz Olup Savrul güncellenir; Külleşme, Direnme, Toparlanma, Döngü ve görsel alfa kontrolü aynı efekt içinde kalır.
- 803–1000: 198 yeni tasarım adayı, 9 kategori × 22. Toplam hedef = 800 + 2 + 198 = 1000.
- Araştırma dizini: 70 erişilebilen kaynak sitesi / dokümantasyon girişi. Bir kısmı teknik belge veya filtre listesi, bir kısmı genel ürün/kütüphane taramasıdır. 70 sitenin her alt sayfası veya her eklentisi incelendi anlamına gelmez. Her adayın bölümünde dayanak ailesi belirtilir. Kaynaklardaki hazır efektlerin birebir kopyası değil, tekniklerden türetilmiş özgün tasarım adaylarıdır.
- Toplam 851 yeni özel kontrol satırı. Ayrıca 801, 802, 361, 203 ve mevcut efekt güncellemeleri ayrı dosyada yer alır.
- Önceki 430 rehberi, 431–462 planı, 463–550 rehberi ve 551–800 aday kataloğuna göre ad ve işlev karşılaştırması yapıldı. Tam eşleşen ad yok; ancak aynı motor/işlevin farklı parametreleri olabilecek teknik yakınlıklar hâlâ olabilir. Önceki paketin 27 birleştirme adayı da çözülmeden duruyor. Bu nedenle 1000, kesinlikle farklı ve çalışır efekt sayısı değil, nominal tasarım hedefidir. Birleştirme gerçekleşirse boşalan sayıya gerçekten farklı aday eklenmelidir.
- Kaynak kodu ve cihaz benchmark'ı incelenmedi. Dosya kod değil; geliştirme şartnamesi ve seçim kataloğudur. Verilen aralıklar test/optimizasyon gerektirir. 3B modelleme, harita verisi, ses analizi ve tanılama görselleri de katalogda var; saf 2B görsel filtre sayısına bunların tamamı eklenmemelidir. 

## Öncelikli geliştirme
İlk olarak günlük animasyonda faydalı ve nispeten düşük bağımlılıklı efektleri uygula: iç boşluk tamamlama, ince çizgi tamamlama, renk paleti çıkarımı, kenar yönünde renk uzatma, çizgi ağırlığı, karton kesiti, kâğıt lifleri, çok hedefli ağırlık merkezi, eksen bazında ebeveynlik, iki noktalı esnetme, adım döngüsü, iris kilidi, etiket çakışma önleme, harf iskeleti, katmanların sahne derinliğine göre sıralanması, tempo analizi, ters yankı, nesne arkasından geçiş, döşeme ek yeri onarımı, kadraj güvenli alanı. Gerçek 3B, otomatik analiz ve ses ayrıştırma ayrı motorlar gerektirir; bunları daha sonra test ederek ekle. Öncelik sırası öneridir.

## Ortak geliştirme kuralları
1. Kaynak medya tahribatsız; RGBA doğru premultiplied/straight alfa işleme; gerçek alfa ile renk örtüsünü karıştırma.
2. Arayüzde Türkçe açıklama, değer birimi ve sıfırlama; kontrol tipleri, aralıklar ve varsayılanlar bölüm tablolarında. Zamanla değişebilir sayısal değerler anahtar kareli; enum/anahtar adımlı; kaynak/analiz seçimleri sabit. Eksik katman, rig, model veya dosya olduğunda sessiz yanlış sonuç yerine açıklayıcı uyarı ve etkisiz çıktı.
3. Rastgele animasyonlar sabit tohum + zaman + parça kimliği ile deterministik; geri sarma ve dışa aktarma aynı zaman noktasında eş sonuç. Kaynak değişikliklerinde önbellek geçersizleşir. Döngü ve anahtar kareler ileri-geri test edilir.
4. Lite yalnız önizleme örneklemesini, geçici render çözünürlüğünü, parçacık ve örnek bütçesini düşürür. Dışa aktarımda tam kullanıcı değerleri korunur. Düşük RAM'de arabellek boyutunu sınırlayıp ara çıktıları temizle; kareler arası filtrelerde gerekli zaman penceresini yönet.
5. 3B efektlerde mesh/UV/normal/derinlik gereksinimini açık göster. Veri görselleştirmelerinde kullanıcıdan sağlanan CSV/JSON/GeoJSON/DEM doğrulanmalı; kaynak ve tarih belirtilmeli. Sonuç tahminiyse açıkça işaretle. Yerel/izinli ses modeli kullan; ayrıştırma kusursuz değildir. Kaynak lisansına uy, lisanssız eklenti kodu veya materyal kopyalama.
6. WardenCB Öğret: her efekt için gereken medya ve katmanları içeren küçük örnek proje, önce varsayılan sonra iki zıt ayar denemesi, önce/sonra karşılaştırması. Kullanıcı değerlerini değiştirebilsin; öğretim projesi ana projeyi bozmasın.
7. Varsayılan, min, max; şeffaf PNG; hareketli kaynak; farklı çözünürlük ve FPS; anahtar kare; ileri/geri sarma; Lite/tam kalite; dışa aktarma testleri. Yüksek frekanslı ışık efektlerinde düşük kontrastlı güvenli varsayılan ve ışık hassasiyeti uyarısı.
8. Mevcut efektlerle aynı sonucu veren önerilerde ayrı ID yerine yeni mod veya hazır şablon. Eski kayıtları kırma; 361 ve 203 gibi güncellemelerde sürüm uyumluluğu şart. 

## ZIP içeriği
- 9 bölüm (her biri 22 efekt): 803–1000.
- 00-OKU.md, 00-Efekt-Indeksi.md, 00-Kaynaklar.md.
- Mevcut-Efekt-Guncellemeleri-801-802.md: 361, külleşme, 801, 802, 203 ve diğer güncellemeler.
- Tam-Katalog.md: bölüm dosyalarının birleşik sürümü. Telefonda küçük kategori dosyalarını açmak daha kolay olabilir.

---

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

---

# Renk, kompozit ve piksel analizi (803–824)

**Araştırma dayanakları:** [07](https://docs.opencv.org/3.4.18/d2/d96/tutorial_py_table_of_contents_imgproc.html) OpenCV, [09](https://docs.gimp.org/3.0/en/filters.html) GIMP, [10](https://gmic.eu/reference/) G’MIC, [16](https://scikit-image.org/docs/stable/api/api.html) scikit-image, [17](https://www.mathworks.com/help/images/) MathWorks, [18](https://imagej.net/plugins/) ImageJ, [42](https://pillow.readthedocs.io/en/stable/reference/ImageFilter.html) Pillow, [67](https://docs.nvidia.com/cuda/npp/) NVIDIA NPP.

Ayarlar uygulama için önerilen başlangıç değerleridir; mevcut kaynak koduyla doğrulanmış değerler değildir. AK = anahtar kare. Adımlı* = yalnız çalışma sırasında değişmesi güvenli olan seçim, anahtar ve tam sayılar; topoloji, örnek bütçesi, analiz gibi ayarlar önbelleği geçersiz kılmalı veya animasyona kapalı kalmalıdır.

## 803. İç Boşluk Tamamlama

**İşlev ve ayrım:** Bir PNG silüetindeki kapalı alfa deliklerini doldurur; açık dış çevre ve istenen büyük delikler korunur. 289 daralt/genişlet tüm kenarı değiştirir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| En büyük delik alanı | Tam sayı | 1000 px² | 1–100000 | Adımlı* |
| Dolgu alfa | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |
| Dolgu rengi | Seçim | En yakın kenar | En yakın kenar/Tek renk | Adımlı* |
| Tek renk | Renk seçici | #FFFFFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 804. Dışbükey Silüet Zarfı

**İşlev ve ayrım:** Nesnenin etrafında en küçük dışbükey örtüyü üretir; girintileri doldurur, konturu ölçeklemez. Maske veya stilize düz şekil olarak kullanılabilir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Gruplama | Seçim | Birleşik | Birleşik/Bileşen başına | Adımlı* |
| Yumuşaklık | Kaydırmalı cetvel + sayısal giriş | 0 px | 0–100 | Evet |
| Çıktı | Seçim | Maske | Maske/Renkli yüzey | Adımlı* |
| Dolgu | Renk seçici | #328CFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 805. Mesafeye Göre Renk Taşıma

**İşlev ve ayrım:** İki bağlı renk bölgesi arasındaki gerçek iç geodezik uzaklıkları kullanarak renk yayar; normal doğrusal gradyandan farklıdır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Başlangıç maskesi | Katman seçici | Yok | Katman | — |
| Bitiş maskesi | Katman seçici | Yok | Katman | — |
| Renk eğrisi | Eğri düzenleyici | Doğrusal | Özel | — |
| Başlangıç | Renk seçici | #328CFF | RGBA / HEX | Evet |
| Bitiş | Renk seçici | #FFFFFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 806. İnce Çizgi Tamamlama

**İşlev ve ayrım:** Kopuk çizgi uçlarını yön ve mesafeye göre eşleştirip aralarını köprüler, çizimi yeniden boyamaz. Harita sınır çizgileri ve taranmış çizimler için.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Boşluk sınırı | Kaydırmalı cetvel + sayısal giriş | 8 px | 1–100 | Evet |
| Açı toleransı | Kaydırmalı cetvel + sayısal giriş | 25° | 0–90 | Evet |
| Köprü kalınlığı | Kaydırmalı cetvel + sayısal giriş | 2 px | 0.5–50 | Evet |
| Önizlemede işaretle | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 807. Çizgi Kavşağı Haritası

**İşlev ve ayrım:** Çizgi iskeletindeki uç ve kavşakları ayrı renklerle gösterir. Rig veya çizgi ağı düzenlemesinde bağlantı kontrolü sağlar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Algılama eşiği | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| Uç rengi | Renk seçici | #FFDD66 | RGBA / HEX | Evet |
| Kavşak rengi | Renk seçici | #328CFF | RGBA / HEX | Evet |
| İşaret çapı | Kaydırmalı cetvel + sayısal giriş | 6 px | 1–50 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 808. Yerel Eğrilik Haritası

**İşlev ve ayrım:** Silüetin düz, içbükey ve dışbükey bölgelerini eğrilik işaretine göre renklendirir; kenar yönü haritası değil, yönün değişimini ölçer.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Ölçüm yarıçapı | Kaydırmalı cetvel + sayısal giriş | 8 px | 1–128 | Evet |
| İçbükey | Renk seçici | #FF9944 | RGBA / HEX | Evet |
| Dışbükey | Renk seçici | #328CFF | RGBA / HEX | Evet |
| Nötr eşik | Kaydırmalı cetvel + sayısal giriş | %10 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 809. Görsel Tekrar Tespiti

**İşlev ve ayrım:** Aynı veya benzer motifleri görüntü içinde bulur, kutular ve benzerlik değerleriyle işaretler; 499 nokta takibi zaman içinde tek noktayı takip eder.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Motif örneği | Katman seçici | Yok | Katman | — |
| Benzerlik | Kaydırmalı cetvel + sayısal giriş | %85 | 0–100 | Evet |
| Azami eşleşme | Tam sayı | 30 | 1–200 | Adımlı* |
| Ölçek değişimine izin ver | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 810. Yerel Aydınlatma Ayırımı

**İşlev ve ayrım:** Görüntüyü yavaş değişen aydınlatma ve yansıtım/renk bileşenine tahminen ayırır. Frekans ayırma gibi sadece yüksek-alçak bant değil, çarpımsal ışık modeli kullanır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Işık ölçeği | Kaydırmalı cetvel + sayısal giriş | 64 px | 4–512 | Evet |
| Kenar koruma | Kaydırmalı cetvel + sayısal giriş | %75 | 0–100 | Evet |
| Çıktı | Seçim | Yansıtım | Yansıtım/Aydınlatma/Yeniden birleştir | Adımlı* |
| Güç | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 811. Renk Paleti Çıkarımı

**İşlev ve ayrım:** Görüntüdeki baskın renkleri analiz edip renk oranlarına göre palet kartı üretir; 15 Palet Haritası mevcut palete eşler.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Renk sayısı | Tam sayı | 6 | 2–32 | Adımlı* |
| Sıralama | Seçim | Alan | Alan/Ton/Parlaklık | Adımlı* |
| Şeffafı dışla | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Yüzde etiketi | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 812. Renk Geçiş Yolunu Ölç

**İşlev ve ayrım:** İki seçili nokta arasındaki görüntü renklerini örnekleyip düzenlenebilir gradyana ve görsel şeride dönüştürür.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Başlangıç | X/Y noktası | 25,50 | Tuval | Evet |
| Bitiş | X/Y noktası | 75,50 | Tuval | Evet |
| Durak sayısı | Tam sayı | 8 | 2–64 | Adımlı* |
| Örnek genişliği | Kaydırmalı cetvel + sayısal giriş | 3 px | 1–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 813. Kenar Yönünde Renk Uzatma

**İşlev ve ayrım:** Dolu piksel çizgilerini kendi yönlerinde genişletir; 591 yalnız şeffaf piksellerde renk verisi uzatırken bu görünür yeni renk dokusu üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Uzama | Kaydırmalı cetvel + sayısal giriş | 20 px | 0–500 | Evet |
| Yön yumuşatma | Kaydırmalı cetvel + sayısal giriş | 8 px | 1–100 | Evet |
| Alfayı genişlet | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |
| Karışım | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 814. Çoklu Pozisyon Medyan Arka Plan

**İşlev ve ayrım:** Bir video boyunca geçici hareketli nesnelerden arındırılmış statik arka plan tahmini oluşturur. 618 tek kare çevresindeki zamansal medyandan farklı olarak seçili uzun aralığı tek plate'e indirger.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Analiz süresi | Kaydırmalı cetvel + sayısal giriş | 5 sn | 0.2–60 | Evet |
| Örnek kare | Tam sayı | 31 | 3–151 | Adımlı* |
| Hareket eşiği | Kaydırmalı cetvel + sayısal giriş | %15 | 0–100 | Evet |
| Sonucu önbellekle | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 815. Kare Eşleşme Kalite Haritası

**İşlev ve ayrım:** İki görüntü arasında yapısal benzerliğin düşük olduğu yerleri gösterir; 600 düz renk farkından farklı olarak yerel kontrast ve yapı benzerliği ölçer.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Referans | Katman seçici | Yok | Katman | — |
| Pencere | Kaydırmalı cetvel + sayısal giriş | 11 px | 3–99 | Evet |
| Hata eşiği | Kaydırmalı cetvel + sayısal giriş | %20 | 0–100 | Evet |
| Çıktı | Seçim | Isı haritası | Isı haritası/Sayı/İkisi | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 816. Doygunluk–Parlaklık Düzlemi

**İşlev ve ayrım:** Piksel dağılımını doygunluk ve parlaklık koordinatlarında görselleştirir; vektör ölçer renk tonu-kroma dağılımını gösterir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Bölme | Tam sayı | 64 | 16–256 | Adımlı* |
| Ölçek | Seçim | Log | Doğrusal/Log | Adımlı* |
| Kaynak renkleri | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Grafik opaklığı | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 817. Renk Uzayı Dilimleyici

**İşlev ve ayrım:** Seçilen 3B renk hacminin içinden düzlemsel dilimi görselleştirir; bir maskeden ziyade renk uzayını inceleyen eğitim aracıdır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Uzay | Seçim | Lab | Lab/HSV/RGB | Adımlı* |
| Eksen | Seçim | L | İlk/İkinci/Üçüncü | Adımlı* |
| Kesit | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| Kaynak noktalarını göster | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 818. Kenar Eğriliğine Göre Mat

**İşlev ve ayrım:** Dışbükey ve içbükey bölgelerden seçici maske çıkarır; 585 yönü seçerken bu yerel dönüşü seçer, iç köşelerde doku gibi uygulanabilir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Seçim | Seçim | İçbükey | İçbükey/Dışbükey/Her ikisi | Adımlı* |
| Ölçüm ölçeği | Kaydırmalı cetvel + sayısal giriş | 12 px | 1–128 | Evet |
| Eşik | Kaydırmalı cetvel + sayısal giriş | %25 | 0–100 | Evet |
| Mat yumuşaklığı | Kaydırmalı cetvel + sayısal giriş | 5 px | 0–80 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 819. Siluet Alanı Ölçeri

**İşlev ve ayrım:** Alfa alanını zaman boyunca ölçüp doluluk, merkez ve çevre oranını ayrı görsel sayaç olarak gösterir; harita alan karşılaştırması değildir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Alfa eşiği | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| Ölçü | Seçim | Alan | Alan/Çevre/Merkez | Adımlı* |
| İz çizgisi | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |
| Etiket | Renk seçici | #FFFFFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 820. Hareket Güven Haritası

**İşlev ve ayrım:** Optik akışın güvenilir ve belirsiz alanlarını maskeye çevirir; hareket yönü matı yerine takip güvenini gösterir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| İleri-geri hata | Kaydırmalı cetvel + sayısal giriş | 2 px | 0.1–20 | Evet |
| Doku eşiği | Kaydırmalı cetvel + sayısal giriş | %15 | 0–100 | Evet |
| Çıktı | Seçim | Güven | Güven/Hata | Adımlı* |
| Yumuşatma | Kaydırmalı cetvel + sayısal giriş | 3 px | 0–30 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 821. Işık Alanı Düzeltmesi

**İşlev ve ayrım:** Bir referans karedeki değişken aydınlatmanın başka kareye göre alanını tahmin edip video boyunca yavaş değişen ışığı dengeler; sensör düz alan kalibrasyonu değil sahne ışığı.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Referans | Katman seçici | Yok | Katman | — |
| Alan ölçeği | Kaydırmalı cetvel + sayısal giriş | 100 px | 10–1000 | Evet |
| Zamansal yumuşatma | Kaydırmalı cetvel + sayısal giriş | 0.4 sn | 0–5 | Evet |
| Güç | Kaydırmalı cetvel + sayısal giriş | %70 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 822. Kanal Başına Alfa Üretimi

**İşlev ve ayrım:** RGB kanallarının ayrı mat olarak çıkarılmasını ve üç farklı katmana uygulanmasını sağlar; 337 aritmetik yaparken burada üç eşzamanlı bağlı maske üretilir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Çıktı | Seçim | Üç mat | Üç mat/Tek kanal | Adımlı* |
| Normalizasyon | Seçim | Yok | Yok/Kanal başına | Adımlı* |
| Kenar eşiği | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| Ters çevir | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 823. Kalınlık Haritası

**İşlev ve ayrım:** Silüet içindeki her bölgenin yerel kalınlığını ölçer; alfa mesafe haritasından farklı olarak medial eksendeki genişliği tüm ilgili bölgeye taşır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| En büyük ölçüm | Kaydırmalı cetvel + sayısal giriş | 256 px | 1–1024 | Evet |
| Çıktı | Seçim | Gri | Gri/Renkli | Adımlı* |
| Detay | Kaydırmalı cetvel + sayısal giriş | 75% | 0–100 | Evet |
| Silueti koru | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 824. Yüzey Pürüz Ölçeri

**İşlev ve ayrım:** Görüntünün yerel dokusal yön tutarlılığını ve pürüzünü ölçer; doku benzerliği haritası bir referansla eşlerken bu referanssız yüzey ölçümüdür.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Pencere | Kaydırmalı cetvel + sayısal giriş | 21 px | 3–101 | Evet |
| Ölçü | Seçim | Pürüz | Pürüz/Yön tutarlılığı | Adımlı* |
| Kontrast | Kaydırmalı cetvel + sayısal giriş | %70 | 0–100 | Evet |
| İşaret | Renk seçici | #FFCC55 | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

# Optik, çevre ve stilize VFX (825–846)

**Araştırma dayanakları:** [01](https://helpx.adobe.com/after-effects/desktop/apply-effects-and-animation-presets/effects-and-animation-presets/effect-list.html) Adobe After Effects, [02](https://borisfx.com/documentation/sapphire/ae/summary-index/) Boris FX, [03](https://support.apple.com/tr-tr/guide/motion/welcome/mac) Apple Motion, [04](https://www.blackmagicdesign.com/products/davinciresolve/fusion) Blackmagic Design, [06](https://docs.derivative.ca/TOP) TouchDesigner, [12](https://www.sidefx.com/docs/houdini/nodes/) Houdini, [13](https://docs.unity3d.com/Packages/com.unity.visualeffectgraph@17.0/manual/Operators.html) Unity, [14](https://docs.godotengine.org/en/stable/tutorials/shaders/index.html) Godot, [38](https://www.maxon.net/en/red-giant) Maxon, [43](https://thebookofshaders.com/) The Book of Shaders, [44](https://www.ronja-tutorials.com/) Ronja’s Tutorials, [45](https://godotshaders.com/) Godot Shaders, [50](https://pixijs.com/8.x/guides/components/filters) PixiJS, [63](https://www.videocopilot.net/tutorials/) Video Copilot, [65](https://manual.notch.one/2026.2/en/) Notch, [68](https://webglfundamentals.org/) WebGL Fundamentals.

Ayarlar uygulama için önerilen başlangıç değerleridir; mevcut kaynak koduyla doğrulanmış değerler değildir. AK = anahtar kare. Adımlı* = yalnız çalışma sırasında değişmesi güvenli olan seçim, anahtar ve tam sayılar; topoloji, örnek bütçesi, analiz gibi ayarlar önbelleği geçersiz kılmalı veya animasyona kapalı kalmalıdır.

## 825. Hacimli Işık Perdesi

**İşlev ve ayrım:** Bir yüzey boyunca dalgalanan yarı şeffaf enerji perdesi oluşturur; tek ışın veya sis değildir. Sahneye bağlı perdenin kıvrımları ve arka plan kırılması vardır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Merkez | X/Y noktası | 50,50 | Tuval | Evet |
| Genişlik | Kaydırmalı cetvel + sayısal giriş | 200 px | 1–2000 | Evet |
| Dalga | Kaydırmalı cetvel + sayısal giriş | 25 px | 0–300 | Evet |
| Akış | Kaydırmalı cetvel + sayısal giriş | 0.6 Hz | 0–10 | Evet |
| Renk | Renk seçici | #55CCFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 826. Işık Kırınım Deseni

**İşlev ve ayrım:** Açıklık/ızgara üzerinden geçen ışığın merkez ve yan maksimum desenini simüle eder; 609 mercek yıldız çizgilerinden farklı olarak spektral bant dizisi üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Açıklık | Seçim | Çift yarık | Tek yarık/Çift yarık/Izgara | Adımlı* |
| Aralık | Kaydırmalı cetvel + sayısal giriş | 25 px | 1–300 | Evet |
| Desen ölçeği | Kaydırmalı cetvel + sayısal giriş | 1 | 0.1–10 | Evet |
| Işık | Renk seçici | #FFFFFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 827. Odak İstifi Birleştirme

**İşlev ve ayrım:** Farklı odak mesafelerindeki eşlenmiş fotoğraflardan keskin bölgeleri seçerek tek görüntü oluşturur; pozlama birleştirme veya bulanık görüntü keskinleştirme değildir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Odak katmanları | Katman seçici | Yok | Çoklu katman | — |
| Odak pencere boyutu | Kaydırmalı cetvel + sayısal giriş | 15 px | 3–99 | Evet |
| Kenar geçişi | Kaydırmalı cetvel + sayısal giriş | 8 px | 0–100 | Evet |
| Otomatik hizala | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 828. Çift Kırılmalı Kristal

**İşlev ve ayrım:** İki farklı yönlü kırılan görüntüyü üst üste gösterir; RGB ayrıştırmak yerine her iki görüntü de tam renklidir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kristal açısı | Kaydırmalı cetvel + sayısal giriş | 35° | 0–360 | Evet |
| Ayrılma | Kaydırmalı cetvel + sayısal giriş | 12 px | 0–300 | Evet |
| İkinci görüntü | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| Kenar yumuşaklığı | Kaydırmalı cetvel + sayısal giriş | 2 px | 0–40 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 829. Yansıma Parlaklık Çizgisi

**İşlev ve ayrım:** Hareket eden dar speküler çizgiyi eğri yüzey normaline bağlı tutar. 81 Işık Süpürme'nin tek doğrultulu geçişinden farklı olarak normal haritasını kullanarak çizgiyi bükebilir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Normal haritası | Katman seçici | Yok | Katman | — |
| Işık açısı | Kaydırmalı cetvel + sayısal giriş | 30° | 0–360 | Evet |
| Parlak bant | Kaydırmalı cetvel + sayısal giriş | 0.15 | 0.01–1 | Evet |
| Renk | Renk seçici | #FFFFFF | RGBA / HEX | Evet |
| Yoğunluk | Kaydırmalı cetvel + sayısal giriş | %80 | 0–300 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 830. Çizgisel Yansıma Uzaması

**İşlev ve ayrım:** Işıklı noktaları yüzey pürüz yönüne göre uzatır, yalnız parlaklık değil normal/yön alanını dikkate alır; 111 ışık çizgilerinden farklı yüzey bağlantılıdır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Yön haritası | Katman seçici | Yok | Katman | — |
| Uzunluk | Kaydırmalı cetvel + sayısal giriş | 45 px | 0–500 | Evet |
| Parlaklık eşiği | Kaydırmalı cetvel + sayısal giriş | %70 | 0–100 | Evet |
| Karışım | Kaydırmalı cetvel + sayısal giriş | %80 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 831. Kenar Fresnel Işıması

**İşlev ve ayrım:** Normal ve kamera açısına bağlı kenar yansıması üretir; düz kontur gibi her kenarda aynı ışık görünmez.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Normal haritası | Katman seçici | Yok | Katman | — |
| Fresnel kuvveti | Kaydırmalı cetvel + sayısal giriş | 3 | 0.1–12 | Evet |
| Güç | Kaydırmalı cetvel + sayısal giriş | %80 | 0–300 | Evet |
| Renk | Renk seçici | #77BBFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 832. Sanal Yüzey Altı Işık

**İşlev ve ayrım:** Yarı şeffaf materyalin kenarından içeri yayılan yumuşak renkli ışığı tahmin eder. 486 Işık Sarma arka plandan dış kenara gelir, bu malzeme kalınlığına bağlı iç saçılmadır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kalınlık haritası | Katman seçici | Yok | Katman | — |
| Saçılma | Kaydırmalı cetvel + sayısal giriş | 16 px | 0–200 | Evet |
| İç renk | Renk seçici | #FFCFA0 | RGBA / HEX | Evet |
| Işık açısı | Kaydırmalı cetvel + sayısal giriş | 0° | 0–360 | Evet |
| Güç | Kaydırmalı cetvel + sayısal giriş | %60 | 0–200 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 833. Gölge İçindeki Işık Aralıkları

**İşlev ve ayrım:** Bir kesik ışık kaynağının kısmi örtülmesiyle çoklu yumuşak gölge bantları üretir. Gobo maskesiyle ışık-gölge dağılımını sahneye taşır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Gobo | Katman seçici | Yok | Katman | — |
| Işık | X/Y noktası | 50,20 | Tuval | Evet |
| Kaynak genişliği | Kaydırmalı cetvel + sayısal giriş | 35 px | 0–400 | Evet |
| Mesafe | Kaydırmalı cetvel + sayısal giriş | 100 px | 0–1000 | Evet |
| Gölge | Kaydırmalı cetvel + sayısal giriş | %60 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 834. Isı Kırılması Katmanı

**İşlev ve ayrım:** Arka plandaki görüntüyü sıcak havadaki yükselen, farklı hızlarda hareket eden kırılma katmanlarıyla büker; genel displacement'tan farklı yükselme alanı ve yoğunluk gradyanı içerir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Yükseliş hızı | Kaydırmalı cetvel + sayısal giriş | 60 px/sn | 0–500 | Evet |
| Kırılma | Kaydırmalı cetvel + sayısal giriş | 12 px | 0–100 | Evet |
| Katman derinliği | Kaydırmalı cetvel + sayısal giriş | 150 px | 1–1000 | Evet |
| Yoğunluk | Kaydırmalı cetvel + sayısal giriş | %60 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 835. Su Altı Askı Zerreleri

**İşlev ve ayrım:** Kameraya göre farklı derinliklerde yavaş süzülen zerreler, derinlik rengi ve odak farkı üretir; yağmur/kabarcık değil, 3B derinlik katmanlı askı alanı.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Zerre | Tam sayı | 150 | 1–3000 | Adımlı* |
| Derinlik | Kaydırmalı cetvel + sayısal giriş | 600 px | 10–3000 | Evet |
| Akış | Kaydırmalı cetvel + sayısal giriş | 10 px/sn | 0–300 | Evet |
| Renk | Renk seçici | #99D9CC | RGBA / HEX | Evet |
| Odak | Kaydırmalı cetvel + sayısal giriş | 50% | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 836. Işıklı Dalga Cephesi

**İşlev ve ayrım:** Bir noktadan çıkan tek enerji cephesinin yüzeyleri geçerken parlak bir yay ve artçı iz oluşturması; 204 halka çiziminden farklı olarak bağlı yüzeylerin renk/ışık tepkisini üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Merkez | X/Y noktası | 50,50 | Tuval | Evet |
| Yarıçap | Kaydırmalı cetvel + sayısal giriş | 100 px | 0–3000 | Evet |
| Cephe genişliği | Kaydırmalı cetvel + sayısal giriş | 20 px | 1–300 | Evet |
| Artçı süre | Kaydırmalı cetvel + sayısal giriş | 0.5 sn | 0–5 | Evet |
| Renk | Renk seçici | #66CCFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 837. Akışkan İz Haritası

**İşlev ve ayrım:** Bir hareketli katmanın geçtiği bölgelere sürekli bir renk/yoğunluk alanı yazar ve alanı akışla taşır; 385 Yankı eski görselleri gösterir, bu kalıcı yoğunluk izi üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| İz kaynağı | Katman seçici | Yok | Katman | — |
| Birikim | Kaydırmalı cetvel + sayısal giriş | %40 | 0–100 | Evet |
| Sönme | Kaydırmalı cetvel + sayısal giriş | 1.5 sn | 0.01–30 | Evet |
| Akış | Kaydırmalı cetvel + sayısal giriş | 30 px/sn | 0–500 | Evet |
| Yayılma | Kaydırmalı cetvel + sayısal giriş | 4 px | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 838. Kütle Koruyan Akış Alanı

**İşlev ve ayrım:** Maske içinde sürekli taşınan yoğunluğu kaynak ve çıkış noktalarıyla dengeler; 513 akış alanı yön üretirken bu yoğunluk taşınımı simüle eder.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Alan maskesi | Katman seçici | Yok | Katman | — |
| Giriş | X/Y noktası | 10,50 | Tuval | Evet |
| Çıkış | X/Y noktası | 90,50 | Tuval | Evet |
| Akış | Kaydırmalı cetvel + sayısal giriş | 100 px/sn | 0–800 | Evet |
| Viskozite | Kaydırmalı cetvel + sayısal giriş | %20 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 839. Yüzeye Biriken Parçacıklar

**İşlev ve ayrım:** Hareketli zerrelerin hedef yüzeye temas ettiğinde orada birikmesini, yüzey hareket ederse birlikte taşınmasını sağlar; sıradan parçacık yayılımından farklı kalıcı tortu maskesi üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Yüzey | Katman seçici | Yok | Katman | — |
| Üretim | Tam sayı | 50/sn | 0–5000 | Adımlı* |
| Yapışma | Kaydırmalı cetvel + sayısal giriş | %80 | 0–100 | Evet |
| Birikim tavanı | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |
| Temizlenme | Kaydırmalı cetvel + sayısal giriş | 0/sn | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 840. Yüzey Boyunca Zerre Akışı

**İşlev ve ayrım:** Parçacıklar 2B silüet sınırına yakalanır ve kenar eğrisini takip eder; 283 yol boyunca kopyalamadan farklı hareketli doğum ve çıkışları vardır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Sınır | Katman seçici | Yok | Katman | — |
| Akış | Kaydırmalı cetvel + sayısal giriş | 80 px/sn | −500–500 | Evet |
| Doğum | Tam sayı | 30/sn | 0–2000 | Adımlı* |
| Ömür | Kaydırmalı cetvel + sayısal giriş | 2 sn | 0.1–20 | Evet |
| Kenar ofseti | Kaydırmalı cetvel + sayısal giriş | 0 px | −100–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 841. Parçacık Bağlantı Ağı

**İşlev ve ayrım:** Yakın parçacık çiftleri arasında mesafeye bağlı çizgiler üretir; ağ diyagramı sabit veri bağlantılarıyla çalışırken burada dinamik komşuluk vardır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Nokta | Tam sayı | 80 | 2–1000 | Adımlı* |
| Bağ mesafesi | Kaydırmalı cetvel + sayısal giriş | 60 px | 1–500 | Evet |
| Azami komşu | Tam sayı | 4 | 1–16 | Adımlı* |
| Çizgi | Renk seçici | #77CCFF | RGBA / HEX | Evet |
| Kalınlık | Kaydırmalı cetvel + sayısal giriş | 1 px | 0.2–20 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 842. İz Ucu Kuyruğu

**İşlev ve ayrım:** Bir hareketli nesnenin rotasını geçmiş zaman örneklerinden kalınlaşan/incelen sürekli şerit halinde çizer; 505 hareket yolu çiziminden farklı olarak kısa kayan kuyruk ve hızla değişen kalınlık vardır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Nesne | Katman seçici | Yok | Katman | — |
| Kuyruk süresi | Kaydırmalı cetvel + sayısal giriş | 0.5 sn | 0.02–10 | Evet |
| Baş kalınlığı | Kaydırmalı cetvel + sayısal giriş | 10 px | 0–200 | Evet |
| Kuyruk profili | Eğri düzenleyici | Azalan | Özel | — |
| Renk | Renk seçici | #55CCFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 843. Optik Gölge Yarığı

**İşlev ve ayrım:** Bir aralık üzerinden geçen ışığı perspektifli yarık ve uzayan gölge sınırları olarak çizer; genel spot ışığından farklı iki kenarlı fiziksel örtülme.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kaynak | X/Y noktası | 50,20 | Tuval | Evet |
| Yarık genişliği | Kaydırmalı cetvel + sayısal giriş | 15 px | 0–500 | Evet |
| Projeksiyon | Kaydırmalı cetvel + sayısal giriş | 300 px | 0–2000 | Evet |
| Kenar penumbrası | Kaydırmalı cetvel + sayısal giriş | 12 px | 0–150 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 844. Çevresel Toz Işık Maskesi

**İşlev ve ayrım:** Parçacıkları yalnız kullanıcı çizdiği ışık hacminde görünür hale getirir; çevresel zerre kaynağıyla aydınlatma kesişimi üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Işık maskesi | Katman seçici | Yok | Katman | — |
| Zerre | Tam sayı | 300 | 0–5000 | Adımlı* |
| Akış | Kaydırmalı cetvel + sayısal giriş | 12 px/sn | 0–300 | Evet |
| Parlaklık | Kaydırmalı cetvel + sayısal giriş | %70 | 0–200 | Evet |
| Maske geçişi | Kaydırmalı cetvel + sayısal giriş | 15 px | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 845. Derinlik Sınırında Parlama

**İşlev ve ayrım:** Derinlik haritasındaki süreksizlikleri tespit edip yalnız önde kalan nesnenin sınırına seçici ışık verir; 57 yumuşak parlamanın parlaklığa dayalı davranışından farklıdır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Derinlik | Katman seçici | Yok | Katman | — |
| Derinlik eşiği | Kaydırmalı cetvel + sayısal giriş | %8 | 0–100 | Evet |
| Hale | Kaydırmalı cetvel + sayısal giriş | 10 px | 0–150 | Evet |
| Renk | Renk seçici | #55AAFF | RGBA / HEX | Evet |
| Güç | Kaydırmalı cetvel + sayısal giriş | %50 | 0–300 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 846. Etkileşimli Işık Maskesi

**İşlev ve ayrım:** Işık kaynağı ile hareketli engel arasındaki görünürlük alanını 2B ışın kesişimleriyle hesaplayarak ışığın erişebildiği bölgeleri dinamik maske yapar; gölge katmanı veya tek spot ışığı üretmez.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Işık kaynağı | X/Y noktası | 50,50 | Tuval | Evet |
| Engel | Katman seçici | Yok | Katman | — |
| Erişim | Kaydırmalı cetvel + sayısal giriş | 500 px | 1–4000 | Evet |
| Açısal örnek | Tam sayı | 128 | 16–1024 | Adımlı* |
| Kenar geçişi | Kaydırmalı cetvel + sayısal giriş | 4 px | 0–50 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

# El çizimi, sanat ve materyal (847–868)

**Araştırma dayanakları:** [09](https://docs.gimp.org/3.0/en/filters.html) GIMP, [10](https://gmic.eu/reference/) G’MIC, [15](https://docs.krita.org/en/reference_manual/filters.html) Krita, [41](https://paint.net/doc/latest/EffectsMenu.html) Paint.NET, [43](https://thebookofshaders.com/) The Book of Shaders, [44](https://www.ronja-tutorials.com/) Ronja’s Tutorials, [46](https://p5js.org/reference/) p5.js, [47](https://processing.org/reference/) Processing, [51](https://www.fabricjs.com/docs/) Fabric.js, [58](https://opentoonz.readthedocs.io/en/latest/) OpenToonz, [69](https://aseprite.org/docs/) Aseprite, [70](https://www.affinity.studio/photo-editing-software) Affinity.

Ayarlar uygulama için önerilen başlangıç değerleridir; mevcut kaynak koduyla doğrulanmış değerler değildir. AK = anahtar kare. Adımlı* = yalnız çalışma sırasında değişmesi güvenli olan seçim, anahtar ve tam sayılar; topoloji, örnek bütçesi, analiz gibi ayarlar önbelleği geçersiz kılmalı veya animasyona kapalı kalmalıdır.

## 847. Çizgi Ağırlığı Düzenleyici

**İşlev ve ayrım:** Çizginin başlangıç, orta ve uç kalınlığını ayrı profille değiştirir; 102 genel inceltmeden farklı uzunluk boyunca basınç profili kullanır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kalınlık profili | Eğri düzenleyici | İnce–kalın–ince | Özel | — |
| En büyük kalınlık | Kaydırmalı cetvel + sayısal giriş | 8 px | 0.5–100 | Evet |
| Yumuşatma | Kaydırmalı cetvel + sayısal giriş | 3 px | 0–50 | Evet |
| Uçları koru | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 848. Çizgi Düzeltme ve Yeniden Çizim

**İşlev ve ayrım:** Piksel konturunu eğrilerle yeniden kurar; elle çizilmiş kenarları düzeltilmiş vektör görünüme dönüştürür.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Uyum toleransı | Kaydırmalı cetvel + sayısal giriş | 2 px | 0.1–20 | Evet |
| Köşe koruma | Kaydırmalı cetvel + sayısal giriş | %75 | 0–100 | Evet |
| Çıktı | Seçim | Vektör | Vektör/Raster | Adımlı* |
| Çizgi kalınlığı | Kaydırmalı cetvel + sayısal giriş | 2 px | 0.2–30 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 849. Çizgiye Renk Sızdırma

**İşlev ve ayrım:** Renkli dolgunun çizgiye yakın bölümünde komşu renkleri çizginin içine doğru taşır; ana konturu renklerle yumuşatır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Dolgu kaynağı | Katman seçici | Yok | Katman | — |
| Sızma | Kaydırmalı cetvel + sayısal giriş | 3 px | 0–50 | Evet |
| Güç | Kaydırmalı cetvel + sayısal giriş | %65 | 0–100 | Evet |
| Koyu çizgi merkezini koru | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 850. Kâğıt Kesik Kat Yerleri

**İşlev ve ayrım:** Kesimden farklı olarak kâğıt üzerindeki kat çizgilerine göre yüzeyleri hafifçe yükseltip iki tarafın ışığını değiştirir; origami tam katlı model üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kat çizgileri | Katman seçici | Yok | Vektör katman | — |
| Kat açısı | Kaydırmalı cetvel + sayısal giriş | 20° | −90–90 | Evet |
| Kırışıklık | Kaydırmalı cetvel + sayısal giriş | 2 px | 0–30 | Evet |
| Işık açısı | Kaydırmalı cetvel + sayısal giriş | 45° | 0–360 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 851. Katmanlı Şablon Baskı

**İşlev ve ayrım:** Renkleri sırayla ayrı fiziksel şablon maskeleriyle basar; destek köprüleri sayesinde iç boşluklar baskıda asılı kalmaz. Risograf kayıt kaymasından farklıdır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Şablon | Tam sayı | 3 | 1–12 | Adımlı* |
| Köprü genişliği | Kaydırmalı cetvel + sayısal giriş | 4 px | 1–50 | Evet |
| Kenar sızıntısı | Kaydırmalı cetvel + sayısal giriş | 1 px | 0–20 | Evet |
| Katman maskelerini çıkar | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 852. Çizgisel Ahşap Oyması

**İşlev ve ayrım:** Görüntüyü oyma keski profillerine göre negatif çizgi kanalları ve kenar kabartısı biçiminde yeniden çizer; linol baskıdan farklı malzeme derinliği içerir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Oyuk derinliği | Kaydırmalı cetvel + sayısal giriş | 5 px | 0–50 | Evet |
| Çizgi aralığı | Kaydırmalı cetvel + sayısal giriş | 6 px | 1–60 | Evet |
| Keski ucu | Seçim | V | V/U | Adımlı* |
| Ahşap | Renk seçici | #AD7849 | RGBA / HEX | Evet |
| Işık açısı | Kaydırmalı cetvel + sayısal giriş | 45° | 0–360 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 853. Kâğıt Delik Nakışı

**İşlev ve ayrım:** Desenin çevresinde düzenli delikler ve delikleri birbirine bağlayan iplik yolları üretir; nakışın sadece kumaş yüzeyi değil, alfa delikleri gerçek maskedir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Delik aralığı | Kaydırmalı cetvel + sayısal giriş | 8 px | 2–100 | Evet |
| Delik çapı | Kaydırmalı cetvel + sayısal giriş | 3 px | 0.5–30 | Evet |
| İplik | Kaydırmalı cetvel + sayısal giriş | 2 px | 0.3–20 | Evet |
| İplik rengi | Renk seçici | #FFFFFF | RGBA / HEX | Evet |
| Delikleri alfa yap | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 854. Karton Katman Kesiti

**İşlev ve ayrım:** Karton objenin açık kenarında iç katmanların çizgilerini ve dalgalı kesitini üretir; 76 doku tüm yüzeyde, bu yalnız kesilmiş kenarda çalışır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Karton kalınlığı | Kaydırmalı cetvel + sayısal giriş | 10 px | 1–100 | Evet |
| Oluk aralığı | Kaydırmalı cetvel + sayısal giriş | 5 px | 1–40 | Evet |
| İç renk | Renk seçici | #AD8760 | RGBA / HEX | Evet |
| Kesit görünümü | Kaydırmalı cetvel + sayısal giriş | %65 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 855. Boya Birikim Kenarı

**İşlev ve ayrım:** Sıvı boyanın kururken kenarında halka şeklinde pigment biriktirmesini simüle eder; sulu mürekkep kenarı genelde dağılım, bu kuruma birikimidir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Halka genişliği | Kaydırmalı cetvel + sayısal giriş | 5 px | 0–60 | Evet |
| Pigment | Kaydırmalı cetvel + sayısal giriş | %30 | 0–100 | Evet |
| Kuruma | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |
| Kenar pürüzü | Kaydırmalı cetvel + sayısal giriş | %20 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 856. Boyayı Kazıyıp Açma

**İşlev ve ayrım:** Üst boya katmanını çizilen yollar veya temas maskesi üzerinden kaldırarak alt katmanı görünür kılar; kazıma sanatı stilinden farklı iki gerçek katman kullanır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Alt katman | Katman seçici | Yok | Katman | — |
| Kazı maskesi | Katman seçici | Yok | Katman | — |
| Kazı genişliği | Kaydırmalı cetvel + sayısal giriş | 15 px | 0.5–200 | Evet |
| Kalıntı | Kaydırmalı cetvel + sayısal giriş | %15 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 857. Kâğıt Lif Ayırma

**İşlev ve ayrım:** Kesilmiş alfa kenarlarından ince, ipliksi lifler uzatır; kâğıt dokusunun tamamını değiştirmez. El yapımı kukla kenarları için.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Lif uzunluğu | Kaydırmalı cetvel + sayısal giriş | 5 px | 0–60 | Evet |
| Lif yoğunluğu | Tam sayı | 20/100px | 0–400 | Adımlı* |
| Lif kalınlığı | Kaydırmalı cetvel + sayısal giriş | 0.8 px | 0.1–8 | Evet |
| Lif rengi | Renk seçici | #E8D8BD | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 858. Çizim Üzerinde Renk Kalemi Basıncı

**İşlev ve ayrım:** Seçilmiş çizgi yolunun basınç verisini renk yoğunluğu ve kâğıt tanesi doluluğuna dönüştürür; kuru pastel veya düz tarama gibi bütün resme filtre uygulamaz.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Çizgi yolu | Katman seçici | Yok | Vektör | — |
| Basınç | Eğri düzenleyici | Orta | Özel | — |
| Tane | Kaydırmalı cetvel + sayısal giriş | 4 px | 1–30 | Evet |
| Yoğunluk | Kaydırmalı cetvel + sayısal giriş | %80 | 0–100 | Evet |
| Renk | Renk seçici | #328CFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 859. Cam Üzerine Oyma

**İşlev ve ayrım:** Bir saydam cam yüzeyinde seçilen desenin bölgelerini matlaştırarak arka planı farklı oranda dağıtır; vitrayda renkli bölmeler, burada saydam ve mat yüzey birlikte.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Oyma maskesi | Katman seçici | Yok | Katman | — |
| Arka plan | Katman seçici | Yok | Katman | — |
| Matlık | Kaydırmalı cetvel + sayısal giriş | %75 | 0–100 | Evet |
| Kırılma | Kaydırmalı cetvel + sayısal giriş | 3 px | 0–40 | Evet |
| Kenar parlaması | Kaydırmalı cetvel + sayısal giriş | %20 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 860. Döğülmüş Metal Kabartı

**İşlev ve ayrım:** Yüzey üzerinde çekiç darbelerine benzeyen geniş çukurcukların normal haritasını üretir; krom yansıması tek malzeme parlamasıdır, bu iz geometrisini üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Çukur çapı | Kaydırmalı cetvel + sayısal giriş | 18 px | 2–200 | Evet |
| Derinlik | Kaydırmalı cetvel + sayısal giriş | 3 px | 0–30 | Evet |
| Darbe örtüşmesi | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| Pürüz | Kaydırmalı cetvel + sayısal giriş | %45 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 861. Çatlak Vernik Katmanı

**İşlev ve ayrım:** İnce üst kaplamada küçük çatlakların arasında renkli alt yüzeyi gösterir. 671 çamur kuruması tüm kütleyi böler, bu çatlakların saydamlığını ve alt katmanı yönetir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Alt yüzey | Katman seçici | Yok | Katman | — |
| Çatlak ölçeği | Kaydırmalı cetvel + sayısal giriş | 25 px | 2–300 | Evet |
| Genişlik | Kaydırmalı cetvel + sayısal giriş | 1 px | 0.2–20 | Evet |
| Vernik opaklığı | Kaydırmalı cetvel + sayısal giriş | %80 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 862. Kırçıllı İplik Karışımı

**İşlev ve ayrım:** Bir çizgiyi birkaç farklı renkte paralel ince liflerden dokur, renkler aynı yol boyunca ayrı akış gösterir; 209 örgü deseni tüm düzlemi doldurur.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Yol | Katman seçici | Yok | Vektör | — |
| Lif | Tam sayı | 7 | 2–32 | Adımlı* |
| Toplam kalınlık | Kaydırmalı cetvel + sayısal giriş | 10 px | 1–100 | Evet |
| Renk karışımı | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| İkinci renk | Renk seçici | #FFFFFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 863. Dikiş Payı ve Sökülme

**İşlev ve ayrım:** Kumaş parçalarının kenarına içe ofsetli dikiş payı ve seçilebilir bölgelerde kopmuş dikiş uçları ekler; 636 kumaş aplike genel kolaj efekti.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Pay | Kaydırmalı cetvel + sayısal giriş | 8 px | 0–100 | Evet |
| Dikiş aralığı | Kaydırmalı cetvel + sayısal giriş | 6 px | 1–50 | Evet |
| Sökülme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| İp uzunluğu | Kaydırmalı cetvel + sayısal giriş | 8 px | 0–100 | Evet |
| İplik | Renk seçici | #FFFFFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 864. Çizgili Oyuncak Dönüş Tabakası

**İşlev ve ayrım:** Ön ve arka iki çizim arasında tarak gibi şeritlerle görünüm seçer; lentiküler baskının fiziksel baskı modelinden farklı, gerçek animasyon dönüş açısı ile iki katman seçer.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Ön | Katman seçici | Yok | Katman | — |
| Arka | Katman seçici | Yok | Katman | — |
| Bakış açısı | Kaydırmalı cetvel + sayısal giriş | 0° | −180–180 | Evet |
| Şerit | Kaydırmalı cetvel + sayısal giriş | 4 px | 1–40 | Evet |
| Geçiş yumuşaklığı | Kaydırmalı cetvel + sayısal giriş | %20 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 865. Piksel Küme Kontur Düzeltmesi

**İşlev ve ayrım:** Piksel sanatındaki tek hücrelik çıkıntı ve düzensiz merdivenleri komşuluk kurallarıyla düzeltir; çözünürlüğü büyütmez veya bulanıklaştırmaz.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hücre boyutu | Tam sayı | 1 px | 1–64 | Adımlı* |
| Kural | Seçim | Çıkıntıları temizle | Çıkıntıları temizle/Çentikleri doldur | Adımlı* |
| Geçiş | Tam sayı | 1 | 1–5 | Adımlı* |
| Paleti koru | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 866. Piksel Altı Tonlama

**İşlev ve ayrım:** Piksel sanatı çözünürlüğünü değiştirmeden yarı ton yerine elle seçilmiş küme desenleriyle ara renk hissi verir, kaynak palete bağlı kalır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Palet | Katman seçici | Yok | Katman | — |
| Küme | Seçim | Köşegen | Köşegen/Dama/Kümeli | Adımlı* |
| Eşik | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| Karışım | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 867. Çizgi Animasyonunda Çift Boyama

**İşlev ve ayrım:** Çizgi katmanının iki tarafını farklı renge boyayarak ışığa bakan kenarı ve gölgeye bakan kenarı ayrı tutar; normal kontur aynı renkli bir şerittir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Işık açısı | Kaydırmalı cetvel + sayısal giriş | 45° | 0–360 | Evet |
| Aydınlık | Renk seçici | #CDEEFF | RGBA / HEX | Evet |
| Gölge | Renk seçici | #223366 | RGBA / HEX | Evet |
| Çizgi kalınlığı | Kaydırmalı cetvel + sayısal giriş | 3 px | 0.5–30 | Evet |
| Geçiş | Kaydırmalı cetvel + sayısal giriş | %20 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 868. Islak Boya Temas Karışımı

**İşlev ve ayrım:** İki boyalı katmanın temas sınırında renkleri pigment gibi karıştırıp taşınan kısa izler üretir; tüm görüntüye mermerleme uygulamaz.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Diğer boya | Katman seçici | Yok | Katman | — |
| Karışım derinliği | Kaydırmalı cetvel + sayısal giriş | 10 px | 0–100 | Evet |
| Islaklık | Kaydırmalı cetvel + sayısal giriş | %70 | 0–100 | Evet |
| Akış | Kaydırmalı cetvel + sayısal giriş | 15 px/sn | 0–100 | Evet |
| Kurutma | Kaydırmalı cetvel + sayısal giriş | 2 sn | 0.1–30 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

# Üretken çizim ve matematiksel şekiller (869–890)

**Araştırma dayanakları:** [06](https://docs.derivative.ca/TOP) TouchDesigner, [12](https://www.sidefx.com/docs/houdini/nodes/) Houdini, [43](https://thebookofshaders.com/) The Book of Shaders, [44](https://www.ronja-tutorials.com/) Ronja’s Tutorials, [46](https://p5js.org/reference/) p5.js, [47](https://processing.org/reference/) Processing, [51](https://www.fabricjs.com/docs/) Fabric.js, [60](https://docs.manim.community/en/stable/reference.html) Manim, [62](https://cavalry.studio/docs/) Cavalry, [65](https://manual.notch.one/2026.2/en/) Notch.

Ayarlar uygulama için önerilen başlangıç değerleridir; mevcut kaynak koduyla doğrulanmış değerler değildir. AK = anahtar kare. Adımlı* = yalnız çalışma sırasında değişmesi güvenli olan seçim, anahtar ve tam sayılar; topoloji, örnek bütçesi, analiz gibi ayarlar önbelleği geçersiz kılmalı veya animasyona kapalı kalmalıdır.

## 869. Kelt Düğümü Çizici

**İşlev ve ayrım:** Bir yolun kendisiyle kesişimlerinde sırayla üst-alt geçişler oluşturarak örülü düğüm çizgileri üretir; dokuma dokusu değil vektör topolojisidir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Tekrar | Tam sayı | 5 | 2–30 | Adımlı* |
| İp genişliği | Kaydırmalı cetvel + sayısal giriş | 12 px | 1–100 | Evet |
| Kesişim boşluğu | Kaydırmalı cetvel + sayısal giriş | 3 px | 0–40 | Evet |
| Düğüm | Seçim | Kare | Kare/Daire | Adımlı* |
| Renk | Renk seçici | #328CFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 870. Fourier Eğri Çizimi

**İşlev ve ayrım:** İçe aktarılan kapalı yolu dönen dairelerin toplamı olarak yeniden çizer; yol üzerinde hareket efekti değil matematiksel yaklaşım animasyonu.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kaynak eğri | Katman seçici | Yok | Vektör | — |
| Harmonik | Tam sayı | 16 | 1–256 | Adımlı* |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| Daireleri göster | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Çizgi | Kaydırmalı cetvel + sayısal giriş | 2 px | 0.2–30 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 871. Süperformül Şekli

**İşlev ve ayrım:** Tek bir matematiksel formülle yıldız, çiçek, yumuşak çokgen ve ara biçimler üretir; çiçek rozeti özel tekrar yerine sürekli parametrik şekildir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Simetri | Kaydırmalı cetvel + sayısal giriş | 6 | 0–32 | Evet |
| Yuvarlaklık | Kaydırmalı cetvel + sayısal giriş | 1 | 0.05–10 | Evet |
| Köşe üssü | Kaydırmalı cetvel + sayısal giriş | 1 | 0.05–10 | Evet |
| Yarıçap | Kaydırmalı cetvel + sayısal giriş | 100 px | 1–2000 | Evet |
| Dolgu | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 872. Evolüt ve İnvolüt Eğrisi

**İşlev ve ayrım:** Seçilen eğrinin yerel eğrilik merkezlerini veya açılan ipin ucunun izini çizer; spirograf sabit dairesel dişli oranıyla çalışır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Temel eğri | Katman seçici | Yok | Vektör | — |
| Tür | Seçim | İnvolüt | Evolüt/İnvolüt | Adımlı* |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |
| Çizgi | Kaydırmalı cetvel + sayısal giriş | 2 px | 0.2–30 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 873. Kontur Ofset Ailesi

**İşlev ve ayrım:** Bir kapalı yolu gerçek geometrik ofsetlerle içe veya dışa paralel eğrilere çoğaltır; 92 kenar tekrarı raster kopya, bu kesişim temizleyen vektör aile.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kaynak | Katman seçici | Yok | Vektör | — |
| Ofset sayısı | Tam sayı | 6 | 1–64 | Adımlı* |
| Aralık | Kaydırmalı cetvel + sayısal giriş | 12 px | 1–200 | Evet |
| Köşe | Seçim | Yuvarlak | Yuvarlak/Keskin | Adımlı* |
| Kesişimi temizle | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 874. Eğri Zarfları

**İşlev ve ayrım:** Bir dizi hareketli doğruya teğet olarak oluşan zarfı çizer; iplik sanatı bağlantı çizgilerini gösterir, bu ortaya çıkan gerçek teğet eğriyi üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Doğru | Tam sayı | 40 | 4–400 | Adımlı* |
| Açı değişimi | Kaydırmalı cetvel + sayısal giriş | 120° | 0–360 | Evet |
| Zarf çizgisi | Kaydırmalı cetvel + sayısal giriş | 3 px | 0.2–30 | Evet |
| Yardımcı doğrular | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 875. Döngüsel Simetriye Boyama

**İşlev ve ayrım:** Kullanıcı çizdiği tek sektörü döndürerek simetrik vektör yoluna çevirir; 150 kaleydoskop mevcut görüntüyü örnekler, bu düzenlenebilir yol üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Sektör | Tam sayı | 8 | 2–32 | Adımlı* |
| Simetri | Seçim | Dönüş | Dönüş/Yansıma | Adımlı* |
| Merkez | X/Y noktası | 50,50 | Tuval | Evet |
| Kaynak sektörü göster | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 876. Aperiodik Şekil Yerleşimi

**İşlev ve ayrım:** Önceden seçilen farklı boyuttaki şekilleri çakışmadan, düzenli bir kafes zorunluluğu olmadan yerleştirir; Penrose özel karo ailesi, bu serbest şekillerle dolgu optimizasyonudur.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Şekiller | Katman seçici | Yok | Çoklu katman | — |
| Adet | Tam sayı | 80 | 1–1000 | Adımlı* |
| Boşluk | Kaydırmalı cetvel + sayısal giriş | 3 px | 0–60 | Evet |
| Boyut değişimi | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| Tohum | Tam sayı | 1 | 0–999999 | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 877. Eş Yoğunlukta Noktalama

**İşlev ve ayrım:** Bir görüntüde seçilen parlaklık yoğunluğuna göre noktaların aralarındaki itişi dengeler; Poisson tekdüze aralık, burada görüntüye göre ağırlıklı dağılım.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Yoğunluk kaynağı | Katman seçici | Yok | Katman | — |
| Nokta | Tam sayı | 300 | 10–5000 | Adımlı* |
| Yineleme | Tam sayı | 12 | 1–100 | Adımlı* |
| Nokta çapı | Kaydırmalı cetvel + sayısal giriş | 3 px | 0.5–30 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 878. Çember Paketleme

**İşlev ve ayrım:** Belirlenen sınırın içine çakışmayan, farklı büyüklüklerde çemberleri mümkün olduğunca sık yerleştirir; Apollon özel üç çembere teğet fraktaldır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Sınır | Katman seçici | Yok | Katman | — |
| En küçük yarıçap | Kaydırmalı cetvel + sayısal giriş | 4 px | 1–100 | Evet |
| En büyük | Kaydırmalı cetvel + sayısal giriş | 40 px | 2–500 | Evet |
| Doluluk | Kaydırmalı cetvel + sayısal giriş | %85 | 0–100 | Evet |
| Tohum | Tam sayı | 1 | 0–999999 | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 879. Hücre Kenarı Ağ Kalınlaştırma

**İşlev ve ayrım:** Hücre diyagramının bağlantı çizgilerini kesintisiz yuvarlak birleşimli ağ haline dönüştürür; hücre deseni kendisini değil ağın geometrisini üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kaynak hücre ağı | Katman seçici | Yok | Katman | — |
| Kenar kalınlığı | Kaydırmalı cetvel + sayısal giriş | 5 px | 0.5–100 | Evet |
| Kavşak yuvarlağı | Kaydırmalı cetvel + sayısal giriş | 5 px | 0–100 | Evet |
| Kapalı dış çevre | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 880. Topolojik Akış Çizgisi

**İşlev ve ayrım:** Bir vektör alanından belli sayıda çizgiyi, birbirinden uzaklık koruyarak entegre eder; 513 akış alanını üretir, bu alanın kesintisiz görsel çizimini yapar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Vektör alanı | Katman seçici | Yok | Katman | — |
| Çizgi aralığı | Kaydırmalı cetvel + sayısal giriş | 10 px | 1–100 | Evet |
| Uzunluk | Kaydırmalı cetvel + sayısal giriş | 200 px | 1–3000 | Evet |
| Adım | Kaydırmalı cetvel + sayısal giriş | 2 px | 0.5–20 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 881. Yoğunluk İzohipsi

**İşlev ve ayrım:** Görüntü veya nokta alanından eş yoğunluk eğrileri üretir; harita yükselti eğrisi gerçek arazi verisine bağlıyken bu genel yoğunluk alanı.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Yoğunluk | Katman seçici | Yok | Katman | — |
| Seviye | Tam sayı | 8 | 2–40 | Adımlı* |
| Yumuşatma | Kaydırmalı cetvel + sayısal giriş | 8 px | 0–100 | Evet |
| Dolgu bantları | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 882. Kuvvet Alanı Akış Animasyonu

**İşlev ve ayrım:** Seçili kaynak ve hedef noktalardan vektör alanı üretip akış boyunca nokta hareketini çizer; 513 genel alan yönlendirmesi, burada düzenlenebilir kaynak/çukur ve çizgisel alan gösterimi vardır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kaynak | X/Y noktası | 25,50 | Tuval | Evet |
| Hedef | X/Y noktası | 75,50 | Tuval | Evet |
| Güç | Kaydırmalı cetvel + sayısal giriş | 1 | −10–10 | Evet |
| Akış noktası | Tam sayı | 50 | 1–1000 | Adımlı* |
| Hız | Kaydırmalı cetvel + sayısal giriş | 30 px/sn | 0–500 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 883. Simetrik Fonksiyon Çizimi

**İşlev ve ayrım:** Kullanıcının güvenli matematiksel ifade seçicisiyle bir fonksiyon grafiğini hareketli olarak çizer, eksen ve teğetleri hesaplar; normal veri grafiklerinden farklı sürekli fonksiyon.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| İfade | Metin / ifade | sin(x) | İzinli matematik fonksiyonları | — |
| X ölçeği | Kaydırmalı cetvel + sayısal giriş | 1 | 0.01–100 | Evet |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |
| Teğet | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 884. Fraktal Kaçış Yolu

**İşlev ve ayrım:** Karmaşık düzlemde bir noktanın yineleme yolunu ardışık noktalarla gösterir; 217 Fraktal sonuç görüntüsünü üretir, bu tek başlangıç noktasının dinamik yörüngesini gösterir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Başlangıç | X/Y noktası | 50,50 | Düzlem | Evet |
| Yineleme | Tam sayı | 25 | 1–200 | Adımlı* |
| Kaçış sınırı | Kaydırmalı cetvel + sayısal giriş | 4 | 2–100 | Evet |
| Çizgi | Kaydırmalı cetvel + sayısal giriş | 2 px | 0.2–20 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 885. Gölge Voronoi Sınırlama

**İşlev ve ayrım:** Birden fazla ışık noktasının ulaşabildiği bölge sınırlarını engelleri hesaba katan yol uzaklığıyla bölerek ışık alanlarını çizer. 658 düzlemde ağırlıklı hücre bölme, burada engel içinden geçilemez.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Engel maskesi | Katman seçici | Yok | Katman | — |
| Kaynaklar | Katman seçici | Yok | Katman grubu | — |
| Çözünürlük | Kaydırmalı cetvel + sayısal giriş | 4 px | 1–32 | Evet |
| Kenar genişliği | Kaydırmalı cetvel + sayısal giriş | 2 px | 0–50 | Evet |
| Bölgeleri renklendir | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 886. Arı Kovanı Yol Bulucu

**İşlev ve ayrım:** Altıgen hücreler arasında verilen engelleri aşan en kısa görsel yolu oluşturur; labirent üretmek yerine kullanıcıya ait hücre haritasında rota çizer.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Engel maskesi | Katman seçici | Yok | Katman | — |
| Başlangıç | X/Y noktası | 10,50 | Tuval | Evet |
| Hedef | X/Y noktası | 90,50 | Tuval | Evet |
| Hücre | Kaydırmalı cetvel + sayısal giriş | 16 px | 4–100 | Evet |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 887. Kavisli Ok Sürüsü

**İşlev ve ayrım:** Bir alanın yönünü çok sayıda küçük okla temsil eder, oklar eğri yönlere göre deforme olur; tek ölçü oku veya sadece noktasal akış değil vektör alanı gösterimi.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Alan | Katman seçici | Yok | Katman | — |
| Aralık | Kaydırmalı cetvel + sayısal giriş | 24 px | 4–150 | Evet |
| Ok boyu | Kaydırmalı cetvel + sayısal giriş | 14 px | 2–100 | Evet |
| Hıza göre boyut | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Renk | Renk seçici | #328CFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 888. Dairesel Veri Örgüsü

**İşlev ve ayrım:** Bir tablo çiftindeki karşılıklı ilişkileri daire içinde eğri şeritlerle gösterir; 709 akış grafiği ve 715 ağ diyagramından farklı dairesel kenar demetleri.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Veri | Dosya seçici | Yok | CSV/JSON | — |
| İç yarıçap | Kaydırmalı cetvel + sayısal giriş | 100 px | 10–1000 | Evet |
| Şerit eğimi | Kaydırmalı cetvel + sayısal giriş | %60 | 0–100 | Evet |
| Boşluk | Kaydırmalı cetvel + sayısal giriş | 4° | 0–30 | Evet |
| Etiketler | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 889. Dairesel Kılcal Desen

**İşlev ve ayrım:** Bir çevrenin başlangıç noktalarından içe doğru uzayan ince eğrileri alan yoğunluğu ve bükülme ile oluşturur; kök ağı dallanma içerirken bu kesişimsiz kılcal alan.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Merkez | X/Y noktası | 50,50 | Tuval | Evet |
| Çizgi | Tam sayı | 100 | 4–1000 | Adımlı* |
| Bükülme | Kaydırmalı cetvel + sayısal giriş | 45° | −180–180 | Evet |
| İç yarıçap | Kaydırmalı cetvel + sayısal giriş | 20 px | 0–1000 | Evet |
| Kalınlık | Kaydırmalı cetvel + sayısal giriş | 1 px | 0.2–20 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 890. Kenar Büyüyen Kristal

**İşlev ve ayrım:** Bir maske kenarında yön bağımlı düzenli kristal fasetleri kademeli büyütür; 515 kar tanesi tek simetrik yapı, burada yüzeye bağlı kristal katmanı.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Başlangıç maskesi | Katman seçici | Yok | Katman | — |
| Büyüme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| Faset boyutu | Kaydırmalı cetvel + sayısal giriş | 12 px | 1–100 | Evet |
| Yönlilik | Kaydırmalı cetvel + sayısal giriş | %60 | 0–100 | Evet |
| Renk | Renk seçici | #AADDFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

# Animasyon, rig ve Countryballs (891–912)

**Araştırma dayanakları:** [03](https://support.apple.com/tr-tr/guide/motion/welcome/mac) Apple Motion, [06](https://docs.derivative.ca/TOP) TouchDesigner, [13](https://docs.unity3d.com/Packages/com.unity.visualeffectgraph@17.0/manual/Operators.html) Unity, [51](https://www.fabricjs.com/docs/) Fabric.js, [57](https://www.synfig.org/) Synfig, [58](https://opentoonz.readthedocs.io/en/latest/) OpenToonz, [59](https://moho.lostmarble.com/) Moho, [61](https://www.svgator.com/help) SVGator, [62](https://cavalry.studio/docs/) Cavalry, [66](https://www.renpy.org/doc/html/transforms.html) Ren’Py.

Ayarlar uygulama için önerilen başlangıç değerleridir; mevcut kaynak koduyla doğrulanmış değerler değildir. AK = anahtar kare. Adımlı* = yalnız çalışma sırasında değişmesi güvenli olan seçim, anahtar ve tam sayılar; topoloji, örnek bütçesi, analiz gibi ayarlar önbelleği geçersiz kılmalı veya animasyona kapalı kalmalıdır.

## 891. Çok Hedefli Ağırlık Merkezi

**İşlev ve ayrım:** Bir katmanı birden fazla hedefin ağırlıklı merkeziyle hareket ettirir; tek hedefe yaklaşma yerine animasyonlu ağırlıklarla grup takibi yapar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hedefler | Katman seçici | Yok | Çoklu katman | — |
| Hedef ağırlıkları | Eğri düzenleyici | Eşit | Özel | — |
| Gecikme | Kaydırmalı cetvel + sayısal giriş | 0 sn | 0–3 | Evet |
| Ofset | X/Y noktası | 0,0 | Tuval | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 892. Eksen Bazında Ebeveynlik

**İşlev ve ayrım:** Bir katmanın X, Y, dönüş ve ölçeğini ayrı kaynaklara bağlar; normal ebeveynlik bütün dönüşümü devralır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| X kaynağı | Katman seçici | Yok | Katman | — |
| Y kaynağı | Katman seçici | Yok | Katman | — |
| Dönüş kaynağı | Katman seçici | Yok | Katman | — |
| Ölçek kaynağı | Katman seçici | Yok | Katman | — |
| Başlangıç ofsetini koru | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 893. Dinamik Pivot Takibi

**İşlev ve ayrım:** Bir hareketli katmanın pivotunu referans noktası veya başka katmana göre yeniden hesaplar, görünür konumu koruyarak pivot değiştirir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Pivot hedefi | Katman seçici | Yok | Katman | — |
| Ofset | X/Y noktası | 0,0 | Tuval | Evet |
| Görsel konumu koru | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Yumuşatma | Kaydırmalı cetvel + sayısal giriş | 0.1 sn | 0–2 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 894. Sürüş Tekerleği Bağlayıcı

**İşlev ve ayrım:** Yüzey üzerinde kat edilen mesafeyi dönüş açısına çevirir; hıza bağlı yön efektinden farklı kaymadan yuvarlanma kısıtı.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hareket kaynağı | Katman seçici | Yok | Katman | — |
| Yarıçap | Kaydırmalı cetvel + sayısal giriş | 50 px | 1–1000 | Evet |
| Kayma | Kaydırmalı cetvel + sayısal giriş | %0 | −100–100 | Evet |
| Yön | Seçim | Otomatik | Otomatik/İleri/Geri | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 895. İki Noktalı Katman Esnetme

**İşlev ve ayrım:** Bir katmanın iki ayrı ucunu iki farklı izlenen noktaya sabitler, ortadaki şekli mesafeye göre uzatır. Köşe sabitle 4 noktalı perspektif, burada iki uçlu boy ekseni.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Baş hedefi | Katman seçici | Yok | Katman | — |
| Son hedefi | Katman seçici | Yok | Katman | — |
| Genişliği koru | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Esneme sınırı | Kaydırmalı cetvel + sayısal giriş | %200 | 100–500 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 896. Katman Arası Temas Uyumlayıcı

**İşlev ve ayrım:** İki silüetin temas sınırında yalnız yakın bölgeyi yumuşakça ezer ve ayrılınca geri getirir; 501 sekme tüm cismin hareketini hesaplar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Temas katmanı | Katman seçici | Yok | Katman | — |
| Etki yarıçapı | Kaydırmalı cetvel + sayısal giriş | 30 px | 1–300 | Evet |
| Ezilme | Kaydırmalı cetvel + sayısal giriş | %20 | 0–100 | Evet |
| Geri dönüş | Kaydırmalı cetvel + sayısal giriş | 0.2 sn | 0.01–3 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 897. Ağırlık Kaydırma

**İşlev ve ayrım:** Karakter gövdesini destek noktaları arasında hareket ettirirken ağırlık merkezi eğimini ve küçük dengeleme dönüşünü üretir; yürüyüşün kendisi değil ağırlık aktarımı.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Destek noktaları | Katman seçici | Yok | Çoklu katman | — |
| Ağırlık konumu | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| Eğim | Kaydırmalı cetvel + sayısal giriş | 5° | 0–45 | Evet |
| Gecikme | Kaydırmalı cetvel + sayısal giriş | 0.1 sn | 0–1 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 898. Ayak Yere Kilitleme

**İşlev ve ayrım:** Yürüyüşte yere basan ayağın sahne konumunu seçili zaman aralıklarında sabit tutar, ayağın kaymasını engeller. IK ile birlikte çalışır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Ayak | Katman seçici | Yok | Katman | — |
| Zemin | Katman seçici | Yok | Katman | — |
| Basış aralıkları | Eğri düzenleyici | Özel | Zaman eğrisi | — |
| Geçiş | Kaydırmalı cetvel + sayısal giriş | 3 kare | 0–30 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 899. Adım Döngüsü Üretici

**İşlev ve ayrım:** Verilen iki veya dört rig bağlantısına sırayla adım ve havalanma fazları uygular; tek zıplama yerine tekrarlı yürüyüş döngüsü.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Rig | Katman seçici | Yok | Katman grubu | — |
| Adım süresi | Kaydırmalı cetvel + sayısal giriş | 0.6 sn | 0.1–4 | Evet |
| Adım boyu | Kaydırmalı cetvel + sayısal giriş | 40 px | 0–400 | Evet |
| Kaldırma | Kaydırmalı cetvel + sayısal giriş | 15 px | 0–150 | Evet |
| Faz | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 900. Göz Bakış Sıçraması

**İşlev ve ayrım:** İzlenen bakış hedefleri arasında kısa beklemeler ve hızlı küçük göz hareketleri üretir. 403 hedef takip eder, burada zamanlanmış doğal bakış değişimi vardır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hedefler | Katman seçici | Yok | Çoklu katman | — |
| Bekleme | Kaydırmalı cetvel + sayısal giriş | 1.5 sn | 0.1–15 | Evet |
| Sıçrama | Kaydırmalı cetvel + sayısal giriş | 0.08 sn | 0.01–0.5 | Evet |
| Mikro hareket | Kaydırmalı cetvel + sayısal giriş | 2 px | 0–20 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 901. Göz Şekli İçinde İris Kilidi

**İşlev ve ayrım:** Göz şekli değiştiğinde irisin izin verilen silüet içinde kalmasını sağlayan sınır kısıtı. 403 takipten bağımsız maskeleme ve konum projeksiyonu.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Göz maskesi | Katman seçici | Yok | Katman | — |
| İris | Katman seçici | Yok | Katman | — |
| Kenar payı | Kaydırmalı cetvel + sayısal giriş | 2 px | 0–50 | Evet |
| İrisi maskele | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 902. İfade Ağırlıklandırıcı

**İşlev ve ayrım:** Birden fazla çizilmiş ifade şeklinin eşleşmiş kontrol noktalarını ağırlıklı olarak karıştırır; 426 ifade değiştirme katmanlar arası seçim, bu eşzamanlı şekil ağırlıkları.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| İfade şekilleri | Katman seçici | Yok | Çoklu vektör | — |
| Ağırlıklar | Eğri düzenleyici | Özel | Eğri | — |
| Ağırlıkları normalize et | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Yumuşatma | Kaydırmalı cetvel + sayısal giriş | %10 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 903. Gövdeye Yapışan Yüz Koordinatları

**İşlev ve ayrım:** Yüz parçalarını yuvarlak CB gövdesinin yüzey koordinatlarına yerleştirip gövde döndükçe görünürlük ve perspektifi değiştirir; parçalı rig genel dönüşüm değil eğri yüzey koordinatı.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Gövde | Katman seçici | Yok | Katman | — |
| Yüz parçaları | Katman seçici | Yok | Katman grubu | — |
| Yatay açı | Kaydırmalı cetvel + sayısal giriş | 0° | −90–90 | Evet |
| Dikey açı | Kaydırmalı cetvel + sayısal giriş | 0° | −90–90 | Evet |
| Arka tarafı gizle | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 904. Eklem Açısı Kısıtı

**İşlev ve ayrım:** Rig ekleminde izin verilen en düşük ve en yüksek açıyı tanımlar, iki kemik arasında dönüş sınırı ve yumuşak yaklaşım uygular. IK hedef konumu çözer; bu yerel eklem kısıtıdır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Eklem | Katman seçici | Yok | Rig | — |
| En düşük | Kaydırmalı cetvel + sayısal giriş | −60° | −180–180 | Evet |
| En yüksek | Kaydırmalı cetvel + sayısal giriş | 60° | −180–180 | Evet |
| Yumuşak yaklaşım | Kaydırmalı cetvel + sayısal giriş | 10° | 0–90 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 905. Hareket Durdurma Pozu

**İşlev ve ayrım:** Bir hareketin bitişinde önceki hızdan hesaplanan kısa gecikmeli duruş pozu üretir; genel yaylanma sürekli parametreye etki eder, bu yalnız duruş olayına bağlanır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kaynak | Katman seçici | Yok | Katman | — |
| Hız eşiği | Kaydırmalı cetvel + sayısal giriş | 10 px/sn | 0–500 | Evet |
| Ön aşma | Kaydırmalı cetvel + sayısal giriş | 8 px | 0–100 | Evet |
| Toparlanma | Kaydırmalı cetvel + sayısal giriş | 0.2 sn | 0.01–2 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 906. Aksiyon Öncesi Hazırlık

**İşlev ve ayrım:** Yaklaşan ana hareketi analiz edip başlangıcından hemen önce ters yönde kontrollü küçük hazırlık hareketi oluşturur; mevcut keyframe'leri değiştirmez.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hazırlık süresi | Kaydırmalı cetvel + sayısal giriş | 0.2 sn | 0.01–2 | Evet |
| Miktar | Kaydırmalı cetvel + sayısal giriş | %15 | 0–100 | Evet |
| Eğri | Eğri düzenleyici | Yumuşak | Özel | — |
| Yalnız seçili keyframe | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 907. Katman Faz Dağıtımı

**İşlev ve ayrım:** Bir grup katmandaki aynı hareketin fazını konum/indekse göre farklılaştırır; 687 parametre sıralayıcı olay sırası, bu periyodik faz dönüşümü.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Grup | Katman seçici | Yok | Katman grubu | — |
| Dağıtım | Seçim | Soldan sağa | İndeks/X/Y/Merkez uzaklığı | Adımlı* |
| Faz farkı | Kaydırmalı cetvel + sayısal giriş | 45° | 0–360 | Evet |
| Uçlar döngüsel | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 908. Animasyon Hızına Göre Poz Geçişi

**İşlev ve ayrım:** Katmanın hesaplanan hızına göre bekleme, yavaş ve hızlı poz setleri arasında yumuşak ağırlık geçişi kurar; 681 ölçek değil poz seçer.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Pozlar | Katman seçici | Yok | Çoklu katman | — |
| Yavaş eşik | Kaydırmalı cetvel + sayısal giriş | 20 px/sn | 0–500 | Evet |
| Hızlı eşik | Kaydırmalı cetvel + sayısal giriş | 150 px/sn | 1–3000 | Evet |
| Geçiş | Kaydırmalı cetvel + sayısal giriş | 0.15 sn | 0–2 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 909. Ritim Alt Bölüm Kısıtı

**İşlev ve ayrım:** Elle yerleştirilmiş keyframe zamanlarını ses vuruşu alt bölümlerine göre kaydırmadan yeniden örnekler; 690 yeni olay dağıtır, bu mevcut hareketi ritme bağlar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Ses | Katman seçici | Yok | Ses katmanı | — |
| Alt bölüm | Seçim | 1/4 | 1/1,1/2,1/4,1/8 | Adımlı* |
| Yumuşatma | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| Güç | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 910. Hareket Simetrisi Eşleyici

**İşlev ve ayrım:** Bir animasyonlu kol veya gözün hareketini farklı pivot çevresine simetrik dönüşümle kopyalar. Ayna kopya görüntüyü çoğaltır; bu parametre bağlantısıdır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kaynak rig | Katman seçici | Yok | Katman | — |
| Hedef rig | Katman seçici | Yok | Katman | — |
| Eksen | Kaydırmalı cetvel + sayısal giriş | 90° | 0–360 | Evet |
| Açıyı tersle | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Ofset | Kaydırmalı cetvel + sayısal giriş | 0 kare | −120–120 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 911. Çizgi Yolu Topolojisi Eşleyici

**İşlev ve ayrım:** İki vektör yolunun başlangıç, yön ve düğüm eşlemesini düzenler; 528 morph'un bozulmadan çalışabilmesi için yol eşlemesi ve önizlemesi üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hedef yol | Katman seçici | Yok | Vektör | — |
| Düğüm | Tam sayı | 32 | 4–512 | Adımlı* |
| Eşleme | Seçim | Yay uzunluğu | Yay uzunluğu/İşaretler | Adımlı* |
| Yönü tersle | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 912. Döngü Poz Arası Kilit

**İşlev ve ayrım:** Başlangıç ve son pozlar arasındaki dönüşüm farkını döngünün tamamına yedirip ek yerindeki hız ve konumu eşler; 689 döngü birleştirmenin çapraz geçişinden farklı dönüşüm düzeltmesi.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Döngü süresi | Kaydırmalı cetvel + sayısal giriş | 2 sn | 0.1–60 | Evet |
| Konum kilidi | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Hız kilidi | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Düzeltme | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

# Metin, veri ve coğrafi görseller (913–934)

**Araştırma dayanakları:** [03](https://support.apple.com/tr-tr/guide/motion/welcome/mac) Apple Motion, [38](https://www.maxon.net/en/red-giant) Maxon, [39](https://newbluefx.com/) NewBlue, [51](https://www.fabricjs.com/docs/) Fabric.js, [52](https://d3js.org/) D3, [53](https://maplibre.org/) MapLibre, [54](https://docs.qgis.org/3.44/en/docs/user_manual/processing_algs/qgis/index.html) QGIS, [55](https://grass.osgeo.org/grass-stable/manuals/) GRASS GIS, [56](https://gdal.org/en/stable/programs/index.html) GDAL, [60](https://docs.manim.community/en/stable/reference.html) Manim, [61](https://www.svgator.com/help) SVGator, [62](https://cavalry.studio/docs/) Cavalry, [64](https://fxfactory.com/) FxFactory.

Ayarlar uygulama için önerilen başlangıç değerleridir; mevcut kaynak koduyla doğrulanmış değerler değildir. AK = anahtar kare. Adımlı* = yalnız çalışma sırasında değişmesi güvenli olan seçim, anahtar ve tam sayılar; topoloji, örnek bütçesi, analiz gibi ayarlar önbelleği geçersiz kılmalı veya animasyona kapalı kalmalıdır.

## 913. Metin Çizgi Üzerinde Yerleşim Kısıtı

**İşlev ve ayrım:** Metinleri belirli yol bölgelerine taşmadan yerleştirir, karakter aralığı yerine tüm kelimelerin yol üzerindeki güvenli alanını hesaplar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Yol | Katman seçici | Yok | Vektör | — |
| Baş payı | Kaydırmalı cetvel + sayısal giriş | 10 px | 0–200 | Evet |
| Son payı | Kaydırmalı cetvel + sayısal giriş | 10 px | 0–200 | Evet |
| Taşma | Seçim | Gizle | Gizle/Küçült/Satır böl | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 914. Harf İçi Renkli Kesit

**İşlev ve ayrım:** Her glifi kendi iç çizgileriyle bölüp aynı harf içinde bağımsız renklendirir; genel metin gradyanı veya harf başına gökkuşağı değildir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Bölme | Tam sayı | 3 | 2–20 | Adımlı* |
| Açı | Kaydırmalı cetvel + sayısal giriş | 45° | 0–360 | Evet |
| Palet | Katman seçici | Yok | Katman | — |
| Bölme boşluğu | Kaydırmalı cetvel + sayısal giriş | 0 px | 0–30 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 915. Yazı Çizgi İskeleti Canlandırma

**İşlev ve ayrım:** Vektör harflerin orta iskeletini tahmin ederek kalemle yazılma sırasını oluşturur. 70 kenar çizerek belirme dış konturu izler; bu iç çizgi yolunu oluşturur.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Sıra | Seçim | Otomatik | Otomatik/Elle | Adımlı* |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| Kalem kalınlığı | Kaydırmalı cetvel + sayısal giriş | 3 px | 0.2–50 | Evet |
| Orijinal glifle birleştir | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 916. Matematik İfade Dizimi

**İşlev ve ayrım:** Kesir, üst-alt indis, kök ve parantezleri gerçek matematiksel yerleşim olarak üretir; standart metin biçimi yerine yapısal ifade oluşturur.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| İfade | Metin / ifade | x²+1 | Desteklenen matematik işaretleri | — |
| Yazı boyu | Kaydırmalı cetvel + sayısal giriş | 48 px | 8–300 | Evet |
| Satır boşluğu | Kaydırmalı cetvel + sayısal giriş | 8 px | 0–100 | Evet |
| Renk | Renk seçici | #FFFFFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 917. Dikey Kesitli Harf Geçişi

**İşlev ve ayrım:** İki farklı metnin eşleşen bölümlerini sabit bırakıp değişen karakter alanlarını aynı satır içinde animasyonlu olarak yer değiştirir; genel metin dönüşümünden farklı dizgi farkı tabanlı.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hedef metin | Metin / ifade | Yeni metin | İçeriğe bağlı | — |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| Hareket | Kaydırmalı cetvel + sayısal giriş | 15 px | 0–200 | Evet |
| Eşleşen bölümü sabit tut | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 918. Konuşma Balonu Çarpışma Yerleşimi

**İşlev ve ayrım:** Birden çok konuşma balonunu kaynak karakterlere bağlı tutarak balonların üst üste binmesini azaltır; 415 tek balon üreticisi.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Balonlar | Katman seçici | Yok | Katman grubu | — |
| En az boşluk | Kaydırmalı cetvel + sayısal giriş | 8 px | 0–100 | Evet |
| Bağ uzunluğu | Kaydırmalı cetvel + sayısal giriş | 80 px | 10–500 | Evet |
| Yerleşim hızı | Kaydırmalı cetvel + sayısal giriş | 0.2 sn | 0.01–2 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 919. Etiket Çakışma Önleyici

**İşlev ve ayrım:** Harita veya diyagram etiketlerinin ekrandaki çarpışmalarını çözerek yakındaki boş alana taşır, bağlantı çizgisini gerektiğinde ekler; 429 etiket boyutunu kilitler, yerleşim çözmez.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Etiketler | Katman seçici | Yok | Katman grubu | — |
| Aralık | Kaydırmalı cetvel + sayısal giriş | 4 px | 0–80 | Evet |
| Taşıma sınırı | Kaydırmalı cetvel + sayısal giriş | 60 px | 0–400 | Evet |
| Bağ çizgisi | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 920. Harf Temelli Izgara Düzeni

**İşlev ve ayrım:** Metni eşit hücreli tabloya veya bulmaca ızgarasına yerleştirir, karakter hücreleri arasında ayrı gecikme animasyonu sunar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Sütun | Tam sayı | 8 | 1–64 | Adımlı* |
| Satır | Tam sayı | 6 | 1–64 | Adımlı* |
| Hücre | Kaydırmalı cetvel + sayısal giriş | 40 px | 4–300 | Evet |
| Gecikme | Kaydırmalı cetvel + sayısal giriş | 0.03 sn | 0–1 | Evet |
| Izgara görünümü | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 921. Veriyle Boyutlanan Sembol Haritası

**İşlev ve ayrım:** Ülke/bölge merkezindeki simgeleri veri büyüklüğüne göre ölçekler; 717 bölgesel renk, bu orantılı sembol ve çakışma kontrolü.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Veri | Dosya seçici | Yok | CSV/GeoJSON | — |
| En küçük simge | Kaydırmalı cetvel + sayısal giriş | 6 px | 1–100 | Evet |
| En büyük | Kaydırmalı cetvel + sayısal giriş | 60 px | 2–300 | Evet |
| Ölçek | Seçim | Alan | Alan/Yarıçap | Adımlı* |
| Çakışmayı önle | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 922. Akış Yönlü Coğrafi Çizgiler

**İşlev ve ayrım:** İki coğrafi nokta arasındaki kullanıcı verisini akış çizgisi kalınlığı ve yön işaretleriyle haritada gösterir; 418 rota çizgisi, bu miktar ve çift yönlü veri temsilidir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Bağlantılar | Dosya seçici | Yok | CSV/GeoJSON | — |
| Kalınlık | Kaydırmalı cetvel + sayısal giriş | 10 px | 1–60 | Evet |
| Ok hızı | Kaydırmalı cetvel + sayısal giriş | 40 px/sn | 0–300 | Evet |
| Bağ eğrisi | Seçim | Jeodezik | Jeodezik/Ekran | Adımlı* |
| Çift yön | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 923. Harita İçin Bölge Birleştirme

**İşlev ve ayrım:** Kullanıcı seçtiği komşu poligonların ortak iç çizgilerini kaldırıp dış sınırı tek geometrik bölgeye dönüştürür; renk vurgusu değil coğrafi topoloji.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Bölge geometrileri | Katman seçici | Yok | Vektör | — |
| Grup alanı | Metin / ifade | grup | Veri alanı | — |
| Tolerans | Kaydırmalı cetvel + sayısal giriş | 0.5 px | 0–10 | Evet |
| İç sınırları sakla | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 924. Harita Kıyı Şeridi Bantları

**İşlev ve ayrım:** Kıyı çizgisine bağlı iç/dış uzaklık bantlarını üretir; kabartma gölgesi değil deniz ve kara sınırına göre mesafe katmanlarıdır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kıyı vektörü | Katman seçici | Yok | Katman | — |
| Bant | Tam sayı | 4 | 1–20 | Adımlı* |
| Aralık | Kaydırmalı cetvel + sayısal giriş | 20 px | 1–500 | Evet |
| Deniz rengi | Renk seçici | #2266AA | RGBA / HEX | Evet |
| Kara bandı | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 925. Harita Su Havzası Görünümü

**İşlev ve ayrım:** Yükseklik verisinden akış yönü ve drenaj havzası bölgelerini hesaplar, coğrafi eğitim görselleştirmesi için. Yükselti eğrilerinden farklı su birikim alanları.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Yükseklik | Dosya seçici | Yok | DEM | — |
| Çıkış | X/Y noktası | 50,50 | Harita | Evet |
| Akış eşiği | Kaydırmalı cetvel + sayısal giriş | 100 | 1–100000 | Evet |
| Havza | Renk seçici | #44AAEE | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 926. Harita Geometrisi Ölçek Dönüşümü

**İşlev ve ayrım:** Bölgelerin alanını seçilen sayısal veriye göre değiştirip komşuluk yapısını mümkün olduğunca koruyan kartogram üretir; 724 alan karşılaştırması yalnız yan yana gösterir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Veri | Dosya seçici | Yok | GeoJSON+CSV | — |
| Yineleme | Tam sayı | 30 | 1–200 | Adımlı* |
| Kenar koruma | Kaydırmalı cetvel + sayısal giriş | %75 | 0–100 | Evet |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 927. Dünya Gündüz Gece Sınırı

**İşlev ve ayrım:** Girilen tarih ve UTC saatine göre dünya haritasında gündüz/gece ve alacakaranlık sınırını çizerek astronomik eğitim görünümü verir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Tarih | Metin / ifade | 2026-01-01 | ISO tarih | — |
| UTC saat | Kaydırmalı cetvel + sayısal giriş | 12 | 0–24 | Evet |
| Alacakaranlık | Kaydırmalı cetvel + sayısal giriş | 12° | 0–18 | Evet |
| Gece opaklığı | Kaydırmalı cetvel + sayısal giriş | %45 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 928. Hareketli Yolculuk Mesafe Çemberi

**İşlev ve ayrım:** Gerçek coğrafi bir merkezden eş uzaklık çizgileri ve etiketler üretir; düz ekran halkası projeksiyon değişimine uymaz.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Merkez | X/Y noktası | 50,50 | Harita koordinatı | Evet |
| Mesafe | Kaydırmalı cetvel + sayısal giriş | 100 km | 1–20000 | Evet |
| Çember | Tam sayı | 3 | 1–20 | Adımlı* |
| Mesafe etiketi | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 929. Çoklu Harita Kesiti

**İşlev ve ayrım:** Tek coğrafi kaynakta iki veya daha fazla zaman/değer sürümünü seçilen kesit çizgileriyle aynı koordinata yerleştirir; küçük harita ve genel görüntü bölmesinden farklı coğrafi eşleştirme.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Harita sürümleri | Katman seçici | Yok | Çoklu katman | — |
| Kesit | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| Sınır çizgisi | Kaydırmalı cetvel + sayısal giriş | 2 px | 0–20 | Evet |
| Koordinatları kilitle | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 930. Şelale Veri Grafiği

**İşlev ve ayrım:** Bir toplamı artı ve eksi değişimlerle aşama aşama gösteren çubuk grafiği oluşturur; normal sütun grafiğinde kümülatif taban değişmez.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Veri | Dosya seçici | Yok | CSV/JSON | — |
| Artı | Renk seçici | #42AA77 | RGBA / HEX | Evet |
| Eksi | Renk seçici | #DD6677 | RGBA / HEX | Evet |
| Boşluk | Kaydırmalı cetvel + sayısal giriş | %20 | 0–80 | Evet |
| Toplam sütunu | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 931. Kutu ve Bıyık Grafiği

**İşlev ve ayrım:** Dağılımın medyan, çeyrekler ve uç değerlerini gösterir; 711 dağılım grafiği ham noktalar, bu özet dağılım istatistiği.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Veri | Dosya seçici | Yok | CSV | — |
| Bıyık katsayısı | Kaydırmalı cetvel + sayısal giriş | 1.5 | 0–5 | Evet |
| Uç noktaları göster | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Kutu genişliği | Kaydırmalı cetvel + sayısal giriş | 30 px | 5–200 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 932. Etkileşimli Hiyerarşi Halkası

**İşlev ve ayrım:** Ağaç yapısını içten dışa halkalarla gösterir, seçilen düğümün alt dallarına yakınlaşır; ağaç haritası dikdörtgensel alan paylaşımıdır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Veri | Dosya seçici | Yok | JSON ağaç | — |
| İç yarıçap | Kaydırmalı cetvel + sayısal giriş | 30 px | 0–500 | Evet |
| Derinlik | Tam sayı | 4 | 1–12 | Adımlı* |
| Boşluk | Kaydırmalı cetvel + sayısal giriş | 1° | 0–20 | Evet |
| Etiket | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 933. Gantt Zaman Planı Grafiği

**İşlev ve ayrım:** Başlangıç ve bitiş verileriyle birden çok işin üst üste gelen sürelerini satırlarda animasyonlu gösterir; tarih şeridi tek olay eksenidir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Veri | Dosya seçici | Yok | CSV | — |
| Satır yüksekliği | Kaydırmalı cetvel + sayısal giriş | 30 px | 8–100 | Evet |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |
| Bağımlılık çizgileri | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 934. Sayı Ölçeği Nokta Haritası

**İşlev ve ayrım:** Toplam miktarı eş değerli küçük noktalarla bölge içine dağıtır; orantılı simge haritası bir simgeyi büyütürken bu her nokta için sabit veri değerini kullanır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Veri | Dosya seçici | Yok | GeoJSON/CSV | — |
| Nokta değeri | Kaydırmalı cetvel + sayısal giriş | 1000 | 1–1000000 | Evet |
| Nokta çapı | Kaydırmalı cetvel + sayısal giriş | 3 px | 0.5–20 | Evet |
| Tohum | Tam sayı | 1 | 0–999999 | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

# Gelişmiş 3B ve sahne efektleri (935–956)

**Araştırma dayanakları:** [04](https://www.blackmagicdesign.com/products/davinciresolve/fusion) Blackmagic Design, [08](https://docs.blender.org/manual/en/3.3/modeling/modifiers/generate/geometry_nodes.html) Blender, [12](https://www.sidefx.com/docs/houdini/nodes/) Houdini, [13](https://docs.unity3d.com/Packages/com.unity.visualeffectgraph@17.0/manual/Operators.html) Unity, [48](https://threejs.org/docs/) three.js, [49](https://www.babylonjs.com/) Babylon.js, [65](https://manual.notch.one/2026.2/en/) Notch, [68](https://webglfundamentals.org/) WebGL Fundamentals.

Ayarlar uygulama için önerilen başlangıç değerleridir; mevcut kaynak koduyla doğrulanmış değerler değildir. AK = anahtar kare. Adımlı* = yalnız çalışma sırasında değişmesi güvenli olan seçim, anahtar ve tam sayılar; topoloji, örnek bütçesi, analiz gibi ayarlar önbelleği geçersiz kılmalı veya animasyona kapalı kalmalıdır.

## 935. Hacim Kafesi Örgüsü

**İşlev ve ayrım:** Bir 3B yüzeyi yalnızca kabukta değil iç hacminde de seçilen düzenle kafes çubuklarıyla doldurur; 532 tel kafes yalnız model kenarlarını gösterir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Model | Katman seçici | Yok | 3B katman | — |
| Hücre | Kaydırmalı cetvel + sayısal giriş | 20 px | 1–500 | Evet |
| Çubuk kalınlığı | Kaydırmalı cetvel + sayısal giriş | 3 px | 0.5–50 | Evet |
| Kafes | Seçim | Küp | Küp/Çapraz | Adımlı* |
| Yüzeye kırp | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 936. Geometrik Kenar Pahı

**İşlev ve ayrım:** Gerçek 3B ağın kenarlarına yeni yüzler ekleyerek yuvarlaklık veya eğimli pah oluşturur; 77 raster görünümü değiştirir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Model | Katman seçici | Yok | 3B katman | — |
| Pah | Kaydırmalı cetvel + sayısal giriş | 3 px | 0–100 | Evet |
| Segment | Tam sayı | 3 | 1–16 | Adımlı* |
| Açı eşiği | Kaydırmalı cetvel + sayısal giriş | 30° | 0–180 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 937. Geometri Delik Köprüleme

**İşlev ve ayrım:** Seçilen açık iki kenar döngüsünü yeni yüzlerle bağlar; loft iki ayrı profil üretir, burada var olan ağın açık kenarları düzenlenir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Model | Katman seçici | Yok | 3B katman | — |
| Kenar seçimi | Seçim | Elle | Elle/En yakın | Adımlı* |
| Ara segment | Tam sayı | 4 | 1–64 | Adımlı* |
| Bükülme | Kaydırmalı cetvel + sayısal giriş | 0° | −180–180 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 938. Yüzey Üzerinde Geodezik Çizgi

**İşlev ve ayrım:** 3B modelin üzerinde iki nokta arasındaki yüzey boyunca en kısa çizgiyi bulur, havada düz bağlantı çizmez.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Model | Katman seçici | Yok | 3B katman | — |
| Başlangıç | X/Y/Z noktası | 0,0,0 | Yüzey | Evet |
| Bitiş | X/Y/Z noktası | 0,0,0 | Yüzey | Evet |
| Kalınlık | Kaydırmalı cetvel + sayısal giriş | 2 px | 0.2–30 | Evet |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 939. Geometri Normal Düzeltici

**İşlev ve ayrım:** 3B ağın yüzey normallerini alan ve açı ağırlığıyla yeniden düzenler, sivri kenarlarda istenen düz gölgelendirmeyi korur; normal haritası resim üretir, bu mesh verisini değiştirir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Ağırlık | Seçim | Alan+açı | Alan/Açı/Alan+açı | Adımlı* |
| Sert kenar | Kaydırmalı cetvel + sayısal giriş | 45° | 0–180 | Evet |
| Güç | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |
| Dışa yönelt | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 940. Yüzey Üzerinde Dikiş Çizgisi

**İşlev ve ayrım:** Modelin UV dikiş veya kullanıcı seçtiği kenarlarından gerçek 3B çizgi üretir, görünürlük kamera açısına uyar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Model | Katman seçici | Yok | 3B katman | — |
| Kaynak | Seçim | UV dikişi | UV dikişi/Seçili kenarlar | Adımlı* |
| Kalınlık | Kaydırmalı cetvel + sayısal giriş | 2 px | 0.2–30 | Evet |
| Renk | Renk seçici | #FFFFFF | RGBA / HEX | Evet |
| Yüzey ofseti | Kaydırmalı cetvel + sayısal giriş | 0.5 px | 0–10 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 941. Geometri Katlanma Açılımı

**İşlev ve ayrım:** Bir 3B ağın seçilen kenarları etrafında yüzleri zincir halinde açarak 2B açınım üretir; 240 tek katlama, bu topolojik yüz zincirini yönetir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Model | Katman seçici | Yok | 3B katman | — |
| Kök yüz | Seçim | Elle | Elle/İlk | Adımlı* |
| Açılım | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| Çakışmaları işaretle | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 942. Yüzeyden Kopan Kabuk

**İşlev ve ayrım:** Seçilen yüzlerden ince ikinci kabuk üretip modelden normal yönünde aşamalı uzaklaştırır; 536 katı parçaların ayrılması, burada yüzey tabakası soyulur.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Model | Katman seçici | Yok | 3B katman | — |
| Yüz maskesi | Katman seçici | Yok | Katman | — |
| Uzaklaşma | Kaydırmalı cetvel + sayısal giriş | 30 px | 0–500 | Evet |
| Kabuk kalınlığı | Kaydırmalı cetvel + sayısal giriş | 1 px | 0–30 | Evet |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 943. 3B Yüzey Dalgası

**İşlev ve ayrım:** Bir yüzey boyunca yayılan dalga cephelerini geodezik uzaklıkla geometriye uygular; 137 düz 2B dalga bükmeden farklı gerçek model koordinatları.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Model | Katman seçici | Yok | 3B katman | — |
| Kaynak | X/Y/Z noktası | 0,0,0 | Yüzey | Evet |
| Genlik | Kaydırmalı cetvel + sayısal giriş | 10 px | 0–200 | Evet |
| Dalga boyu | Kaydırmalı cetvel + sayısal giriş | 50 px | 1–500 | Evet |
| Hız | Kaydırmalı cetvel + sayısal giriş | 80 px/sn | 0–800 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 944. Eğimde Nesne Tutunması

**İşlev ve ayrım:** Bir nesneyi 3B yüzeyde hareket ettirirken tabanını yerel normale göre döndürür ve yerden ofseti korur; 730 yüzeye oturtma yalnız yerleşim, bu hareketli yön kısıtı.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Yüzey | Katman seçici | Yok | 3B katman | — |
| Takip nesnesi | Katman seçici | Yok | 3B katman | — |
| Ofset | Kaydırmalı cetvel + sayısal giriş | 0 px | −100–100 | Evet |
| Dönüş yumuşaklığı | Kaydırmalı cetvel + sayısal giriş | 0.2 sn | 0–2 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 945. Sanal Kemik Yayılması

**İşlev ve ayrım:** Rig üzerinde seçilen kemikten çevre kemiklere ağırlıkla gecikmeli dönüş iletir; 498 fiziksel yay zincirinden farklı animasyon dağıtımıdır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Rig | Katman seçici | Yok | 3B/2B rig | — |
| Yayılım derinliği | Tam sayı | 3 | 1–20 | Adımlı* |
| Gecikme | Kaydırmalı cetvel + sayısal giriş | 0.05 sn | 0–1 | Evet |
| Azalma | Kaydırmalı cetvel + sayısal giriş | %60 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 946. 3B Parçacık Yüzeye Dönüş

**İşlev ve ayrım:** Bir modelin örneklenmiş noktalarından farklı hedef model yüzeyine taşınan parçacıkları eşler; 528 iki 2B görsel morph'u değil üç boyutlu nokta eşleşmesi.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kaynak | Katman seçici | Yok | 3B katman | — |
| Hedef | Katman seçici | Yok | 3B katman | — |
| Parçacık | Tam sayı | 1000 | 10–20000 | Adımlı* |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| Dağılım | Kaydırmalı cetvel + sayısal giriş | %20 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 947. Doku Atlası Yüz Seçimi

**İşlev ve ayrım:** Tek atlas dokusundaki kutuları geometri yüzlerine kimlik veya sıra ile dağıtır. UV eşleme koordinat aktarır, bu yüz başına farklı atlas hücresi seçer.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Atlas | Dosya seçici | Yok | PNG | — |
| Sütun | Tam sayı | 4 | 1–64 | Adımlı* |
| Satır | Tam sayı | 4 | 1–64 | Adımlı* |
| Seçim | Seçim | Kimlik | Kimlik/Sıra/Tohum | Adımlı* |
| Tohum | Tam sayı | 1 | 0–999999 | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 948. Sanal Kamera Yüzey Yakalama

**İşlev ve ayrım:** Bir kameradan görünen model alanını maske olarak üretir ve ikinci kamerada gösterir; 600 katman renk farkı değil kamera görünürlük aktarımı.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kaynak kamera | Katman seçici | Yok | Kamera | — |
| Model | Katman seçici | Yok | 3B katman | — |
| Derinlik toleransı | Kaydırmalı cetvel + sayısal giriş | 1 px | 0.01–20 | Evet |
| Çıktı | Seçim | Maske | Maske/Renk aktarımı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 949. Yüzey Üzerine Projeksiyon Boyama

**İşlev ve ayrım:** Seçilen kamera veya projektör düzlemindeki resmi görünür 3B yüzeye işler, yüzey gölgelenirken renk yüzeyde kalır; 538 decal yerel küçük çıkartma, bu tüm kamera frustumu.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Projektör | Katman seçici | Yok | Kamera | — |
| Görüntü | Katman seçici | Yok | Katman | — |
| Kenar geçişi | Kaydırmalı cetvel + sayısal giriş | %10 | 0–100 | Evet |
| Gizli yüzlere uygulama | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 950. Çok Açılı Model Panosu

**İşlev ve ayrım:** Bir 3B nesneyi eşzamanlı ön, yan, üst ve perspektif kameralarda aynı görüntüye yerleştirir; normal çok kamera klip editinden farklı ortak 3B sahne renderı.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Model | Katman seçici | Yok | 3B katman | — |
| Düzen | Seçim | 2×2 | 2×2/Yatay | Adımlı* |
| Boşluk | Kaydırmalı cetvel + sayısal giriş | 12 px | 0–100 | Evet |
| Kamera etiketleri | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 951. Derinlikli Nokta Boyutu

**İşlev ve ayrım:** Nokta bulutunun parçalarının kamera mesafesine göre gerçek piksel büyüklüğünü dengeleyerek görünür yoğunluğu sabitler; 533 nokta bulutunu üretir, burada var olan nokta verisine ayrı görüntüleme kısıtı uygulanır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Nokta bulutu | Katman seçici | Yok | 3B katman | — |
| Yakın boyut | Kaydırmalı cetvel + sayısal giriş | 5 px | 0.2–100 | Evet |
| Uzak boyut | Kaydırmalı cetvel + sayısal giriş | 2 px | 0.2–100 | Evet |
| Yoğunluk koruma | Kaydırmalı cetvel + sayısal giriş | %75 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 952. Yüzey Alanına Göre Örnekleme

**İşlev ve ayrım:** Model üzerinde nokta dağılımını yüzlerin alanına ve seçilmiş ağırlık haritasına göre eşitler; 539 nesne saçılımından farklı olarak çıktı düzenlenebilir örnek noktası setidir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Model | Katman seçici | Yok | 3B katman | — |
| Nokta | Tam sayı | 500 | 1–20000 | Adımlı* |
| Ağırlık haritası | Katman seçici | Yok | Katman | — |
| En az mesafe | Kaydırmalı cetvel + sayısal giriş | 0 px | 0–100 | Evet |
| Tohum | Tam sayı | 1 | 0–999999 | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 953. Normal Çizgi Görünümü

**İşlev ve ayrım:** Yüzey normallerini model üzerinde yön okları olarak çizer; normal haritası RGB görselken bu gerçek geometri yönlerini görselleştirir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Model | Katman seçici | Yok | 3B katman | — |
| Ok boyu | Kaydırmalı cetvel + sayısal giriş | 20 px | 1–200 | Evet |
| Atlama | Tam sayı | 4 | 1–100 | Adımlı* |
| Tür | Seçim | Yüz | Yüz/Tepe | Adımlı* |
| Renk | Renk seçici | #44CCFF | RGBA / HEX | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 954. Derinlikte Katman Sıralama

**İşlev ve ayrım:** 2B katman grubu içindeki kartların gerçek kamera derinliğine göre çizim sırasını her karede yeniden düzenler; 693 karakter parça sırası elle rig sırası, bu kamera uzayında otomatik sıralama.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Katmanlar | Katman seçici | Yok | Katman grubu | — |
| Kamera | Katman seçici | Yok | Kamera | — |
| Derinlik toleransı | Kaydırmalı cetvel + sayısal giriş | 0.5 px | 0–20 | Evet |
| Alfa karışımını koru | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 955. Üç Boyutlu Kamera Yakın Plan Kısıtı

**İşlev ve ayrım:** Hedef 3B modelin ekran kaplama oranını sabit tutmak için kamera mesafesi veya lens açısını ayarlar; 796 iki 2B hedefin kadrajını izler.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hedef | Katman seçici | Yok | 3B katman | — |
| Kaplama | Kaydırmalı cetvel + sayısal giriş | %60 | 5–95 | Evet |
| Telafi | Seçim | Mesafe | Mesafe/Odak | Adımlı* |
| Yumuşatma | Kaydırmalı cetvel + sayısal giriş | 0.3 sn | 0–3 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 956. Sahne Kesit Gölgeli Kapağı

**İşlev ve ayrım:** Kesilen 3B ağın açık kesit yüzeylerini kapatır ve kesit malzemesiyle gölgelendirir; 534 yalnız görüntüleme kesiti, bu kapalı yeni topoloji üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Model | Katman seçici | Yok | 3B katman | — |
| Düzlem | X/Y/Z noktası | 0,0,0 | 3B | Evet |
| Kesit rengi | Renk seçici | #D0C0AA | RGBA / HEX | Evet |
| Kapak gölgesi | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

# Ses, müzik analizi ve ritim (957–978)

**Araştırma dayanakları:** [05](https://ffmpeg.org/ffmpeg-filters.html) FFmpeg, [19](https://manual.audacityteam.org/man/effect_menu.html) Audacity, [20](https://librosa.org/doc/latest/index.html) librosa, [21](https://essentia.upf.edu/algorithms_reference.html) Essentia, [22](https://www.reaper.fm/reaplugs/) REAPER, [23](https://www.waves.com/plugins) Waves, [24](https://www.fabfilter.com/products) FabFilter, [25](https://www.meldaproduction.com/effects) MeldaProduction, [26](https://www.airwindows.com/) Airwindows, [27](https://www.soundtoys.com/product/) Soundtoys, [28](https://www.ableton.com/en/live-manual/12/live-audio-effect-reference/) Ableton, [29](https://www.image-line.com/fl-studio-learning/fl-studio-online-manual/html/effects_plugins.htm) FL Studio, [30](https://www.sonicvisualiser.org/) Sonic Visualiser.

Ayarlar uygulama için önerilen başlangıç değerleridir; mevcut kaynak koduyla doğrulanmış değerler değildir. AK = anahtar kare. Adımlı* = yalnız çalışma sırasında değişmesi güvenli olan seçim, anahtar ve tam sayılar; topoloji, örnek bütçesi, analiz gibi ayarlar önbelleği geçersiz kılmalı veya animasyona kapalı kalmalıdır.

## 957. Müzik Vokal Ayırıcı

**İşlev ve ayrım:** Miks içindeki vokali ve eşlik katmanını yerel veya izinli modelle tahmini ayrı akışlara ayırır. Ses gürültüsü giderme bütün gürültüyü ayırır; bu kaynak ayrıştırmadır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Çıktı | Seçim | Vokal | Vokal/Eşlik/İki kanal | Adımlı* |
| Kalite | Seçim | Dengeli | Hızlı/Dengeli/Yüksek | Adımlı* |
| Kalıntı azaltma | Kaydırmalı cetvel + sayısal giriş | %30 | 0–100 | Evet |
| Analiz | Buton | Başlat | İçeriğe bağlı | — |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 958. Davul ve Tonlu Ses Ayırıcı

**İşlev ve ayrım:** Sesin darbeli ve sürekli harmonik bileşenlerini spektral zaman-frekans yapısıyla ayırır; vokal ayrıştırmadan farklı kaynak modeli.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Çıktı | Seçim | Darbeli | Darbeli/Harmonik/İkisi | Adımlı* |
| Zaman pencere | Kaydırmalı cetvel + sayısal giriş | 50 ms | 5–500 | Evet |
| Frekans penceresi | Kaydırmalı cetvel + sayısal giriş | 200 Hz | 10–2000 | Evet |
| Ayırma sertliği | Kaydırmalı cetvel + sayısal giriş | %70 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 959. Nota Eğrisi Görselleştirici

**İşlev ve ayrım:** Monofonik kaydın tahmini temel frekansını nota ekseninde çizerek animasyon kontrolü sağlar; pitch shift sesin frekansını değiştirir, bu ölçümdür.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Ses | Katman seçici | Yok | Ses katmanı | — |
| Alt sınır | Kaydırmalı cetvel + sayısal giriş | 60 Hz | 20–1000 | Evet |
| Üst sınır | Kaydırmalı cetvel + sayısal giriş | 1200 Hz | 100–8000 | Evet |
| Güven eşiği | Kaydırmalı cetvel + sayısal giriş | %60 | 0–100 | Evet |
| Nota etiketleri | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 960. Akort Sapması Ölçeri

**İşlev ve ayrım:** Analiz edilen monofonik sesin en yakın notaya göre cent sapmasını gösterir; perde değiştirme değildir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Referans A | Kaydırmalı cetvel + sayısal giriş | 440 Hz | 400–480 | Evet |
| Yumuşatma | Kaydırmalı cetvel + sayısal giriş | 0.15 sn | 0–2 | Evet |
| Ölçek | Seçim | Cent | Cent/Hz | Adımlı* |
| Nota etiketi | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 961. Akort Düzeltme

**İşlev ve ayrım:** Sesin tahmini notalarını seçilen gam ve düzeltme hızıyla hedef notaya yaklaştırır; tek sabit pitch shift yerine nota başına dinamik telafi.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Gam | Seçim | Kromatik | Kromatik/Majör/Minör/Özel | Adımlı* |
| Düzeltme | Kaydırmalı cetvel + sayısal giriş | %80 | 0–100 | Evet |
| Tepki | Kaydırmalı cetvel + sayısal giriş | 80 ms | 5–500 | Evet |
| Formant koru | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 962. Akor Renk Çarkı

**İşlev ve ayrım:** Müziğin tahmini akor/ton sınıflarını nota çemberindeki ağırlıklara dönüştürür ve canlı renkli animasyon üretir; spektrum Hz bantlarına bakar, bu perde sınıfları.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Ses | Katman seçici | Yok | Ses katmanı | — |
| Pencere | Kaydırmalı cetvel + sayısal giriş | 0.5 sn | 0.1–4 | Evet |
| Çıktı | Seçim | 12 sınıf | 12 sınıf/Akor etiketi | Adımlı* |
| Yumuşatma | Kaydırmalı cetvel + sayısal giriş | %60 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 963. Tempo Eğrisi Analizi

**İşlev ve ayrım:** Müzik hızının zamanla değişimini BPM eğrisi olarak çıkarır; 690 tek vuruş olaylarından farklı değişken tempo haritasıdır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Min BPM | Kaydırmalı cetvel + sayısal giriş | 60 | 20–200 | Evet |
| Max BPM | Kaydırmalı cetvel + sayısal giriş | 180 | 40–300 | Evet |
| Pencere | Kaydırmalı cetvel + sayısal giriş | 6 sn | 1–30 | Evet |
| Elle düzeltme | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 964. Ses Başlangıç Darbesi Algılayıcı

**İşlev ve ayrım:** Vuruş dışındaki ani ses başlangıçlarını da tespit edip görsel olay verisine dönüştürür; ritim dağıtıcı metrik ritim üzerine olay kurar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Ses | Katman seçici | Yok | Ses katmanı | — |
| Duyarlılık | Kaydırmalı cetvel + sayısal giriş | %60 | 0–100 | Evet |
| En az aralık | Kaydırmalı cetvel + sayısal giriş | 80 ms | 10–1000 | Evet |
| Mod | Seçim | Spektral | Spektral/Enerji/Karma | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 965. Konuşma Boşluğu Algılama

**İşlev ve ayrım:** Konuşma segmentleri arasındaki sessiz aralıkları zaman maskesine dönüştürür; gürültü kapısı sesi kısar, bu düzenlenebilir klip/veri üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| En az sessizlik | Kaydırmalı cetvel + sayısal giriş | 0.3 sn | 0.05–5 | Evet |
| Eşik | Kaydırmalı cetvel + sayısal giriş | −40 dB | −80–−10 | Evet |
| Kenar payı | Kaydırmalı cetvel + sayısal giriş | 0.08 sn | 0–1 | Evet |
| Yalnız analiz | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 966. Üç Boyutlu Ses Alanı

**İşlev ve ayrım:** Sesin azimut, yükseklik ve uzaklık konumuna göre binaural sanal sahne üretir; stereo kanal konumundan farklı kulaklar arası filtreleme. Kulaklık önizlemesi.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Konum | X/Y/Z noktası | 0,0,0 | Sahne | Evet |
| Mesafe | Kaydırmalı cetvel + sayısal giriş | 1 m | 0.1–50 | Evet |
| HRTF | Seçim | Standart | Standart/İzinli profil | Adımlı* |
| Islak karışım | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 967. Ses Yansıma Erken Alanı

**İşlev ve ayrım:** Bir sanal odada doğrudan ses ile ilk yansıma yollarını ayrı hesaplar; genel reverb'den farklı erken yansıma denetimi.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Oda | X/Y/Z noktası | 5,3,4 | Metre | Evet |
| Kaynak | X/Y/Z noktası | 1,1,1 | Metre | Evet |
| Yüzey emilimi | Kaydırmalı cetvel + sayısal giriş | %35 | 0–100 | Evet |
| Yansıma karışımı | Kaydırmalı cetvel + sayısal giriş | %30 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 968. Ters Yankı Kuyruğu

**İşlev ve ayrım:** Bir ses olayının başlangıcından önce geriye doğru büyüyen yankı oluşturur; ters oynatma tüm klibi tersine çevirirken burada yalnız hazırlayıcı yankı katmanı vardır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kuyruk | Kaydırmalı cetvel + sayısal giriş | 1 sn | 0.05–10 | Evet |
| Ön boşluk | Kaydırmalı cetvel + sayısal giriş | 0 sn | 0–2 | Evet |
| Karışım | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| Ana sesi koru | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 969. Spektral Frekans Kaydırıcı

**İşlev ve ayrım:** Tüm spektral bileşenleri aynı Hertz miktarıyla taşır; pitch shift frekansları oranla çarpar, bu harmonik olmayan yeni doku üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kaydırma | Kaydırmalı cetvel + sayısal giriş | 30 Hz | −2000–2000 | Evet |
| Karışım | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |
| Stereo ayrım | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 970. Spektral Çözünürlük Bulanıklığı

**İşlev ve ayrım:** Ses spektrumundaki dar tepe yapısını komşu frekanslara yayarak yumuşak ses dokusu oluşturur; EQ belirli bant kazançlarını değiştirir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Frekans yayılımı | Kaydırmalı cetvel + sayısal giriş | 80 Hz | 0–2000 | Evet |
| Zaman yayılımı | Kaydırmalı cetvel + sayısal giriş | 40 ms | 0–500 | Evet |
| Karışım | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 971. Ses Dondurup Sürdürme

**İşlev ve ayrım:** Seçilen kısa ses bölgesini faz tutarlı tekrar ile uzatır; 767 spektral dondurma spektrumunu tutarken bu kaynak döngüsü, başlangıç ve bitiş çapraz geçişleriyle sustain üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Döngü başlangıcı | Kaydırmalı cetvel + sayısal giriş | 0 sn | Klip süresi | Evet |
| Örnek uzunluğu | Kaydırmalı cetvel + sayısal giriş | 80 ms | 10–1000 | Evet |
| Sürdürme | Kaydırmalı cetvel + sayısal giriş | 2 sn | 0.1–60 | Evet |
| Çapraz geçiş | Kaydırmalı cetvel + sayısal giriş | 15 ms | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 972. Çoklu Nota Harmonisi

**İşlev ve ayrım:** Bir vokal/monofonik girişin notasını izleyip seçilen gamda paralel armoni sesleri üretir; koro efektindeki küçük detune yerine ayrı müzikal aralıklar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Gam | Seçim | Majör | Majör/Minör/Özel | Adımlı* |
| Aralık | Seçim | 3 ve 5 | Özel nota aralıkları | Adımlı* |
| Harmoni seviyesi | Kaydırmalı cetvel + sayısal giriş | −12 dB | −40–0 | Evet |
| Stereo dağılım | Kaydırmalı cetvel + sayısal giriş | %40 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 973. Kısa Oda Kutu Sesi

**İşlev ve ayrım:** Sesin küçük kapalı bir mekândaki modal rezonanslarını seçilen boyutlarla hesaplar; genel yankılanmadan farklı dar rezonans modelidir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Boyut | X/Y/Z noktası | 1,1,1 | Metre | Evet |
| Sönüm | Kaydırmalı cetvel + sayısal giriş | %60 | 0–100 | Evet |
| Karışım | Kaydırmalı cetvel + sayısal giriş | %30 | 0–100 | Evet |
| Rezonans tavanı | Kaydırmalı cetvel + sayısal giriş | 12 dB | 0–18 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 974. Ses İçin Paralel Geçiş Ağı

**İşlev ve ayrım:** Birden çok ses filtresinin frekans bölme yapmadan aynı sinyale paralel uygulanmasını ve seviyelerin karıştırılmasını sağlar; seri efekt zinciri değildir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| İşlem kolları | Katman seçici | Yok | Ses efekt grubu | — |
| Kol seviyeleri | Eğri düzenleyici | Eşit | Özel | — |
| Gecikme telafisi | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Çıkış | Kaydırmalı cetvel + sayısal giriş | 0 dB | −30–6 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 975. Kanal Başına Gecikme Düzeltmesi

**İşlev ve ayrım:** Bir stereo/çok kanallı ses kaydındaki zaman farkını analiz ederek kanalları hizalar; 763 stereo gecikme efektinin yaratıcı kaydırmasından farklı otomatik düzeltmedir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Arama sınırı | Kaydırmalı cetvel + sayısal giriş | 20 ms | 1–100 | Evet |
| Referans | Seçim | Sol | Sol/Sağ/İlk kanal | Adımlı* |
| Güç | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |
| Analiz | Buton | Başlat | İçeriğe bağlı | — |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 976. Ses Spektral Denge Eşleme

**İşlev ve ayrım:** Referans kaydın uzun dönem frekans dengesini hedef sese yumuşak eğriyle aktarır; sabit parametrik EQ yerine analiz ve eşleme.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Referans | Katman seçici | Yok | Ses katmanı | — |
| Analiz süresi | Kaydırmalı cetvel + sayısal giriş | 5 sn | 0.5–60 | Evet |
| Düzeltme sınırı | Kaydırmalı cetvel + sayısal giriş | 6 dB | 0–18 | Evet |
| Güç | Kaydırmalı cetvel + sayısal giriş | %70 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 977. Ses Giriş ve Çıkış Zarfı

**İşlev ve ayrım:** Bir kaydın algılanan başlangıç ve kuyruk olaylarını ayrı zarf olarak çıkarır; geçiş şekillendirici transient seviyesini düzenlerken bu animasyon kontrol sinyali üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Ses | Katman seçici | Yok | Ses katmanı | — |
| Başlangıç tepki | Kaydırmalı cetvel + sayısal giriş | 20 ms | 1–500 | Evet |
| Kuyruk tepki | Kaydırmalı cetvel + sayısal giriş | 200 ms | 10–3000 | Evet |
| Çıktı | Seçim | İki kanal | Giriş/Çıkış/İkisi | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 978. Ses Enerji Yönü Görselleştirme

**İşlev ve ayrım:** Stereo kanallardaki frekans başına sol-sağ dağılımı renkli düzlemde gösterir; faz grafiği zaman örneklerinin ilişkisi, burada frekans ve yatay konum vardır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Bant | Tam sayı | 32 | 8–256 | Adımlı* |
| Yumuşatma | Kaydırmalı cetvel + sayısal giriş | 0.2 sn | 0–2 | Evet |
| Alt frekans | Kaydırmalı cetvel + sayısal giriş | 40 Hz | 20–1000 | Evet |
| Üst frekans | Kaydırmalı cetvel + sayısal giriş | 16000 Hz | 1000–20000 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

# Kurgu, görüntü akışı ve geçişler (979–1000)

**Araştırma dayanakları:** [01](https://helpx.adobe.com/after-effects/desktop/apply-effects-and-animation-presets/effects-and-animation-presets/effect-list.html) Adobe After Effects, [02](https://borisfx.com/documentation/sapphire/ae/summary-index/) Boris FX, [03](https://support.apple.com/tr-tr/guide/motion/welcome/mac) Apple Motion, [05](https://ffmpeg.org/ffmpeg-filters.html) FFmpeg, [11](https://docs.kdenlive.org/en/effects_and_filters.html) Kdenlive, [31](https://dyne.org/frei0r/) frei0r, [32](https://www.vapoursynth.com/doc/functions.html) VapourSynth, [33](https://avisynthplus.readthedocs.io/en/latest/avisynthdoc/corefilters.html) AviSynth+, [34](https://www.virtualdub.org/) VirtualDub, [35](https://www.pinnaclesys.com/en/products/studio/) Pinnacle Studio, [36](https://www.openshot.org/features/) OpenShot, [37](https://www.vegascreativesoftware.com/vegas-pro/) VEGAS, [39](https://newbluefx.com/) NewBlue, [40](https://revisionfx.com/) RE:Vision Effects, [64](https://fxfactory.com/) FxFactory, [69](https://aseprite.org/docs/) Aseprite.

Ayarlar uygulama için önerilen başlangıç değerleridir; mevcut kaynak koduyla doğrulanmış değerler değildir. AK = anahtar kare. Adımlı* = yalnız çalışma sırasında değişmesi güvenli olan seçim, anahtar ve tam sayılar; topoloji, örnek bütçesi, analiz gibi ayarlar önbelleği geçersiz kılmalı veya animasyona kapalı kalmalıdır.

## 979. Kamera Pozundan Perspektif Eşleme

**İşlev ve ayrım:** İki karedeki manuel eşleşen düzlem ve ufuk çizgisini kullanarak ikinci görüntünün kamera perspektifini hizalar; 500 izleme zaman boyunca takip, bu iki görüntü arası eşleme.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hedef | Katman seçici | Yok | Katman | — |
| Nokta seti | Seçim | 4 nokta | 4/6/8 | Adımlı* |
| Güç | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |
| Ufku koru | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 980. Kesme Noktası Vuruş Önizlemesi

**İşlev ve ayrım:** İki klip kesmesinin müzikal vuruş ve görüntü hareketi açısından uyuşmasını görselleştirir; otomatik kurgu yapmadan kullanıcıya kesme kaydırma aralığı sunar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Ses | Katman seçici | Yok | Ses katmanı | — |
| Arama | Kaydırmalı cetvel + sayısal giriş | 0.5 sn | 0.05–3 | Evet |
| Ritim ağırlığı | Kaydırmalı cetvel + sayısal giriş | %60 | 0–100 | Evet |
| Hareket uyumu | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 981. Zamansal Kare Yeterliliği Maskesi

**İşlev ve ayrım:** Klipteki tekrar, donma veya sahne kesimlerini ardışık kare karşılaştırmasıyla işaretleyerek zaman maskesi üretir; 386 kare atlama oynatmayı değiştirir, bu analiz yapar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Klip | Katman seçici | Yok | Video | — |
| Benzerlik eşiği | Kaydırmalı cetvel + sayısal giriş | %98 | 0–100 | Evet |
| Donma alt sınırı | Tam sayı | 3 | 2–120 | Adımlı* |
| Çıktı | Seçim | Donma | Donma/Kesme/İkisi | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 982. Doku Eşlemeli Kesme

**İşlev ve ayrım:** İki karedeki benzer yerel doku bölgelerini karşılaştırarak eşleşen yerleri önce değiştirir, renk eşlemeli geçiş tek renk benzerliğine dayanır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hedef | Katman seçici | Yok | Katman | — |
| Doku ölçeği | Kaydırmalı cetvel + sayısal giriş | 12 px | 2–100 | Evet |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| Eşleşme eşiği | Kaydırmalı cetvel + sayısal giriş | %70 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 983. Nesne Arkasından Geçiş

**İşlev ve ayrım:** İzlenen ön plan nesnesinin silüetini sahne değişiminin örtücüsü olarak kullanır, ön planı ayrı maske ile korur; düz wipe'tan farklı gerçek katman örtülmesi.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Ön plan maskesi | Katman seçici | Yok | Katman | — |
| Hedef klip | Katman seçici | Yok | Katman | — |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| Kenar payı | Kaydırmalı cetvel + sayısal giriş | 2 px | 0–40 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 984. Görüntü İçinden Görüntü Geçişi

**İşlev ve ayrım:** İlk klipteki seçilen dörtgen ekranı ikinci kliple doldurup kamera hareketiyle ekran sınırlarını tuval dışına taşır; 161 köşe sabitle tek katman deformasyonu, bu eşlenmiş iki klip animasyonudur.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hedef klip | Katman seçici | Yok | Katman | — |
| Ekran köşeleri | Seçim | Elle | 4 nokta | Adımlı* |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| Kamera eğrisi | Eğri düzenleyici | Yumuşak | Özel | — |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 985. Derinlik Sıralı Sahne Geçişi

**İşlev ve ayrım:** İki klip arasında önce yakın, sonra uzak yüzeyleri değiştirerek üç boyutlu katmanlar halinde sahne açar. İki kaynaklı derinlik sırası gerektirir, 303 tek matı ve 537 dilimleri üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hedef klip | Katman seçici | Yok | Katman | — |
| Derinlik | Katman seçici | Yok | Katman | — |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| Katman geçişi | Kaydırmalı cetvel + sayısal giriş | %12 | 0–100 | Evet |
| Sırayı ters çevir | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 986. Menteşeli Mozaik Geçişi

**İşlev ve ayrım:** Çok sayıdaki küçük panonun birbirine bağlı menteşeler üzerinden sırayla dönmesiyle ikinci görüntüyü açar; kart silme bağımsız kartlar, bu komşu bağlantılı yön ve gecikme.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hedef | Katman seçici | Yok | Katman | — |
| Satır | Tam sayı | 6 | 1–30 | Adımlı* |
| Sütun | Tam sayı | 8 | 1–30 | Adımlı* |
| Gecikme | Kaydırmalı cetvel + sayısal giriş | %40 | 0–100 | Evet |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 987. Eğri Rota Üzerinde Pencere Geçişi

**İşlev ve ayrım:** Bir görüntü penceresini düzenlenebilir eğri boyunca gezdirip geçtiği alanlarda ikinci klibi açar; dairesel açılış sabit merkezli, bu birikimli yol maskesi.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hedef | Katman seçici | Yok | Katman | — |
| Rota | Katman seçici | Yok | Vektör | — |
| Pencere genişliği | Kaydırmalı cetvel + sayısal giriş | 80 px | 1–1000 | Evet |
| İlerleme | Kaydırmalı cetvel + sayısal giriş | %0 | 0–100 | Evet |
| İzi kalıcı tut | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 988. Pencereli Çoklu Zaman Öyküsü

**İşlev ve ayrım:** Aynı klibin birden çok bağımsız zaman noktasını bir panelde gösterir; 621 zaman mozaiği her hücre için düzenli zaman adımı kullanır, bu elle veya olaylara bağlı klip pencereleri.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kaynak | Katman seçici | Yok | Katman | — |
| Pencere | Tam sayı | 4 | 2–16 | Adımlı* |
| Zaman noktaları | Eğri düzenleyici | Özel | Klip süresi | — |
| Boşluk | Kaydırmalı cetvel + sayısal giriş | 8 px | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 989. Kare Sonu Poz Tutma

**İşlev ve ayrım:** Bir hareketin seçilen tamamlanma anında durur, sonrasında yalnız belirlenen arka plan ve efektler akmaya devam eder; genel kare atlama tüm görüntüyü zamanlar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Dondurulacak katman | Katman seçici | Yok | Katman | — |
| Poz zamanı | Kaydırmalı cetvel + sayısal giriş | 1 sn | Klip süresi | Evet |
| Tutma | Kaydırmalı cetvel + sayısal giriş | 0.5 sn | 0–30 | Evet |
| Çıkış yumuşatma | Kaydırmalı cetvel + sayısal giriş | 0.1 sn | 0–2 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 990. Kare Süresi Görselleştirici

**İşlev ve ayrım:** Video karelerinin sunum zaman damgalarını kullanarak kare süreleri, bekleme ve değişken FPS dağılımını renkli zaman şeridinde gösterir; 622 zamanı değiştirirken bu kaynak zamanlamasını analiz eder.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kaynak | Katman seçici | Yok | Video | — |
| Zaman ölçeği | Kaydırmalı cetvel + sayısal giriş | 1 sn | 0.1–60 | Evet |
| Uzun kareleri işaretle | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |
| Uyarı eşiği | Kaydırmalı cetvel + sayısal giriş | 50 ms | 1–500 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 991. Sahne Kesimi Sonrası Renk Uyumlama

**İşlev ve ayrım:** Kesmenin iki yanındaki karelerin renk istatistiklerini karşılaştırıp yalnız geçiş aralığında uyum sağlar; 494 referansa renk eşleme bütün klibe sabit uygulanır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Komşu klip | Katman seçici | Yok | Katman | — |
| Analiz | Kaydırmalı cetvel + sayısal giriş | 0.5 sn | 0.05–5 | Evet |
| Geçiş | Kaydırmalı cetvel + sayısal giriş | 0.3 sn | 0–3 | Evet |
| Güç | Kaydırmalı cetvel + sayısal giriş | %60 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 992. Geçiş Önü Ses Köprüsü

**İşlev ve ayrım:** Görüntü kesilmeden önce ikinci klibin sesini veya sonra ilk klibin sesini duyuracak bağımsız görsel-ses zarfı oluşturur; 770 ses geçişi yalnız çapraz ses karışımıdır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| İkinci klip | Katman seçici | Yok | Katman | — |
| Biçim | Seçim | J | J/L | Adımlı* |
| Ön/son pay | Kaydırmalı cetvel + sayısal giriş | 0.5 sn | 0–10 | Evet |
| Ses geçişi | Kaydırmalı cetvel + sayısal giriş | 0.2 sn | 0–5 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 993. Kadraj Güvenli Alan Kontrolü

**İşlev ve ayrım:** Klipteki belirlenen önemli bölgelerin farklı ekran oranlarında kesilip kesilmediğini işaretler; 795 akıllı kadraj görüntüyü taşır, bu çoklu oran analizi.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Önemli bölgeler | Katman seçici | Yok | Katman | — |
| Oranlar | Seçim | 9:16+16:9 | Çoklu seçim | Adımlı* |
| Güven payı | Kaydırmalı cetvel + sayısal giriş | %5 | 0–25 | Evet |
| İhlal uyarısı | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 994. Döşeme Ek Yeri Onarımı

**İşlev ve ayrım:** Tekrarlanacak görselin karşılıklı kenarlarını renk ve doku sürekliliği için düzeltir; 172 döşeme tekrar eder, bu kaynak dokunun kesintisiz olması için düzenler.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Kenar şeridi | Kaydırmalı cetvel + sayısal giriş | 20 px | 1–500 | Evet |
| Eksen | Seçim | İki eksen | X/Y/İkisi | Adımlı* |
| Doku koruma | Kaydırmalı cetvel + sayısal giriş | %75 | 0–100 | Evet |
| Tekrar önizleme | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 995. Kare Akış Tutarlılığı

**İşlev ve ayrım:** Üretken veya manuel düzenlenmiş karelerde küçük rastgele görünüm değişikliklerini optik akışla komşu kareye bağlı tutar; zamansal gürültü temizleme yerine edit katmanı tutarlılığı.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Düzenleme maskesi | Katman seçici | Yok | Katman | — |
| Bağlılık | Kaydırmalı cetvel + sayısal giriş | %60 | 0–100 | Evet |
| Komşu kare | Tam sayı | 2 | 1–8 | Adımlı* |
| Oklüzyon eşiği | Kaydırmalı cetvel + sayısal giriş | %20 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 996. Zaman Döngüsü Uygunluk Tarayıcı

**İşlev ve ayrım:** Klibin olası başlangıç ve bitiş karelerini görsel benzerliğe ve hareket uyumuna göre sıralar; 689 verilen döngü sınırlarını birleştirir, bu aday aralıkları analiz eder.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| En kısa süre | Kaydırmalı cetvel + sayısal giriş | 0.5 sn | 0.1–20 | Evet |
| En uzun | Kaydırmalı cetvel + sayısal giriş | 5 sn | 0.5–60 | Evet |
| Aday | Tam sayı | 5 | 1–30 | Adımlı* |
| Hareket ağırlığı | Kaydırmalı cetvel + sayısal giriş | %50 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 997. Çoklu Ekran İçerik Dağıtımı

**İşlev ve ayrım:** Tek geniş kompozisyonu farklı boyutlu ekran veya panel bölgelerine gerçek koordinat ve kenar boşluğu ile kırpar; 144 panel döşeme aynı içeriği kopyalar, bu tek kompozisyonu parçalara böler.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Ekran | Tam sayı | 3 | 1–16 | Adımlı* |
| Düzen | Seçim | Elle | Elle/Yatay/Dikey | Adımlı* |
| Çerçeve payı | Kaydırmalı cetvel + sayısal giriş | 10 px | 0–100 | Evet |
| Ekran numaraları | Aç/kapat | Kapalı | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 998. Sanal Kamera Odak Derinliği Takibi

**İşlev ve ayrım:** Hedef katmanın derinlik haritasını takip ederek odak düzlemini sürekli günceller; 123 derinlik bulanıklığı sabit odaklı, bu odak parametresini gerçek zamanlı bağlar.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Hedef | Katman seçici | Yok | Katman | — |
| Derinlik | Katman seçici | Yok | Katman | — |
| Tepki | Kaydırmalı cetvel + sayısal giriş | 0.3 sn | 0–3 | Evet |
| Öncelik | Kaydırmalı cetvel + sayısal giriş | %100 | 0–100 | Evet |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 999. Klip Kenarı Devamlılık Genişletme

**İşlev ve ayrım:** Video sınırlarında komşu karelerin görünür alanlarından içerik alarak kısa dolgu oluşturur; 347 tek arka plan büyütür, bu zamansal hareketle içerik yeniden kullanır.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Genişletme | Kaydırmalı cetvel + sayısal giriş | 50 px | 0–500 | Evet |
| Arama karesi | Tam sayı | 8 | 1–60 | Adımlı* |
| Kenar geçişi | Kaydırmalı cetvel + sayısal giriş | 10 px | 0–100 | Evet |
| Yoksa şeffaf bırak | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

## 1000. Sabit Kamera Çoklu Pozisyon Panosu

**İşlev ve ayrım:** Bir klipte takip edilen nesnenin farklı zamanlardaki konumlarını aynı sabit sahne üzerinde birbirinden ayrı maskelerle yerleştirir; 385 yankı sürekli saydam iz, bu seçilmiş temiz poz grubu üretir.

| Ayar | Kontrol | Önerilen varsayılan | Aralık / seçenek | AK |
|---|---|---|---|---|
| Nesne maskesi | Katman seçici | Yok | Katman | — |
| Poz | Tam sayı | 5 | 2–30 | Adımlı* |
| Zaman aralığı | Kaydırmalı cetvel + sayısal giriş | 0.5 sn | 0.02–10 | Evet |
| Arka planı sabitle | Aç/kapat | Açık | Açık / Kapalı | Adımlı* |

**Kaynak bağı:** Bu Warden Motion önerisi, bölüm başındaki teknik referans ailesinden esinlenir; aynı isimde hazır eklenti bulunduğu anlamına gelmez.

---

# Araştırma kayıtları: 70 kaynak

Erişilen sonuçlar arasında ayrıntılı teknik dokümanlar, ürün katalogları, referans indeksleri ve genel tarama sayfaları bulunur. Bunlar araştırma başlangıçlarıdır; her birinin her alt sayfası okunmuş değildir. Başarısız/kapalı sonuçlar bu listeye eklenmedi. Katalog grupları bu referanslardan esinlenen Warden Motion tasarımlarıdır.

| No | Kaynak | Araştırma konusu |
|---:|---|---|
| 01 | [Adobe After Effects](https://helpx.adobe.com/after-effects/desktop/apply-effects-and-animation-presets/effects-and-animation-presets/effect-list.html) | Efekt kataloğu |
| 02 | [Boris FX](https://borisfx.com/documentation/sapphire/ae/summary-index/) | Sapphire işlem aileleri; Continuum kataloğu ayrıca incelendi |
| 03 | [Apple Motion](https://support.apple.com/tr-tr/guide/motion/welcome/mac) | Filtre, davranış, üretici ve parçacıklar |
| 04 | [Blackmagic Design](https://www.blackmagicdesign.com/products/davinciresolve/fusion) | Birleştirme ve 3B araçları |
| 05 | [FFmpeg](https://ffmpeg.org/ffmpeg-filters.html) | Video/ses filtreleri |
| 06 | [TouchDesigner](https://docs.derivative.ca/TOP) | Görüntü operatörleri ve veri akışı |
| 07 | [OpenCV](https://docs.opencv.org/3.4.18/d2/d96/tutorial_py_table_of_contents_imgproc.html) | Görüntü işleme ve bölütleme |
| 08 | [Blender](https://docs.blender.org/manual/en/3.3/modeling/modifiers/generate/geometry_nodes.html) | Düğümlü geometri yaklaşımı |
| 09 | [GIMP](https://docs.gimp.org/3.0/en/filters.html) | Filtre aileleri |
| 10 | [G’MIC](https://gmic.eu/reference/) | Görüntü işleme, prosedürel filtreler |
| 11 | [Kdenlive](https://docs.kdenlive.org/en/effects_and_filters.html) | Kurgu efektleri ve filtre mimarisi |
| 12 | [Houdini](https://www.sidefx.com/docs/houdini/nodes/) | Düğüm, simülasyon, geometri |
| 13 | [Unity](https://docs.unity3d.com/Packages/com.unity.visualeffectgraph@17.0/manual/Operators.html) | VFX operatör mimarisi |
| 14 | [Godot](https://docs.godotengine.org/en/stable/tutorials/shaders/index.html) | Shader yaklaşımı |
| 15 | [Krita](https://docs.krita.org/en/reference_manual/filters.html) | Çizim filtreleri ve tahribatsız işlem |
| 16 | [scikit-image](https://scikit-image.org/docs/stable/api/api.html) | Ölçüm, morfoloji, dönüşüm |
| 17 | [MathWorks](https://www.mathworks.com/help/images/) | Görüntü analizi ve kayıt |
| 18 | [ImageJ](https://imagej.net/plugins/) | Ölçüm, görüntü işlemleri |
| 19 | [Audacity](https://manual.audacityteam.org/man/effect_menu.html) | Ses efekt grupları |
| 20 | [librosa](https://librosa.org/doc/latest/index.html) | Ses ve müzik analizi |
| 21 | [Essentia](https://essentia.upf.edu/algorithms_reference.html) | Ses öznitelikleri ve ritim |
| 22 | [REAPER](https://www.reaper.fm/reaplugs/) | Ses işleme eklentileri |
| 23 | [Waves](https://www.waves.com/plugins) | Ses eklentisi kataloğu |
| 24 | [FabFilter](https://www.fabfilter.com/products) | Filtre, dinamik ve yaratıcı ses |
| 25 | [MeldaProduction](https://www.meldaproduction.com/effects) | Ses efekt kataloğu |
| 26 | [Airwindows](https://www.airwindows.com/) | Yaratıcı DSP esintileri |
| 27 | [Soundtoys](https://www.soundtoys.com/product/) | Yaratıcı ses ve mekân |
| 28 | [Ableton](https://www.ableton.com/en/live-manual/12/live-audio-effect-reference/) | Ses efekt referansı |
| 29 | [FL Studio](https://www.image-line.com/fl-studio-learning/fl-studio-online-manual/html/effects_plugins.htm) | Ses efekt iş akışı |
| 30 | [Sonic Visualiser](https://www.sonicvisualiser.org/) | Ses analizi ve görselleştirme |
| 31 | [frei0r](https://dyne.org/frei0r/) | Açık filtre ve karıştırıcı mimarisi |
| 32 | [VapourSynth](https://www.vapoursynth.com/doc/functions.html) | Video kare işlemleri |
| 33 | [AviSynth+](https://avisynthplus.readthedocs.io/en/latest/avisynthdoc/corefilters.html) | Video filtreleri |
| 34 | [VirtualDub](https://www.virtualdub.org/) | Filtre arşivi giriş noktası |
| 35 | [Pinnacle Studio](https://www.pinnaclesys.com/en/products/studio/) | Kurgu özellikleri, genel ürün taraması |
| 36 | [OpenShot](https://www.openshot.org/features/) | Kurgu ve animasyon özellikleri |
| 37 | [VEGAS](https://www.vegascreativesoftware.com/vegas-pro/) | Kurgu, renk ve görsel efektler |
| 38 | [Maxon](https://www.maxon.net/en/red-giant) | Parçacık, stil, metin, VFX kategorileri |
| 39 | [NewBlue](https://newbluefx.com/) | Kurgu ve grafik ürünleri; genel tarama |
| 40 | [RE:Vision Effects](https://revisionfx.com/) | Hareket ve video işleme ürünleri |
| 41 | [Paint.NET](https://paint.net/doc/latest/EffectsMenu.html) | Görüntü efekt aileleri |
| 42 | [Pillow](https://pillow.readthedocs.io/en/stable/reference/ImageFilter.html) | Piksel filtreleri |
| 43 | [The Book of Shaders](https://thebookofshaders.com/) | Prosedürel shader teknikleri |
| 44 | [Ronja’s Tutorials](https://www.ronja-tutorials.com/) | Shader örnekleri |
| 45 | [Godot Shaders](https://godotshaders.com/) | Topluluk shader kütüphanesi; lisanslar ayrı |
| 46 | [p5.js](https://p5js.org/reference/) | Üretken çizim ve etkileşim |
| 47 | [Processing](https://processing.org/reference/) | Üretken grafikler |
| 48 | [three.js](https://threejs.org/docs/) | 3B sahne, malzeme, çizim |
| 49 | [Babylon.js](https://www.babylonjs.com/) | 3B grafik motoru; genel tarama |
| 50 | [PixiJS](https://pixijs.com/8.x/guides/components/filters) | 2B GPU filtre mimarisi |
| 51 | [Fabric.js](https://www.fabricjs.com/docs/) | Vektör ve nesne dönüşümleri |
| 52 | [D3](https://d3js.org/) | Veri görselleştirme |
| 53 | [MapLibre](https://maplibre.org/) | Harita çizimi ve stiller |
| 54 | [QGIS](https://docs.qgis.org/3.44/en/docs/user_manual/processing_algs/qgis/index.html) | Coğrafi veri algoritmaları |
| 55 | [GRASS GIS](https://grass.osgeo.org/grass-stable/manuals/) | Coğrafi analiz ve raster/vektör işlemleri |
| 56 | [GDAL](https://gdal.org/en/stable/programs/index.html) | Raster/vektör dönüşümleri |
| 57 | [Synfig](https://www.synfig.org/) | 2B animasyon özellikleri |
| 58 | [OpenToonz](https://opentoonz.readthedocs.io/en/latest/) | Çizgi animasyon iş akışları |
| 59 | [Moho](https://moho.lostmarble.com/) | 2B rig ve animasyon özellikleri |
| 60 | [Manim](https://docs.manim.community/en/stable/reference.html) | Matematik ve grafik animasyonu |
| 61 | [SVGator](https://www.svgator.com/help) | Vektör animasyonu |
| 62 | [Cavalry](https://cavalry.studio/docs/) | Prosedürel hareket tasarımı |
| 63 | [Video Copilot](https://www.videocopilot.net/tutorials/) | VFX ve optik eğitim kataloğu |
| 64 | [FxFactory](https://fxfactory.com/) | Kurgu eklenti kataloğu |
| 65 | [Notch](https://manual.notch.one/2026.2/en/) | Gerçek zamanlı düğümler ve VFX |
| 66 | [Ren’Py](https://www.renpy.org/doc/html/transforms.html) | Görsel dönüşüm ve animasyon |
| 67 | [NVIDIA NPP](https://docs.nvidia.com/cuda/npp/) | Hızlandırılmış görüntü/sinyal işleme |
| 68 | [WebGL Fundamentals](https://webglfundamentals.org/) | Grafik motoru ve shader temelleri |
| 69 | [Aseprite](https://aseprite.org/docs/) | Piksel animasyon ve döşeme |
| 70 | [Affinity](https://www.affinity.studio/photo-editing-software) | Fotoğraf düzenleme; genel tarama |

Ek ayrıntılı başvurular (aynı siteler, 70’e ayrıca eklenmedi):
- [Boris FX Continuum efekt listesi](https://borisfx.com/documentation/continuum/bcc-effects-list/)
- [Boris FX Sapphire özet indeksi](https://borisfx.com/documentation/sapphire/ae/summary-index/)
- [Apple Motion davranış türleri](https://support.apple.com/en-euro/guide/motion/motn95a79a3e/6.4/mac/26.6)
