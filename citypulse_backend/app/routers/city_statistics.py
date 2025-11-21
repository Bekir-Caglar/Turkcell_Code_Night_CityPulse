from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
from typing import Dict, Any

from ..database import get_db
from .. import models
from ..utils import success_response, error_response


router = APIRouter(
    prefix="/api/city-statistics",
    tags=["city_statistics"]
)


@router.get("/{city_id}")
def get_city_weekly_statistics(city_id: str, db: Session = Depends(get_db)):
    """
    Belirli bir şehir için son 1 haftalık istatistikleri hesapla ve döndür.
    
    İstatistikler:
    - Ortalama sinyal gücü
    - İnternet kullanım oranı (ortalama GB)
    - Günlük Paycell işlem sayısı (ortalama)
    - Hava kalitesi (ortalama)
    """
    try:
        # Şehir var mı kontrol et
        city = db.query(models.City).filter(models.City.city_id == city_id).first()
        if not city:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"Şehir ID {city_id} bulunamadı", "CITY_NOT_FOUND")
            )
        
        # Son 1 haftalık tarih aralığını hesapla
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=7)
        
        # ==================== AĞ İSTATİSTİKLERİ ====================
        stats_query = db.query(
            func.avg(models.CityStats.signal_strength).label('avg_signal'),
            func.avg(models.CityStats.traffic_gb).label('avg_traffic'),
            func.count(models.CityStats.date).label('data_count')
        ).filter(
            models.CityStats.city_id == city_id,
            models.CityStats.date >= start_date,
            models.CityStats.date <= end_date
        ).first()
        
        avg_signal_strength = round(float(stats_query.avg_signal), 2) if stats_query.avg_signal else 0
        avg_traffic_gb = round(float(stats_query.avg_traffic), 2) if stats_query.avg_traffic else 0
        stats_data_count = stats_query.data_count if stats_query.data_count else 0
        
        # ==================== PAYCELL İSTATİSTİKLERİ ====================
        paycell_query = db.query(
            func.avg(models.PaycellStats.transactions_count).label('avg_transactions'),
            func.avg(models.PaycellStats.total_amount).label('avg_amount'),
            func.count(models.PaycellStats.date).label('data_count')
        ).filter(
            models.PaycellStats.city_id == city_id,
            models.PaycellStats.date >= start_date,
            models.PaycellStats.date <= end_date
        ).first()
        
        avg_daily_transactions = round(float(paycell_query.avg_transactions), 2) if paycell_query.avg_transactions else 0
        avg_daily_amount = round(float(paycell_query.avg_amount), 2) if paycell_query.avg_amount else 0
        paycell_data_count = paycell_query.data_count if paycell_query.data_count else 0
        
        # ==================== HAVA DURUMU İSTATİSTİKLERİ ====================
        weather_query = db.query(
            func.avg(models.CityWeather.temp_c).label('avg_temp'),
            func.avg(models.CityWeather.air_quality).label('avg_air_quality'),
            func.count(models.CityWeather.date).label('data_count')
        ).filter(
            models.CityWeather.city_id == city_id,
            models.CityWeather.date >= start_date,
            models.CityWeather.date <= end_date
        ).first()
        
        avg_temperature = round(float(weather_query.avg_temp), 2) if weather_query.avg_temp else 0
        avg_air_quality = round(float(weather_query.avg_air_quality), 2) if weather_query.avg_air_quality else 0
        weather_data_count = weather_query.data_count if weather_query.data_count else 0
        
        # ==================== SKORLAR ====================
        scores_query = db.query(
            func.avg(models.CityScore.eco_score).label('avg_eco_score'),
            func.avg(models.CityScore.alerts_count).label('avg_alerts'),
            func.count(models.CityScore.date).label('data_count')
        ).filter(
            models.CityScore.city_id == city_id,
            models.CityScore.date >= start_date,
            models.CityScore.date <= end_date
        ).first()
        
        avg_eco_score = round(float(scores_query.avg_eco_score), 2) if scores_query.avg_eco_score else 0
        avg_alerts = round(float(scores_query.avg_alerts), 2) if scores_query.avg_alerts else 0
        scores_data_count = scores_query.data_count if scores_query.data_count else 0
        
        # ==================== RESPONSE HAZIRLA ====================
        response_data = {
            "city_info": {
                "city_id": city.city_id,
                "name": city.name,
                "region": city.region,
                "population": city.population
            },
            "period": {
                "start_date": str(start_date),
                "end_date": str(end_date),
                "days": 7
            },
            "network_statistics": {
                "avg_signal_strength": avg_signal_strength,
                "avg_internet_usage_gb": avg_traffic_gb,
                "data_points": stats_data_count,
                "description": f"Ortalama sinyal gücü: {avg_signal_strength}, İnternet kullanımı: {avg_traffic_gb} GB"
            },
            "financial_statistics": {
                "avg_daily_transactions": avg_daily_transactions,
                "avg_daily_amount": avg_daily_amount,
                "data_points": paycell_data_count,
                "description": f"Günlük ortalama {avg_daily_transactions} işlem, {avg_daily_amount} TL"
            },
            "weather_statistics": {
                "avg_temperature": avg_temperature,
                "avg_air_quality": avg_air_quality,
                "data_points": weather_data_count,
                "description": f"Ortalama sıcaklık: {avg_temperature}°C, Hava kalitesi: {avg_air_quality}"
            },
            "scores": {
                "avg_eco_score": avg_eco_score,
                "avg_alerts": avg_alerts,
                "data_points": scores_data_count
            },
            "summary": {
                "total_data_points": stats_data_count + paycell_data_count + weather_data_count + scores_data_count,
                "data_availability": {
                    "network": stats_data_count > 0,
                    "financial": paycell_data_count > 0,
                    "weather": weather_data_count > 0,
                    "scores": scores_data_count > 0
                }
            }
        }
        
        return success_response(
            data=response_data,
            message=f"{city.name} şehri için son 7 günlük istatistikler hesaplandı"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"İstatistikler hesaplanırken hata: {str(e)}", "CALCULATION_ERROR")
        )


