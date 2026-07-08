# Audit 07 — Mobile + Integration (Yedi/Tidal Flutter app ↔ Laravel API)

Phạm vi: kiến trúc app Flutter, tích hợp API, và hợp đồng (contract) API↔app. Static review sâu, trích dẫn `file:line`.
App: `source/yedi-tidal-app` (~22k LOC, Flutter ^3.5.2, đã ship, version `1.0.5+26`).
API đối chiếu: `source/yedi-tidal-api` (Laravel 11).

> **Delta so với black-box cũ:** bản audit trước chỉ thấy placeholder 403. Đây là source thật, app đã lên store. Toàn bộ finding dưới đây đọc code thật.

---

## 1. API client & điểm coupling 422 (`lib/modules/api/api.dart`)

Một `ApiService` Dio duy nhất (`api.dart:8`). Interceptor request (`api.dart:17-42`) chèn:
- `Authorization: Bearer <bearerToken>` đọc từ `SharedPreferences['bearerToken']` (`api.dart:22-26`)
- `X-FCM-Token` từ singleton `FirebaseToken` (`api.dart:28-31`)

`_handleException` (`api.dart:109-138`) map 422 → `APIValidationException{errors: Map<field,String>}` (`api.dart:119-131`), lấy `value[0]` của mỗi field. Đây là **điểm coupling cứng**: key trong `errors` phải trùng khít tên field validation của API, nếu không lỗi hiển thị sai/mất im lặng.

### Kết quả cross-check drift (đã đối chiếu ~15 endpoint, field-by-field)

**KHÔNG phát hiện drift đang active** — mọi key app đọc đều khớp rule API tương ứng. Bảng đối chiếu:

| Endpoint | App gửi / đọc `errors[...]` | API rule (FormRequest) | Khớp |
|---|---|---|---|
| `auth/login` | `email,password` | `LoginRequest` | ✅ |
| `auth/reset-password` | `email,token,password,password_confirmation` | `ResetPasswordRequest` (`password:confirmed`) | ✅ |
| `change-password` | `current_password,password,password_confirmation` | `ChangePasswordRequest` | ✅ |
| `change-email/request` | `new_email` | `RequestEmailChangeRequest` | ✅ |
| `change-email/verify-code` | `new_email,code` | `VerifyEmailChangeCodeRequest` | ✅ |
| profile/address (common+signup) | `line_1,line_2,town_city,postcode,country` | `UpdateAddressRequest`/`SubmitAddressRequest` | ✅ |
| advertiser `profile/update-profile` | `name,email,telephone,bio,additional_info` (flat) | `Advertiser/Profile/UpdateProfileRequest` (flat) | ✅ |
| advertiser `sign-up/create-profile` | `advertiser.name,advertiser.email,...` (nested) | `Advertiser/SignUp/CreateProfileRequest` (nested `advertiser.*`) | ✅ |
| applicant qualifications | `qualification,teacher_number` | `UpdateQualificationsRequest` | ✅ |
| applicant compliance (profile) | `photograph_id,evidence_of_id_id` | `UpdateComplianceRequest` | ✅ |
| applicant compliance (signup) | `photograph_id,evidence_of_id_id,video_verification_id` (`compliance_form_state.dart:59-61`) | `SubmitComplianceRequest` (yêu cầu cả `video_verification_id`) | ✅ |
| right-to-work | `right_to_work_uk,require_visa_to_work_uk,lived_or_worked_outside_uk_6_months,has_criminal_convictions_or_prosecutions_pending` | `...RightToWorkDeclarationRequest` | ✅ |
| create advert | `title,description,starts_at,ends_at,shift_start_time,shift_end_time,contact_*,type,day_to_day_active_minutes,apply_by,advertiser_pay_rate*` | `CreateAdvertRequest` | ✅ |
| rate application | (API: `rating`) | `RateApplicationRequest` | ✅ |
| upload from-google | `name,postcode` | `UploadFromGoogleRequest` | ✅ |

