"""
Feedback mesajlarını kategorilemek için kural tabanlı NLP servisi
"""
from typing import Optional
import re


# Kategori anahtar kelimeleri
CATEGORY_KEYWORDS = {
    "Trafik": [
        # Trafik durumu
        "trafik", "yol", "cadde", "sokak", "bulvar", "kavşak", "köprü",
        "yoğunluk", "sıkışık", "araç", "otobüs", "minibüs", "taksi",
        "park", "otopark", "durak", "kaldırım", "yaya", "kaza",
        # Yol durumu
        "çukur", "bozuk", "asfalt", "kırık", "sinyalizasyon", "ışık",
        "işaret", "levha", "şerit", "yol çalışması", "kapalı yol",
        "viraj", "merdiven", "rampa", "geçit", "şerit", "yol yapımı",
        "trafik lambası", "kırmızı ışık", "yeşil ışık", "trafik cezası",
        "hız", "yavaş", "hızlı", "akış", "tıkanma", "araç yoğunluğu",
        "ulaşım", "toplu taşıma", "metro", "tramvay", "dolmuş"
    ],
    
    "Çevre": [
        # Hava kalitesi
        "hava", "kirli", "temiz", "hava kalitesi", "duman", "egzoz",
        "toz", "koku", "kokulu", "pis", "karbonmonoksit", "pm2.5",
        "hava kirliliği", "smog", "sis", "kirlenme",
        # Yeşil alan
        "park", "yeşil alan", "ağaç", "çiçek", "bahçe", "orman",
        "bitki", "çim", "ot", "peyzaj", "doğa", "mesire",
        # Temizlik
        "çöp", "temizlik", "pis", "kirli", "atık", "pislik",
        "süpürge", "temiz", "hijyen", "kir", "leke", "koku",
        "çöp kutusu", "çöplük", "moloz", "enkaz", "pislik",
        "temizleme", "temizleyici", "çöp toplama", "çöp kamyonu",
        # Genel çevre
        "çevre", "doğa", "sürdürülebilir", "geri dönüşüm", "atık",
        "yeşil", "ekoloji", "enerji tasarrufu", "su tasarrufu"
    ],
    
    "Bağlantı": [
        # İnternet
        "internet", "wifi", "wi-fi", "bağlantı", "ağ", "sinyal",
        "çekmemek", "çekmiyor", "yavaş", "kesik", "kopuk", "bağlanmıyor",
        "mobil veri", "4g", "5g", "3g", "gsm", "mobil", "operatör",
        # Teknik terimler
        "bant genişliği", "hız", "mbps", "latency", "ping", "yükleme",
        "indirme", "donma", "takılma", "gecikmeli", "erişim",
        "bağlanamadım", "bağlanamıyorum", "açılmıyor", "yüklenmiyor",
        # Telekomünikasyon
        "telefon", "arama", "konuşma", "hat", "şebeke", "kapsama",
        "alan", "operatör", "turkcell", "vodafone", "türk telekom",
        "fiber", "adsl", "modem", "router", "access point",
        "hotspot", "ücretsiz internet", "kablosuz", "kablo",
        "baz istasyonu", "çekim gücü", "sinyal gücü"
    ]
}


def temizle_metin(metin: str) -> str:
    """Metni temizle ve normalize et"""
    if not metin:
        return ""
    
    # Küçük harfe çevir
    metin = metin.lower()
    
    # Türkçe karakterleri düzelt
    metin = metin.replace('ı', 'i').replace('ğ', 'g').replace('ü', 'u')
    metin = metin.replace('ş', 's').replace('ö', 'o').replace('ç', 'c')
    
    # Noktalama işaretlerini kaldır
    metin = re.sub(r'[^\w\s]', ' ', metin)
    
    # Fazla boşlukları temizle
    metin = ' '.join(metin.split())
    
    return metin


def kategori_bul(mesaj: str) -> str:
    """
    Mesajı analiz ederek kategori bul
    
    Args:
        mesaj: Kullanıcının gönderdiği feedback mesajı
        
    Returns:
        str: Kategori adı (Trafik, Çevre, Bağlantı, Öneri)
    """
    if not mesaj or not mesaj.strip():
        return "Öneri"
    
    # Metni temizle
    temiz_mesaj = temizle_metin(mesaj)
    
    # Her kategori için eşleşme skorunu hesapla
    kategori_skorlari = {}
    
    for kategori, kelimeler in CATEGORY_KEYWORDS.items():
        skor = 0
        eslesme_sayisi = 0
        
        for kelime in kelimeler:
            temiz_kelime = temizle_metin(kelime)
            
            # Tam kelime eşleşmesi (word boundary)
            pattern = r'\b' + re.escape(temiz_kelime) + r'\b'
            eslesme = len(re.findall(pattern, temiz_mesaj))
            
            if eslesme > 0:
                eslesme_sayisi += eslesme
                # Daha uzun kelimeler daha fazla puan alsın
                skor += eslesme * (len(kelime) / 5)
        
        if eslesme_sayisi > 0:
            kategori_skorlari[kategori] = {
                'skor': skor,
                'eslesme': eslesme_sayisi
            }
    
    # En yüksek skora sahip kategoriyi seç
    if kategori_skorlari:
        en_iyi_kategori = max(
            kategori_skorlari.items(),
            key=lambda x: (x[1]['skor'], x[1]['eslesme'])
        )
        return en_iyi_kategori[0]
    
    # Hiçbir kategoriye uymuyorsa
    return "Öneri"


