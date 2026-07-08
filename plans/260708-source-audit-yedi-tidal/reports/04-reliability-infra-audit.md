# Báo cáo Audit 04 — Reliability / Infra (Yedi/Tidal)

Phạm vi: Laravel 11 API + Flutter app (marketplace white-label "Yedi"/"Tidal"). Review tĩnh về vận hành: queue, scheduling, error tracking, hạ tầng, CI/CD, reliability phía app.

Nguồn:
- API: `source/yedi-tidal-api`
- App: `source/yedi-tidal-app`

Quy ước severity: 🔴 Critical · 🟠 High · 🟡 Medium · 🟢 Low.

> **Black-box → source truth**: bản đánh giá black-box trước đó chỉ *giả định* "không có CI/CD, không backup tự động, retry queue yếu". Nay xác nhận từ source: **không có `.github/workflows`, `.gitlab-ci.yml`, fastlane, codemagic ở cả hai repo**; backup/monitoring chỉ tồn tại dưới dạng script thủ công trong `docs/deployment-guide.md`; Horizon đặt `tries => 1` toàn cục, không job nào override retry/backoff/`failed()`.

---

## 1. Queue (Horizon + Redis)

Cấu hình: `config/horizon.php:181-206`. Queues: `default`, `conversions`, `documents`, `audits` (`config/horizon.php:187`). Jobs: `app/Jobs/*` (6 job).

### 🔴 F-R1 — `tries => 1` toàn cục, không retry / backoff / dead-letter thực sự
`config/horizon.php:191` đặt `'tries' => 1`, `'timeout' => 60` cho supervisor mặc định; **không job nào** trong `app/Jobs/*` khai báo `public $tries`, `public $backoff`, `public $retryUntil`, hay `public function failed()`.

Hệ quả: mọi lỗi *transient* (DocGen HTTP timeout, S3 chập chờn, DB deadlock) làm job **fail vĩnh viễn ngay lần đầu**. Các job này tạo tài liệu tài chính/pháp lý:
- `CreateAdvertInvoiceJob` (hóa đơn gửi advertiser) — `app/Jobs/CreateAdvertInvoiceJob.php`
- `CreateAdvertPayslipJob` (payslip gửi applicant) — `app/Jobs/CreateAdvertPayslipJob.php`
- `CreateAdvertiserContractJob` / `CreateApplicantContractJob` (hợp đồng)
- `CreateReferencePdfJob` (PDF reference đã ký)

Job fail → rơi vào bảng `failed_jobs`, không có `failed()` để bù trừ/thông báo. Phục hồi chỉ bằng `queue:retry` thủ công → im lặng mất hóa đơn/payslip cho advert đã hoàn thành. Không ai biết trừ khi soi Horizon.

- **Impact**: mất tài liệu tài chính/pháp lý không cảnh báo; đối soát sai; rủi ro compliance (payslip là nghĩa vụ pháp lý ở UK).
- **Khuyến nghị**: mỗi document-job đặt `public $tries = 3` + `public $backoff = [30, 120, 300]` (exponential); thêm `failed(Throwable $e)` → `report()` + notify admin (Sentry/Slack) + đánh dấu bản ghi để re-dispatch. Với DocGen dùng `RequestException` → phân biệt lỗi 4xx (không retry) vs 5xx/timeout (retry). Cấu hình alert Horizon khi `failed_jobs` tăng.
- **Effort**: 1–1.5 ngày.

### 🟠 F-R2 — Jobs không idempotent, không `ShouldBeUnique`
Không job nào implement `ShouldBeUnique`. `CreateAdvertInvoiceJob` (`app/Jobs/CreateAdvertInvoiceJob.php:72-88`) luôn `make()` invoice mới; nếu bị dispatch 2 lần (xem F-R6) sẽ tạo **2 hóa đơn trùng**. `CreateReferencePdfJob` có guard `status !== PendingConfirmation` (`:38`) — idempotent một phần. `CreateAdvertPayslipJob` luôn tạo payslip mới, không kiểm tra tồn tại.

