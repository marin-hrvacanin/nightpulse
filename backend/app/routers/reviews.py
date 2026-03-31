from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.user import User
from ..models.club import Club
from ..models.review import Review
from ..schemas.review import ReviewCreate, ReviewOut
from ..middleware.auth import get_current_user
from ..services.geo_service import is_within_radius

router = APIRouter(prefix="/reviews", tags=["Reviews"])


@router.post("", response_model=ReviewOut, status_code=status.HTTP_201_CREATED)
def submit_review(
    data: ReviewCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    club = db.query(Club).filter(Club.id == data.club_id).first()
    if not club:
        raise HTTPException(status_code=404, detail="Club not found")

    if not is_within_radius(data.latitude, data.longitude, club.latitude, club.longitude, 300):
        raise HTTPException(
            status_code=403,
            detail="You must be within 300m of the club to submit a review",
        )

    review = Review(
        user_id=current_user.id,
        club_id=data.club_id,
        crowd_rating=data.crowd_rating,
        atmosphere_rating=data.atmosphere_rating,
        music_genre=data.music_genre,
        wait_minutes=data.wait_minutes,
        latitude=data.latitude,
        longitude=data.longitude,
    )
    db.add(review)
    db.commit()
    db.refresh(review)
    return review


@router.get("/mine", response_model=list[ReviewOut])
def my_reviews(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    reviews = (
        db.query(Review)
        .filter(Review.user_id == current_user.id)
        .order_by(Review.created_at.desc())
        .limit(50)
        .all()
    )
    return reviews
