from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import date

from ..database import get_db
from .. import models, schemas
from ..utils import success_response, error_response


router = APIRouter(
    prefix="/api/stats",
    tags=["city_stats"]
)

# NOT: CREATE/UPDATE/DELETE endpoint'leri kaldırıldı - sadece READ işlemleri

# @router.post - KAPALI (veritabanı hazır)
def _create_stats_disabled(stats: schemas.CityStatsCreate, db: Session = Depends(get_db)):
    """Yeni ağ verisi oluştur"""
    try:
        # Şehir var mı kontrol et
        city = db.query(models.City).filter(models.City.city_id == stats.city_id).first()
        if not city:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"Şehir ID {stats.city_id} bulunamadı", "CITY_NOT_FOUND")
            )
        
        # Bu tarih için veri zaten var mı?
        existing = db.query(models.CityStats).filter(
            models.CityStats.city_id == stats.city_id,
            models.CityStats.date == stats.date
        ).first()
        if existing:
            raise HTTPException(
                status_code=400,
                detail=error_response(
                    f"Bu şehir ve tarih için veri zaten mevcut", 
                    "DUPLICATE_STATS"
                )
            )
        
        db_stats = models.CityStats(**stats.model_dump())
        db.add(db_stats)
        db.commit()
        db.refresh(db_stats)
        
        return success_response(
            data={
                "city_id": db_stats.city_id,
                "date": str(db_stats.date),
                "signal_strength": db_stats.signal_strength,
                "traffic_gb": db_stats.traffic_gb
            },
            message="Ağ verisi başarıyla oluşturuldu"
        )
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Ağ verisi oluşturulurken hata: {str(e)}", "CREATE_ERROR")
        )


@router.get("/")
def get_all_stats(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Tüm ağ verilerini listele"""
    try:
        stats = db.query(models.CityStats).offset(skip).limit(limit).all()
        stats_list = [
            {
                "city_id": s.city_id,
                "date": str(s.date),
                "signal_strength": s.signal_strength,
                "traffic_gb": s.traffic_gb
            }
            for s in stats
        ]
        return success_response(
            data=stats_list,
            message=f"{len(stats_list)} ağ verisi bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Ağ verileri getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.get("/{city_id}")
def get_city_stats(city_id: str, db: Session = Depends(get_db)):
    """Belirli bir şehrin tüm ağ verilerini getir"""
    try:
        stats = db.query(models.CityStats).filter(models.CityStats.city_id == city_id).all()
        stats_list = [
            {
                "city_id": s.city_id,
                "date": str(s.date),
                "signal_strength": s.signal_strength,
                "traffic_gb": s.traffic_gb
            }
            for s in stats
        ]
        return success_response(
            data=stats_list,
            message=f"{len(stats_list)} ağ verisi bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Ağ verileri getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.get("/{city_id}/{date}")
def get_stats_by_date(city_id: str, date: date, db: Session = Depends(get_db)):
    """Belirli bir şehir ve tarihe ait ağ verisini getir"""
    try:
        stats = db.query(models.CityStats).filter(
            models.CityStats.city_id == city_id,
            models.CityStats.date == date
        ).first()
        
        if stats is None:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"Bu şehir ve tarih için veri bulunamadı", "NOT_FOUND")
            )
        
        return success_response(
            data={
                "city_id": stats.city_id,
                "date": str(stats.date),
                "signal_strength": stats.signal_strength,
                "traffic_gb": stats.traffic_gb
            },
            message="Ağ verisi bulundu"
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Ağ verisi getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


# UPDATE ve DELETE endpoint'leri kaldırıldı - READ-ONLY mod
