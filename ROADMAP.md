# NightPulse - Development Roadmap

## Current State (Pre-MVP)

**What exists:**
- Flutter UI: 5 main screens (Home, Map, Live Review, Favourites, Profile) + auth screens
- Backend skeleton: FastAPI with user registration endpoint only
- Azure PostgreSQL database provisioned (1 table: `users`)
- Mock data in frontend (5 hardcoded Zagreb clubs)
- No live API integration between frontend and backend

**What's missing for MVP:**
- JWT authentication flow
- Club, review, and favourite endpoints
- Database schema (clubs, reviews, favourites tables)
- Frontend-backend integration
- Geofencing validation
- Deployment pipeline

---

## Phase 1: Backend Foundation (Week 1-2)

> Goal: A working API with auth, clubs, and reviews that the frontend can connect to.

### 1.1 Project Setup
- [ ] Restructure backend into `routers/`, `schemas/`, `services/`, `models/` modules
- [ ] Set up Alembic for database migrations
- [ ] Create `docker-compose.yml` for local dev (API + Postgres)
- [ ] Create `Dockerfile` for the FastAPI app
- [ ] Add `config.py` with pydantic-settings for env management

### 1.2 Authentication
- [ ] Implement `POST /auth/login` — returns JWT access token + refresh token
- [ ] Implement `POST /auth/refresh` — refresh expired access token
- [ ] Implement `GET /auth/me` — return current user profile
- [ ] Add JWT verification middleware/dependency
- [ ] Add CORS middleware (allow Flutter app origins)
- [ ] Extend `users` table: `avatar_url`, `preferences` (JSONB), `created_at`, `updated_at`

### 1.3 Database Schema
- [ ] Create `genres` table with seed data (Techno, House, Pop, Trap, R&B)
- [ ] Create `clubs` table with geolocation fields
- [ ] Create `club_genres` junction table
- [ ] Create `reviews` table with constraint checks
- [ ] Create `favourites` table with unique constraint
- [ ] Seed 5-10 Zagreb clubs with real coordinates
- [ ] Write Alembic migration for all tables

### 1.4 Club Endpoints
- [ ] `GET /clubs` — list with genre filter, search, pagination
- [ ] `GET /clubs/{id}` — detail with computed live stats
- [ ] `GET /clubs/nearby` — geospatial query (lat, lng, radius)

### 1.5 Review Endpoints
- [ ] `POST /reviews` — submit review with GPS verification (Haversine 300m check)
- [ ] `GET /reviews/mine` — current user's review history
- [ ] Live stats aggregation: AVG crowd/atmosphere, MODE genre, AVG wait time from last 2 hours

### 1.6 Favourite Endpoints
- [ ] `GET /favourites` — list user's favourites
- [ ] `POST /favourites/{club_id}` — add
- [ ] `DELETE /favourites/{club_id}` — remove

---

## Phase 2: Frontend Integration (Week 3-4)

> Goal: Replace all mock data with live API calls. Full auth flow works end-to-end.

### 2.1 API Service Rewrite
- [ ] Configurable base URL (env-based, default to `10.0.2.2:8000` for emulator)
- [ ] HTTP client with automatic JWT injection (Authorization header)
- [ ] Token refresh interceptor (auto-refresh on 401)
- [ ] Error handling (network errors, server errors, validation errors)

### 2.2 Auth Integration
- [ ] Login screen calls `POST /auth/login`, stores JWT in secure storage
- [ ] Signup screen calls `POST /auth/register`
- [ ] Onboarding screen calls `PUT /users/me/preferences` to save genre preferences
- [ ] Auto-login on app start if valid token exists
- [ ] Logout clears tokens and navigates to login

### 2.3 Home Screen Integration
- [ ] Fetch clubs from `GET /clubs` with genre filter
- [ ] Search calls `GET /clubs?search=...`
- [ ] Club cards show live stats from API
- [ ] Pull-to-refresh

### 2.4 Map Screen Integration
- [ ] Fetch clubs from `GET /clubs` for markers
- [ ] Bottom sheet shows live stats from API
- [ ] Favourite toggle calls API

### 2.5 Live Review Integration
- [ ] Fetch nearby clubs from `GET /clubs/nearby` using device GPS
- [ ] Request location permission on screen load
- [ ] Submit review calls `POST /reviews` with device coordinates
- [ ] Server validates 300m proximity

