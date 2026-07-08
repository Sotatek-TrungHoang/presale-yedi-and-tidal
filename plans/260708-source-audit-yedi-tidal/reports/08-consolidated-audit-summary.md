# 08 — Tổng hợp Source Audit Yedi+Tidal (điểm truy cập)

> Nội bộ Sotatek · 2026-07-08 · **audit source thật** (`source/yedi-tidal-api` Laravel 11 + `source/yedi-tidal-app` Flutter). Đây là **"Phase 0 — code audit"** mà proposal black-box 03/07 đã hứa. Deliverable tiếng Việt, nội bộ. **KHÔNG** generate proposal/docx mới lần này (defer). Pricing/£ defer (chờ rate card).
> Chi tiết từng domain: `01-security` · `02-payments` · `03-feature-completeness-rescored` · `04-reliability-infra` · `05-database` · `06-test` · `07-mobile-integration`. Setup: `00-audit-setup-access`.

---

## 1. Kết luận 1 dòng
Build **hoàn thiện hơn rất nhiều so với black-box** (không phải ~8% MVP mà **~69–77% MVP**): có app Flutter 2 phía đã ship + API application-lifecycle/compliance/billing thật. Nhưng **chưa production-grade** — chuỗi lỗ hổng **auth-hardening + tính toàn vẹn tài chính (idempotency) + 0 test/CI + secrets commit + vài gap thật (timesheet/matching/DBS-engine)**. Hướng đúng = **harden + hoàn thiện**, KHÔNG rebuild.

## 2. Đính chính black-box (delta lớn — giá trị cốt lõi của audit)
| Claim black-box cũ | Source thật | Nguồn |
|---|---|---|
| **~8% MVP** (1/13 done) | **~69% straight / ~77% weighted** (9/13 MVP done; 63 base ID: 22✅/21🟡/20🔴) | report 03 |
| Portal candidate/client = 🔴 greenfield (~126 md) | **App Flutter 22.4k LOC, release-signed v1.0.5+26, 2 phía, đã ship store** | 03, 07 |
| Billing generation "vắng mặt tuyệt đối" | **Engine DocGen + Jobs CÓ** (invoice/payslip/contract, trigger khi complete) — chưa hoàn thiện & có lỗi, không phải absent | 02 |
| Compliance = nhãn thủ công, không enforcement | **Enforcement gate CÓ** (query gate trên `Compliant`; references/RTW/declarations/evidence/video verification thật) — nhưng **generic**, không có engine DBS/safeguarding cấu trúc | 03 |
| Nhiều nghi vấn IDOR (rate/video/compliance) | **Đều được authorize** qua FormRequest/Policy/UploadRule — portal authorization thiết kế tốt | 01 |
| Thiếu CORS = lỗ hổng | **Không phải** (route `app/*` ≠ default `api/*`) | 01 |
| VAT/tiền chưa xử lý | **VAT 20% CÓ tính+lưu**; brick/money đúng minor units; invoice snapshot bất biến | 02 |
| No test / CI / backup (giả định) | **CONFIRMED** từ source (0 test, 0 CI, backup chỉ script tay trong doc) | 04, 06 |

## 3. Tổng finding theo severity
| Domain | 🔴 | 🟠 | 🟡 | 🟢 | Report |
|---|:--:|:--:|:--:|:--:|---|
| Security | 2 | 4 | 7 | 8 | 01 |
| Payments | 2 | 3 | 3 | 3 | 02 |
| Reliability/Infra | 3 | ~7 | ~6 | ~2 | 04 |
| Database | 2 | 6 | ~4 | — | 05 |
| Test | 2 | — | — | — | 06 |
| Mobile/Integration | 2 | ~3 | ~4 | — | 07 |
| **Σ (xấp xỉ)** | **13** | **~23** | **~24** | **~13** | |

*(Feature-completeness (03) là re-score, không tính severity finding.)*

## 4. Danh sách 🔴 Critical hợp nhất (fix trước khi go-live)
1. **Không rate-limit ở bất kỳ đâu** (login/forgot-password/signed form) → brute-force/enumeration. *(01-A1)*
2. **Token Sanctum vĩnh viễn + không endpoint revoke/logout server** + **lưu plaintext SharedPreferences** + **secrets (Maps+Firebase key) commit git dùng chung 2 brand** → chuỗi chiếm tài khoản vĩnh viễn. *(01-A2/B1/B2)*
3. **Idempotency tài chính** — scheduler `everyMinute` không `withoutOverlapping`/`onOneServer` + **không unique index** → **invoice/payslip trùng lặp** (race đa server). *(02-F2, 04-R6)* — **rủi ro toàn vẹn tài chính cao nhất.**
4. **Payslip PDF không có số tiền** (stub bỏ dở hay bug — cần xác nhận). *(02-F1)*
5. **Horizon `tries=1` toàn cục, không retry/backoff/`failed()`** cho job tài chính → DocGen sập ⇒ **mất chứng từ âm thầm**. *(04, 02-F3)*
6. **`applications` thiếu `unique(applicant_id, advert_id)`** → DB không chặn double-apply/race. *(05)*
7. **Tiền lưu dạng JSON** (Brick Money cast) → mất aggregate/CHECK; `MoneyCast::get()` không null-guard. *(05)*
8. **0 file test API** + **~0% coverage app** (22.4k LOC) → không lưới an toàn cho refactor/hardening. *(06)*
9. **FCM half-wired** — gửi token nhưng không `onMessage`/`onBackgroundMessage` → app **không hiển thị push** ⇒ yêu cầu "thông báo" xem như hỏng. *(07)*
10. **Không xử lý 401 giữa phiên** → token hết hạn ⇒ app kẹt, không auto-logout. *(07)*
11. **Crashlytics tắt hoàn toàn** trên app đã ship 22.4k LOC → mù crash production. *(04, 07)*