- **Impact**: hóa đơn/payslip trùng khi retry hoặc scheduler overlap → sai số liệu tài chính.
- **Khuyến nghị**: thêm `ShouldBeUnique` (key theo `advert_id`) cho invoice/payslip; hoặc guard "đã tồn tại invoice/payslip cho advert này thì return". Do dùng `SerializesModels` + `tries=1` hiện tại ít retry, nhưng overlap scheduler (F-R6) vẫn hở.
- **Effort**: 0.5 ngày.

### 🟠 F-R3 — `CreateImageConversionsJob` rò rỉ file tạm + không transaction
`app/Jobs/CreateImageConversionsJob.php:42-46`: tạo `$originalTempPathRelative` trên disk `tmp` nhưng **không bao giờ xóa** (chỉ xóa file conversion tạm ở `:99`). Mỗi lần chạy để lại 1 file gốc trên `storage/app/tmp`. Ngoài ra job không bọc DB transaction; lỗi giữa chừng để lại `image_width/height` đã update nhưng conversions thiếu. `catch` mỗi conversion chỉ `report()` rồi tiếp tục (`:117-119`) → job "thành công" dù thiếu ảnh.

- **Impact**: disk `tmp` phình dần → hết dung lượng → toàn bộ upload/convert fail. Không có cron dọn `tmp`.
- **Khuyến nghị**: `try/finally` xóa `$originalTempPathRelative`; hoặc dùng `Storage::disk('tmp')->delete()` ở cuối. Bổ sung command dọn `tmp` cũ (>1h) vào scheduler.
- **Effort**: 0.5 ngày.

### 🟠 F-R4 — `SerializesModels` + model bị xóa → fail vĩnh viễn
Mọi job nhận full Eloquent model qua constructor (`Queueable` ⇒ `SerializesModels`). Nếu `Advert`/`Reference`/... bị xóa giữa lúc dispatch và lúc worker chạy → `ModelNotFoundException` khi deserialize; với `tries=1` job chết luôn.

- **Impact**: lỗi khó tái hiện, mất document; nhiễu Sentry.
- **Khuyến nghị**: chấp nhận (hiếm) nhưng nên thêm `failed()` để nuốt `ModelNotFoundException` gọn (soft-fail). Kết hợp với F-R1.
- **Effort**: gộp vào F-R1.

### 🟡 F-R5 — Worker OOM risk cho conversions
`config/horizon.php:191` `memory => 128` (MB/worker), production `maxProcesses => 10`. `CreateImageConversionsJob` dùng Spatie Image (GD/Imagick) load full ảnh vào RAM; ảnh lớn dễ vượt 128MB → worker bị kill giữa job → `tries=1` → mất conversion, và file tmp gốc rò rỉ (F-R3).

- **Khuyến nghị**: tách queue `conversions` sang supervisor riêng với `memory` cao hơn (256–512MB) và `maxProcesses` thấp; validate kích thước ảnh đầu vào.
- **Effort**: 0.5 ngày.

---

## 2. Scheduling

Wiring: `bootstrap/app.php:58-68`. **6 command được lịch**, **3 command KHÔNG được lịch** (đính chính: lead ước "2" — thực tế 3).

| Command | Tần suất | Ghi chú |
|---|---|---|
| `ClearExpiredAddressesCommand` | 5 phút | cleanup |
| `ClearExpiredDeviceTokensCommand` | 5 phút | cleanup |
| `ClearExpiredUploadsCommand` | 5 phút | cleanup (forceDelete) |
| `MarkAdvertsAsCompleteCommand` | **mỗi phút** | **dispatch invoice + payslip** (tài chính) |
| `UpdateApprovedAdvertsStatusesCommand` | mỗi phút | đổi status + notify |
| `UpdatePendingAllocationAdvertsStatusesCommand` | mỗi phút | đổi status |
| `PopulateMissingAddressCoordinatesCommand` | **KHÔNG lịch** | backfill lat/long không bao giờ tự chạy |
| `GenerateAdvertiserContractsCommand` | **KHÔNG lịch** | chỉ chạy tay |
| `GenerateApplicantContractsCommand` | **KHÔNG lịch** | chỉ chạy tay |

