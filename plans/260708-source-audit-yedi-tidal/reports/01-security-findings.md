# Báo cáo Audit Bảo mật — Yedi / Tidal (Laravel 11 API + Flutter App)

**Loại:** Presale source-code security review (static, deep)
**Phạm vi:** `source/yedi-tidal-api` (Laravel 11 + Filament + Sanctum), `source/yedi-tidal-app` (Flutter)
**Ngày:** 2026-07-08
**Chú thích mức độ:** 🔴 Critical · 🟠 High · 🟡 Medium · 🟢 Low
**Effort fix:** S (<0.5 ngày) · M (0.5–2 ngày) · L (>2 ngày)

Marketplace nhân sự white-label. Lưu PII nhạy cảm: references (safeguarding), right-to-work, ID docs, video verification. Yedi phục vụ giáo dục → có dữ liệu liên quan trẻ em. Rủi ro GDPR/compliance cao.

---

## A. CODEBASE: API (Laravel)

### A.1 — Xác thực & Session

#### 🔴 A1. Không có rate limiting ở BẤT KỲ đâu — brute-force + enumeration
- **Location:** `bootstrap/app.php:36-47` (group `api` chỉ append `DeviceTokenMiddleware`, không có `throttle`); `routes/app/common.php:18-22` (login/forgot/reset không throttle); `routes/web.php` (reference `store` không throttle). Grep toàn repo: 0 `throttle` / `RateLimiter` (chỉ có `config/auth.php:98` là throttle của password broker, không liên quan HTTP).
- **Mô tả:** Toàn bộ endpoint public không giới hạn tần suất: `POST app/common/auth/login`, `forgot-password`, `reset-password`, form reference public write, verify-code đổi email.
- **Tác động:** Brute-force mật khẩu không giới hạn; dò 6-số OTP (đổi email) khả thi (10^6, xem A5); spam gửi reset/reference mail (dùng nạn nhân làm relay lạm dụng Mailgun). Kết hợp A5/A6 → chiếm tài khoản.
- **Khuyến nghị:** Thêm `throttle:` cho nhóm `api` và riêng cho login/forgot/reset/verify (vd `throttle:5,1` theo email+IP). Cân nhắc captcha cho sign-up + forgot-password.
- **Effort:** S

#### 🔴 A2. Sanctum token vĩnh viễn + KHÔNG có endpoint logout/revoke phía server
- **Location:** `config/sanctum.php:49` (`'expiration' => null`); toàn bộ `routes/app/*.php` không có route logout/revoke; `AuthController.php` không có method logout; token tạo ở `AuthController.php:37` và `ApplicantSignUpController.php:102` với name `'sign_up'`, không set abilities (full-access).
- **Mô tả:** Token cấp ra không bao giờ hết hạn. Không có API thu hồi token. Logout chỉ xoá phía client (xem App A4).
- **Tác động:** Token bị lộ (backup thiết bị, MITM — xem App A1/A3) = truy cập vĩnh viễn, không cách nào vô hiệu hoá từ server ngoài xoá thủ công trong DB. Vi phạm nguyên tắc revoke-on-logout.
- **Khuyến nghị:** Set `expiration` (vd 60*24*30 phút) + sliding refresh; thêm route `logout` gọi `$user->currentAccessToken()->delete()`; endpoint "logout all devices".
- **Effort:** S–M

#### 🟡 A5. OTP/verification code dùng RNG không an toàn (`rand`/`mt_rand`), 6 số, không giới hạn thử
- **Location:** `ChangeEmailController.php:22` (`rand(0,999999)`); `Models/VideoVerification.php:25` (`mt_rand(0,999999)`).
- **Mô tả:** Mã xác thực đổi email & mã video verification sinh bằng PRNG không mật mã, 6 chữ số. `verifyCode` (`ChangeEmailController.php:35-65`) không đếm số lần thử, không throttle.
- **Tác động:** Kết hợp A1, kẻ tấn công có thể vét cạn 6-số để xác nhận đổi email → tiếp quản email tài khoản. RNG đoán được làm giảm entropy thêm.
- **Khuyến nghị:** Dùng `random_int()`; giới hạn số lần verify (vd 5 lần rồi vô hiệu code); throttle endpoint.
- **Effort:** S

