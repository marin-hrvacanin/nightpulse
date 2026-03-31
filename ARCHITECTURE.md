# NightPulse - System Architecture

## 1. High-Level Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENTS                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                     │
│  │ Android  │  │   iOS    │  │   Web    │                      │
│  │ (Flutter)│  │ (Flutter)│  │ (Flutter)│                      │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                     │
│       └──────────────┼──────────────┘                           │
│                      │ HTTPS                                    │
└──────────────────────┼──────────────────────────────────────────┘
                       │
┌──────────────────────┼──────────────────────────────────────────┐
│                AZURE CLOUD                                      │
│                      │                                          │
│  ┌───────────────────▼───────────────────┐                     │
│  │      Azure App Service / Container    │                     │
│  │    ┌─────────────────────────────┐    │                     │
│  │    │    FastAPI Application      │    │                     │
│  │    │  ┌───────┐  ┌───────────┐   │    │                     │
│  │    │  │ Auth  │  │    API    │   │    │                     │
│  │    │  │(JWT)  │  │ Endpoints │   │    │                     │
│  │    │  └───────┘  └───────────┘   │    │                     │
│  │    │  ┌───────┐  ┌───────────┐   │    │                     │
│  │    │  │ Geo   │  │  Review   │   │    │                     │
│  │    │  │ Logic │  │ Aggregator│   │    │                     │
│  │    │  └───────┘  └───────────┘   │    │                     │
│  │    └─────────────────────────────┘    │                     │
│  └───────────┬───────────────┬───────────┘                     │
│              │               │                                  │
│  ┌───────────▼───────┐ ┌────▼──────────────┐                  │
│  │  Azure Database   │ │  Azure Key Vault   │                  │
│  │  for PostgreSQL   │ │  (secrets, keys)   │                  │
│  │                   │ │                    │                   │
│  │  - users          │ └────────────────────┘                  │
│  │  - clubs          │                                          │
│  │  - reviews        │ ┌────────────────────┐                  │
│  │  - favourites     │ │  Azure Blob Storage │                  │
│  │  - genres         │ │  (club photos,      │                  │
│  └───────────────────┘ │   user avatars)     │                  │
│                        └────────────────────┘                   │
└─────────────────────────────────────────────────────────────────┘
```

## 2. Database Schema

### Entity Relationship Diagram

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────────┐
│    users     │     │      clubs       │     │     genres       │
├──────────────┤     ├──────────────────┤     ├──────────────────┤
│ id (PK)      │     │ id (PK)          │     │ id (PK)          │
│ email        │     │ name             │     │ name             │
│ hashed_pass  │     │ slug             │     │ icon             │
│ full_name    │     │ description      │     └──────────────────┘
│ avatar_url   │     │ address          │
│ preferences  │     │ latitude         │        ┌───────────────┐
│ created_at   │     │ longitude        │        │  club_genres  │
│ updated_at   │     │ photo_url        │        │  (junction)   │
└──────┬───────┘     │ created_at       │        ├───────────────┤
       │             └────────┬─────────┘        │ club_id (FK)  │
       │                      │                  │ genre_id (FK) │
       │                      │                  └───────────────┘
       │                      │
       │    ┌─────────────────┴──────────────────┐
       │    │            reviews                  │
       │    ├─────────────────────────────────────┤
       │    │ id (PK)                             │
       ├───►│ user_id (FK → users)                │
       │    │ club_id (FK → clubs)                │
       │    │ crowd_rating (1-5)                  │
       │    │ atmosphere_rating (1-5)             │
       │    │ music_genre (text)                  │
       │    │ wait_minutes (0-20)                 │
       │    │ latitude (reviewer location)        │
       │    │ longitude (reviewer location)       │
       │    │ created_at                          │
       │    └─────────────────────────────────────┘
       │
       │    ┌─────────────────────────────────────┐
       │    │          favourites                  │
       │    ├─────────────────────────────────────┤
       │    │ id (PK)                             │
       └───►│ user_id (FK → users)                │
            │ club_id (FK → clubs)                │
            │ created_at                          │
            └─────────────────────────────────────┘
```

### SQL Schema

