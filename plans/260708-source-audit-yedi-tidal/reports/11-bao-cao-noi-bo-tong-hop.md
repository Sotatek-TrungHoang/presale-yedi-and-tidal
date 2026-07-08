# BÁO CÁO NỘI BỘ — Source Audit + Tư vấn + Ước tính Yedi & Tidal

> **Nội bộ Sotatek presale** · 2026-07-08 · điểm truy cập tổng hợp. Chi tiết kỹ thuật ở `reports/00`–`10`.
> Đối tượng: nền tảng staffing white-label 2 brand **Yedi** (education) + **Tidal** (beauty/retail/event), 1 codebase (Laravel 11 API + Flutter app).

---

## 1. Executive Summary

Đã có **source code thật** của khách → thực hiện **audit source-grounded** (static + chạy thật local + đối chiếu client brief), thay cho đánh giá black-box trước đó (03/07).

**Kết luận cốt lõi:** build của khách **hoàn thiện hơn RẤT NHIỀU so với black-box** — không phải ~8% MVP mà **~69–77% MVP**. Có app mobile Flutter đã ship (v1.0.5+26, 2 phía), API application-lifecycle + compliance-gate + billing-engine thật. **Hướng đúng = harden + hoàn thiện, KHÔNG rebuild.** Nhưng chưa production-grade: chuỗi lỗ hổng bảo mật + toàn vẹn tài chính + 0 test/CI + vài gap thật (timesheet, matching, payroll, DBS-enforcement).

| Chỉ số | Giá trị |
|---|---|
| **MVP completeness (đúng)** | ~69% straight / ~77% weighted *(black-box: ~8%)* |
| **Effort MVP (Yedi+Tidal cùng launch)** | **≈ 240–355 md · planning ~295 md** *(black-box: ~660 md)* |
| **Chi phí MVP** | **≈ $36k–54k · đề xuất chốt ~$45k** *(theo rate card Sotatek)* |
| **Timeline** | ~3–4.5 tháng · team ~5–6 |
| **Số finding audit** | ~13 Critical · ~23 High · ~24 Medium · ~13 Low (7 domain) |
| **Kiến trúc** | Shared multi-tenant (1 codebase) — **verified từ source**, khuyến nghị giữ |

---

## 2. Bối cảnh
- **03/07:** audit **black-box** (chỉ login Filament admin live; app portal trả 403) → kết luận ~8% MVP, portal greenfield ~126 md, ~660 md MVP; tự flag "cần Phase 0 code-audit".
- **08/07:** có source → **audit này = Phase 0 đó**. Chạy được local (Sail migrate 49/49 clean, flutter analyze sạch) → xác nhận codebase **runnable**.

## 3. Kết quả audit — headline

### Đính chính black-box (giá trị cốt lõi)
| Black-box cũ | Source thật |
|---|---|
| ~8% MVP | **~69–77% MVP** |
| Portal candidate/client greenfield | **App Flutter 22.4k LOC đã ship, 2 phía** |
| Billing "vắng mặt tuyệt đối" | **Engine DocGen invoice/payslip/contract CÓ** (buggy) |
| Compliance chỉ nhãn thủ công | **Enforcement gate CÓ** (generic; thiếu DBS-structured) |
| Nhiều nghi vấn IDOR | **Đều authorize đúng** (portal authz tốt) |
| Thiếu CORS = lỗ hổng | **Không** (route `app/*` ≠ default `api/*`) |
| VAT chưa xử lý | **VAT 20% CÓ tính+lưu** |

### 13 vấn đề 🔴 Critical (fix trước go-live)
1. Không rate-limit ở đâu → brute-force/enumeration.
2. Token Sanctum vĩnh viễn + không revoke + lưu **plaintext** + **secrets commit git** dùng chung 2 brand → account-takeover chain.
3. **Idempotency tài chính** — scheduler mỗi phút không khóa + không unique index → **invoice/payslip trùng**.
4. **Payslip PDF rỗng số tiền** (stub bỏ dở — xác nhận từ template).
5. Horizon `tries=1` không retry → DocGen sập ⇒ mất chứng từ âm thầm.
6. `applications` thiếu `unique(applicant_id, advert_id)` → DB không chặn double-apply.
7. Tiền lưu JSON → mất aggregate/report; cast không null-guard.
8. **0 file test API** + **~0% coverage app** (37k LOC) → không lưới an toàn.
9. **FCM half-wired** — không handle message ⇒ push không hiển thị (notifications hỏng).
10. Không xử lý 401 giữa phiên → token hết hạn app kẹt.
11. Crashlytics tắt → mù crash production.
*(+ onboarding: thiếu `.env.example`/`bootstrap/cache`, pre-script hardcode path máy dev cũ → clone không boot được.)*

## 3bis. App Flutter (NỬA SẢN PHẨM — tách riêng cho rõ)

> App mobile = **22.4k LOC (295 file, 45 bloc/cubit, 17 service, 22 model, 11 module)** — **còn lớn hơn API (15k)**. Đã audit ở report **07** (toàn bộ) + phần app trong 01/03/04/06.

