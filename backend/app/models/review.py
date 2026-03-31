from sqlalchemy import Column, Integer, String, SmallInteger, Float, DateTime, ForeignKey, CheckConstraint, func
from sqlalchemy.orm import relationship
from ..database import Base


class Review(Base):
    __tablename__ = "reviews"
    __table_args__ = (
        CheckConstraint("crowd_rating BETWEEN 1 AND 5", name="ck_crowd_rating"),
        CheckConstraint("atmosphere_rating BETWEEN 1 AND 5", name="ck_atmosphere_rating"),
        CheckConstraint("wait_minutes BETWEEN 0 AND 20", name="ck_wait_minutes"),
    )

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    club_id = Column(Integer, ForeignKey("clubs.id", ondelete="CASCADE"), nullable=False, index=True)
    crowd_rating = Column(SmallInteger, nullable=False)
    atmosphere_rating = Column(SmallInteger, nullable=False)
    music_genre = Column(String(50))
    wait_minutes = Column(SmallInteger, nullable=False)
    latitude = Column(Float)
    longitude = Column(Float)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    user = relationship("User", back_populates="reviews")
    club = relationship("Club", back_populates="reviews")