def kategori_detayli_analiz(mesaj: str) -> dict:
    """
    Mesajı detaylı analiz et ve kategori bilgilerini döndür
    
    Returns:
        dict: {
            'kategori': str,
            'guven_skoru': float (0-100),
            'bulunan_kelimeler': list,
            'analiz_detayi': dict
        }
    """
    if not mesaj or not mesaj.strip():
        return {
            'kategori': 'Öneri',
            'guven_skoru': 0,
            'bulunan_kelimeler': [],
            'analiz_detayi': {}
        }
    
    temiz_mesaj = temizle_metin(mesaj)
    
    tum_skorlar = {}
    tum_kelimeler = {}
    
    for kategori, kelimeler in CATEGORY_KEYWORDS.items():
        skor = 0
        bulunan = []
        
        for kelime in kelimeler:
            temiz_kelime = temizle_metin(kelime)
            pattern = r'\b' + re.escape(temiz_kelime) + r'\b'
            eslesme = len(re.findall(pattern, temiz_mesaj))
            
            if eslesme > 0:
                bulunan.append(kelime)
                skor += eslesme * (len(kelime) / 5)
        
        tum_skorlar[kategori] = skor
        tum_kelimeler[kategori] = bulunan
    
    # En iyi kategoriyi bul
    if any(tum_skorlar.values()):
        en_iyi_kategori = max(tum_skorlar.items(), key=lambda x: x[1])[0]
        en_iyi_skor = tum_skorlar[en_iyi_kategori]
        
        # Güven skorunu hesapla (0-100)
        toplam_skor = sum(tum_skorlar.values())
        guven_skoru = (en_iyi_skor / toplam_skor * 100) if toplam_skor > 0 else 0
        
        return {
            'kategori': en_iyi_kategori,
            'guven_skoru': round(guven_skoru, 2),
            'bulunan_kelimeler': tum_kelimeler[en_iyi_kategori],
            'analiz_detayi': {
                'tum_skorlar': tum_skorlar,
                'mesaj_uzunlugu': len(mesaj),
                'kelime_sayisi': len(mesaj.split())
            }
        }
    else:
        return {
            'kategori': 'Öneri',
            'guven_skoru': 0,
            'bulunan_kelimeler': [],
            'analiz_detayi': {
                'tum_skorlar': tum_skorlar,
                'mesaj_uzunlugu': len(mesaj),
                'kelime_sayisi': len(mesaj.split())
            }
        }


# Test fonksiyonu
if __name__ == "__main__":
    print("🧪 Kategori Tespiti Test Scripti\n")
    print("=" * 60)
    
    test_mesajlari = [
        "Gazi Mahallesi girişinde sinyalizasyon aksaklığı var.",
        "İnternet çok yavaş, wifi bağlantısı sürekli kopuyor.",
        "Parkta çöpler toplanmıyor, çok kirli.",
        "Cadde üzerinde derin çukurlar var, yol bozuk.",
        "Hava çok kirli, egzoz dumanı çok fazla.",
        "Mobil veri çekmiyor, 4G sinyali yok.",
        "Yeni bir bisiklet yolu yapılabilir mi?",
        "Yeşil alan çok az, ağaç dikilmeli.",
        "Trafik çok yoğun, kavşakta ışıklar çalışmıyor.",
        "Bu bölgede daha fazla çöp kutusu olmalı."
    ]
    
    for mesaj in test_mesajlari:
        analiz = kategori_detayli_analiz(mesaj)
        print(f"\n📝 Mesaj: {mesaj}")
        print(f"✅ Kategori: {analiz['kategori']}")
        print(f"📊 Güven: {analiz['guven_skoru']}%")
        if analiz['bulunan_kelimeler']:
            print(f"🔑 Anahtar kelimeler: {', '.join(analiz['bulunan_kelimeler'][:3])}")
        print("-" * 60)