**ĐÃ CÓ (shipped, release-signed v1.0.5+26 — đã lên store):**
- **Applicant:** signup/compliance onboarding sâu (references, evidence, right-to-work, **video verification**), browse/apply/cancel advert, bookings (applied/confirmed), profile, xem contract/payslip.
- **Advertiser:** advert CRUD, accept/decline/rate application, hearted applicants, xem invoice/contract, profile.
- **Kiến trúc:** bloc + get_it + go_router + Dio ApiService, sạch (`flutter analyze` chỉ 3 info). Flavor Yedi/Tidal runtime.

**GAP app phải build cho MVP (grep xác nhận absent):**
| Feature | App hiện tại | Cần build phía app |
|---|---|---|
| Timesheet | ❌ không có screen | Applicant submit/view + advertiser approve |
| Availability | ❌ không có | Picker UI (calendar/slots) + service |
| Notifications | 🟡 gửi token, **không handle message** | `onMessage`/`onBackground` + notification center |
| Multi-headcount booking | 🟡 xem booking của mình | Views per-person booking |
| Matching ranked-list | ❌ | UI suggested-candidates (advertiser) |
| Compliance expiry | 🟡 profile/compliance | Cảnh báo hết hạn + upload có expiry |
| Client dashboard/reporting | ❌ (nếu in-app) | Dashboard advertiser |
| Umbrella payroll | 🟡 xem payslip | Onboarding handoff (webview/link) |

**Risk app (report 01/04/07):** token plaintext SharedPreferences · Maps key commit dùng chung 2 brand · no cert pinning · logout client-only · **crashlytics tắt** · **no 401 handling** (token hết hạn → kẹt) · **FCM half-wired** · no offline · build script hardcode path máy dev cũ · **~0 test**.

**Effort app (Flutter) — ĐÃ nằm trong estimate, tách rõ ở report 10 "Estimate 2 cột":** **≈ 55–82 md ≈ ~30% dev subtotal** (API 126–188 / App 55–82 / dev 181–270). Cùng rate Developer → split ảnh hưởng staffing/lịch, không đổi tổng chi phí. **Team cần ~1–2 Flutter dev.**

## 4. Tư vấn chiến lược

### 4.1 Payroll — ⚠️ pháp lý (research UK có nguồn)
- **Code hiện tại = gross-only, 0 logic thuế/NI** → **bất hợp pháp cho Yedi**: supply teacher không được self-employed (HMRC s44 ITEPA/IR35), bắt buộc PAYE/umbrella.
- **Rủi ro nếu giữ nguyên: CRITICAL** — back-tax 20 năm, phạt, director liability, mất hợp đồng trường.
- **✅ CHỐT: MVP tích hợp umbrella company** (Parasol/Umbrella.co.uk) — outsource ~95% compliance; in-house PAYE để Phase 2.

### 4.2 Kiến trúc — giữ nền tảng, thêm brand-policy layer
- Foundation Controller→Handler→Model + shared multi-tenant **đúng, extend as-is** (verified 1 codebase, không fork).
- **Khuyến nghị:** thêm **brand-policy DB layer** (mở rộng `Settings`: credential-set / gate-rules / payroll-model / matching-weights) để tránh `if(config==yedi)` rải rác khi Yedi/Tidal phân kỳ compliance.
- **2 insight design chi phối effort:** billing dùng **giờ kế hoạch** (thêm timesheet = refactor billing); **1 accepted app/advert** (multi-headcount = refactor AdvertStatus).
- Design gap: **Booking entity** (multi-headcount), **Matching = ranked-list** (không engine), **DBS = typed credential + expiry + gate**.

### 4.3 DBS/Safeguarding — human-review + expiry-gate (theo đúng client brief)
Client (Tidal.docx dòng 56/86) yêu cầu: *admin verifies (human)* + *system stores expiry / flags / cannot be booked*. → **KHÔNG cần engine tự động đầy đủ**; chỉ cần: giữ admin review sẵn có + thêm **cột expiry + auto-flip NonCompliant + gate chặn book theo hạn**. Auto-reminder + DBS-Update-Service API = Future (dòng 97).

## 5. Gói MVP chốt (Yedi + Tidal cùng launch)

**Quyết định đã khóa (user 08/07):** ✅ umbrella payroll · ✅ cùng launch (DBS in) · ✅ multi-headcount booking · ✅ timesheet (+billing-rewire) · ✅ reporting/dashboard · ✅ single-server MVP (scale Phase-2) · ✅ matching ranked-list.

### Scope build (baseline = code khách; build = gap + harden)
| Workstream | Nội dung | MD |
|---|---|---:|
| **A. Hardening/productionize** | security (rate-limit/token/secrets/GDPR), payments-integrity (payslip/idempotency/retry), reliability (retry/crash/monitoring), DB (unique/money-2-cột), mobile (FCM/401/timeout/build), **test baseline + CI 2 repo** | 65–89 |
| **B. Gap features** | Booking multi-headcount · Timesheet + billing-rewire · Availability · Matching ranked-list · Reporting+dashboard · Notifications completion · DBS human-review+expiry-gate | 83–129 |
| **C. Umbrella payroll** | PayrollProvider connector + onboarding handoff + payslip proxy + AWR tracking | 25–40 |
| **D. Brand-policy layer** | Settings → brand-configurable compliance/payroll/matching | 8–12 |
| **Dev subtotal** | | **181–270** |
| + UI/UX + PM 12% + Contingency 12% | | +58–85 |
| **TỔNG MVP** | | **≈ 240–355 md** (planning ~295) |

