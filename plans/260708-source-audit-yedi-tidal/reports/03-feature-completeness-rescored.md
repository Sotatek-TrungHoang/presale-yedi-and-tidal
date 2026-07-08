# Phase 03 — Feature Completeness RE-SCORED (đối chiếu source thật)

> Re-score ma trận traceability black-box (`260703-.../05-requirements-traceability-matrix.md`) trên **source thật**.
> Source: API Laravel 11 (`source/yedi-tidal-api`) + App Flutter v1.0.5+26, ~22.4k LOC (`source/yedi-tidal-app`).
> Legend: ✅ Done · 🟡 Partial · 🔴 Missing. Cột "BB cũ" = phán quyết black-box (chỉ thấy admin panel; mobile portal 403).
> **Kết luận đảo chiều:** black-box gọi ~92% self-service là greenfield vì KHÔNG thấy app. Source cho thấy **có app mobile 2 chiều đầy đủ** + API ~60 endpoint triển khai gần trọn vòng đời. MVP thật ~**69% Done** (9/13) chứ không phải 8%.

---

## Bối cảnh chốt bằng source (những điều black-box bỏ sót)

| Hạng mục | Source thật | Evidence |
|---|---|---|
| App mobile 2 chiều | Applicant + Advertiser, release-signed v1.0.5+26, 32 route | `app/pubspec.yaml:19`; `app/lib/pages/router.dart:50-88` |
| Self-registration | Có, đa bước cả 2 phía | `api/routes/app/applicant.php:20-35`, `advertiser.php:18-28` |
| Vòng đời application | apply/accept/decline/rate/cancel + auto-decline sibling + advert→Filled | `api/app/Handlers/Advertisers/Adverts/AcceptApplicationHandler.php:28-42` |
| Compliance ENFORCEMENT gate | Chặn apply & create job nếu `compliance_status != Compliant` | `api/app/Policies/AdvertPolicy.php:108-138`; `Applicant/AdvertsController.php:39` |
| Billing generation | Job tạo Invoice + Payslip khi advert hoàn tất; DocGen PDF; contract commands | `api/app/Console/Commands/Adverts/MarkAdvertsAsCompleteCommand.php:43-46` |
| Push notification (server) | FCM thật qua Kreait Firebase + mail; token lưu qua middleware | `api/app/Notifications/Channels/FcmChannel.php:14-40`; `api/app/Http/Middleware/DeviceTokenMiddleware.php:20-36` |
| Push token (app) | App gửi `X-FCM-Token` mỗi request → server lưu DeviceToken | `app/lib/modules/api/api.dart:28-30`; `app/lib/main.dart:74-87` |

**GAP thật đã xác nhận vắng mặt (grep sạch cả 2 repo):** timesheet, availability, matching/recommendation engine, region, DBS/safeguarding-specific fields, RBAC hạt mịn (spatie), export API, advert edit/update, app-side FCM message handler (`onMessage`/`onBackgroundMessage`).

---

## §2.1 Candidate/Worker (C1–C15)

| ID | Capability | BB cũ | Source thật | Evidence (file:line) | Ghi chú |
|---|---|:--:|:--:|---|---|
| C1 | Đăng ký self-service | 🔴 | ✅ | app `sign_up_service.dart:52`; api `applicant.php:25` | Đảo: có multi-step signup + bearer token |
| C2 | Xây/sửa hồ sơ | 🔴 | ✅ | app `update_applicant_profile_cubit.dart`; api `applicant.php:46` | Đảo: profile CRUD self-service |
| C3 | Upload tài liệu | 🔴 | ✅ | app `common/services/upload_service.dart:15`; api `applicant.php:30`, `common.php:26` | Đảo: evidence + upload luồng candidate |
| C4 | Kinh nghiệm/kỹ năng/preference | 🔴 | 🟡 | `Enums/ApplicantQualification.php`; `Applicant.php:29-42` (teacher_number/qualification/type_of_work/job_role) | Có field cấu trúc-hạn chế; thiếu skills/experience/preference tự do |
| C5 | Đặt availability | 🔴 | 🔴 | grep `availabilit` = 0 (cả 2 repo) | Vắng mặt xác nhận |
| C6 | Xem cơ hội/job | 🔴 | ✅ | app `applicant_advert_service.dart:12`; api `Applicant/AdvertsController.php:30` | Đảo: list adverts theo type |
| C7 | Apply shift | 🔴 | ✅ | app `apply_to_advert_cubit.dart`; api `ApplyToAdvertHandler.php:19` | Đảo (mô hình pull: applicant apply, advertiser accept) |
| C8 | Nhận xác nhận booking | 🔴 | ✅ | api `Applicant/BookingsController.php:18` (confirmed) + `ApplicationAcceptedNotification` | Đảo |
| C9 | Xem lịch sắp tới | 🔴 | 🟡 | app `applicant_bookings_view.dart:26`; api confirmed `orderBy starts_at` | List "Confirmed"; KHÔNG có calendar/schedule view |
| C10 | Nộp timesheet | 🔴 | 🔴 | grep `timesheet` = 0 | Vắng mặt xác nhận |
| C11 | Theo dõi duyệt/thanh toán | 🔴 | ✅ | api `BookingsController.php:29` (appliedTo) + `PayslipsController.php:16` | Đảo: status application + payslip |
| C12 | Nhận notification | 🔴 | 🟡 | server `FcmChannel.php`; app `api.dart:28-30` gửi token NHƯNG `main.dart` thiếu `onMessage/onBackgroundMessage` | Push tới OS được; app KHÔNG xử lý message in-app |
| C13 | Nhận feedback/rating | 🔴 | 🟡 | `RateApplicationHandler.php:21-28`; app `applicant_home_content.dart:46-54` | Chỉ rating tổng hợp; không có list feedback từng job |
| C14 | Training/onboarding | 🔴 | 🔴 | — | Compliance onboarding có, training module không |
| C15 | Referral | 🔴 | 🔴 | — | Vắng mặt |

