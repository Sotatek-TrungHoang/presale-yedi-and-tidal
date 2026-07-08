# Deployment Guide

**Last updated:** 2026-07-08

## Local Development Setup (Sail)

### Prerequisites
- Docker & Docker Compose installed
- PHP 8.2+ (for local IDE support; not required for Sail)
- Node.js 18+ (for asset compilation)

### Quick Start

```bash
# Clone repository
git clone <repo-url>
cd yedi-tidal-api

# Copy environment template (update as needed)
cp .env.example .env

# Install dependencies
composer install
npm install

# Start Docker containers (MySQL 8, Redis, Mailpit)
./vendor/bin/sail up -d

# Generate app key
./vendor/bin/sail artisan key:generate

# Run migrations
./vendor/bin/sail artisan migrate

# (Optional) Seed with defaults
./vendor/bin/sail artisan db:seed

# Start dev server + queue + assets (concurrent)
composer run dev
```

Services available:
- API: `http://localhost`
- Filament admin: `http://localhost/admin` (login: `admin@example.com` / `password`)
- Mailpit (email testing): `http://localhost:8025`
- MySQL: `localhost:3306` (forward port set in docker-compose.yml)
- Redis: `localhost:6379` (forward port set in docker-compose.yml)

### Before Committing

Ensure Sail containers are running, then stage changes:

```bash
git add .
# Husky pre-commit hook runs Laravel Pint (through Sail)
git commit -m "..."
```

If Pint fails and containers aren't running, start them and commit again.

---

## Production Deployment

### Infrastructure Requirements

- **Compute:** PHP 8.2+, Laravel 11 compatible web server (Apache/Nginx)
- **Database:** MySQL 8.0+
- **Cache/Queue:** Redis 6+
- **File Storage:** S3 or equivalent object storage (required; local storage not supported in prod)
- **Email:** Mailgun account (SMTP alternative possible)
- **External Services:**
  - DocGen service (HTTP endpoint for PDF generation)
  - Google Maps API (geocoding, place photos)
  - Firebase project (FCM push notifications)
  - Sentry account (error tracking, optional)

### Environment Variables (Complete Checklist)

#### Core
```bash
APP_NAME=Yedi-Tidal                     # App name
APP_ENV=production                      # Environment
APP_DEBUG=false                         # Debug mode OFF in production
APP_URL=https://api.example.com         # Public API URL
APP_KEY=base64:...                      # Generated via artisan key:generate
APP_TIMEZONE=UTC                        # Server timezone
APP_CONFIGURATION=yedi                  # Brand: yedi or tidal (separate deployment per brand)
APP_DEEPLINK_URL=app://                 # Mobile deep-link base URL
```

#### Database
```bash
DB_CONNECTION=mysql                     # Database type
DB_HOST=db.example.com                  # Database host
DB_PORT=3306                            # Database port
DB_DATABASE=yedi_tidal                  # Database name
DB_USERNAME=...                         # Database user
DB_PASSWORD=...                         # Database password (secure!)
```

#### Redis & Queues
```bash
REDIS_HOST=redis.example.com            # Redis host
REDIS_PASSWORD=...                      # Redis password (if auth enabled)
REDIS_PORT=6379                         # Redis port
REDIS_CLIENT=phpredis                   # Redis client library
QUEUE_CONNECTION=redis                  # Queue backend (use redis in production)
HORIZON_SUPERVISOR=yedi-v2-supervisor   # Horizon supervisor name
HORIZON_DOMAIN=api.example.com          # Horizon domain
HORIZON_PATH=/horizon                   # Horizon path (must match APP_URL)
```

#### Cache & Session
```bash
CACHE_STORE=redis                       # Cache backend
SESSION_DRIVER=database                 # Session storage (or redis)
SESSION_DOMAIN=.example.com             # Session domain (optional, for cookies)
SANCTUM_STATEFUL_DOMAINS=api.example.com # Sanctum stateful domain list (comma-separated)
```

#### Filesystem
```bash
FILESYSTEM_DISK=s3                      # Default storage disk
AWS_ACCESS_KEY_ID=...                   # S3 access key
AWS_SECRET_ACCESS_KEY=...               # S3 secret (secure!)
AWS_DEFAULT_REGION=eu-west-1            # S3 region
AWS_BUCKET=yedi-tidal-uploads           # S3 bucket name
AWS_URL=https://s3-cdn.example.com      # S3 public CDN URL (for signed URLs)
AWS_ENDPOINT=...                        # S3 endpoint (if not AWS)
AWS_USE_PATH_STYLE_URL=false            # Path style URLs (set true for MinIO)
```