## 5. Reusability (input cho re-estimate — KHÔNG ra £)
- **REUSE as-is (mạnh):** data model lõi (User/Advertiser/Applicant/Advert/Shift/Application), application lifecycle + Policy, compliance onboarding + gate (references/RTW/declarations/evidence/video), Filament admin CRUD, cấu trúc DocGen pipeline, kiến trúc app (bloc/get_it/go_router), flavor/white-label system.
- **FIX/HARDEN (đã có, cần siết):** auth (rate-limit, token revoke, secure storage, gỡ secrets khỏi git), payments (idempotency, payslip amounts, mô hình payroll), reliability (retry/overlap-guard, crash reporting, CI/CD), DB (unique constraints, chuẩn hoá lưu tiền, index/FK), mobile (FCM handler, 401, timeout, deep-link autoVerify), portable build script.
- **BUILD NEW (gap thật, grep-clean absent):** **timesheet** (vỡ W3/C10/B8/A10/M10), **availability**, **matching/recommendation engine**, **Yedi DBS/safeguarding engine cấu trúc**, **reporting/export + client-visibility dashboard**, advert-edit.

## 6. Risk register — cập nhật vs black-box R1–R10
| Risk cũ | Trạng thái sau source | Ghi chú |
|---|---|---|
| R1 Safeguarding Yedi 🔴 | **GIỮ (hạ mức)** — gate enforcement CÓ nhưng **generic, thiếu DBS-structured engine** → vẫn gate go-live Yedi | 03 |
| R2 No test/CI 🔴 | **CONFIRMED** | 06,04 |
| R3 No RBAC 🔴 | **REFRAME** — portal authorization tốt; **admin RBAC single `isSuperAdmin`** (không phân quyền admin) | 01 |
| R4 PII/GDPR 🔴 | **CONFIRMED + sâu hơn** — audits/log giữ PII, không purge khi xoá tài khoản, không retention/erasure/SAR | 01,05 |
| R5 Declarations bug 🟡 | chưa re-verify source riêng (repro Livewire live) — để mở | — |
| R6 Booking→billing no engine 🟡 | **OVERTURN** — engine CÓ (buggy, không absent) | 02 |
| R7 No source 🟡 | **RESOLVED** (đã có source) | — |
| R8 Two forks drifting 🟡 | **OVERTURN phần lớn** — mono-repo 1 codebase; drift không phải vấn đề (cần git remote confirm) | — |
| R9 Uploads no AV 🟡 | **CONFIRMED** | 01 |
| R10 No backup/monitoring 🟡 | **CONFIRMED** (manual script trong doc) | 04 |
| **MỚI** | duplicate invoice/payslip; payslip rỗng; token-takeover chain; double-apply race; FCM notifications hỏng; no-401; non-portable build script | 02,04,05,07,00 |

## 7. Reconciliation gate
✅ **PASS** — 110 ID map hết về {REUSE/MVP/T2/FUT/OUT}, **0 FLAG** (report 03). Đủ điều kiện cập nhật báo cáo nội bộ (Plan B).

## 8. Open Questions — phần lớn đã trả lời từ CODE (chi tiết: report 09)
| # | Câu hỏi | Trạng thái |
|---|---|---|
| 1 | Mô hình lao động applicant | **ĐÃ TRẢ LỜI (code):** code không mã hoá mô hình nào, **gross-only, 0 logic payroll/thuế**; contract = free-text admin. Payroll PAYE/umbrella = build mới nếu khách cần. *(còn: khách xác nhận muốn mô hình gì)* |
| 2 | Payslip rỗng = stub/bug? | **ĐÃ TRẢ LỜI (code):** STUB bỏ dở (`pdfs/payslip.blade.php` chỉ in số) — Critical thật |
| 3 | Prod 1 hay nhiều app-server? | **ĐÃ GIẢI THÍCH:** quyết severity race idempotency; fix (unique index + `onOneServer`) đúng cho cả 2 → làm bất kể. *(còn: khách cho biết số server)* |
| 4 | Prod DB/config | **KHÔNG có access → assumption** (mysql, s3, data thấp-trung); không block scope |
| 5 | DBS/safeguarding có gì / gap | **ĐÃ TRẢ LỜI (code):** có framework generic (required_evidence/declarations relabel "DBS Evidence"/"Safeguarding Declaration"); **0 cột expiry trên mọi doc compliance**, không DBS-structured/QTS/enforcement-theo-hạn → **build mới, gate go-live Yedi** |
| 6 | Maps key server có trùng mobile? | **CODE:** server key = `env()` (giá trị ở prod .env, không trong repo) → **không xác nhận trùng từ code**; risk chắc = mobile key committed+shared. Cần prod .env / test key để chốt |
| — | Còn cần khách chốt để ra md | DBS có phải MVP-blocking? Timesheet/matching MVP hay Phase-2? Booking entity riêng? Mô hình payroll? Số app-server? |

→ **Scope baseline-vs-gap** (baseline = code khách đã làm; gap = Sotatek build): **report 09** §cuối.

## 9. Bước tiếp theo
- **Plan B (lite):** cập nhật báo cáo nội bộ VN cũ (`plans/260703-.../reports/`) về đúng source — mục "Cập nhật sau source audit". KHÔNG generate docx, KHÔNG chốt commercial.
- **Defer (task riêng):** regenerate proposal client-facing + quyết định framing/pricing khi có rate card + trả lời open questions.
