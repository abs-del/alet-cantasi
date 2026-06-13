---
name: vault-inspector
description: Bir vault HTML dosyasının yapısını, şemasını, öğe sayısını ve büyüklüğünü context-pollute etmeden çıkarır. 12MB'lık vault'u tek seferde okumadan içeriği özetler. Vault şema değişikliklerinden önce ZORUNLU çalıştırılır.
---

# Vault Inspector Skill

Büyük vault HTML'ini bellek-dostu şekilde inceler. Embed-edilmiş `<script id="data" type="application/json">...</script>` veya benzeri data island'ı bulup şemayı çıkarır.

## Kullanım

Claude şu durumlarda bu skill'i çağırır:
- Kullanıcı "PromptVault'un yapısı nedir?" diye sorduğunda
- Yeni alan eklenmeden önce mevcut şema doğrulanırken
- Vault arası migration planı kurulurken
- 5MB'tan büyük herhangi bir vault'a dokunmadan önce

## Yöntem

`scripts/inspect.sh` kullan:

```bash
bash scripts/inspect.sh PromptVault.html
```

Bu script:
1. `wc -l` ve `du -h` ile boyut/satır sayısı
2. `grep -n 'id="data"' file` ile data island konumu
3. `sed -n 'START,ENDp' file | jq` ile sadece şema örneklerini çıkarır (ilk 3 öğe)
4. `jq 'keys'` ile tüm alanları toplar
5. Tag frekansı (öneri 82)
6. Kategori sayısı

Çıktı: ~500 satırlık özet — vault'un tüm 12MB'ı yerine.

## Sınırlar

- ASLA tüm dosyayı `Read` ile okuma. Sadece scripts/inspect.sh çıktısına güven.
- 30 saniyeden fazla sürerse iptal et — bir şey yanlış.
- Çıktıdaki örnek öğeler **temsili**, kullanıcı tüm öğeleri görmek isterse `/vault-grep` komutu önerilir.