#### Mail
```bash
MAIL_MAILER=mailgun                     # Mail driver
MAILGUN_DOMAIN=notifications.example.com # Mailgun domain
MAILGUN_SECRET=...                      # Mailgun API secret
MAILGUN_ENDPOINT=api.eu.mailgun.net     # Mailgun endpoint (EU or US)
MAIL_FROM_ADDRESS=noreply@example.com   # From address
MAIL_FROM_NAME="Yedi/Tidal"             # From name
```

#### External Services
```bash
# Google Maps (Geocoding, Place Photos)
GOOGLE_MAPS_ENABLED=true                # Enable geocoding
GOOGLE_MAPS_API_KEY=...                 # Google API key

# DocGen (PDF Generation Service)
DOCGEN_URL=https://docgen.example.com/  # DocGen service URL
DOCGEN_USERNAME=...                     # DocGen HTTP Basic username
DOCGEN_PASSWORD=...                     # DocGen HTTP Basic password

# Firebase (Push Notifications)
FIREBASE_CREDENTIALS='{"type":"service_account",...}' # Firebase service account JSON (escaped)

# Sentry (Error Tracking, Optional)
SENTRY_LARAVEL_DSN=https://key@sentry.io/project   # Sentry DSN
SENTRY_ENVIRONMENT=production           # Environment label
SENTRY_RELEASE=v2.0.0                   # Release version
```

#### Monitoring & Features
```bash
AUDITING_ENABLED=true                   # Enable Owen-It auditing
LOG_CHANNEL=single                      # Logging channel
LOG_LEVEL=warning                       # Log level (prod: warning or higher)
```

### Deployment Checklist

1. **Pre-flight**
   - [ ] Clone repository to deployment directory
   - [ ] Create `.env` file with all variables above (use `.env.example` as template)
   - [ ] Run `composer install --no-dev` (production dependencies only)
   - [ ] Run `npm ci` (lock-file based install)
   - [ ] Run `npm run build` (compile assets for production)

2. **Database**
   - [ ] Run `php artisan migrate --force` (run migrations)
   - [ ] (If fresh) Run `php artisan db:seed` (seed initial data)
   - [ ] Verify tables created: `SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'yedi_tidal';`

3. **Cache & Config**
   - [ ] Run `php artisan config:cache` (cache config for performance)
   - [ ] Run `php artisan route:cache` (cache routes)
   - [ ] Run `php artisan view:cache` (cache Blade views)
   - [ ] Verify Redis connection: `php artisan tinker` → `Redis::ping()`

4. **Queue & Scheduling**
   - [ ] Start Horizon worker: `php artisan horizon` (background process or systemd service)
   - [ ] Verify Horizon running: `http://{APP_URL}/horizon` (admin auth required)
   - [ ] Setup Linux cron for Laravel scheduler: `* * * * * php /path/to/artisan schedule:run >> /dev/null 2>&1`

5. **Web Server**
   - [ ] Configure Nginx/Apache to point to `public/` directory
   - [ ] Enable HTTPS (SSL/TLS certificate)
   - [ ] Set document root: `{APP_URL}/public/index.php`
   - [ ] Verify API responding: `curl https://api.example.com/up` (should return 200 OK)

6. **Admin Panel**
   - [ ] Login to Filament: `https://api.example.com/admin` (use seed admin user or create new super admin)
   - [ ] Change default admin password immediately
   - [ ] Configure Settings (charge percentages, invoice terms, contract templates)
   - [ ] Create declarations and required evidence templates

7. **Monitoring & Alerts**
   - [ ] Verify Sentry receiving errors: trigger a test error, check Sentry dashboard
   - [ ] Configure Sentry alerts (Slack, PagerDuty, etc.)
   - [ ] Setup Horizon monitoring (alert on failed jobs)
   - [ ] Monitor MySQL and Redis resources

8. **Testing**
   - [ ] Create test advertiser account
   - [ ] Create test applicant account
   - [ ] Test advert creation → application flow
   - [ ] Verify invoice/payslip generation (check S3 bucket)
   - [ ] Test push notifications (register test FCM token)
   - [ ] Test email delivery (check Mailgun logs)

### Systemd Service File (Horizon)

Create `/etc/systemd/system/yedi-tidal-horizon.service`:

```ini
[Unit]
Description=Yedi/Tidal Horizon Queue Worker
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/yedi-tidal-api
ExecStart=/usr/bin/php /var/www/yedi-tidal-api/artisan horizon
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable & start:
```bash
sudo systemctl enable yedi-tidal-horizon
sudo systemctl start yedi-tidal-horizon
sudo systemctl status yedi-tidal-horizon
```

### Cron for Scheduler

Add to system crontab or use `crontab -e` for www-data user:

```bash
* * * * * cd /var/www/yedi-tidal-api && php artisan schedule:run >> /dev/null 2>&1
```

### Database Backup Strategy

**Daily incremental backups** (example using mysqldump + cron):

```bash
#!/bin/bash
BACKUP_DIR=/backups/yedi-tidal
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
DB_NAME=yedi_tidal
DB_USER=backup_user
DB_PASS=secure_password