### 🟠 Rủi ro coupling structural (dù chưa có mismatch)

- **Bất nhất nội bộ API là "bẫy" cho refactor tương lai:** cùng khái niệm advertiser profile nhưng **signup dùng nested `advertiser.name`** (`sign_up_create_profile_step.dart:272-313` khớp `Advertiser/SignUp/CreateProfileRequest`) còn **profile-update dùng flat `name`** (`advertiser_update_profile_content.dart:80-119` khớp `Advertiser/Profile/UpdateProfileRequest`). Hiện khớp từng-endpoint, nhưng bất kỳ ai "chuẩn hoá" một bên sẽ làm bên kia mất hiển thị lỗi im lặng. Không có test contract nào chặn.
- **🟠 Lỗi nested `documents.*` bị nuốt im lặng:** `CreateAdvertRequest` validate `documents.*.title` và `documents.*.upload_id`, nhưng UI create-advert chỉ đọc key phẳng (`create_advert_content.dart:119-362`) — không có chỗ đọc `errors['documents.0.title']`. Nếu tài liệu đính kèm sai → 422 trả về nhưng người dùng **không thấy lỗi**, chỉ thấy submit thất bại không rõ lý do. Fix: hiển thị lỗi theo prefix `documents.` hoặc gộp về banner chung.
- **🟡 `_handleException` giả định body 422 là Map:** `data.containsKey('errors')` (`api.dart:121`) không guard `data is Map` (trong khi nhánh message ở `api.dart:114` có guard). Nếu proxy/WAF trả 422 kèm HTML/string (hiếm nhưng xảy ra ở tầng hạ tầng) → `NoSuchMethodError` không bắt được, văng ra ngoài. Fix: thêm `data is Map` guard.

---

## 2. Endpoint inventory (~64 endpoint) → route mapping

Route API đăng ký qua `bootstrap/app.php:33-45` với prefix `app/common`, `app/applicant`, `app/advertiser` (KHÔNG dùng `routes/api.php`). Đã enumerate **64 endpoint literal** app gọi (grep services). **Tất cả 64 đều map tới route tồn tại** — không có app-call trỏ route chết.

- Common (12): auth login/forgot/reset/user, uploads, uploads/from-google, change-email/request+verify-code, change-password, delete-account, dropdowns, settings.
- Applicant (~30): sign-up/{pages,create-profile,submit-compliance,submit-address,submit-qualifications,submit-references,submit-evidence/{id},agree-to-declaration/{id},submit-right-to-work-declaration,complete-sign-up,cancel-sign-up}; required-evidence/{id}; declarations/{id}; references; profile/{index,update-*,agree-to-declaration/{id}}; adverts/{index,show,apply,cancel-application}; bookings/{confirmed,applied-to}; video-verifications/{store,submit}; payslips; contracts.
- Advertiser (~22): sign-up/{pages,create-profile,submit-address,submit-photograph,complete-sign-up,cancel-sign-up}; profile/{update-profile,update-address}; adverts/{index,store,show,destroy,applications}; applications/{index,accept,decline,rate}; applicants/{index,heart,unheart}; invoices; contracts.

**🟢 Dead API surface (route API app không gọi):**
- `GET app/common/uploads/{upload}` (serve) & `GET app/common/image-conversions/{imageConversion}` (serve): không gọi qua `ApiService` nhưng dùng gián tiếp bằng mở URL trực tiếp (ảnh/tài liệu) → không thực sự chết.
- `GET /` của mỗi group trả plain string `'Common'`/`'Applicant'`/`'Advertiser'` (debug stub): nên gỡ trước release.

---

## 3. 🔴 FCM push — half-wired (KHÔNG hiển thị được noti)

`main.dart:58-88` khởi tạo Firebase per-flavor, xin quyền, lấy `getToken()`, đăng ký `FirebaseToken` singleton và refresh token → gửi lên API qua header `X-FCM-Token` (lưu `DeviceToken` phía API). **Nhưng KHÔNG có bất kỳ handler nhận message nào:**