**C: 6 ✅ · 4 🟡 · 5 🔴** (BB cũ: 0 ✅ · 0 🟡 · 15 🔴).

---

## §2.2 Client/School (B1–B11)

| ID | Capability | BB cũ | Source thật | Evidence (file:line) | Ghi chú |
|---|---|:--:|:--:|---|---|
| B1 | Đăng ký tài khoản | 🔴 | ✅ | app `sign_up_service.dart:43`; api `advertiser.php:23` | Đảo |
| B2 | Gửi yêu cầu nhân sự (advert) | 🔴 | ✅ | app `advertiser_advert_service.dart:75`; api `advertiser.php:43`, `CreateAdvertHandler.php` | Đảo; **lưu ý: chỉ create/list/delete, KHÔNG có edit/update** |
| B3 | Ghi chú/yêu cầu đặc biệt | 🔴 | 🟡 | advert có description + `CreateDocumentHandler.php` (đính kèm) | Generic; không structured special-requirement |
| B4 | Xem candidate gợi ý | 🔴 | 🟡 | api `HeartedApplicantsController@index`; app `hearted_applicants_service.dart:14` | Duyệt + heart applicant được; KHÔNG có gợi ý/matching |
| B5 | Duyệt/xác nhận booking | 🔴 | ✅ | api `advertiser.php:56`, `AcceptApplicationHandler.php:19` | Đảo |
| B6 | Xem booking sắp tới | 🔴 | ✅ | app `advertiser_adverts_view.dart`; api advert list + `AdvertStatus::Filled` | Đảo (advert-level) |
| B7 | Theo dõi attendance | 🔴 | 🔴 | — | Không check-in/attendance |
| B8 | Duyệt timesheet | 🔴 | 🔴 | grep `timesheet` = 0 | Vắng mặt |
| B9 | Feedback | 🔴 | ✅ | api `advertiser.php:58`, `RateApplicationHandler.php` | Đảo (advertiser→applicant rating sau job) |
| B10 | Xem invoice/summary | 🔴 | ✅ | app `document_service.dart:25`; api `Advertiser/InvoicesController.php:16` | Đảo |
| B11 | Báo cáo cơ bản | 🔴 | 🔴 | chỉ Filament widget admin; không dashboard client | Không coverage/fill/spend cho client |

**B: 6 ✅ · 2 🟡 · 3 🔴** (BB cũ: toàn 🔴).

---

## §2.3 Admin/Internal (A1–A18)