mysqldump -h db.example.com -u $DB_USER -p$DB_PASS $DB_NAME \
  | gzip > $BACKUP_DIR/yedi-tidal-$TIMESTAMP.sql.gz

# Keep 7 days of backups
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
```

Add to crontab:
```bash
0 2 * * * /usr/local/bin/backup-yedi-tidal.sh
```

---

## Production Monitoring

### Key Metrics to Watch

| Metric | Tool | Threshold |
|--------|------|-----------|
| API response time | Sentry / APM | < 500ms (p95) |
| Queue depth | Horizon | < 1000 jobs |
| Failed jobs | Horizon | 0 per hour (alert on > 5) |
| Database connections | MySQL | < max_connections / 2 |
| Redis memory | Redis CLI | < 80% of allocated |
| Error rate | Sentry | < 1% of requests |
| Disk space (S3) | AWS CloudWatch | Monitor bucket size |

### Log Aggregation

Configure log forwarding to centralized service:

```bash
# If using ELK stack or similar
LOG_CHANNEL=single
# Pipe logs to log aggregator:
# tail -f storage/logs/laravel.log | filebeat -c filebeat.yml
```

### Horizon Monitoring

Access Horizon dashboard at `https://api.example.com/horizon` (admin auth required).

Monitor:
- Job throughput (completed, failed)
- Worker pool status
- Queue lengths per queue (default, documents, conversions, audits)

---

## Scaling Considerations

### Horizontal Scaling (Multiple App Instances)

1. **Session Storage:** Must use database or Redis (not file-based)
   ```bash
   SESSION_DRIVER=redis
   ```

2. **Queue Sharing:** All instances share same Redis queue (works out of the box)

3. **Load Balancing:** Front with Nginx or AWS ELB; sticky sessions not required (Sanctum tokens are stateless)

4. **File Uploads:** Must use S3 (not local filesystem)

### Vertical Scaling (More Resources)

- Increase PHP-FPM worker count (default 10; tune per CPU cores)
- Increase MySQL connection pool
- Increase Redis memory
- Increase Horizon worker count (`HORIZON_PROCESSES` env var)

---

## Rollback Procedure

If deployment fails or causes issues:

```bash
# Rollback code to previous release
git revert <commit-hash>
# or
git checkout <previous-tag>

# Re-run migrations (if database schema changed in rollback)
php artisan migrate:rollback

# Clear cache
php artisan cache:clear
php artisan route:clear
php artisan config:clear

# Restart queue worker
systemctl restart yedi-tidal-horizon

# Verify health
curl https://api.example.com/up
```

---

## Multi-Tenant Deployment (Two Brands)

Each brand requires separate deployment (separate `APP_CONFIGURATION` env var):

**Yedi Deployment:**
- `APP_CONFIGURATION=yedi`
- URL: `https://api-yedi.example.com`
- Database: `yedi_tidal_yedi` (or shared DB with brand prefixes)
- S3 bucket: `yedi-tidal-uploads-yedi`

**Tidal Deployment:**
- `APP_CONFIGURATION=tidal`
- URL: `https://api-tidal.example.com`
- Database: `yedi_tidal_tidal` (or shared DB with brand prefixes)
- S3 bucket: `yedi-tidal-uploads-tidal`

Both share same code; branding/terminology switched via `___()` helper and `config('app.configuration')`.

---

## Troubleshooting

### Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| "No application encryption key has been specified" | Missing APP_KEY | Run `php artisan key:generate` |
| "Connection refused" to MySQL | DB not running / wrong host | Check DB_HOST, port, credentials |
| Queued jobs not processing | Horizon not running | `systemctl start yedi-tidal-horizon` |
| PDFs not generating | DocGen unreachable | Verify DOCGEN_URL, credentials, network connectivity |
| Push notifications not sent | Firebase credentials invalid | Check FIREBASE_CREDENTIALS JSON format |
| Signed URLs invalid | S3 URL mismatch | Verify AWS_URL matches CloudFront / CDN URL |

### Debug Commands

```bash
# Test database connection
php artisan tinker
>>> DB::connection()->getPdo();

# Test Redis connection
>>> Redis::ping()

# Check queue status
php artisan queue:work --verbose

# View failed jobs
php artisan queue:failed

# Retry failed jobs
php artisan queue:retry <job-id>

# Test mail delivery
php artisan tinker
>>> Mail::to('test@example.com')->send(new TestMail());
```

---

## References

- Full environment checklist: config/ files
- Infrastructure setup: bootstrap/app.php (schedule, routing)
- Queue configuration: config/horizon.php
- Service integrations: config/services.php, app/Http/Integrations/