```
grep onMessage|onBackgroundMessage|getInitialMessage|onMessageOpenedApp
       |RemoteMessage|flutter_local_notifications  →  0 kết quả trong toàn lib/
```
`pubspec.yaml`: có `firebase_messaging: ^15.2.1` (`pubspec.yaml:22`) nhưng **không có `flutter_local_notifications`** (`pubspec.yaml`).

**Tác động (Critical):** app đăng ký token và server có thể gửi push, nhưng:
- Foreground: `onMessage` chưa lắng nghe → không show gì.
- Background/killed: không có background handler / không có local-notification channel → Android foreground data-message không hiện; không có notification center trong app.
- `getInitialMessage`/`onMessageOpenedApp` không có → tap noti không điều hướng.

→ **Yêu cầu "thông báo" xem như hỏng phía người dùng cuối.** Chi phí hoàn thiện: thêm `flutter_local_notifications`, background handler top-level, wiring điều hướng deep-link từ payload, và (tuỳ) notification center. Đây là hạng mục effort thật, không phải bug nhỏ.

---

## 4. Chất lượng kiến trúc mobile & lỗ hổng guard

**Tổng thể tốt:** `flutter_bloc` (Bloc/Cubit) + `get_it` singleton + `RepositoryProvider` cho services + `go_router`. Tách module `lib/modules/<feature>/{bloc,models,services}` rõ ràng. Blocs bắt `APIValidationException` nhất quán (42 file có error-catch) và đổ vào `state.errors`.

**Pattern `abstract ProfileService` + `UnimplementedError` — ĐÃ xác nhận là base-default, KHÔNG phải feature chết:** `ProfileService` (`profile_service.dart:4-40`) khai báo default throw `UnimplementedError`; `AdvertiserProfileService` override `updateAddress/updateProfile`, `ApplicantProfileService` override toàn bộ method applicant. Advertiser không có compliance/qualifications nên default-throw là đúng thiết kế (role không bao giờ gọi).

**Guard redirect (`router.dart:107-177`):**
- `unknown` → giữ splash (`router.dart:123-125`) ✅
- `unauthenticated` + route không thuộc `unauthenticatedRoutes` → `/landing` (`router.dart:168-172`) ✅
- authenticated nhưng chưa hoàn tất signup → ép `/landing/sign-up` (`router.dart:127-139`) ✅
- cross-role: `/applicant*` với advertiser (và ngược lại) → toast + về home đúng role (`router.dart:156-164`) ✅

**🟡 Lỗ guard / vấn đề điều hướng:**
- **Reset-password bỏ qua guard trạng thái auth:** `router.dart:112-120` xử lý `resetPassword` **trước** switch và `return null` (cho qua) miễn có `email`+`token`, kể cả khi user đang đăng nhập. User đã login vẫn vào được màn reset. Rủi ro thấp nhưng là lỗ logic.
- **🟢 Hằng số route sai lệch (latent):** `Routes.applicantUpdateProfile = '/advertiser/update-profile'` và `applicantUpdateCompliance = '/advertiser/update-compliance'` (`router.dart:64-66`) — giá trị chuỗi trỏ nhầm sang `/advertiser`. Hiện KHÔNG gây bug vì đăng ký route dùng `.split('/').last` (chỉ lấy segment cuối, nested dưới `/applicant`) và điều hướng dùng `pushNamed(...Page.name)` theo NAME (`applicant_home_content.dart:150-156`). Nhưng nếu ai đó `context.go(Routes.applicantUpdateProfile)` → sẽ bị guard cross-role đá về home. Bom nổ chậm, nên sửa cho đúng.
- **Không có 404/typed error page tử tế:** `errorPageBuilder` chỉ `Text(state.toString())` (`router.dart:104-106`).

---

## 5. Tích hợp ngoài