### 2.6 Favourites Screen Integration
- [ ] Fetch from `GET /favourites`
- [ ] Remove calls `DELETE /favourites/{club_id}`
- [ ] Empty state when no favourites

### 2.7 Profile Screen Integration
- [ ] Display user data from `GET /auth/me`
- [ ] Stats show real review count, club count
- [ ] Logout and delete account functional

---

## Phase 3: Deployment & DevOps (Week 5)

> Goal: App is deployed on Azure and accessible. CI/CD runs on every push.

### 3.1 Azure Infrastructure
- [ ] Provision Azure App Service (Linux, B1 tier)
- [ ] Provision Azure Container Registry
- [ ] Migrate secrets from `.env` to Azure Key Vault
- [ ] Configure App Service to pull secrets from Key Vault
- [ ] Set up Azure Blob Storage for club photos and avatars

### 3.2 CI/CD Pipeline
- [ ] GitHub Actions workflow: test → build → push → deploy
- [ ] Run `pytest` on every PR
- [ ] Build Docker image and push to ACR on merge to `main`
- [ ] Auto-deploy to App Service on image push
- [ ] Separate staging and production environments

### 3.3 Monitoring
- [ ] Enable Azure Application Insights for the backend
- [ ] Add structured logging (JSON logs)
- [ ] Set up health check endpoint (`GET /health`)
- [ ] Configure Azure alerts for error rate spikes

---

## Phase 4: Polish & Launch Prep (Week 6-7)

> Goal: Production-quality app ready for initial user testing.

### 4.1 Data & Content
- [ ] Populate database with 20-30 real Zagreb clubs (coordinates, photos, genres)
- [ ] Upload club photos to Azure Blob Storage
- [ ] Create admin tooling for club management (script or simple admin panel)

### 4.2 UX Polish
- [ ] Loading skeletons on all data-fetching screens
- [ ] Error states with retry buttons
- [ ] Empty states for all lists
- [ ] Smooth page transitions / animations
- [ ] Push notification permission prompt

### 4.3 Performance
- [ ] Add response caching for club listings (60s)
- [ ] Optimize database queries with proper indexes
- [ ] Lazy-load images with placeholder shimmer

### 4.4 Testing
- [ ] Backend: pytest for all endpoints (auth, clubs, reviews, favourites)
- [ ] Backend: test geofencing edge cases
- [ ] Frontend: widget tests for critical flows
- [ ] Manual E2E testing on Android + iOS

### 4.5 Release
- [ ] Generate signed release APK
- [ ] Set up Google Play Console (internal testing track)
- [ ] Build release IPA (requires Mac + Apple Developer account)
- [ ] Set up TestFlight for iOS beta distribution

---

## Phase 5: Post-Launch (Week 8+)

> Goal: Iterate based on user feedback, add advanced features.

### 5.1 Engagement Features
- [ ] Push notifications ("Club X is heating up right now!")
- [ ] Review streak / gamification (points, badges)
- [ ] Social features (see friends' reviews)
- [ ] Club "trending" algorithm based on review velocity

### 5.2 Scale
- [ ] Add Redis cache for live stats
- [ ] Enable App Service auto-scaling
- [ ] PostGIS for efficient spatial queries
- [ ] CDN for static assets (Azure Front Door)

### 5.3 Advanced Features
- [ ] Club owner dashboard (claim venue, upload photos, see analytics)
- [ ] Event listings (special nights, DJs, promotions)
- [ ] Real-time WebSocket updates for live stats
- [ ] Multi-city expansion (Split, Rijeka, Ljubljana, Belgrade)

---

## Decision Log

| Date       | Decision                                          | Rationale                                            |
|------------|--------------------------------------------------|------------------------------------------------------|
| 2026-03-18 | Flutter for cross-platform                        | Single codebase for Android, iOS, Web                |
| 2026-03-18 | FastAPI for backend                               | Async, fast, auto-docs, team knows Python            |
| 2026-03-18 | Azure PostgreSQL                                  | Already provisioned, team has Azure access            |
| 2026-03-18 | No WebSockets in MVP                              | Poll-based refresh is simpler, sufficient for launch |
| 2026-03-18 | Croatian UI language                              | Target market is Zagreb                              |
| 2026-03-31 | JWT over session auth                             | Better fit for mobile apps, stateless backend        |
| 2026-03-31 | 2-hour review window for live stats               | Balances freshness with having enough data points    |
| 2026-03-31 | 300m geofence server-side validation              | Prevents fake reviews, core trust mechanism          |
