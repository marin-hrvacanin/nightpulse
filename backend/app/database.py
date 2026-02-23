import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASS')}@{os.getenv('DB_HOST')}:5432/{os.getenv('DB_NAME')}?sslmode=require"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def apply_sql_schema(file_path: str):
    """
    Marin's special function for reading external
    SQL file instead of using models.py for SQL practice :)
    """
    with open(file_path, "r") as f:
        sql_script = f.read()
    
    with engine.connect() as connection:
        with connection.begin():
            response = connection.execute(text(sql_script))
    print(response)
    print("SQL Schema Applied Successfully!")