### 🔴 F-R6 — Không `withoutOverlapping` / `onOneServer` cho command tài chính mỗi phút
`bootstrap/app.php:64-66`: cả 3 advert command chạy `everyMinute()` **không** `withoutOverlapping()` cũng không `onOneServer()`.

`MarkAdvertsAsCompleteCommand` (`app/Console/Commands/Adverts/MarkAdvertsAsCompleteCommand.php:41-55`) duyệt `cursor()`, với mỗi advert: `update(marked_as_completed_at)` **rồi mới** dispatch invoice+payslip. Guard `whereNull('marked_as_completed_at')` (`:43`) chống re-dispatch — **nhưng select-then-update không atomic**. Nếu:
- một lần chạy kéo dài >60s (dữ liệu lớn), hoặc
- deploy đa app-server (production `maxProcesses`/nhiều node),

hai lần chạy có thể cùng select 1 advert trước khi bên nào set `marked_as_completed_at` → **dispatch invoice+payslip 2 lần** → hóa đơn/payslip trùng (nối với F-R2).

- **Impact**: nhân đôi tài liệu tài chính; race không xác định.
- **Khuyến nghị**: thêm `->withoutOverlapping()` + `->onOneServer()` cho cả 3 advert command; bọc select→update trong transaction có `lockForUpdate()` hoặc dùng atomic `update()...->whereNull(...)` trả về số dòng để quyết dispatch.
- **Effort**: 0.5 ngày.

### 🟠 F-R7 — Command không try/catch: 1 bản ghi lỗi làm hỏng cả batch mỗi tick
Các command dùng `cursor()->each(...)` không có try/catch quanh từng bản ghi (vd `UpdateApprovedAdvertsStatusesCommand.php:39-56`). Một advert throw (vd notify handler lỗi, advertiser null) → cả `each` throw → những advert còn lại trong batch bị bỏ qua tick đó, và **tick sau lại vấp đúng advert lỗi đó đầu tiên** → batch kẹt vĩnh viễn ở bản ghi độc.

- **Impact**: một bản ghi hỏng chặn toàn bộ pipeline chuyển trạng thái advert.
- **Khuyến nghị**: bọc `try/catch` mỗi iteration → `report($e)` + continue. Cân nhắc chunk thay vì cursor cho tập lớn.
- **Effort**: 0.5 ngày.

### 🟡 F-R8 — Không có failure visibility cho scheduler
Không command nào dùng `->onFailure()`, `->emailOutputOnFailure()`, `->pingOnFailure()`. Scheduler chạy qua cron (`docs/deployment-guide.md:194`) `>> /dev/null 2>&1` → **output/lỗi bị vứt**. Nếu cron chết hoặc command lỗi liên tục, không ai biết.

- **Khuyến nghị**: thêm heartbeat (`->pingOnSuccess(url)` tới healthchecks.io/Cronitor) cho `schedule:run`; bỏ `>/dev/null` hoặc ghi log riêng.
- **Effort**: 0.5 ngày.

### 🟡 F-R9 — `PopulateMissingAddressCoordinates` không được lịch
`app/Console/Commands/Common/PopulateMissingAddressCoordinatesCommand.php` backfill lat/long (dùng cho geo-matching advert↔applicant) nhưng không nằm trong `withSchedule`. Địa chỉ thiếu tọa độ (do geocoding fail lúc tạo) sẽ **không bao giờ được backfill** trừ khi chạy tay → matching sai.

- **Khuyến nghị**: thêm vào scheduler `->hourly()` với `withoutOverlapping()`, hoặc xác nhận là công cụ vận hành thủ công có chủ đích.
- **Effort**: 0.25 ngày.

---

## 3. Error tracking (Sentry)

Cấu hình `config/sentry.php`, wiring `bootstrap/app.php:56` (`Integration::handles($exceptions)`).

