# Kullanıcının rehbere ek istekleri

## 801 Savrulan Glitch — iki ayar
- **Uzaklık** (K, px, varsayılan 200, 0–3000): glitch parçalarının kaynaktan en fazla ne kadar uzağa gidebileceği.
  Rehberdeki "Azami uzaklık" ayarı bu ayardır; ayrı ikinci bir mesafe ayarı yapılmaz, adı "Uzaklık" olur.
- **Yayılım** (K, %, varsayılan 50, 0–100): parçaların bu en fazla mesafe içinde ne kadar dağılacağı.
  %0: hepsi aynı mesafeye (Uzaklık değerine) gider, dar bir şerit halinde.
  %100: her parça 0 ile Uzaklık arasında tohuma bağlı farklı bir mesafeye gider; yön sapmasıyla birlikte geniş bir yelpazeye yayılır.
