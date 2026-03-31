from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Table, func
from sqlalchemy.orm import relationship
from ..database import Base


class ClubGenre(Base):
    __tablename__ = "club_genres"

    club_id = Column(Integer, ForeignKey("clubs.id", ondelete="CASCADE"), primary_key=True)
    genre_id = Column(Integer, ForeignKey("genres.id", ondelete="CASCADE"), primary_key=True)


class Genre(Base):
    __tablename__ = "genres"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), unique=True, nullable=False)
    icon = Column(String(50))

    clubs = relationship("Club", secondary="club_genres", back_populates="genres")


class Club(Base):
    __tablename__ = "clubs"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    slug = Column(String(255), unique=True, nullable=False)
    description = Column(String)
    address = Column(String(500))
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    photo_url = Column(String(500))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    genres = relationship("Genre", secondary="club_genres", back_populates="clubs")
    reviews = relationship("Review", back_populates="club", cascade="all, delete-orphan")
    favourites = relationship("Favourite", back_populates="club", cascade="all, delete-orphan")