@router.get("/{city_id}/summary")
def get_city_statistics_summary(city_id: str, db: Session = Depends(get_db)):
    """
    Şehir için özet istatistikler - Flutter için optimize edilmiş basit format
    """
    try:
        # Şehir var mı kontrol et
        city = db.query(models.City).filter(models.City.city_id == city_id).first()
        if not city:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"Şehir ID {city_id} bulunamadı", "CITY_NOT_FOUND")
            )
        
        # Son 1 hafta
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=7)
        
        # Ortalama sinyal gücü
        avg_signal = db.query(func.avg(models.CityStats.signal_strength)).filter(
            models.CityStats.city_id == city_id,
            models.CityStats.date >= start_date
        ).scalar()
        
        # İnternet kullanımı
        avg_traffic = db.query(func.avg(models.CityStats.traffic_gb)).filter(
            models.CityStats.city_id == city_id,
            models.CityStats.date >= start_date
        ).scalar()
        
        # Paycell işlemleri
        avg_transactions = db.query(func.avg(models.PaycellStats.transactions_count)).filter(
            models.PaycellStats.city_id == city_id,
            models.PaycellStats.date >= start_date
        ).scalar()
        
        # Hava kalitesi
        avg_air = db.query(func.avg(models.CityWeather.air_quality)).filter(
            models.CityWeather.city_id == city_id,
            models.CityWeather.date >= start_date
        ).scalar()
        
        return success_response(
            data={
                "city_name": city.name,
                "avg_signal_strength": round(float(avg_signal), 2) if avg_signal else 0,
                "avg_internet_usage_gb": round(float(avg_traffic), 2) if avg_traffic else 0,
                "avg_daily_transactions": round(float(avg_transactions), 2) if avg_transactions else 0,
                "avg_air_quality": round(float(avg_air), 2) if avg_air else 0
            },
            message="Özet istatistikler"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"İstatistikler hesaplanırken hata: {str(e)}", "CALCULATION_ERROR")
        )


def calculate_city_sustainability_score(
    signal_strength: float,
    air_quality: float, 
    traffic_gb: float,
    eco_feedback_ratio: float
) -> float:
    """
    City Sustainability Score hesapla (0-100 arası)
    
    Formül: (sinyal + hava_kalitesi + hız + çevre_mesaj_oranı) / 4
    
    Parametreler:
    - signal_strength: Sinyal gücü (0-100)
    - air_quality: Hava kalitesi (0-100)
    - traffic_gb: İnternet hızı/kullanımı (normalize edilecek)
    - eco_feedback_ratio: Çevre mesaj oranı (0-100)
    """
    
    # Sinyal gücünü 0-100 aralığına normalize et (varsayılan max: 100)
    normalized_signal = min(max(signal_strength, 0), 100)
    
    # Hava kalitesini 0-100 aralığına normalize et (varsayılan max: 100)
    normalized_air = min(max(air_quality, 0), 100)
    
    # İnternet trafiğini 0-100 aralığına normalize et (varsayılan max: 10000 GB)
    # Daha yüksek trafik = daha iyi skor
    normalized_traffic = min((traffic_gb / 10000) * 100, 100)
    
    # Çevre mesaj oranı zaten 0-100 aralığında
    normalized_eco = min(max(eco_feedback_ratio, 0), 100)
    
    # Ortalama hesapla
    score = (normalized_signal + normalized_air + normalized_traffic + normalized_eco) / 4
    
    return round(score, 2)