| ID | Capability | BB cũ | Source thật | Evidence (file:line) | Ghi chú |
|---|---|:--:|:--:|---|---|
| A1 | Xem tất cả candidate | ✅ | ✅ | `Filament/Resources/ApplicantResource` | Giữ |
| A2 | Duyệt/từ chối đăng ký | 🟡 | ✅ | `Applicant.php:57-63` (profile_status→Active bắn `AccountActiveNotification`) | Đảo: có hàng đợi self-registration + duyệt + notify |
| A3 | Verify tài liệu | 🟡 | 🟡 | `Enums/ReferenceStatus.php` (workflow 5 trạng thái); evidence per `RequiredEvidence` | Giàu hơn BB nghĩ (references workflow) nhưng verify vẫn thủ công |
| A4 | Track compliance | 🟡 | 🟡 | `ApplicantComplianceStatus` + gate enforcement `AdvertPolicy.php:136` | Set thủ công NHƯNG được enforce; thiếu auto-compute/expiry |
| A5 | Tạo & quản lý booking | 🔴 | 🟡 | Advert+Application+Shift lifecycle (`Advert.php:127` shifts) | Không có Booking entity riêng; quản lý qua Advert (Filament) |
| A6 | Gán candidate vào shift | 🟡 | ✅ | `AcceptApplicationHandler.php` (accept=allocate, auto-decline sibling, advert→Filled) | Đảo |
| A7 | Override matching thủ công | 🔴 | 🔴 | grep matching = 0 | Không có matching để override |
| A8 | Xem availability | 🔴 | 🔴 | — | Không model |
| A9 | Quản lý account client/school | ✅ | ✅ | `AdvertiserResource` | Giữ |
| A10 | Quản lý timesheet | 🔴 | 🔴 | — | Vắng mặt |
| A11 | Track booking status | 🔴 | ✅ | `Enums/AdvertStatus.php` + `Console/Commands/Adverts/*` (scheduler cập nhật status) | Đảo (advert-level lifecycle) |
| A12 | Gửi notification | 🔴 | 🟡 | `app/Notifications/*` (Admin/Advertiser/Applicant) + `FcmChannel` | Notification tự động theo event có đủ; KHÔNG có composer gửi thủ công |
| A13 | Hủy/no-show | 🔴 | 🟡 | cancel `CancelApplicationHandler.php`; advert delete `AdvertPolicy.php:163` | Cancel có; no-show không |
| A14 | Track feedback 2 chiều | 🔴 | 🟡 | `RateApplicationHandler.php` (chỉ advertiser→applicant) | Một chiều; applicant→advertiser không có |
| A15 | Tạo báo cáo | 🟡 | 🟡 | `Filament/Widgets/ExpenditureOverview.php` + charts | Widget đếm/£; không report builder |
| A16 | Export data | 🔴 | 🔴 | không thấy export action | Vắng mặt |
| A17 | Quản lý region/role/rate | 🟡 | 🟡 | `JobRole`/`TypeOfWork` + rate trên advert/settings; grep region = 0 | Role/rate có; region không |
| A18 | RBAC | 🔴 | 🟡 | `Enums/UserType.php` (3 role) + policies + middleware `user-type` | Role-based access có enforce; KHÔNG có permission hạt mịn (no spatie) |

**A: 5 ✅ · 8 🟡 · 5 🔴** (BB cũ: 3 ✅ · 6 🟡 · 9 🔴).

---

## §3 Yedi-specific (Y1–Y10)

| ID | Capability | BB cũ | Source thật | Evidence (file:line) | Ghi chú |
|---|---|:--:|:--:|---|---|
| Y1 | DBS status + expiry | 🔴 | 🔴 | grep `dbs` = 0; compliance generic qua `RequiredEvidence` | **GAP critical Yedi** — không có DBS number/expiry |
| Y2 | Safeguarding training | 🔴 | 🔴 | grep `safeguard` = 0 | **GAP critical Yedi** |
| Y3 | Right to work | 🟡 | ✅ | `Models/RightToWorkDeclaration.php` + api `applicant.php:32`; app `right_to_work_bloc.dart` | Đảo: declaration có model + luồng riêng |
| Y4 | References | 🟡 | ✅ | `RequestReferenceHandler.php` + `ReferenceStatus` workflow + referee endpoint public | Đảo: workflow đủ 5 trạng thái |
| Y5 | Qualifications | 🟡 | 🟡 | `ApplicantQualification` enum + teacher_number + `submit-qualifications` | Structured-hạn chế; không record institution/date |
| Y6 | Employment history | 🔴 | 🔴 | — | Không structured |
| Y7 | Document expiry flag trước book | 🔴 | 🔴 | — | Không expiry tracking |
| Y8 | Compliance warning/notes | 🔴 | 🟡 | gate enforcement chặn apply (`AdvertPolicy.php:136`) | Enforce có; warning/notes/expiry không |
| Y9 | School booking flow | 🔴 | ✅ | dùng chung advert→apply→accept (school=advertiser) | Đảo: luồng booking chạy được |
| Y10 | Matching giáo dục | 🔴 | 🔴 | — | Không matching |

**Y: 3 ✅ · 3 🟡 · 4 🔴.** GAP riêng Yedi vẫn nặng: DBS/safeguarding/employment-history/expiry-gate.

---

## §4 Tidal-specific (T1–T4)