#### 🟡 A6. Đổi email không yêu cầu re-auth mật khẩu
- **Location:** `ChangeEmailController.php:17-33`.
- **Mô tả:** `requestEmailChange` chỉ cần token hợp lệ, không xác nhận lại mật khẩu hiện tại. Nếu token bị lộ (A1/A2/App A1) → đổi email → chiếm tài khoản hoàn toàn.
- **Khuyến nghị:** Bắt buộc nhập lại password khi đổi email; gửi cảnh báo về email cũ.
- **Effort:** S

#### 🟡 A7. Tạo tài khoản không cần xác minh email + rò rỉ enumeration email
- **Location:** `routes/app/applicant.php:24-25` & `advertiser.php:22-23` (`withoutMiddleware` bỏ auth cho `pages`/`create-profile`); `CreateProfileRequest.php:36` (`Rule::unique('users','email')`).
- **Mô tả:** Đăng ký ẩn danh, không verify email trước khi ghi DB (`ApplicantSignUpController::createProfile:69-114`). Rule `unique` trả lỗi 422 khi email đã tồn tại → cho phép dò email nào đã đăng ký.
- **Tác động:** Enumeration tài khoản; spam DB tài khoản rác; tạo tài khoản với email người khác (họ không kiểm soát) gây rối.
- **Khuyến nghị:** Verify email (link/OTP) trước khi kích hoạt; trả thông báo enumeration-safe; captcha.
- **Effort:** M

### A.2 — Phân quyền (Authorization / IDOR)

#### 🟠 A4. Không có RBAC hạt mịn cho panel Admin (Filament)
- **Location:** `app/Providers/Filament/AdminPanelProvider.php:56-58` (`authMiddleware([Authenticate::class])`); `Models/User.php:94-97` (`canAccessPanel` chỉ kiểm `type === Admin`).
- **Mô tả:** Mọi User `type=Admin` có toàn quyền trên tất cả Filament Resources (users, applicants, references safeguarding, uploads, financials). Không có role/permission (không dùng spatie/permission). `isSuperAdmin()` chỉ dùng lẻ tẻ, không phải cổng RBAC toàn cục. Chỉ có 3 Policy (`Advert`, `Application`, `VideoVerification`) — không phủ hầu hết resource admin.
- **Tác động:** Không phân tách được least-privilege giữa các admin (vd staff hỗ trợ vs quản trị tài chính). Một tài khoản admin bị lộ = lộ toàn bộ PII + safeguarding + dữ liệu trẻ em. Với domain giáo dục đây là rủi ro compliance nghiêm trọng.
- **Khuyến nghị:** Triển khai roles/permissions (spatie/laravel-permission + Filament Shield), Policy per-resource, audit hành động admin.
- **Effort:** L

> **Ghi chú tích cực (đã verify):** Authorization object-level ở API applicant/advertiser **khá tốt** — Adverts/Applications dùng Policy qua `Gate::authorize` hoặc `FormRequest::authorize`. Nhiều "nghi vấn IDOR" từ recon đã bị **bác bỏ** (xem mục "So với black-box cũ").

#### 🟢 A8. Upload chưa gán chủ có thể bị "claim" bởi user khác (nếu biết UUID)
- **Location:** `app/Rules/UploadRule.php:41-47` — nhánh `owner === null` cho phép bất kỳ upload nào chưa có `owner`.
- **Mô tả:** Upload tạo với `uploadedBy = user hiện tại` nhưng `owner = null` ban đầu (`UploadFileHandler`/`Models/Upload.php`). `UploadRule` chỉ kiểm `owner`, không kiểm `uploaded_by_id`. User B biết UUID upload chưa claim của A có thể gán vào hồ sơ mình.
- **Tác động:** Thấp — ID là `Str::orderedUuid` (122-bit), khó đoán; cửa sổ hẹp (upload hết hạn 10 phút).
- **Khuyến nghị:** Trong `UploadRule` nhánh null-owner, thêm điều kiện `uploaded_by_id === Auth::id()`.
- **Effort:** S

