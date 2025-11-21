from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# SQLite veritabanı URL'si (proje klasöründe sql_app.db adında bir dosya oluşturulacak)
SQLALCHEMY_DATABASE_URL = "sqlite:///./sql_app.db"

# PostgreSQL kullanmak isterseniz:
# SQLALCHEMY_DATABASE_URL = "postgresql://user:password@localhost/dbname"
    
# Engine oluştur
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, 
    connect_args={"check_same_thread": False}  # SQLite için gerekli
)

# SessionLocal sınıfı - her request için bir veritabanı oturumu
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base sınıfı - tüm modeller bu sınıftan türeyecek
Base = declarative_base()


# Dependency - her request için DB session sağlar
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
