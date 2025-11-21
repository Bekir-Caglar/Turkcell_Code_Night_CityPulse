"""
City Scores tablosundaki eco_score değerlerini güncelleme scripti

Bu script tüm şehirler için sürdürülebilirlik skorunu hesaplar ve 
city_scores tablosundaki eco_score değerlerini günceller.

Kullanım:
    python update_eco_scores.py
"""
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.database import SessionLocal, engine
from app import models
from app.routers.city_statistics import calculate_city_sustainability_score


def update_all_eco_scores():
    """Tüm şehirler ve tarihleri için eco_score değerlerini güncelle"""
    db = SessionLocal()
    
    try:
        print("=" * 70)
        print("🔄 ECO SCORE GÜNCELLEME BAŞLIYOR")
        print("=" * 70)
        
        # Son 1 hafta
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=7)
        
        # Tüm şehirleri getir
        cities = db.query(models.City).all()
        
        total_updated = 0
        total_cities = len(cities)
        
        for idx, city in enumerate(cities, 1):
            print(f"\n[{idx}/{total_cities}] 🏙️  {city.name} (ID: {city.city_id})")
            
            # Her şehir için haftalık istatistikleri hesapla
            avg_signal = db.query(func.avg(models.CityStats.signal_strength)).filter(
                models.CityStats.city_id == city.city_id,
                models.CityStats.date >= start_date
            ).scalar() or 0
            
            avg_air_quality = db.query(func.avg(models.CityWeather.air_quality)).filter(
                models.CityWeather.city_id == city.city_id,
                models.CityWeather.date >= start_date
            ).scalar() or 0
            
            avg_traffic = db.query(func.avg(models.CityStats.traffic_gb)).filter(
                models.CityStats.city_id == city.city_id,
                models.CityStats.date >= start_date
            ).scalar() or 0
            
            total_feedback = db.query(func.count(models.CityFeedback.id)).filter(
                models.CityFeedback.city_id == city.city_id
            ).scalar() or 0
            
            eco_feedback = db.query(func.count(models.CityFeedback.id)).filter(
                models.CityFeedback.city_id == city.city_id,
                models.CityFeedback.category.in_(['Çevre', 'Yeşil', 'Sürdürülebilirlik', 'Enerji'])
            ).scalar() or 0
            
            eco_feedback_ratio = (eco_feedback / total_feedback * 100) if total_feedback > 0 else 0
            
            # Sürdürülebilirlik skorunu hesapla (0-100)
            sustainability_score = calculate_city_sustainability_score(
                signal_strength=float(avg_signal),
                air_quality=float(avg_air_quality),
                traffic_gb=float(avg_traffic),
                eco_feedback_ratio=eco_feedback_ratio
            )
            
            # 0-10 arası normalize et (veritabanında 10 üzerinden)
            eco_score_normalized = round(sustainability_score / 10, 2)
            
            print(f"   📊 Hesaplanan Skor: {sustainability_score}/100 → {eco_score_normalized}/10")
            print(f"      - Sinyal: {avg_signal:.2f}")
            print(f"      - Hava Kalitesi: {avg_air_quality:.2f}")
            print(f"      - Trafik: {avg_traffic:.2f} GB")
            print(f"      - Çevre Feedback: {eco_feedback_ratio:.2f}%")
            
            # Bu şehir için tüm city_scores kayıtlarını güncelle
            city_scores = db.query(models.CityScore).filter(
                models.CityScore.city_id == city.city_id
            ).all()
            
            updated_count = 0
            for score_record in city_scores:
                old_score = score_record.eco_score
                score_record.eco_score = eco_score_normalized
                updated_count += 1
            
            if updated_count > 0:
                db.commit()
                print(f"   ✅ {updated_count} kayıt güncellendi")
                total_updated += updated_count
            else:
                print(f"   ⚠️  Güncellenecek kayıt bulunamadı")
        
        print("\n" + "=" * 70)
        print(f"✨ GÜNCELLEME TAMAMLANDI")
        print(f"📈 Toplam {total_updated} kayıt güncellendi")
        print(f"🏙️  {total_cities} şehir işlendi")
        print("=" * 70)
        
    except Exception as e:
        print(f"\n❌ HATA: {str(e)}")
        db.rollback()
    finally:
        db.close()


def show_eco_scores_comparison():
    """Güncelleme öncesi ve sonrası skorları karşılaştır"""
    db = SessionLocal()
    
    try:
        print("\n" + "=" * 70)
        print("📊 ŞEHİRLERE GÖRE ECO SCORE DEĞERLERİ")
        print("=" * 70)
        
        cities = db.query(models.City).all()
        
        for city in cities:
            # Her şehir için ortalama eco_score
            avg_eco = db.query(func.avg(models.CityScore.eco_score)).filter(
                models.CityScore.city_id == city.city_id
            ).scalar()
            
            # Son eco_score
            latest_score = db.query(models.CityScore).filter(
                models.CityScore.city_id == city.city_id
            ).order_by(models.CityScore.date.desc()).first()
            
            if latest_score:
                print(f"{city.name:20} → Son Skor: {latest_score.eco_score:.2f}/10  |  Ortalama: {avg_eco:.2f}/10")
        
        print("=" * 70)
        
    finally:
        db.close()


if __name__ == "__main__":
    print("\n🚀 City Scores Eco Score Güncelleme Aracı")
    print("\nBu script city_scores tablosundaki eco_score değerlerini")
    print("hesaplanan sürdürülebilirlik skoruyla güncelleyecek.\n")
    
    # Önce mevcut durumu göster
    show_eco_scores_comparison()
    
    # Kullanıcıdan onay al
    response = input("\n⚠️  Veritabanını güncellemek istediğinize emin misiniz? (evet/hayır): ")
    
    if response.lower() in ['evet', 'yes', 'e', 'y']:
        update_all_eco_scores()
        
        # Sonucu göster
        print("\n📋 Güncelleme Sonrası Durum:")
        show_eco_scores_comparison()
    else:
        print("\n❌ İşlem iptal edildi.")
