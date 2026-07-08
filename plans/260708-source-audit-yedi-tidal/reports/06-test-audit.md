# Báo cáo Audit 06 — Test Coverage & Testability (Yedi/Tidal)

Phạm vi: đánh giá độ phủ test + khả năng test (testability) của Laravel 11 API và Flutter app; đề xuất bộ test harness tối thiểu và CI gate.

Nguồn:
- API: `source/yedi-tidal-api`
- App: `source/yedi-tidal-app`

Quy ước severity: 🔴 Critical · 🟠 High · 🟡 Medium · 🟢 Low.

> **Black-box → source truth**: black-box trước đó chỉ *giả định* "gần như không có test". Nay xác nhận từ source: **API có 0 file test** (thư mục `tests/Unit`, `tests/Feature` không có file nào); **App chỉ có 2 file boilerplate** (assert `1+1==2` và pump `Text('Hello')`). Harness PHPUnit **đã cấu hình sẵn** nhưng rỗng.

---

## 1. Hiện trạng độ phủ

### 1.1 API — 0 test thực (🔴 F-T1)
- `phpunit.xml` cấu hình đầy đủ: suite `Unit` (`tests/Unit`) + `Feature` (`tests/Feature`); env test: `DB_DATABASE=testing`, `QUEUE_CONNECTION=sync`, `CACHE_STORE=array`, `SESSION_DRIVER=array`, `MAIL_MAILER=array`, `BCRYPT_ROUNDS=4`, `TELESCOPE_ENABLED=false`, `PULSE_ENABLED=false`.
- Thực tế: `find tests -type f` → **rỗng**. Không có `tests/Unit/*`, không có `tests/Feature/*`, không có `TestCase.php` tùy biến, không có `Pest.php`.
- Chỉ tồn tại `database/factories/UserFactory.php` (1 factory duy nhất). Không factory cho `Advert`, `Application`, `Applicant`, `Advertiser`, `Reference`, `Invoice`, `Payslip`...
- README thừa nhận: "Run tests (if any)" (`README.md:35`).

**Kết luận**: harness sẵn sàng, **0% độ phủ** trên toàn bộ domain tài chính/compliance/lifecycle.

### 1.2 App — 2 file boilerplate, ~0% (🔴 F-T2)
- `test/unit_test.dart`: chỉ `expect(1 + 1, 2)`.
- `test/widget_test.dart`: pump `MaterialApp(Scaffold(body: Text('Hello')))`, assert `findsOneWidget`.
- Codebase: **22,424 LOC** Dart (`lib/**/*.dart`), **22 bloc + 23 cubit** (45 state-machine) → **0 test thực**.
- `dev_dependencies` (`pubspec.yaml`): chỉ `flutter_test`, `flutter_lints`, `custom_lint`, `flutter_env_native`. **Không có `bloc_test`, `mocktail`/`mockito`, `golden_toolkit`** → chưa có công cụ để test bloc/mock.

**Kết luận**: ~0% độ phủ trên app; không có hạ tầng test.

---

## 2. Đánh giá Testability (khả năng test)

### 2.1 API — testability TỐT (điểm mạnh)
Kiến trúc Handler/DTO có seam rõ, dễ test:

- **Charge/pay math là pure computed accessors** — ứng viên vàng cho unit test, **không cần DB**:
  - `app/Models/Advert.php:135-188`: `totalAdvertiserPay`, `advertiserChargeRate`, `advertiserCharge`, `applicantChargeRate`, `applicantCharge` — thuần toán `Brick\Money` với `RoundingMode::HALF_UP`, phân nhánh `PayType::Hourly/Daily`. Logic tài chính cốt lõi, hiện **0 test** → rủi ro sai tiền cao nhất, ROI test cao nhất.
  - VAT 20% + due date trong `CreateAdvertInvoiceJob.php:67-77` (`multipliedBy(0.2, HALF_UP)`).
- **Handlers là class đơn nhiệm, inject qua DI** (`app/Handlers/*` — 19 handler) → dễ dựng test hoặc gọi qua Feature test. Ví dụ `CreateAdvertHandler.php` gán charge %.
- **QUEUE_CONNECTION=sync** trong test (`phpunit.xml`) → job chạy inline trong Feature test → assert được invoice/payslip tạo ra ngay.
- **Route group tách theo user-type** (`bootstrap/app.php:36-46`: `app/applicant`, `app/advertiser` với `auth:sanctum` + `user-type`) → dễ test isolation quyền + Sanctum `actingAs`.
- 30 controller (`app/Http/Controllers`) mỏng, đẩy logic xuống Handler → Feature test tập trung.

