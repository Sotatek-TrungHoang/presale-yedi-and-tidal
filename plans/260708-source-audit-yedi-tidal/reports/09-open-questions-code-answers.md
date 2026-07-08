# 09 — Trả lời Open Questions từ CODE + Scope baseline-vs-gap

> Nội bộ Sotatek · 2026-07-08 · trả lời các câu hỏi mở của report 08 bằng **bằng chứng code** (không đoán). Nguyên tắc estimate (user chốt): **baseline = tình trạng code hiện tại (khách đã làm); phần chưa có = Sotatek build cho khách.**

## Q1 — Mô hình lao động (payroll) applicant: code đang dùng gì?
**Trả lời: CODE KHÔNG mã hoá mô hình nào — không có logic payroll/thuế. Chỉ hỗ trợ trả GROSS (self-employed / payroll ngoài hệ thống).**
Bằng chứng:
- **0 tham chiếu** PAYE / National Insurance / umbrella / self-employed / payroll / HMRC / tax trong `app/`, `lang/`, `config/`, `database/seeders/` (grep sạch).
- **Payslip là stub** — `resources/views/pdfs/payslip.blade.php` body chỉ có `<h1>Payslip: {{ payslip_number }}</h1>`, KHÔNG số tiền/giờ/khấu trừ. Model `Payslip` chỉ `title` + `payslip_number` (`app/Models/Payslip.php:17`), không cột gross/net/tax/NI.
- **Contract applicant = free text admin**: `applicant-contract.blade.php` render `{!! $wording !!}` ← `Settings.applicant_contract` (`app/Models/Settings.php:28`), cột `mediumText` (`migration 2025_02_04_102843:16`). Câu chữ pháp lý quan hệ lao động do admin gõ, **không** trong code.
- **VAT chỉ ở invoice (B2B advertiser)**, không ở payslip → củng cố: advertiser bị bill có VAT, applicant trả gross không khấu trừ → **mô hình self-employed / contractor**.
**Hệ quả estimate:** payslip + mọi logic PAYE/umbrella/khấu trừ thuế = **BUILD MỚI** nếu khách cần payroll thực. Nếu khách giữ self-employed gross → chỉ cần **hoàn thiện payslip stub** (điền số tiền/giờ, nhỏ). → cần khách xác nhận mô hình mong muốn, nhưng **code hiện tại = gross-only**.

## Q2 — Payslip rỗng = stub hay chủ ý?
**Trả lời: STUB bỏ dở, 100% chắc từ template.** `pdfs/payslip.blade.php` chỉ in số payslip; toàn bộ dữ liệu tiền (advert pay, hours, charge) có sẵn qua `$payslip->advert` nhưng **không được render**. Đây là Critical thật (report 02-F1), không phải design. Fix = viết template + (tùy) thêm cột. Nhỏ nếu gross; vừa nếu kèm payroll (xem Q1).

## Q3 — "Prod 1 hay nhiều app-server?" nghĩa là gì + vì sao hỏi
**Giải thích:** Command `MarkAdvertsAsCompleteCommand` chạy **mỗi phút** (scheduler) → dispatch job sinh invoice/payslip khi advert hoàn thành. Rủi ro **sinh trùng chứng từ tài chính** phụ thuộc kiến trúc chạy prod:
- **Nếu 1 app-server + 1 scheduler:** rủi ro chỉ ở retry/overlap trong 1 máy → **Medium**. `withoutOverlapping()` (chưa dùng) đủ xử lý.
- **Nếu NHIỀU app-server**, mỗi máy chạy cron `schedule:run` riêng (kiểu scale ngang phổ biến, không leader-election): **cùng 1 advert bị nhiều máy xử lý đồng thời → invoice/payslip trùng CHẮC CHẮN** → **High/Critical**. Cần `onOneServer()` (khóa qua cache chung) — **hiện KHÔNG dùng**, và **không có unique index** chặn ở DB.
**Kết luận:** không biết số server prod nên để **conditional**, NHƯNG fix đúng cho cả 2 trường hợp và rẻ: **thêm unique index (advert_id) trên invoices/payslips + `withoutOverlapping()->onOneServer()`**. Khuyến nghị làm bất kể số server. *(deployment-guide.md có nhắc scale ngang + `HORIZON_PROCESSES` → khả năng multi-instance là có thật.)*

## Q4 — Prod DB / config: không có access → assumption
**Assumption dùng cho audit (đánh dấu rõ, cần chốt nếu có access sau):**
- `DB_CONNECTION` prod = **mysql** (config default là sqlite — `deployment-guide.md:94` hướng mysql; giả định prod đã set đúng).
- `FILESYSTEM_DISK=s3` đã set ở prod (guide bắt buộc s3 cho prod).
- Data volume: **giả định có data thật ở mức thấp-trung** (không phải chỉ seed) — nhưng migration/data-cleanup scope coi như **nhỏ** cho tới khi verify. Không block MVP scope.

## Q5 — DBS/Safeguarding: code hiện có gì, gap gì?
**Trả lời: CÓ khung compliance GENERIC (đủ dùng như "catalog upload"), KHÔNG có engine DBS/safeguarding có cấu trúc.**