### A.3 — File / Signed URL / Serving

#### 🟠 A3. Signed URL phục vụ file private là VĨNH VIỄN (không expiry)
- **Location:** `Models/Upload.php:92` & `Models/ImageConversion.php:55` dùng `URL::signedRoute(...)` (không phải `temporarySignedRoute`); `Notifications/Public/NewReferenceRequestNotification.php:46` cũng `signedRoute`. Serve: `UploadController.php:52-58`, `ImageConversionController.php:12-18` chỉ check `hasValidSignature()`.
- **Mô tả:** URL truy cập ID docs, ảnh chân dung, **video verification (định danh)**, form reference (safeguarding) được ký nhưng không có `expires` → hợp lệ mãi mãi.
- **Tác động:** URL lộ qua email history, log proxy, Referer, chia sẻ nhầm → truy cập vĩnh viễn tài liệu định danh & dữ liệu nhạy cảm. Không thể thu hồi trừ khi đổi `APP_KEY`. GDPR: dữ liệu định danh/trẻ em phơi bày lâu dài.
- **Khuyến nghị:** Dùng `temporarySignedRoute(..., now()->addMinutes(5))`; với file rất nhạy cảm cân nhắc stream qua controller có kiểm quyền sở hữu thay vì chỉ chữ ký.
- **Effort:** S

#### 🟡 A9. Upload không AV-scan; content-type suy đoán từ client
- **Location:** `UploadFileRequest.php:22-29` (rule `clamav` bị comment out `// 'clamav'`); `UploadFileHandler.php:22-33` (`getClientOriginalName`, `guessExtension`, lưu thẳng); serve trả nguyên `mime_type`/`file_name` (`UploadController.php:58`).
- **Mô tả:** Không quét malware; tên/ext lấy từ client; không whitelist mime chặt. File độc (vd HTML/SVG có script) có thể được lưu và phục vụ.
- **Tác động:** Lưu trữ malware phát tán tới admin/advertiser; nếu serve inline có nguy cơ stored-XSS qua SVG/HTML (mitigate bởi content-disposition mặc định của Storage::response — cần xác nhận).
- **Khuyến nghị:** Bật ClamAV (rule đã có sẵn, chỉ bị comment); whitelist mime/ext theo mục đích; ép `Content-Disposition: attachment` + `X-Content-Type-Options: nosniff`.
- **Effort:** M

### A.4 — Mass Assignment / Injection / Config

#### 🟢 A10. Mass-assignment phí % trên Advert (latent, chưa khai thác được)
- **Location:** `Models/Advert.php:45-46` (`applicant_charge_percentage`, `advertiser_charge_percentage` trong `$fillable`).
- **Mô tả:** Hai trường tài chính này fillable. **Đã verify KHÔNG reachable** từ input advertiser: `CreateAdvertRequest.php` không có 2 field này; `CreateAdvertHandler.php:56-57` set từ `settings` (server-side). Chỉ là rủi ro defense-in-depth nếu tương lai có endpoint khác `fill()` từ request thô.
- **Khuyến nghị:** Bỏ 2 trường khỏi `$fillable`, set explicit trong handler.
- **Effort:** S

#### 🟢 A11. Blade unescaped `{!! !!}` trong PDF template
- **Location:** `resources/views/pdfs/applicant-contract.blade.php:79`, `advertiser-contract.blade.php:79` (`{!! $wording !!}`); `pdfs/invoice.blade.php:156` (`{!! $settings->invoice_contact_address !!}`).
- **Mô tả:** Nội dung admin-controlled (settings/wording) render không escape trong PDF server-side. Rủi ro HTML/CSS-injection thấp (nguồn từ admin, render ra PDF chứ không phải browser session).
- **Khuyến nghị:** Sanitize nếu có bất kỳ giá trị nào đến từ user; giữ nguyên nếu chỉ admin.
- **Effort:** S

