from sqlalchemy import Column, Integer, String, Float, Boolean, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base


class City(Base):
    """Ana şehir tablosu"""
    __tablename__ = "cities"

    city_id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    region = Column(String, nullable=True)
    population = Column(Integer, nullable=True)

    # İlişkiler
    stats = relationship("CityStats", back_populates="city", cascade="all, delete-orphan")
    weather = relationship("CityWeather", back_populates="city", cascade="all, delete-orphan")
    paycell_stats = relationship("PaycellStats", back_populates="city", cascade="all, delete-orphan")
    scores = relationship("CityScore", back_populates="city", cascade="all, delete-orphan")
    feedbacks = relationship("CityFeedback", back_populates="city", cascade="all, delete-orphan")


class CityStats(Base):
    """Ağ verileri tablosu - Composite Primary Key"""
    __tablename__ = "city_stats"

    city_id = Column(String, ForeignKey("cities.city_id", ondelete="CASCADE"), primary_key=True)
    date = Column(Date, primary_key=True)
    signal_strength = Column(Integer, nullable=True)
    traffic_gb = Column(Integer, nullable=True)

    # İlişki
    city = relationship("City", back_populates="stats")


class CityWeather(Base):
    """Hava durumu tablosu - Composite Primary Key"""
    __tablename__ = "city_weather"

    city_id = Column(String, ForeignKey("cities.city_id", ondelete="CASCADE"), primary_key=True)
    date = Column(Date, primary_key=True)
    temp_c = Column(Float, nullable=True)
    air_quality = Column(Integer, nullable=True)

    # İlişki
    city = relationship("City", back_populates="weather")


class PaycellStats(Base):
    """Finansal veri tablosu - Composite Primary Key"""
    __tablename__ = "paycell_stats"

    city_id = Column(String, ForeignKey("cities.city_id", ondelete="CASCADE"), primary_key=True)
    date = Column(Date, primary_key=True)
    transactions_count = Column(Integer, nullable=True)
    total_amount = Column(Float, nullable=True)

    # İlişki
    city = relationship("City", back_populates="paycell_stats")


class CityScore(Base):
    """Hesaplanan skorlar tablosu - Composite Primary Key"""
    __tablename__ = "city_scores"

    city_id = Column(String, ForeignKey("cities.city_id", ondelete="CASCADE"), primary_key=True)
    date = Column(Date, primary_key=True)
    eco_score = Column(Float, nullable=True)
    alerts_count = Column(Integer, nullable=True)

    # İlişki
    city = relationship("City", back_populates="scores")


class FeedbackCategory(Base):
    """Kategori tanımları tablosu"""
    __tablename__ = "feedback_categories"

    category = Column(String, primary_key=True, index=True)
    description = Column(String, nullable=True)

    # İlişki
    feedbacks = relationship("CityFeedback", back_populates="category_rel", cascade="all, delete-orphan")


class CityFeedback(Base):
    """Kullanıcı mesajları tablosu"""
    __tablename__ = "city_feedback"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    city_id = Column(String, ForeignKey("cities.city_id", ondelete="CASCADE"), nullable=False)
    user = Column(String, nullable=False)
    message = Column(String, nullable=False)
    category = Column(String, ForeignKey("feedback_categories.category", ondelete="CASCADE"), nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow, nullable=False)

    # İlişkiler
    city = relationship("City", back_populates="feedbacks")
    category_rel = relationship("FeedbackCategory", back_populates="feedbacks")