## 6. Ước tính chi phí (rate card Sotatek · 1 man-month = 20 md)

| Vai trò | USD/tháng | USD/md | % | MD | Chi phí |
|---|---:|---:|---:|---:|---:|
| Development (BE+FE+Lead) | 3,000 | 150 | 68% | 201 | $30,150 |
| QC | 2,800 | 140 | 13% | 38 | $5,320 |
| BA & Designer | 3,000 | 150 | 9% | 27 | $4,050 |
| PM | 3,600 | 180 | 7% | 21 | $3,780 |
| DevOps | 3,400 | 170 | 3% | 9 | $1,530 |
| **TỔNG (planning ~295 md)** | | | 100% | **~296** | **≈ $44,800** |

| Kịch bản | MD | Chi phí |
|---|---:|---:|
| Optimistic | 240 | ~$36,500 |
| **Đề xuất báo** | **295** | **≈ $44,800** |
| Conservative | 355 | ~$54,000 |

**Blended ≈ $152/md.** → **MVP ≈ $36k–54k, đề xuất chốt ~$45k.**

**KHÔNG bao gồm:** phí umbrella (~£30–50/worker/tháng, client trả) · hosting/infra · license 3rd-party (Maps/DocGen/Firebase/Sentry/umbrella) · support sau launch.

## 7. Timeline & team
- **~3–4.5 tháng** MVP · team **~5–6** (1 Lead/BE, 2–3 Dev BE/FE, 1 QC, PM + BA/Designer part-time, DevOps part-time).
- Critical path: **Booking → Timesheet → Billing-rewire → Payslip** (nối tiếp); Availability/Matching, DBS, security, test chạy song song.
- **Hard blocker:** timesheet phải trước billing-rewire (không ship chung auto-billing cũ = sai giờ/double-charge).

## 8. Rủi ro chính & khuyến nghị
| Rủi ro | Mức | Khuyến nghị |
|---|---|---|
| Payroll gross-only bất hợp pháp (Yedi) | 🔴 | Umbrella integration (đã chốt) — **không thương lượng cho education** |
| Toàn vẹn tài chính (invoice/payslip trùng, payslip rỗng) | 🔴 | Fix idempotency + payslip trong WS-A ngay đầu |
| Bảo mật (token/secrets/rate-limit) | 🔴 | Rotate secrets + gỡ khỏi git + hardening đầu MVP |
| 0 test/CI (brownfield refactor) | 🔴 | Test baseline + CI **trước** khi refactor billing |
| DBS-enforcement thiếu (an toàn trẻ em Yedi) | 🔴 | Expiry+gate là blocker go-live Yedi |
| Brownfield — sửa code người khác | 🟡 | Contingency 12% (cân nhắc 15% nếu muốn phòng thủ) |

## 9. Phase 2 (extend — client tự xếp Future)
Multi-server scaling + `onOneServer` · in-house PAYE (RTI/NI/pension/holiday) · full DBS engine (Update Service API + barred-list + auto-reminder) · automated matching engine · advanced reporting/regional dashboard/talent pools · ratings depth · referral · in-app training · worker rewards · calendar integration.

## 10. Điều kiện & bước tiếp theo
- **Chờ chốt:** con số dùng nội bộ; nếu ra **fixed-price client** → cân nhắc contingency + buffer thương mại.
- **Còn verify (không block):** read-only prod DB (data volume, engine mysql/s3) + DocGen/Firebase creds (dynamic test billing/push).
- **Defer:** regenerate proposal client-facing (docx EN) — làm khi khách yêu cầu.
- **Assumption ghi rõ:** man-month = 20 md; contingency 12%; role-mix 68/13/9/7/3.

---

## Phụ lục — danh mục report chi tiết
| File | Nội dung |
|---|---|
| `00-audit-setup-access.md` | Môi trường, dựng local, giới hạn dynamic |
| `01-security-findings.md` | 22 finding bảo mật (2🔴) |
| `02-payments-financials-audit.md` | 11 finding tài chính (2🔴) |
| `03-feature-completeness-rescored.md` | Re-score 110 ID, completeness đúng |
| `04-reliability-infra-audit.md` | 18 finding reliability (3🔴) |
| `05-database-audit.md` | Schema 49 migration (2🔴) |
| `06-test-audit.md` | Test coverage (2🔴) |
| `07-mobile-integration-audit.md` | Mobile + contract (2🔴) |
| `08-consolidated-audit-summary.md` | Tổng hợp audit 7 domain |
| `09-open-questions-code-answers.md` | Trả lời câu hỏi mở từ code |
| `10-consulting-design-and-md-estimate.md` | Tư vấn payroll/design + estimate MD + chi phí |
| **`11` (file này)** | **Báo cáo nội bộ tổng hợp — entry point** |
