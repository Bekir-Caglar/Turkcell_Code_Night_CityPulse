from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from .. import models, schemas
from ..utils import success_response, error_response


router = APIRouter(
    prefix="/api/cities",
    tags=["cities"]
)

# NOT: CREATE/UPDATE/DELETE endpoint'leri kaldırıldı - sadece READ işlemleri


@router.get("/")
def get_cities(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Tüm şehirleri listele"""
    try:
        cities = db.query(models.City).offset(skip).limit(limit).all()
        cities_list = [
            {
                "city_id": city.city_id,
                "name": city.name,
                "region": city.region,
                "population": city.population
            }
            for city in cities
        ]
        return success_response(
            data=cities_list,
            message=f"{len(cities_list)} şehir bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Şehirler getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.get("/{city_id}")
def get_city(city_id: str, db: Session = Depends(get_db)):
    """Belirli bir şehri ID ile getir"""
    try:
        city = db.query(models.City).filter(models.City.city_id == city_id).first()
        if city is None:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"Şehir ID {city_id} bulunamadı", "NOT_FOUND")
            )
        
        return success_response(
            data={
                "city_id": city.city_id,
                "name": city.name,
                "region": city.region,
                "population": city.population
            },
            message="Şehir bulundu"
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Şehir getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


# UPDATE ve DELETE endpoint'leri kaldırıldı - READ-ONLY mod