### 🟡 F-R10 — Sentry: DSN gating OK, nhưng sample_rate 100% và SQL breadcrumbs bật
- **DSN gating**: `config/sentry.php:11` `dsn => env('SENTRY_LARAVEL_DSN', env('SENTRY_DSN'))` — nếu env không set thì Sentry no-op (an toàn). ✔
- **PII**: `:36` `send_default_pii => false` — tốt; `:59` `sql_bindings => false` — không log tham số query (tốt). ✔
- **Rủi ro**: `:26` `sample_rate` mặc định **1.0 (100%)** — mọi exception gửi đi; ở production tải cao có thể ngập quota/nhiễu. `:52` SQL **query** breadcrumbs bật (`sql_queries => true`) — query string vẫn có thể lộ dữ liệu nhúng trong SQL (dù binding đã off). `traces_sample_rate` null (tracing off — hợp lý cho chi phí).
- **Khuyến nghị**: đặt `SENTRY_SAMPLE_RATE` ~0.5–1.0 tùy volume; đặt `SENTRY_RELEASE` (hiện null → không gắn version, khó điều tra) từ git hash lúc deploy; cân nhắc `before_send` scrub thêm; xác nhận `SENTRY_ENVIRONMENT` set để tách prod/staging.
- **Effort**: 0.5 ngày.

---

## 4. Hạ tầng / Deployment

### 🟠 F-R11 — Không CORS config, không rate limiting (reliability + DoS)
- **CORS**: không có `config/cors.php` → dùng default Laravel 11 `HandleCors` (`allowed_origins => ['*']`). API mở cho mọi origin.
- **Rate limiting**: `grep throttle|RateLimiter|Limit::` trên `app/`, `routes/`, `bootstrap/` → **0 kết quả**. Không endpoint nào (kể cả login/OTP/signed reference form) bị giới hạn tần suất.

- **Impact**: brute-force auth/OTP; DoS; khuếch đại chi phí DocGen (mỗi request tạo PDF tốn tiền); không có backpressure.
- **Khuyến nghị**: định nghĩa `config/cors.php` với origin cụ thể; áp `throttle:` middleware cho nhóm route `api` và siết chặt hơn cho auth (vd `throttle:5,1`) và signed reference form.
- **Effort**: 0.5 ngày.

### 🟡 F-R12 — Storage mặc định `local` — rủi ro mất dữ liệu ở prod
`config/filesystems.php:17` `default => env('FILESYSTEM_DISK', 'local')`; disk `local` root `storage/app/private` (`:34`). Mọi PDF (invoice/payslip/contract/reference) và upload lưu vào đây nếu prod **quên** set `FILESYSTEM_DISK=s3`. Trên container ephemeral/redeploy → **mất toàn bộ tài liệu**. Không có validation/guard buộc dùng s3 ở production.

- **Khuyến nghị**: ép `FILESYSTEM_DISK=s3` ở prod; thêm health-check/boot assertion cảnh báo nếu `app()->isProduction()` mà disk=local. Đảm bảo signed URL trỏ s3.
- **Effort**: 0.5 ngày.

### 🟠 F-R13 — Không CI/CD, không IaC, không Dockerfile-prod
- `docker-compose.yml` là **Laravel Sail (chỉ dev)** — build từ `vendor/laravel/sail/runtimes/8.4`, mount source, MySQL/Redis/Mailpit. Không có Dockerfile production, không k8s/helm, không Terraform/Ansible.
- Không `.github/workflows`, `.gitlab-ci.yml`, fastlane, codemagic ở **cả hai repo** (xác nhận từ source).
- Husky pre-commit (`.husky/pre-commit`) **chỉ chạy Pint** (format); `phpstan` và `pest` bị **comment out**. Không có cổng test/tĩnh nào chặn commit/PR.
- Deploy hoàn toàn thủ công theo `docs/deployment-guide.md` (checklist bằng tay: cron, supervisor, backup mysqldump script, monitoring checklist).

- **Impact**: không reproducible build; rủi ro drift môi trường; không gate chất lượng; deploy dễ sai người/sai bước; rollback thủ công (`docs/deployment-guide.md:344`).
- **Khuyến nghị**: (1) viết CI tối thiểu (mục 6 báo cáo test): Pint --test + PHPStan + Pest với MySQL service. (2) Dockerfile production multi-stage (php-fpm + horizon + scheduler containers). (3) tự động hóa backup + monitoring (hiện chỉ là doc). (4) app: codemagic/GH Actions `flutter analyze` + `flutter test` + build.
- **Effort**: 2–3 ngày cho baseline CI + Dockerfile prod.