- **Google Maps (`ui/adverts/advert_location.dart`):** `GoogleMap` hiển thị marker toạ độ (`advert_location.dart:38-52`) + nút "Get Directions" mở `address.directionsUrl` bằng `url_launcher` (`advert_location.dart:56-60`). API key nạp qua `resValue google_maps_api_key` từ `GOOGLE_MAPS_API_KEY` (`android/app/build.gradle:46`, manifest `AndroidManifest.xml:40`). Đơn giản, view-only, ổn.
- **Upload (`upload_service.dart`):** multipart `POST app/common/uploads` field `file` (`upload_service.dart:19-27`); và `from-google` gửi `{name,postcode}` (`upload_service.dart:29-37`). Khớp API.
- **DocGen (`document_service.dart`):** fetch danh sách payslips/invoices/contracts (`document_service.dart`), file mở external qua `url_launcher` — view-only, không lưu/không viewer nội bộ. Đúng như mô tả.
- **Deep links (Android `AndroidManifest.xml:17-23`):** intent-filter `http`/`https` host=`${host}` (`app.yedi.group`/`app.tidalagency.co.uk` — `build.gradle:70,76`). **🟠 THIẾU `android:autoVerify="true"`** và không thấy `assetlinks.json` được tham chiếu/cấu hình → đây KHÔNG phải verified App Links: Android sẽ hiện hộp chọn app (disambiguation) thay vì auto-mở, làm luồng reset-password link kém tin cậy. iOS thì có `associated-domains: applinks:...` trong entitlements (`RunnerDebug/Profile-*.entitlements:11-13`). Ngoài ra filter bắt **mọi** path tới host (không `pathPrefix`).
- **🟡 Sign in with Apple — capability khai báo nhưng KHÔNG implement:** filter `signinwithapple` bị comment ở Android (`AndroidManifest.xml:26-35`), nhưng iOS entitlements vẫn bật `com.apple.developer.applesignin` (`Runner.entitlements:7`, các RunnerDebug/Profile). Không có code Apple Sign-In trong `lib/`. → capability chết, rủi ro friction khi review App Store (Apple yêu cầu implement thực nếu bật capability / có social-login khác).

---

## 6. Build/release & flavor

- Flavor `yedi`/`tidal` qua `flavorDimensions "default"` + `productFlavors` (`build.gradle:64-78`): `applicationId` `com.ne6.yedi`/`com.ne6.tidal`, `app_name`, `manifestPlaceholders.host` khác nhau. Runtime `appFlavor` branch theme/asset. `--dart-define-from-file .env.{flavor}` nạp `BASE_API_URL`+`GOOGLE_MAPS_API_KEY`; `Env.validate()` throw nếu thiếu (`env.dart:6-14`).
- **Ký release thật:** `signingConfigs.release` đọc `key.properties` (`build.gradle:49-56`), `buildTypes.release` dùng nó (`build.gradle:58-62`) → build phân phối store. `key.properties`/keystore KHÔNG có trong repo (đúng).
- **🟡 Footgun flavor:** `firebase_options.dart` và `app_localizations.dart` là **file dùng chung, generate lại theo flavor** bởi `pre_<flavor>.sh`. Switch flavor mà quên chạy pre-script → build sai Firebase config + sai strings brand, không báo lỗi compile. Đây là nguồn bug lặp lại đã ghi trong CLAUDE.md; nên gắn vào một script build duy nhất (build script hiện đã gọi pre-script, nhưng `flutter run` thủ công thì không).

---

## 7. Các finding tích hợp khác

- **🔴 Không xử lý session-expiry (401):** interceptor `onError` chỉ pass-through (`api.dart:38-41`); `_handleException` map 401 thành `APIException` generic (`api.dart:132-134`). Không có interceptor nào bắt 401 để auto-logout/redirect login/refresh token. `AuthenticationBloc` chỉ chuyển `unauthenticated` khi `getCurrentUser` fail lúc **khởi động** (`main.dart:40-44`, `authentication_bloc.dart:53-60`). → **Token hết hạn giữa phiên**: mọi màn hình văng lỗi generic, user **không bị đưa về login**, kẹt trong app đăng nhập-hỏng. Fix: interceptor 401 → clear token + emit unauthenticated.
- **🟡 Dio không set timeout:** `BaseOptions` chỉ có `baseUrl` (`api.dart:9-13`) — không `connectTimeout/receiveTimeout/sendTimeout`. Mạng kém → request treo vô thời hạn, không có spinner-timeout. Nên set timeout hợp lý.
- **🟡 Crashlytics tắt hoàn toàn:** toàn bộ Crashlytics bị comment (`main.dart:19,62-71`; `android/app/build.gradle:5`). App production **không có crash reporting** (dù có `firebase_analytics`). Với app đã lên store, đây là mù thông tin sự cố.