@router.get("/{city_id}/sustainability-score")
def get_city_sustainability_score(city_id: str, db: Session = Depends(get_db)):
    """
    Belirli bir şehir için City Sustainability Score hesapla (0-100)
    
    Formül: (sinyal + hava_kalitesi + hız + çevre_mesaj_oranı) / 4
    """
    try:
        # Şehir var mı kontrol et
        city = db.query(models.City).filter(models.City.city_id == city_id).first()
        if not city:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"Şehir ID {city_id} bulunamadı", "CITY_NOT_FOUND")
            )
        
        # Son 1 hafta
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=7)
        
        # 1. Ortalama sinyal gücü
        avg_signal = db.query(func.avg(models.CityStats.signal_strength)).filter(
            models.CityStats.city_id == city_id,
            models.CityStats.date >= start_date
        ).scalar() or 0
        
        # 2. Ortalama hava kalitesi
        avg_air_quality = db.query(func.avg(models.CityWeather.air_quality)).filter(
            models.CityWeather.city_id == city_id,
            models.CityWeather.date >= start_date
        ).scalar() or 0
        
        # 3. Ortalama internet trafiği (hız göstergesi)
        avg_traffic = db.query(func.avg(models.CityStats.traffic_gb)).filter(
            models.CityStats.city_id == city_id,
            models.CityStats.date >= start_date
        ).scalar() or 0
        
        # 4. Çevre mesaj oranı hesapla
        # Toplam feedback sayısı
        total_feedback = db.query(func.count(models.CityFeedback.id)).filter(
            models.CityFeedback.city_id == city_id
        ).scalar() or 0
        
        # Çevre kategorisindeki feedback sayısı
        eco_feedback = db.query(func.count(models.CityFeedback.id)).filter(
            models.CityFeedback.city_id == city_id,
            models.CityFeedback.category.in_(['Çevre', 'Yeşil', 'Sürdürülebilirlik', 'Enerji'])
        ).scalar() or 0
        
        # Oran hesapla (0-100)
        eco_feedback_ratio = (eco_feedback / total_feedback * 100) if total_feedback > 0 else 0
        
        # City Sustainability Score hesapla
        sustainability_score = calculate_city_sustainability_score(
            signal_strength=float(avg_signal),
            air_quality=float(avg_air_quality),
            traffic_gb=float(avg_traffic),
            eco_feedback_ratio=eco_feedback_ratio
        )
        
        return success_response(
            data={
                "city_id": city.city_id,
                "city_name": city.name,
                "sustainability_score": sustainability_score,
                "score_details": {
                    "signal_strength": round(float(avg_signal), 2),
                    "air_quality": round(float(avg_air_quality), 2),
                    "internet_traffic_gb": round(float(avg_traffic), 2),
                    "eco_feedback_ratio": round(eco_feedback_ratio, 2)
                },
                "feedback_info": {
                    "total_feedbacks": total_feedback,
                    "eco_feedbacks": eco_feedback
                },
                "period": {
                    "start_date": str(start_date),
                    "end_date": str(end_date)
                }
            },
            message=f"{city.name} için sürdürülebilirlik skoru: {sustainability_score}/100"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Skor hesaplanırken hata: {str(e)}", "SCORE_CALCULATION_ERROR")
        )


@router.get("/leaderboard/green-cities")
def get_green_cities_leaderboard(db: Session = Depends(get_db)):
    """
    Haftanın Yeşil Şehri - En yüksek sürdürülebilirlik skoruna sahip 3 şehir
    
    Tüm şehirler için City Sustainability Score hesaplanır ve en yüksek 3 tanesi döndürülür.
    """
    try:
        # Son 1 hafta
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=7)
        
        # Tüm şehirleri getir
        cities = db.query(models.City).all()
        
        city_scores = []
        
        for city in cities:
            # Her şehir için istatistikleri hesapla
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
            
            # Skor hesapla
            score = calculate_city_sustainability_score(
                signal_strength=float(avg_signal),
                air_quality=float(avg_air_quality),
                traffic_gb=float(avg_traffic),
                eco_feedback_ratio=eco_feedback_ratio
            )
            
            city_scores.append({
                "city_id": city.city_id,
                "city_name": city.name,
                "region": city.region,
                "population": city.population,
                "sustainability_score": score,
                "score_breakdown": {
                    "signal_strength": round(float(avg_signal), 2),
                    "air_quality": round(float(avg_air_quality), 2),
                    "internet_traffic": round(float(avg_traffic), 2),
                    "eco_feedback_ratio": round(eco_feedback_ratio, 2)
                }
            })
        
        # Skora göre sırala (en yüksekten en düşüğe)
        city_scores.sort(key=lambda x: x['sustainability_score'], reverse=True)
        
        # En iyi 3 şehri al
        top_3_cities = city_scores[:3]
        
        # Sıralama ekle
        for idx, city_data in enumerate(top_3_cities, start=1):
            city_data['rank'] = idx
            if idx == 1:
                city_data['badge'] = '🥇 Haftanın En Yeşil Şehri'
            elif idx == 2:
                city_data['badge'] = '🥈 İkinci'
            elif idx == 3:
                city_data['badge'] = '🥉 Üçüncü'
        
        return success_response(
            data={
                "week_period": {
                    "start_date": str(start_date),
                    "end_date": str(end_date)
                },
                "top_3_green_cities": top_3_cities,
                "all_cities_count": len(cities),
                "evaluated_cities_count": len(city_scores)
            },
            message="Haftanın en yeşil 3 şehri"
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Liderlik tablosu hesaplanırken hata: {str(e)}", "LEADERBOARD_ERROR")
        )