### 🟢 F-R14 — Health endpoint có sẵn
`bootstrap/app.php:22` `health: '/up'` và Sentry ignore `/up` (`config/sentry.php:44`). ✔ Có sẵn để LB/uptime probe. Thiếu: health check sâu (DB/Redis/queue depth) — hiện `/up` chỉ boot framework.
- **Khuyến nghị (low)**: cân nhắc custom health check kiểm tra Redis/DB/Horizon status.

---

## 5. Reliability phía App (Flutter)

### 🔴 F-R15 — Crash reporting TẮT hoàn toàn
Crashlytics bị comment ở **cả 3 nơi**:
- `lib/main.dart:16` import comment; `:62-70` `FlutterError.onError` / `PlatformDispatcher.instance.onError` handlers comment.
- `android/app/build.gradle:5` plugin comment; `android/settings.gradle:24` comment.
- `pubspec.yaml`: không có `firebase_crashlytics`, chỉ `firebase_analytics: ^11.4.1`.

Ứng dụng ~22,424 LOC (22 bloc + 23 cubit) **không có bất kỳ crash visibility production nào**. Crash chỉ thấy qua review store — không stack trace, không breadcrumb.

- **Impact**: mù hoàn toàn về lỗi production trên thiết bị người dùng.
- **Khuyến nghị**: bật lại `firebase_crashlytics` (đã có sẵn Firebase core) hoặc Sentry Flutter; nối `FlutterError.onError` + `PlatformDispatcher.onError`.
- **Effort**: 0.5 ngày.

### 🟠 F-R16 — Không token refresh; interceptor `onError` là no-op; xử lý 401 rời rạc
`lib/modules/api/api.dart:38-41`: `onError` chỉ `handler.next(e)` — **không làm gì**. Không refresh token, không global logout khi 401. Xử lý 401 chỉ tồn tại lẻ tẻ **một chỗ** (`lib/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart:208`); mọi nơi khác 401 nổi lên thành `APIException` chung → UX không nhất quán, user có thể kẹt với token hết hạn.

- **Impact**: hết phiên → hành vi thất thường; không auto-logout/redirect; không gia hạn.
- **Khuyến nghị**: global 401 handler trong interceptor → clear `bearerToken` + điều hướng về login; (Sanctum không có refresh token mặc định → tối thiểu cần logout sạch).
- **Effort**: 0.5–1 ngày.

### 🟠 F-R17 — Không offline / không timeout → app treo trên mạng yếu
`lib/modules/api/api.dart:9-13`: `BaseOptions(baseUrl: ...)` — **không set `connectTimeout`/`receiveTimeout`/`sendTimeout`**. Dio mặc định = **không timeout** → request treo vô hạn trên mạng kém. Không có `connectivity_plus`, không cache, không retry (pubspec không có gói offline nào).

- **Impact**: mạng chập chờn → spinner treo mãi, không thông báo lỗi.
- **Khuyến nghị**: đặt `connectTimeout`/`receiveTimeout` ~15–30s; thêm connectivity check + thông báo offline; cân nhắc retry idempotent (GET).
- **Effort**: 0.5 ngày.

### 🟡 F-R18 — `getCurrentUser` fail bị nuốt im lặng lúc khởi động
`lib/main.dart:39-44`: `try { user = await ...getCurrentUser() } catch (e) { // }` — catch rỗng. Nếu token còn nhưng mạng down/API lỗi lúc mở app → **im lặng coi như chưa đăng nhập**, không phản hồi, user bị đá về landing dù thực ra đã login.

- **Khuyến nghị**: phân biệt lỗi network (giữ trạng thái, hiển thị retry) vs lỗi auth (logout); tối thiểu log/report.
- **Effort**: 0.25 ngày.

---

## 6. Tổng hợp (severity-sorted)