| ID | Capability | BB cũ | Source thật | Evidence | Ghi chú |
|---|---|:--:|:--:|---|---|
| T1 | Brand/retail/fragrance experience | 🔴 | 🔴 | chỉ qualification/role/type generic | Không field experience structured |
| T2 | Talent pool theo city/brand | 🔴 | 🟡 | browse applicants + heart; geocoding `GetAddressCoordinatesHandler.php` | Duyệt/heart có; không pool filter city/brand |
| T3 | Client visibility (coverage/fill/spend) | 🔴 | 🟡 | advert status + invoices (spend) | Spend visibility có; coverage/fill dashboard không |
| T4 | Matching beauty | 🔴 | 🔴 | — | Không matching |

**T: 0 ✅ · 2 🟡 · 2 🔴.**

---

## §5 Workflows (W1–W5)

| ID | Workflow | BB cũ | Source thật | Đứt gãy | Evidence |
|---|---|:--:|:--:|---|---|
| W1 | Registration | 🔴 | ✅ | — | self-signup 2 phía + duyệt admin (`applicant.php:20-35`) |
| W2 | Client booking | 🔴 | 🟡 | thiếu bước match/suggest (thay bằng pull-apply) | advert→apply→accept→confirm→invoice/payslip đủ chuỗi |
| W3 | Timesheet | 🔴 | 🔴 | **toàn bộ** | không tồn tại |
| W4 | Compliance | 🟡 | 🟡 | thiếu expiry flag/DBS | upload+references+status+**enforcement gate** (`AdvertPolicy.php:108,136`) |
| W5 | Feedback | 🔴 | 🟡 | thiếu chiều applicant→advertiser | advertiser→applicant rating loop đủ (`RateApplicationHandler.php`) |

---

## §6 MVP (M1–M13) — completeness đã sửa

| ID | MVP item | BB cũ | Source thật | Evidence |
|---|---|:--:|:--:|---|
| M1 | Đăng ký candidate | 🔴 | ✅ | `applicant.php:25` |
| M2 | Đăng ký client/school | 🔴 | ✅ | `advertiser.php:23` |
| M3 | Admin dashboard | ✅ | ✅ | `Filament/Widgets/Dashboard.php` |
| M4 | Quản lý hồ sơ | 🟡 | ✅ | profile CRUD 2 phía |
| M5 | Upload tài liệu | 🟡 | ✅ | `upload_service.dart:15` |
| M6 | Availability | 🔴 | 🔴 | vắng mặt |
| M7 | Tạo booking | 🔴 | ✅ | advert create + lifecycle |
| M8 | Gán candidate | 🟡 | ✅ | `AcceptApplicationHandler.php` |
| M9 | Xác nhận booking | 🔴 | ✅ | accept→confirmed + notification |
| M10 | Timesheet | 🔴 | 🔴 | vắng mặt |
| M11 | Notification cơ bản | 🔴 | 🟡 | server push đủ; app thiếu message handler |
| M12 | Compliance status cơ bản | 🟡 | ✅ | status + enforcement gate |
| M13 | Reporting/export cơ bản | 🟡 | 🟡 | widget admin; không export |

### % MVP đã sửa (thay figure ~8% cũ)
- ✅ Done: **9/13** (M1,M2,M3,M4,M5,M7,M8,M9,M12)
- 🟡 Partial: **2/13** (M11,M13)
- 🔴 Missing: **2/13** (M6,M10)
- **Completeness thẳng: 9/13 ≈ 69% Done.** Trọng số (Done=1, Partial=0.5): (9 + 1)/13 ≈ **77%**.
- So sánh: black-box báo **1/13 (~8%)**. → **Sai lệch ~61 điểm %** do không thấy app + backend ẩn.

### Tổng thể 110 ID
| Nhóm | ✅ | 🟡 | 🔴 | Tổng |
|---|:--:|:--:|:--:|:--:|
| C (15) | 6 | 4 | 5 | 15 |
| B (11) | 6 | 2 | 3 | 11 |
| A (18) | 5 | 8 | 5 | 18 |
| Y (10) | 3 | 3 | 4 | 10 |
| T (4) | 0 | 2 | 2 | 4 |
| W (5) | 2 | 2 | 1 | 5 |
| M (13) | 9 | 2 | 2 | 13 |
| **Tổng** | **31** | **23** | **22** | **76** (không tính M trùng: 63 ID gốc C+B+A+Y+T+W → 22✅/21🟡/20🔴) |

*Lưu ý: M1–M13 phần lớn trùng C/B/A/W nên không cộng dồn để tránh double-count. Trên 63 ID gốc (C+B+A+Y+T+W): **22 ✅ · 21 🟡 · 20 🔴** → ~35% Done thẳng, ~50% nếu tính Partial nửa điểm.* Đây là **build đã tồn tại đáng kể**, không phải greenfield.

