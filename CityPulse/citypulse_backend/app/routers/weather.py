from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import date

from ..database import get_db
from .. import models, schemas
from ..utils import success_response, error_response


router = APIRouter(
    prefix="/api/weather",
    tags=["weather"]
)

# NOT: Sadece READ işlemleri - CREATE/UPDATE/DELETE YOK


@router.get("/")
def get_all_weather(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Tüm hava durumu verilerini listele"""
    try:
        weather_data = db.query(models.CityWeather).offset(skip).limit(limit).all()
        weather_list = [
            {
                "city_id": w.city_id,
                "date": str(w.date),
                "temp_c": w.temp_c,
                "air_quality": w.air_quality
            }
            for w in weather_data
        ]
        return success_response(
            data=weather_list,
            message=f"{len(weather_list)} hava durumu verisi bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Hava durumu verileri getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.get("/{city_id}")
def get_city_weather(city_id: str, db: Session = Depends(get_db)):
    """Belirli bir şehrin tüm hava durumu verilerini getir"""
    try:
        weather_data = db.query(models.CityWeather).filter(
            models.CityWeather.city_id == city_id
        ).all()
        
        weather_list = [
            {
                "city_id": w.city_id,
                "date": str(w.date),
                "temp_c": w.temp_c,
                "air_quality": w.air_quality
            }
            for w in weather_data
        ]
        
        return success_response(
            data=weather_list,
            message=f"{len(weather_list)} hava durumu verisi bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Hava durumu verileri getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.get("/{city_id}/{date}")
def get_weather_by_date(city_id: str, date: date, db: Session = Depends(get_db)):
    """Belirli bir şehir ve tarihe ait hava durumu verisini getir"""
    try:
        weather = db.query(models.CityWeather).filter(
            models.CityWeather.city_id == city_id,
            models.CityWeather.date == date
        ).first()
        
        if weather is None:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"Bu şehir ve tarih için hava durumu bulunamadı", "NOT_FOUND")
            )
        
        return success_response(
            data={
                "city_id": weather.city_id,
                "date": str(weather.date),
                "temp_c": weather.temp_c,
                "air_quality": weather.air_quality
            },
            message="Hava durumu bulundu"
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Hava durumu getirilirken hata: {str(e)}", "FETCH_ERROR")
        )