---

## Tổng hợp theo mức độ

| # | Mức | Finding | Vị trí |
|---|---|---|---|
| 1 | 🔴 | FCM half-wired: không có onMessage/onBackgroundMessage/local-noti → không hiển thị được push; không notification center | `main.dart:58-88`, `pubspec.yaml:22` (thiếu flutter_local_notifications) |
| 2 | 🔴 | Không xử lý 401 giữa phiên → không auto-logout, app kẹt khi token hết hạn | `api.dart:38-41,132-134`, `authentication_bloc.dart:53-60` |
| 3 | 🟠 | Lỗi validation nested `documents.*.title/upload_id` bị nuốt im lặng trong UI create-advert | API `CreateAdvertRequest` vs `create_advert_content.dart:119-362` |
| 4 | 🟠 | Coupling 422 structural: API bất nhất nested (`advertiser.*`) vs flat giữa signup/profile-update — refactor 1 bên sẽ vỡ bên kia im lặng; không có contract test | `sign_up_create_profile_step.dart:272-313` vs `advertiser_update_profile_content.dart:80-119` |
| 5 | 🟠 | Deep link Android thiếu `autoVerify` + không có verified assetlinks → App Links không auto-mở, reset-password link kém tin cậy; filter bắt mọi path | `AndroidManifest.xml:17-23` |
| 6 | 🟡 | iOS bật capability Sign in with Apple + associated-domains nhưng feature không implement (Android filter đã comment) → rủi ro review store, config chết | `Runner*.entitlements:7-13`, `AndroidManifest.xml:26-35` |
| 7 | 🟡 | Dio không set timeout → request treo vô hạn khi mạng kém | `api.dart:9-13` |
| 8 | 🟡 | Crashlytics tắt hoàn toàn → không crash reporting production | `main.dart:19,62-71`, `android/app/build.gradle:5` |
| 9 | 🟡 | `_handleException` giả định body 422 là Map, không guard → NoSuchMethodError nếu 422 trả non-JSON | `api.dart:121` |
| 10 | 🟡 | Footgun flavor: quên `pre_<flavor>.sh` → build sai Firebase/strings, không lỗi compile | `firebase_options.dart`, `app_localizations.dart` (generated dùng chung) |
| 11 | 🟢 | Hằng số route `applicantUpdateProfile/Compliance = '/advertiser/...'` sai lệch (latent, cứu bởi điều hướng theo name) | `router.dart:64-66` |
| 12 | 🟢 | Reset-password route bỏ qua guard trạng thái auth (user đã login vẫn vào được) | `router.dart:112-120` |
| 13 | 🟢 | Dead API surface: `GET /` mỗi group trả plain string debug stub | `routes/app/{common,applicant,advertiser}.php` |

**Điểm mạnh cần ghi nhận:** kiến trúc bloc/get_it/go_router sạch; 64/64 endpoint app gọi đều map route tồn tại (không có call chết); pattern `UnimplementedError` là base-default hợp lệ (không phải feature chết); không phát hiện field-name drift đang active trên mẫu ~15 endpoint đã đối chiếu.

**Câu hỏi mở:**
- Notification requirement có nằm trong scope hợp đồng bản gốc không? (quyết định effort FCM #1)
- Có `assetlinks.json`/AASA host-side đã deploy chưa? (không kiểm được từ source app — cần xác nhận phía hạ tầng cho #5)