**Thiếu để test được ngay**: bộ **factory** cho các model domain (chỉ có UserFactory) — cần bổ sung trước khi viết Feature test.

### 2.2 App — testability TRUNG BÌNH (có nợ seam)
- **Bloc/Cubit tách biệt** (`flutter_bloc`) → hợp `bloc_test` nếu thêm gói.
- **Vướng seam**: `ApiService` là **class cụ thể**, đăng ký trong `getIt` như concrete type (`lib/main.dart:52`: `getIt.registerSingleton<ApiService>(ApiService())`), không có interface. Bloc lấy qua `getIt.get<ApiService>()` → muốn test phải **override getIt** bằng fake `ApiService` (mà `ApiService` khởi tạo `Dio` thật trong constructor) → khó mock sạch.
- **Khuyến nghị seam**: trích interface `IApiService` (hoặc inject `Dio` vào `ApiService` để chèn `MockAdapter`), đăng ký qua getIt → test override dễ. Đây là điều kiện tiên quyết để bloc-test có ý nghĩa.

---

## 3. Bộ test harness TỐI THIỂU đề xuất

Ưu tiên theo rủi ro nghiệp vụ (tiền → compliance → lifecycle).

### 3.1 API — Critical-path Feature/Unit tests (thứ tự ưu tiên)

| # | Loại | Đối tượng | Vì sao |
|---|---|---|---|
| P1 | **Unit (pure)** | Charge/pay math: `Advert::totalAdvertiserPay/advertiserCharge/applicantCharge/*ChargeRate` (`Advert.php:135-188`) + VAT trong `CreateAdvertInvoiceJob` | Rủi ro sai tiền cao nhất; không cần DB; nhanh |
| P2 | **Feature** | Compliance gating: applicant **không** apply được khi references/declarations/right-to-work/evidence/video chưa duyệt | Cổng pháp lý cốt lõi; regression nguy hiểm |
| P3 | **Feature (command)** | Application lifecycle: `MarkAdvertsAsCompleteCommand`, `UpdateApprovedAdvertsStatusesCommand`, `UpdatePendingAllocationAdvertsStatusesCommand` → assert chuyển status Approved→PendingAllocation→NotFilled/Filled→Complete + invoice/payslip dispatch (queue sync) + **không dispatch trùng** | Bao trùm F-R6/F-R2 reliability |
| P4 | **Feature** | Signed reference form: submit qua signed URL → `CreateReferencePdfJob` chạy, tạo upload, status chuyển | Luồng public, ký PDF pháp lý |
| P5 | **Feature** | Auth + `user-type` middleware: applicant không gọi được route advertiser và ngược lại (`bootstrap/app.php:36-46`) | Phân quyền |
| P6 | **Feature** | Invoice/payslip amounts đầu-cuối trên advert Filled (VAT, rounding, số lượng shift Hourly vs Daily) | Chốt số liệu tài chính |

**Điều kiện chuẩn bị**: viết factory cho `Advert`, `Shift`, `Applicant`, `Advertiser`, `Application`, `Reference`, `Settings`, `Invoice`, `Payslip`; `TestCase` với `RefreshDatabase`. Fake DocGen connector (Saloon `MockClient`) để không gọi HTTP thật trong P3/P4/P6.

### 3.2 App — bloc/widget tests

| # | Loại | Đối tượng |
|---|---|---|
| A1 | Seam refactor | Trích `IApiService` / inject `Dio` để mock (điều kiện tiên quyết) |
| A2 | `bloc_test` | Authentication bloc (login → lưu bearerToken; 401 → logout), sign-up flow bloc |
| A3 | `bloc_test` | Application submission bloc (compliance gating phía client, validation) |
| A4 | Widget smoke | Màn hình cốt lõi: login, advert list, application detail — pump + render không crash |
| A5 | Golden (tùy chọn) | Màn hình compliance (reference form ký) |

Thêm `dev_dependencies`: `bloc_test`, `mocktail`, (tùy chọn) `golden_toolkit`, `http_mock_adapter` (mock Dio).

---

## 4. CI Gate đề xuất (🟠 F-T3 — hiện KHÔNG có)

