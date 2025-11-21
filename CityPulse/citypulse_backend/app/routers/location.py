from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import Optional

from ..database import get_db
from .. import models
from ..utils import success_response, error_response
from ..geocoding_service import koordinattan_sehir_bul, get_city_id_from_name


router = APIRouter(
    prefix="/api/location",
    tags=["location"]
)


class CoordinateRequest(BaseModel):
    """Koordinat isteği için model"""
    latitude: float = Field(..., ge=-90, le=90, description="Enlem (-90 ile 90 arası)")
    longitude: float = Field(..., ge=-180, le=180, description="Boylam (-180 ile 180 arası)")


@router.post("/find-city")
def find_city_from_coordinates(
    coordinates: CoordinateRequest,
    db: Session = Depends(get_db)
):
    """
    Flutter'dan gelen enlem/boylam bilgisine göre şehir bul
    
    Request Body:
    {
        "latitude": 39.9208,
        "longitude": 32.8541
    }
    
    Response:
    {
        "success": true,
        "data": {
            "city_name": "Ankara",
            "city_id": "06",
            "full_address": "...",
            "coordinates": {
                "latitude": 39.9208,
                "longitude": 32.8541
            }
        }
    }
    """
    try:
        # Koordinattan şehir bul
        result = koordinattan_sehir_bul(coordinates.latitude, coordinates.longitude)
        
        if not result['success']:
            raise HTTPException(
                status_code=404,
                detail=error_response(
                    result.get('error', 'Şehir bulunamadı'),
                    "CITY_NOT_FOUND"
                )
            )
        
        city_name = result['city_name']
        
        # Veritabanında bu şehir var mı kontrol et
        city = db.query(models.City).filter(
            models.City.name.ilike(f"%{city_name}%")
        ).first()
        
        if not city:
            # Şehir veritabanında yok
            return success_response(
                data={
                    "city_name": city_name,
                    "city_id": None,
                    "in_database": False,
                    "full_address": result['full_address'],
                    "district": result.get('district'),
                    "coordinates": {
                        "latitude": coordinates.latitude,
                        "longitude": coordinates.longitude
                    },
                    "message": f"{city_name} veritabanında bulunamadı. Lütfen başka bir şehir seçin."
                },
                message=f"{city_name} şehri tespit edildi ancak veritabanında yok"
            )
        
        # Şehir veritabanında var
        return success_response(
            data={
                "city_name": city.name,
                "city_id": city.city_id,
                "region": city.region,
                "population": city.population,
                "in_database": True,
                "full_address": result['full_address'],
                "district": result.get('district'),
                "coordinates": {
                    "latitude": coordinates.latitude,
                    "longitude": coordinates.longitude
                }
            },
            message=f"{city.name} şehri başarıyla tespit edildi"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(
                f"Konum işlenirken hata: {str(e)}",
                "LOCATION_PROCESSING_ERROR"
            )
        )


@router.get("/find-city")
def find_city_from_coordinates_get(
    latitude: float = Query(..., ge=-90, le=90, description="Enlem"),
    longitude: float = Query(..., ge=-180, le=180, description="Boylam"),
    db: Session = Depends(get_db)
):
    """
    GET metodu ile koordinattan şehir bul (Test için)
    
    Örnek: GET /api/location/find-city?latitude=39.9208&longitude=32.8541
    """
    coordinates = CoordinateRequest(latitude=latitude, longitude=longitude)
    return find_city_from_coordinates(coordinates, db)


@router.get("/city-coordinates/{city_id}")
def get_city_coordinates(city_id: str, db: Session = Depends(get_db)):
    """
    Şehir ID'sinden (plaka kodu) enlem/boylam bilgisi getir
    
    Flutter şehir seçtiğinde bu endpoint'i kullanarak koordinatları alır.
    
    Örnek: GET /api/location/city-coordinates/06
    
    Response:
    {
        "success": true,
        "data": {
            "city_id": "06",
            "city_name": "Ankara",
            "latitude": 39.9334,
            "longitude": 32.8597
        }
    }
    """
    try:
        # Şehir var mı kontrol et
        city = db.query(models.City).filter(models.City.city_id == city_id).first()
        if not city:
            raise HTTPException(
                status_code=404,
                detail=error_response(
                    f"Şehir ID {city_id} bulunamadı",
                    "CITY_NOT_FOUND"
                )
            )
        
        # Geopy ile şehir adından koordinat bul
        from ..geocoding_service import sehirden_koordinat_bul
        
        result = sehirden_koordinat_bul(city.name)
        
        if not result['success']:
            raise HTTPException(
                status_code=404,
                detail=error_response(
                    result.get('error', 'Koordinat bulunamadı'),
                    "COORDINATES_NOT_FOUND"
                )
            )
        
        return success_response(
            data={
                "city_id": city.city_id,
                "city_name": city.name,
                "region": city.region,
                "latitude": result['latitude'],
                "longitude": result['longitude'],
                "full_address": result['full_address']
            },
            message=f"{city.name} koordinatları başarıyla bulundu"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(
                f"Koordinat bulunurken hata: {str(e)}",
                "COORDINATE_FETCH_ERROR"
            )
        )


@router.get("/test-coordinates")
def test_coordinate_service():
    """
    Geocoding servisini test et - örnek koordinatlar
    """
    test_data = [
        {"name": "Altındağ/Ankara", "lat": 39.9414, "lon": 32.8687},
        {"name": "Kızılay/Ankara", "lat": 39.9208, "lon": 32.8541},
        {"name": "Kadıköy/İstanbul", "lat": 41.0422, "lon": 29.0067},
        {"name": "İzmir", "lat": 38.4237, "lon": 27.1428}
    ]
    
    results = []
    for test in test_data:
        result = koordinattan_sehir_bul(test['lat'], test['lon'])
        results.append({
            "test_name": test['name'],
            "coordinates": {"lat": test['lat'], "lon": test['lon']},
            "result": result
        })
    
    return success_response(
        data=results,
        message="Test koordinatları işlendi"
    )