---

## §7 Reconciliation gate — mọi ID map 1 target {MVP/T2/FUT/REUSE/OUT}, không FLAG

**REUSE** (đã build, dùng as-is; hardening nhẹ): C1,C2,C3,C6,C7,C8,C11, B1,B2,B5,B6,B9,B10, A1,A2,A6,A9,A11, Y3,Y4,Y9, W1,W2,W5, M1,M2,M3,M4,M5,M7,M8,M9,M12.

**MVP** (cần build/hoàn thiện để đạt MVP ổn định): C5(availability), C9(schedule view), C10(timesheet), C12/M11(app FCM handler), B8(timesheet), A5(booking entity hoá), A10(timesheet), A12(admin notify composer), Y8(compliance warning/expiry), W3(timesheet), M6(availability), M10(timesheet). *Yedi launch bổ sung:* Y1(DBS), Y2(safeguarding), Y7(expiry gate).

**T2** (phase-2, nâng chất): C4(skills/experience structured), C13(feedback list), B3(structured requirements), B4/T2-pool(browse→gợi ý), A3(auto-verify), A4(auto-compute compliance), A13(no-show), A14(2-chiều feedback), A15(report builder), A16(export), A17(region), A18(RBAC hạt mịn), Y5(qualifications structured), Y6(employment history), B11/T3(client dashboard), T1(experience Tidal).

**FUT** (future/nice-to-have): C14(training), C15(referral), A7(matching override), A8(admin availability), Y10(matching giáo dục), T4(matching beauty), B4(matching engine gốc).

**OUT** (ngoài scope MVP hiện tại): — (không ID nào loại hẳn; matching xếp FUT).

→ **0 FLAG.** Mọi ID có target.

---

## §8 Backlog thật (build mới) vs "đã build — cần hardening"

### A. BUILD MỚI (thật sự vắng mặt — grep sạch cả 2 repo)
1. **Timesheet** (model/route/table/UI cả 2 phía) — vỡ W3, C10, B8, A10, M10. *Backlog lớn nhất.*
2. **Availability** (model + UI + admin view) — C5, A8, M6.
3. **Matching/recommendation engine** (geocoding có sẵn nhưng không proximity) — B4, A7, Y10, T4.
4. **Yedi safeguarding engine**: DBS number/expiry, safeguarding training record, document-expiry gate chặn book — Y1, Y2, Y6, Y7. *Critical cho ra mắt Yedi (an toàn trẻ em).*
5. **Reporting/export**: export API + client-facing dashboard (coverage/fill/spend) — A16, B11, T3, A15 sâu.
6. **Referral (C15), Training (C14).**
7. **Structured experience/skills** (Tidal T1, C4) + **talent pool filter** city/brand (T2).
8. **Attendance/no-show** (B7, A13) + **feedback 2 chiều** applicant→advertiser (A14, W5).
9. **Admin manual notification composer** (A12) + **RBAC hạt mịn** (A18).
10. **Advert edit/update** (hiện chỉ create/list/delete cả app lẫn API).

### B. ĐÃ BUILD — cần HARDENING (không phải build mới)
1. **App FCM message handler**: server push + token registration đủ; app thiếu `onMessage`/`onBackgroundMessage`/`onMessageOpenedApp` (`app/lib/main.dart`) — nhận noti không hiển thị/điều hướng in-app. *Sửa nhỏ.*
2. **Compliance**: enforcement gate ĐÃ hoạt động (đảo phán quyết BB "thiếu enforcement"); còn thiếu expiry/auto-compute.
3. **References/evidence**: workflow đủ nhưng verify thủ công.
4. **Region field** thiếu trong quản lý rate (A17).
5. **Schedule/calendar view** cho applicant (hiện chỉ list Confirmed bookings).

---

## Câu hỏi chưa giải quyết
1. "Booking entity" — client có yêu cầu object Booking riêng, hay mô hình Advert+Application+Shift hiện tại chấp nhận được? (ảnh hưởng A5/M7 là REUSE hay MVP-build).
2. Matching: client kỳ vọng engine gợi ý thật, hay mô hình pull (applicant apply + advertiser heart) đủ cho MVP? (ảnh hưởng B4/W2).
3. Yedi DBS/safeguarding: bắt buộc cho MVP launch Yedi (an toàn trẻ em) hay chấp nhận compliance generic giai đoạn 1?
4. Timesheet: có nằm trong MVP hay phase-2? (backlog nặng nhất, vỡ 5 ID).
</content>
</invoke>