Xác nhận: **không `.github/workflows`** ở cả hai repo; Husky `.husky/pre-commit` chỉ chạy Pint (PHPStan/Pest **bị comment**). Không cổng test nào chặn merge.

**API — GitHub Actions (`.github/workflows/api-ci.yml`)**:
- services: MySQL 8, Redis.
- steps: `composer install` → `pint --test` (chặn format) → `phpstan analyse` (bỏ comment, nếu có config) → `php artisan test` (Pest/PHPUnit) với `DB_DATABASE=testing`.
- Gate: fail PR nếu bất kỳ bước fail. Bật branch protection.

**App — GH Actions/Codemagic (`.github/workflows/app-ci.yml`)**:
- `flutter pub get` → `flutter analyze` (custom_lint) → `flutter test --coverage` → `flutter build apk --debug` (đảm bảo compile).
- Gate: fail nếu analyze/test fail.

**Ngưỡng coverage**: khởi đầu đặt gate mềm (chỉ cần pass + build), sau khi có critical-path thì đặt ngưỡng tối thiểu (vd 40% cho module tài chính API) và tăng dần.

---

## 5. Ước lượng effort đạt baseline

| Hạng mục | Nội dung | Effort |
|---|---|---|
| API factories + TestCase | ~9 factory + base test setup + DocGen MockClient | 1–1.5d |
| API P1 (charge math unit) | ~15–20 assertion pure money math | 0.5d |
| API P2–P6 (Feature) | ~10–15 feature test critical path | 2–3d |
| App A1 (seam refactor) | trích interface / inject Dio + đăng ký getIt | 0.5–1d |
| App A2–A4 (bloc + widget smoke) | 6–8 bloc test + 3–4 widget smoke | 2–3d |
| CI cả hai repo | 2 workflow + branch protection | 1d |
| **Tổng baseline** | smoke + critical-path + CI gate | **~8–11 ngày-người** |

Đây là mức "lưới an toàn tối thiểu" (không phải full coverage), tập trung vào tiền/compliance/lifecycle — nơi regression gây thiệt hại lớn nhất.

---

## 6. Tổng hợp (severity-sorted)

| # | Severity | Vấn đề | Bằng chứng | Effort khắc phục |
|---|---|---|---|---|
| F-T1 | 🔴 | API 0 test thực trên toàn domain tài chính/compliance/lifecycle (harness rỗng) | `tests/` rỗng; chỉ `database/factories/UserFactory.php`; `phpunit.xml` cấu hình sẵn | P1–P6: ~4–5d |
| F-T2 | 🔴 | App ~0% coverage / 22,424 LOC, 45 bloc+cubit; chỉ 2 file boilerplate | `test/unit_test.dart`, `test/widget_test.dart`; `pubspec.yaml` thiếu `bloc_test`/mock | A1–A4: ~3–4d |
| F-T3 | 🟠 | Không CI gate; Husky chỉ Pint (PHPStan/Pest comment) | không `.github/workflows`; `.husky/pre-commit` | ~1d |
| F-T4 | 🟠 | API thiếu factory domain (chỉ UserFactory) → chặn viết Feature test | `database/factories/` | gộp F-T1 |
| F-T5 | 🟡 | App: `ApiService` concrete, `Dio` khởi tạo trong constructor → thiếu seam mock | `lib/main.dart:52`; `lib/modules/api/api.dart:9-13` | 0.5–1d |

**Điểm mạnh ghi nhận**: (1) charge/pay math là pure accessor — cực dễ unit test, ROI cao; (2) Handler layering + DI + route group theo user-type → Feature test thuận lợi; (3) `QUEUE_CONNECTION=sync` trong `phpunit.xml` cho phép assert job inline; (4) harness PHPUnit đã cấu hình chuẩn — chỉ thiếu test files + factories.

### Câu hỏi chưa giải đáp
- Chọn PHPUnit thuần hay Pest? (README/composer chưa rõ Pest đã cài chưa — `.husky` có nhắc `pest` bị comment ⇒ có thể đã có; cần xác nhận `composer.json` require-dev).
- Ngưỡng coverage tối thiểu mong muốn cho gate (đề xuất khởi đầu: soft gate → 40% module tài chính).
- DocGen có sandbox/mock endpoint để test integration thật không, hay chỉ mock ở tầng Saloon?