```sql
-- Users table (exists, needs extension)
CREATE TABLE users (
    id              SERIAL PRIMARY KEY,
    email           VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    full_name       VARCHAR(255),
    avatar_url      VARCHAR(500),
    preferences     JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Genres lookup
CREATE TABLE genres (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    icon VARCHAR(50)
);

INSERT INTO genres (name, icon) VALUES
    ('Techno', 'equalizer'),
    ('House', 'headphones'),
    ('Pop', 'music_note'),
    ('Trap', 'mic'),
    ('R&B', 'piano');

-- Clubs
CREATE TABLE clubs (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    slug        VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    address     VARCHAR(500),
    latitude    DOUBLE PRECISION NOT NULL,
    longitude   DOUBLE PRECISION NOT NULL,
    photo_url   VARCHAR(500),
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_clubs_location ON clubs (latitude, longitude);

-- Club-genre junction
CREATE TABLE club_genres (
    club_id  INTEGER REFERENCES clubs(id) ON DELETE CASCADE,
    genre_id INTEGER REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (club_id, genre_id)
);

-- Live reviews (core feature)
CREATE TABLE reviews (
    id                 SERIAL PRIMARY KEY,
    user_id            INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    club_id            INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    crowd_rating       SMALLINT CHECK (crowd_rating BETWEEN 1 AND 5),
    atmosphere_rating  SMALLINT CHECK (atmosphere_rating BETWEEN 1 AND 5),
    music_genre        VARCHAR(50),
    wait_minutes       SMALLINT CHECK (wait_minutes BETWEEN 0 AND 20),
    latitude           DOUBLE PRECISION,
    longitude          DOUBLE PRECISION,
    created_at         TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reviews_club_time ON reviews (club_id, created_at DESC);
CREATE INDEX idx_reviews_user ON reviews (user_id);

-- User favourites
CREATE TABLE favourites (
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    club_id    INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (user_id, club_id)
);
```

## 3. API Design

### Authentication

| Method | Endpoint           | Description                    | Auth     |
|--------|-------------------|--------------------------------|----------|
| POST   | `/auth/register`  | Create account                 | Public   |
| POST   | `/auth/login`     | Get JWT access + refresh token | Public   |
| POST   | `/auth/refresh`   | Refresh expired access token   | Refresh  |
| GET    | `/auth/me`        | Get current user profile       | Bearer   |

**Token strategy:** Short-lived access tokens (15 min) + long-lived refresh tokens (30 days), stored in `httpOnly` cookies on web, secure storage on mobile.

### Clubs

| Method | Endpoint                 | Description                         | Auth   |
|--------|-------------------------|--------------------------------------|--------|
| GET    | `/clubs`                | List clubs (filter by genre, search) | Public |
| GET    | `/clubs/{id}`           | Get club details + live stats        | Public |
| GET    | `/clubs/nearby`         | Get clubs within radius (lat/lng/r)  | Public |
| GET    | `/clubs/{id}/reviews`   | Get recent reviews for a club        | Public |

### Reviews

| Method | Endpoint         | Description                              | Auth   |
|--------|-----------------|------------------------------------------|--------|
| POST   | `/reviews`      | Submit live review (GPS-verified)         | Bearer |
| GET    | `/reviews/mine` | Get current user's review history         | Bearer |

**Geofencing:** Server validates that the reviewer's GPS coordinates are within 300m of the club's coordinates using the Haversine formula. Rejects if outside range.

### Favourites

| Method | Endpoint                    | Description            | Auth   |
|--------|-----------------------------|------------------------|--------|
| GET    | `/favourites`               | Get user's favourites  | Bearer |
| POST   | `/favourites/{club_id}`     | Add to favourites      | Bearer |
| DELETE | `/favourites/{club_id}`     | Remove from favourites | Bearer |

### Users

| Method | Endpoint              | Description              | Auth   |
|--------|-----------------------|--------------------------|--------|
| PUT    | `/users/me`           | Update profile           | Bearer |
| PUT    | `/users/me/preferences` | Update genre preferences | Bearer |
| DELETE | `/users/me`           | Delete account           | Bearer |

### Live Stats (Aggregated)

Each club exposes computed live stats based on reviews from the last 2 hours:

```json
{
  "club_id": 1,
  "name": "THE CLUB",
  "live_stats": {
    "crowd_avg": 4.2,
    "atmosphere_avg": 3.8,
    "top_genre": "Techno",
    "wait_minutes_avg": 12,
    "review_count": 15,
    "last_updated": "2026-03-31T23:45:00Z"
  }
}
```

Reviews older than 2 hours are excluded from live stats but kept for historical analytics.

## 4. Backend Architecture