#### 🟢 A12. DeviceTokenMiddleware cho phép xoá device token tuỳ ý khi chưa auth
- **Location:** `app/Http/Middleware/DeviceTokenMiddleware.php:28-31`.
- **Mô tả:** Request KHÔNG auth kèm header `X-FCM-Token = <token nạn nhân>` → xoá bản ghi DeviceToken khớp. Middleware này gắn vào toàn nhóm `api`.
- **Tác động:** DoS push notification có chủ đích (nạn nhân ngừng nhận thông báo). Thấp, cần biết/đoán token.
- **Khuyến nghị:** Chỉ xoá token khi thuộc user đã auth; không thao tác DB dựa trên header của request ẩn danh.
- **Effort:** S

#### 🟢 A13. PII trong log & audit trail (GDPR)
- **Location:** `Handlers/Uploads/CreateUploadFromGoogleHandler.php:34-54` (log name/postcode/photo_reference vào channel `google_maps`); owen-it auditing bật trên `Reference`, `User`, `Upload`, `Advert`... → bảng `audits` lưu nguyên diff (references chứa dữ liệu safeguarding/trẻ em, chữ ký, `signature`).
- **Tác động:** PII/safeguarding lưu plaintext trong log + audits; chưa thấy chính sách retention/erasure/SAR. Rủi ro GDPR (right-to-erasure, minimisation). Lưu ý `DeleteAccountController`/`cancelSignUp` xoá bản ghi chính nhưng **audits & log không được dọn** → dữ liệu định danh còn tồn tại sau khi user xoá tài khoản.
- **Khuyến nghị:** Loại PII khỏi log; mã hoá/at-rest cho cột nhạy cảm; định nghĩa retention + purge audits/log khi erasure; hỗ trợ SAR/export.
- **Effort:** L

#### 🟢 A14. Reference public write: bảo vệ hợp lý nhưng thiếu chống replay/rate-limit
- **Location:** `routes/web.php` (`middleware:['signed']`); `Controllers/Public/ReferenceController.php:33-46`; `Requests/Public/CompleteReferenceRequest.php:16-19` (`authorize` yêu cầu status `SentToReferee`).
- **Mô tả (đã verify):** `reference_id` là UUID (`Models/Reference.php:74`) → không IDOR đoán được. Chữ ký chống tampering. `store` chỉ hợp lệ khi status `SentToReferee`, sau submit chuyển `PendingConfirmation` → replay lần 2 bị chặn bởi `authorize`. **Tốt.** Điểm yếu còn lại: signed URL vĩnh viễn (A3) + không rate-limit (A1) + không giới hạn kích thước `comments`/`signature` (string tự do → có thể gửi payload lớn).
- **Khuyến nghị:** temporary signed link + throttle + giới hạn độ dài field.
- **Effort:** S

#### ℹ️ A15. Không có `config/cors.php` — **KHÔNG phải lỗ hổng** (đính chính recon)
- **Location:** `config/cors.php` không tồn tại → dùng default package: `paths => ['api/*','sanctum/csrf-cookie']`.
- **Mô tả:** Route ứng dụng nằm dưới prefix `app/*` (`bootstrap/app.php:37-47`), **không khớp** `api/*` → không có header CORS nào được cấp → mặc định trình duyệt chặn cross-origin. Thực tế chặt hơn, không phải rủi ro mở CORS. (Recon black-box cũ đánh dấu nghi vấn — đính chính.)

---

## B. CODEBASE: APP (Flutter)

### B.1 — Lưu trữ credential & bảo vệ token

