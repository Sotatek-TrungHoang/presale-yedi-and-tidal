# Yedi/Tidal API

A Laravel 11 white-label marketplace API connecting advertisers (schools/brands) with applicants (teachers/candidates) for shift-work and gig assignments. Single codebase serves two brands via environment configuration. Includes Filament 3 admin panel for compliance review and advert management.

**What it does:**
- Two-sided marketplace: Advertisers post Adverts (shift-based job postings); Applicants apply after compliance gating (references, declarations, right-to-work, evidence, video verification)
- Compliance enforcement: Admin review of applicant and advertiser profiles before platform access
- Document generation: Contracts, invoices (to advertisers), payslips (to applicants) via external DocGen service
- Financial: Calculates advertiser/applicant pay rates and platform charge percentages; money in GBP via Brick Money
- White-label: `APP_CONFIGURATION=yedi` or `tidal` switches brand terminology, styling, and Filament theme

## Quick Start

### Local development with Sail

```bash
git clone <repo>
cd yedi-tidal-api

# Start Docker containers (MySQL 8, Redis, Mailpit)
./vendor/bin/sail up -d

# Run migrations
./vendor/bin/sail artisan migrate

# Seed with defaults
./vendor/bin/sail artisan db:seed

# Start dev server + queue + assets (concurrent)
composer run dev

# Run tests (if any)
./vendor/bin/sail artisan test
```

Visit `http://localhost` for landing page; `/admin` for Filament (login: `admin@example.com` / `password`).

## Key Resources

- **[CLAUDE.md](./CLAUDE.md)** — Architecture overview, routing, layering, commands
- **[docs/](./docs/)** — Full documentation:
  - `project-overview-pdr.md` — Product overview & requirements
  - `codebase-summary.md` — Directory structure and key files
  - `code-standards.md` — Coding conventions and patterns
  - `system-architecture.md` — System design with diagrams
  - `project-roadmap.md` — Feature inventory and known gaps
  - `deployment-guide.md` — Production setup and environment variables

## Stack

- **Framework:** Laravel 11 (PHP 8.2+)
- **Admin:** Filament 3
- **API Auth:** Laravel Sanctum
- **Database:** MySQL 8 (migrations managed)
- **Cache/Queue:** Redis + Horizon
- **File Storage:** Local (Sail) or S3 (production)
- **Money:** Brick Money (GBP)
- **Auditing:** Owen-It Laravel Auditing (change history)
- **DTOs:** Spatie Data
- **PDF Generation:** External DocGen service (via Saloon)
- **Maps/Geocoding:** Google Maps API
- **Push Notifications:** Firebase FCM
- **Error Tracking:** Sentry
- **Email:** Mailgun (production) or Mailpit (dev)

## Development Notes

- Husky pre-commit hook runs Laravel Pint linting (via Sail) — ensure containers running before commit
- No tests directory yet; PHPUnit config exists but unused
- Scheduling and queue workers run via Horizon; local dev uses `composer run dev`
- Both brands use identical codebase; switching via `APP_CONFIGURATION` env var

## Support

See [CLAUDE.md](./CLAUDE.md) for architecture decisions. Docs folder contains full technical reference.