### Project Structure (Target)

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI app, CORS, lifespan
│   ├── config.py            # Settings from env/Key Vault
│   ├── database.py          # Engine, session, Base
│   │
│   ├── models/              # SQLAlchemy models
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── club.py
│   │   ├── review.py
│   │   └── favourite.py
│   │
│   ├── schemas/             # Pydantic request/response schemas
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── club.py
│   │   ├── review.py
│   │   └── user.py
│   │
│   ├── routers/             # API route handlers
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── clubs.py
│   │   ├── reviews.py
│   │   ├── favourites.py
│   │   └── users.py
│   │
│   ├── services/            # Business logic
│   │   ├── __init__.py
│   │   ├── auth_service.py  # JWT creation, password hashing
│   │   ├── geo_service.py   # Haversine distance, geofencing
│   │   └── stats_service.py # Live stats aggregation
│   │
│   └── middleware/          # Custom middleware
│       ├── __init__.py
│       └── auth.py          # JWT verification dependency
│
├── alembic/                 # Database migrations
│   ├── alembic.ini
│   └── versions/
│
├── tests/
│   ├── conftest.py
│   ├── test_auth.py
│   ├── test_clubs.py
│   └── test_reviews.py
│
├── Dockerfile
├── docker-compose.yml       # Local dev (API + Postgres)
├── requirements.txt
├── .env
└── .env.example
```

### Key Design Decisions

1. **Haversine geofencing** — computed server-side, not client-trusted. The client sends its GPS coords with each review; the server verifies distance <= 300m from the club.

2. **Live stats are computed, not stored** — query reviews from last 2 hours and aggregate (AVG, MODE). For scale, cache with a 60-second TTL.

3. **No WebSockets initially** — the app polls on screen focus / pull-to-refresh. WebSockets can be added later when real-time push is needed.

4. **Alembic migrations** — all schema changes go through Alembic, never raw `CREATE TABLE` in production.

## 5. Frontend Architecture

### Data Flow (Target)

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│   Screens   │────►│   Services   │────►│   FastAPI     │
│  (Widgets)  │◄────│ (ApiService) │◄────│   Backend     │
└─────────────┘     └──────────────┘     └──────────────┘
       │                    │
       │              ┌─────▼──────┐
       │              │  Secure    │
       │              │  Storage   │
       │              │ (JWT token)│
       │              └────────────┘
       │
  ┌────▼─────┐
  │  Models  │
  │ (Dart)   │
  └──────────┘
```

### API Service (Target)

Replace current hardcoded `http://192.168.1.66:8000` with environment-configurable base URL:

```dart
class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',  // Android emulator → host
  );

  // Auth
  static Future<AuthResponse> login(String email, String password);
  static Future<AuthResponse> register(String email, String password, String name);
  static Future<void> logout();

  // Clubs
  static Future<List<Club>> getClubs({String? genre, String? search});
  static Future<Club> getClub(int id);
  static Future<List<Club>> getNearbyClubs(double lat, double lng, {int radius = 300});

  // Reviews
  static Future<void> submitReview(ReviewSubmission review);

  // Favourites
  static Future<List<Club>> getFavourites();
  static Future<void> addFavourite(int clubId);
  static Future<void> removeFavourite(int clubId);
}
```

### Secure Token Storage

- **Android/iOS:** `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences on Android)
- **Web:** `httpOnly` cookies (set by backend)

## 6. Azure Infrastructure

### Required Resources

| Resource                     | SKU / Tier          | Purpose                          |
|------------------------------|---------------------|----------------------------------|
| Azure Database for PostgreSQL| Burstable B1ms      | Primary datastore                |
| Azure App Service            | B1 (Basic)          | Host FastAPI backend             |
| Azure Key Vault              | Standard             | Store DB creds, JWT secret       |
| Azure Blob Storage           | Hot tier             | Club photos, user avatars        |
| Azure Container Registry     | Basic                | Store Docker images              |

### Deployment Pipeline (Target)

```
GitHub Push (main)
       │
       ▼
GitHub Actions
  ├── Run tests (pytest)
  ├── Build Docker image
  ├── Push to Azure Container Registry
  └── Deploy to Azure App Service
```

### Environment Separation

| Environment | Database              | App Service         | Purpose          |
|-------------|----------------------|---------------------|------------------|
| `dev`       | Local Docker Postgres| localhost:8000      | Local development|
| `staging`   | Azure PostgreSQL (staging)| nightpulse-staging.azurewebsites.net | Testing |
| `prod`      | Azure PostgreSQL (prod)  | nightpulse.azurewebsites.net        | Production|

### Key Vault Secrets

```
nightpulse-db-host
nightpulse-db-name
nightpulse-db-user
nightpulse-db-password
nightpulse-jwt-secret
nightpulse-blob-connection-string
```

## 7. Security

- **Passwords:** bcrypt with salt (already implemented via passlib)
- **JWT:** RS256 or HS256 with a strong secret from Key Vault. Access token (15 min), refresh token (30 days)
- **CORS:** Restrict origins to app domains only
- **Rate limiting:** 100 requests/minute per user for review submissions (prevent spam)
- **SQL injection:** Prevented by SQLAlchemy's parameterized queries
- **Input validation:** All inputs validated through Pydantic schemas
- **HTTPS:** Enforced via Azure App Service (TLS termination)
- **GPS spoofing mitigation:** Server-side distance validation. Future: cross-reference with other users at same venue

## 8. Scalability Path

### Phase 1 (Current — MVP)
- Single App Service instance
- Single PostgreSQL instance
- Sufficient for ~1,000 DAU

### Phase 2 (Growth — 10K DAU)
- Add Redis for caching live stats (60s TTL)
- Enable App Service auto-scaling (2-4 instances)
- Add CDN for club photos (Azure Front Door)

### Phase 3 (Scale — 100K+ DAU)
- PostGIS extension for spatial queries
- WebSocket support for real-time updates
- Event-driven architecture (Azure Service Bus) for review processing
- Read replicas for PostgreSQL
- Background workers for stats aggregation