| # | Severity | Vấn đề | Vị trí | Effort |
|---|---|---|---|---|
| F-R1 | 🔴 | `tries=1` toàn cục, không retry/backoff/`failed()` cho job tài chính | `config/horizon.php:191`; `app/Jobs/*` | 1–1.5d |
| F-R6 | 🔴 | Command tài chính mỗi phút không `withoutOverlapping`/`onOneServer` → invoice/payslip trùng | `bootstrap/app.php:64-66`; `MarkAdvertsAsCompleteCommand.php:41-55` | 0.5d |
| F-R15 | 🔴 | Crash reporting (Crashlytics) tắt hoàn toàn trên app 22k LOC | `lib/main.dart:62-70`; `android/app/build.gradle:5`; `pubspec.yaml` | 0.5d |
| F-R2 | 🟠 | Jobs không idempotent, không `ShouldBeUnique` | `app/Jobs/CreateAdvertInvoiceJob.php:72`; `CreateAdvertPayslipJob.php` | 0.5d |
| F-R3 | 🟠 | `CreateImageConversionsJob` rò rỉ file tmp + không transaction | `app/Jobs/CreateImageConversionsJob.php:42-46` | 0.5d |
| F-R4 | 🟠 | `SerializesModels` + model xóa → fail vĩnh viễn | `app/Jobs/*` (Queueable) | gộp F-R1 |
| F-R7 | 🟠 | Command không try/catch mỗi iteration → 1 bản ghi kẹt cả batch | `app/Console/Commands/Adverts/*` | 0.5d |
| F-R11 | 🟠 | Không CORS config, không rate limiting (DoS + brute-force) | thiếu `config/cors.php`; không `throttle` | 0.5d |
| F-R13 | 🟠 | Không CI/CD, không IaC, không Dockerfile-prod; Husky chỉ Pint | `.husky/pre-commit`; `docker-compose.yml` (Sail) | 2–3d |
| F-R16 | 🟠 | Không token refresh; `onError` no-op; xử lý 401 rời rạc | `lib/modules/api/api.dart:38-41` | 0.5–1d |
| F-R17 | 🟠 | Không offline/không timeout Dio → app treo mạng yếu | `lib/modules/api/api.dart:9-13` | 0.5d |
| F-R5 | 🟡 | Worker OOM risk cho conversions (128MB) | `config/horizon.php:191` | 0.5d |
| F-R8 | 🟡 | Scheduler không có failure visibility (cron `>/dev/null`) | `bootstrap/app.php:58-68`; `deployment-guide.md:194` | 0.5d |
| F-R9 | 🟡 | `PopulateMissingAddressCoordinates` không được lịch | `bootstrap/app.php` (thiếu) | 0.25d |
| F-R10 | 🟡 | Sentry sample_rate 100%, không set RELEASE, SQL breadcrumbs bật | `config/sentry.php:26,20,52` | 0.5d |
| F-R12 | 🟡 | Storage mặc định `local` → mất tài liệu nếu prod quên set s3 | `config/filesystems.php:17` | 0.5d |
| F-R18 | 🟡 | `getCurrentUser` fail nuốt im lặng lúc khởi động | `lib/main.dart:39-44` | 0.25d |
| F-R14 | 🟢 | Health `/up` nông (chỉ boot framework) | `bootstrap/app.php:22` | 0.25d |

**Tổng effort khắc phục reliability/infra ước tính: ~9–12 ngày-người** (chưa gồm CI đầy đủ ở báo cáo test).

**Điểm mạnh ghi nhận**: Horizon + Sentry đã cài đặt đúng khung; `send_default_pii=false` + `sql_bindings=false`; health endpoint có sẵn; jobs bọc DB transaction (trừ conversions); scheduler guard `marked_as_completed_at` chống re-dispatch cơ bản.

### Câu hỏi chưa giải đáp
- Production chạy 1 hay nhiều app-server? (quyết định mức độ nghiêm trọng F-R6 — đa server làm race chắc chắn xảy ra).
- `FILESYSTEM_DISK` production thực tế đã set `s3` chưa? (F-R12).
- Có hệ thống alert nào ngoài Sentry (Slack/PagerDuty) để nối `failed()` không?