**ĐÃ CÓ (generic framework — REUSE):**
- `required_evidence` (`title`, `time_to_complete`, `required`) — admin tạo mục yêu cầu upload; seed tạo 1 mục **tên "DBS Evidence"** (`YediSeeder.php:103`) — chỉ là **nhãn của 1 required-upload**, không có field DBS.
- `declarations` (`title`, `description`, `upload_id`, `required`) — seed tạo **"Safeguarding Declaration"** (`YediSeeder.php:49`) = 1 doc-upload có tên, không logic.
- References (form referee ký ngoài, có câu hỏi "disciplinary/safeguarding concerns?" — `reference-form.blade.php:311`), Right-to-Work declaration, video verification, evidence uploads, workflow duyệt admin, `ApplicantComplianceStatus` gate marketplace.
- Qualification = enum học vấn generic (GCSE→PhD, `ApplicantQualification.php`) — **KHÔNG có QTS**.

**GAP (BUILD MỚI cho Yedi education):**
- **KHÔNG có cột expiry/renewal trên BẤT KỲ doc compliance nào** — grep xác nhận `expir/renew/valid_until/issue_date` chỉ có ở email-code / uploads / addresses / tokens, **KHÔNG ở** references/RTW/evidence/declarations/DBS. → **không track hạn tài liệu**.
- Không record DBS có cấu trúc: số chứng chỉ, loại (basic/standard/enhanced/enhanced+barred), ngày cấp, **ngày hết hạn**, DBS Update Service status, barred-list check.
- Không record safeguarding-training + hạn + nhắc gia hạn.
- Không field QTS/qualification giảng dạy có cấu trúc.
- Không **enforcement theo hạn** ("chặn book nếu DBS hết hạn/thiếu") — gate hiện chỉ là 1 nhãn status tính thủ công, không soi từng doc.
- Không nhắc compliance tự động.
→ Đúng như audit: "DBS Evidence"/"Safeguarding Declaration" = **required-upload relabel**, không phải compliance engine. Đây là **gap critical gate go-live Yedi** (an toàn trẻ em).

## Q6 — Maps key: code đang như nào?
**Trả lời từ code:**
- **Server (API):** key lấy từ `env('GOOGLE_MAPS_API_KEY')` (`config/services.php:44`), dùng ở `GoogleMapsConnector.php:26`. **Giá trị nằm trong prod `.env` — KHÔNG có trong repo** → **không thể xác nhận từ code là có TRÙNG key mobile hay không.**
- **Mobile:** key `AIzaSy…REDACTED_MAPS_KEY` **commit** trong `.env.yedi/.env.tidal` + hardcode `AppDelegate.swift:15`, **dùng chung 2 brand** — đây là rủi ro đã xác nhận (client-side key phải restrict theo app/bundle).
- **Để chốt "có trùng không":** cần prod `.env` HOẶC test key committed với Google API xem restriction (IP-restricted = server key; app/referrer-restricted = mobile key). Nếu **trùng + không IP-restrict** → nâng lên 🔴 (key server bị lộ qua app, ai cũng gọi được).
**Khuyến nghị bất kể:** tách 2 key (server IP-restricted riêng, mobile app-restricted riêng), rotate key đã lộ, gỡ khỏi git history.

---

## Scope baseline-vs-gap (input estimate — baseline = code khách đã làm)
> Không ra £ (chờ rate card). Bảng = "khách đã có" vs "Sotatek build". Dựa completeness re-score (report 03) + trả lời trên.

| Hạng mục | Baseline (code đã có) | Sotatek build (gap) |
|---|---|---|
| Auth/portal 2 phía | ✅ App Flutter ship + API auth | Harden: rate-limit, token revoke, secure storage, 401 handling |
| Application lifecycle | ✅ apply/accept/decline/rate/cancel + Policy | Booking entity riêng (nếu khách cần) |
| Compliance onboarding | ✅ references/RTW/declarations/evidence/video + gate generic | **DBS/safeguarding structured engine + expiry + enforcement (Yedi)** |
| Billing | ✅ engine DocGen invoice (VAT), contract | **Fix payslip stub**; idempotency (unique index + onOneServer); job retry |
| Payroll/thuế | — (gross-only, không logic) | PAYE/umbrella/khấu trừ **nếu khách cần** (nếu giữ self-employed → chỉ hoàn thiện payslip) |
| Notifications | 🟡 server push + token; app không handle | App `onMessage`/`onBackgroundMessage` + notification center |
| Timesheet | 🔴 không có | Build mới (model + flow submit/duyệt) |
| Availability | 🔴 không có | Build mới |
| Matching engine | 🔴 không có (chỉ browse + heart) | Build mới (hoặc xác nhận pull-apply đủ MVP) |
| Reporting/export + client dashboard | 🔴 chỉ 1 widget admin | Build mới |
| Test/CI | 🔴 ~0 | Test baseline + CI 2 repo (~17–23 md, report 04+06) |
| Reliability | 🟡 Horizon/schedule/Sentry có | retry/overlap-guard, crash reporting app, backup/monitoring |
| DB integrity | 🟡 schema chạy sạch | unique constraints, chuẩn hoá lưu tiền, index/FK |
| Infra onboarding | 🟡 | `.env.example`, tạo `bootstrap/cache`, sửa pre-script hardcode path |

**Còn cần khách để chốt md:** (a) mô hình payroll (Q1), (b) DBS/safeguarding có phải MVP-blocking Yedi, (c) timesheet + matching MVP hay Phase-2, (d) Booking entity riêng?, (e) số app-server prod (Q3).
