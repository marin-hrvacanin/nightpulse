from datetime import datetime, timedelta, timezone
from collections import Counter
from sqlalchemy.orm import Session
from ..models.review import Review
from ..schemas.club import LiveStats


def get_live_stats(db: Session, club_id: int) -> LiveStats:
    """Aggregate reviews from the last 2 hours into live stats."""
    cutoff = datetime.now(timezone.utc) - timedelta(hours=2)

    reviews = (
        db.query(Review)
        .filter(Review.club_id == club_id, Review.created_at >= cutoff)
        .all()
    )

    if not reviews:
        return LiveStats()

    crowd_ratings = [r.crowd_rating for r in reviews]
    atmosphere_ratings = [r.atmosphere_rating for r in reviews]
    wait_times = [r.wait_minutes for r in reviews]
    genres = [r.music_genre for r in reviews if r.music_genre]

    top_genre = Counter(genres).most_common(1)[0][0] if genres else None
    last_updated = max(r.created_at for r in reviews)

    return LiveStats(
        crowd_avg=round(sum(crowd_ratings) / len(crowd_ratings), 1),
        atmosphere_avg=round(sum(atmosphere_ratings) / len(atmosphere_ratings), 1),
        top_genre=top_genre,
        wait_minutes_avg=round(sum(wait_times) / len(wait_times), 1),
        review_count=len(reviews),
        last_updated=last_updated,
    )