#### 🟠 B1. Bearer token lưu SharedPreferences plaintext (không secure storage)
- **Location:** `lib/modules/api/api.dart:22-26` (đọc `prefs.getString('bearerToken')`); `lib/modules/authentication/services/authentication_service.dart:42,45-51` (set/remove qua SharedPreferences). `pubspec.yaml`: có `shared_preferences` (dòng 39), **không có** `flutter_secure_storage`.
- **Mô tả:** Token bearer lưu plaintext trong SharedPreferences (Android: XML plaintext; iOS: plist), không dùng Keychain/Keystore.
- **Tác động:** Trên thiết bị root/jailbreak, qua backup, hoặc malware cùng sandbox → trích xuất token. Kết hợp A2 (token vĩnh viễn) + A4 (không revoke) = **chiếm tài khoản vĩnh viễn**.
- **Khuyến nghị:** Chuyển sang `flutter_secure_storage` (Keychain/EncryptedSharedPreferences/Keystore).
- **Effort:** S

#### 🟡 B4. Logout chỉ client-side, không revoke server
- **Location:** `authentication_service.dart:41-43` (`logOut` chỉ `remove('bearerToken')`).
- **Mô tả:** Đăng xuất chỉ xoá token local; server vẫn coi token hợp lệ (A2). Không có API logout để gọi.
- **Tác động:** Token cũ (đã copy trước khi logout, hoặc còn trong backup) vẫn dùng được vô hạn.
- **Khuyến nghị:** Gọi endpoint revoke khi logout (song song với fix A2).
- **Effort:** S

#### 🟢 B5. Không có biometric / local auth khoá ứng dụng
- **Location:** `pubspec.yaml` không có `local_auth`; grep `biometric`/`local_auth` = rỗng.
- **Tác động:** Ai cầm thiết bị đã mở khoá đều truy cập được app + dữ liệu nhạy cảm. Với app xử lý ID/định danh nên có tuỳ chọn khoá sinh trắc.
- **Khuyến nghị:** Thêm `local_auth` gate tuỳ chọn khi mở app / thao tác nhạy cảm.
- **Effort:** M

### B.2 — Bí mật hard-code & Transport

#### 🟠 B2. Secret commit vào git: Google Maps + Firebase keys, dùng chung 2 brand
- **Location:** `.env.yedi` & `.env.tidal` (`GOOGLE_MAPS_API_KEY=AIzaSy…REDACTED_MAPS_KEY` — **giống hệt nhau**); hard-code lần 2 tại `ios/Runner/AppDelegate.swift:15`; `android/app/build.gradle:46` inject vào string resource. Firebase keys committed: `android/app/google-services.json:18` (`AIzaSy…REDACTED_FIREBASE_KEY`), `android/app/src/yedi/google-services.json:18`, `.../tidal/...`. **`git ls-files` xác nhận `.env.yedi`, `.env.tidal`, `AppDelegate.swift` đều được track trong repo.**
- **Mô tả:** Khoá API bị commit vào VCS; cùng một Google Maps key cho cả Yedi & Tidal; iOS hard-code cứng (không đọc từ config, code đọc-config bị comment). Backend (`CreateUploadFromGoogleHandler`) cũng gọi Google Places → nếu trùng key sẽ bị lộ cả key server-side.
- **Tác động:** Đánh cắp quota/billing (Google Places/Maps), lạm dụng key; lộ trong lịch sử git ngay cả khi xoá về sau. Dùng chung key = compromise 1 brand ảnh hưởng brand kia.
- **Khuyến nghị:** Rotate toàn bộ key ngay; restrict theo bundle-id/SHA + API scope + HTTP referrer; tách key theo brand & theo môi trường; đưa `.env.*` ra khỏi VCS (git-filter-repo dọn lịch sử); iOS đọc key từ config đã build.
- **Effort:** M

#### 🟡 B3. Không có certificate pinning (Dio thuần qua HTTPS)
- **Location:** `lib/modules/api/api.dart:8-43` (Dio khởi tạo, chỉ interceptor header; không cấu hình `badCertificateCallback`/pinning). Grep `Pinning`/`certificate` = rỗng.
- **Tác động:** Trên mạng thù địch / proxy MITM có CA giả (thiết bị bị cài CA) → chặn bắt token bearer + toàn bộ PII (B1 làm token dễ tái sử dụng).
- **Khuyến nghị:** Certificate/public-key pinning (vd `dio` + `http_certificate_pinning` hoặc `SecurityContext`).
- **Effort:** M

