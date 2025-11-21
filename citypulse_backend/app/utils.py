"""
Genel yardımcı fonksiyonlar
"""
from typing import Any, Dict


def success_response(data: Any = None, message: str = "İşlem başarılı") -> Dict:
    """Başarılı response formatı - Flutter'da kolayca parse edilebilir"""
    return {
        "success": True,
        "message": message,
        "data": data
    }


def error_response(message: str = "Bir hata oluştu", error_code: str = None) -> Dict:
    """Hata response formatı - Flutter'da kolayca parse edilebilir"""
    response = {
        "success": False,
        "message": message,
        "data": None
    }
    if error_code:
        response["error_code"] = error_code
    return response