### B.3 — App signing / Deep link

#### 🟡 B6. assetlinks dùng CHUNG một SHA-256 signing fingerprint cho 2 package
- **Location:** `assetlinks_yedi.json` (package `com.ne6.yedi`) và `assetlinks_tidal.json` (package `com.ne6.tidal`) — **cùng** `F0:8E:0F:47:38:81:D1:EF:0B:99:61:CC:88:9E:62:6D:37:EA:7D:AB:C9:FA:E7:19:DA:A3:B6:1E:EC:7D:5A:F5`.
- **Mô tả:** Hai app khác brand ký bằng cùng một khoá ký. Compromise/leak keystore ảnh hưởng đồng thời cả hai app; ranh giới tin cậy App Links bị nhập nhằng.
- **Tác động:** Một khoá ký lộ = có thể ký giả cả hai app; không cô lập được sự cố theo brand.
- **Khuyến nghị:** Tách keystore riêng cho từng brand/gói; cập nhật assetlinks tương ứng.
- **Effort:** M

#### 🟢 B7. Deep-link intent-filter http+https thiếu `android:autoVerify`
- **Location:** `android/app/src/main/AndroidManifest.xml:17-23` (`data scheme http` & `https` cho `${host}`, không có `android:autoVerify="true"`).
- **Tác động:** Link không được verify → hiện hộp chọn app / app khác có thể đăng ký cùng host để hijack deep link. `scheme http` (cleartext) cũng nên bỏ.
- **Khuyến nghị:** `android:autoVerify="true"`, chỉ `https`, khớp assetlinks.
- **Effort:** S

---

## C. Bảng tổng hợp (sắp theo mức độ)

| # | Mức | Codebase | Hạng mục | Tiêu đề | Effort |
|---|-----|----------|----------|---------|--------|
| A1 | 🔴 | API | Auth | Không có rate limiting (brute-force/enumeration) | S |
| A2 | 🔴 | API | Auth | Token Sanctum vĩnh viễn + không revoke/logout | S–M |
| A3 | 🟠 | API | File/URL | Signed URL file private vĩnh viễn (ID/safeguarding) | S |
| A4 | 🟠 | API | AuthZ | Không RBAC hạt mịn cho admin Filament | L |
| B1 | 🟠 | App | Credential | Token lưu SharedPreferences plaintext | S |
| B2 | 🟠 | App | Secrets | Maps/Firebase key commit git, chung 2 brand | M |
| A5 | 🟡 | API | Auth | OTP `rand()`, 6 số, không giới hạn thử | S |
| A6 | 🟡 | API | Auth | Đổi email không re-auth mật khẩu | S |
| A7 | 🟡 | API | Auth | Đăng ký không verify email + enumeration | M |
| A9 | 🟡 | API | File | Upload không AV-scan, mime từ client | M |
| B3 | 🟡 | App | Transport | Không certificate pinning | M |
| B4 | 🟡 | App | Auth | Logout chỉ client-side | S |
| B6 | 🟡 | App | Signing | assetlinks chung 1 fingerprint 2 package | M |
| A8 | 🟢 | API | AuthZ | Claim upload chưa gán chủ qua UUID | S |
| A10 | 🟢 | API | MassAssign | Phí % Advert fillable (chưa reachable) | S |
| A11 | 🟢 | API | XSS | Blade `{!! !!}` trong PDF (admin-controlled) | S |
| A12 | 🟢 | API | DoS | Xoá device token tuỳ ý khi chưa auth | S |
| A13 | 🟢 | API | GDPR | PII trong log & audits, không retention/purge | L |
| A14 | 🟢 | API | Logic | Reference thiếu throttle/giới hạn field | S |
| B5 | 🟢 | App | Auth | Không biometric/local auth | M |
| B7 | 🟢 | App | Deeplink | Thiếu `autoVerify`, còn scheme http | S |
| A15 | ℹ️ | API | CORS | Thiếu `config/cors.php` — không phải lỗ hổng (đính chính) | — |

**Đếm:** 🔴 2 · 🟠 4 · 🟡 7 · 🟢 8 · ℹ️ 1

---

## D. So với black-box cũ (delta)

| Nghi vấn recon/black-box | Sự thật từ source | Nguồn (file:line) |
|--------------------------|-------------------|-------------------|
| IDOR: `rate()` không có Gate | **Bác bỏ** — authorize trong FormRequest | `RateApplicationRequest.php:14-17` (`Gate::authorize('rate',...)`) |
| IDOR: `VideoVerification::submit` thiếu Gate | **Bác bỏ** — authorize qua FormRequest | `SubmitVideoVerificationRequest.php:15-18` (`Gate::authorize('update',...)`), policy `VideoVerificationPolicy.php:10-13` |
| IDOR: `submitCompliance` gán upload/VV tuỳ ý | **Bác bỏ** — có kiểm sở hữu | `SubmitComplianceRequest.php:25-27` (`UploadRule($applicant)` + `Rule::exists(...where applicant_id)`) |
| Mass-assign phí % Advert khai thác được | **Giảm nhẹ** — fillable nhưng không reachable (set từ settings) | `CreateAdvertRequest.php` (không có field), `CreateAdvertHandler.php:56-57` |
| Reference public write dễ IDOR/replay | **Phần lớn bác bỏ** — UUID + status-gated, chống replay | `Reference.php:74`, `CompleteReferenceRequest.php:16-19` |
| Thiếu `config/cors.php` = CORS mở | **Bác bỏ/đính chính** — app/* không khớp default `api/*` → không header CORS | `bootstrap/app.php:37-47` (đính chính A15) |
| Admin gated bởi `isSuperAdmin()` | **Đính chính** — thực ra `canAccessPanel` chỉ kiểm `type===Admin` (còn lỏng hơn) | `User.php:94-97` |
| **Xác nhận đúng:** token plaintext SharedPreferences | Đúng | `api.dart:22-26`, `authentication_service.dart:42` |
| **Xác nhận đúng:** Maps key commit + hard-code AppDelegate, chung brand | Đúng (còn thêm Firebase keys) | `.env.yedi`, `AppDelegate.swift:15`, `google-services.json:18` |
| **Xác nhận đúng:** không cert pinning / không revoke / không rate-limit / assetlinks chung fingerprint / không biometric | Đúng toàn bộ | (như trên) |

**Điểm tích cực (verify):** Authorization object-level của portal applicant/advertiser thiết kế tốt (Policy `Advert`/`Application`/`VideoVerification` + `UploadRule` kiểm ownership + FormRequest authorize). Login/forgot-password không rò rỉ enumeration (login trả `auth.failed` chung; forgot trả success chung) — điểm yếu chính là **thiếu rate-limit**, không phải logic. `APP_DEBUG` default false, `APP_ENV` default production; không có raw SQL (0 `DB::raw`/`whereRaw`) → không bề mặt SQLi rõ ràng.

---

## E. Câu hỏi mở / cần xác nhận với khách

1. Google Maps key server-side (backend `.env`) có **trùng** key mobile committed không? Nếu có → mức B2 nâng 🔴 (lộ key server + billing).
2. Bảng `audits` (owen-it) và log `google_maps` có được đưa vào quy trình erasure/retention GDPR chưa? (A13)
3. `Storage::response` khi serve upload có ép `Content-Disposition: attachment` mặc định không (ảnh hưởng đánh giá stored-XSS ở A9)? Cần test runtime.
4. Firebase API keys trong `google-services.json` có bị hạn chế (API restriction) trên Google Cloud Console chưa?
5. Có kế hoạch tách keystore ký riêng cho 2 brand (B6) hay chấp nhận rủi ro dùng chung?

---

**Status:** DONE
