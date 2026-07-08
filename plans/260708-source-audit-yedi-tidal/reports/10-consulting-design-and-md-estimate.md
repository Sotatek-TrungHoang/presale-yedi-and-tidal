# 10 — Tư vấn (payroll + design) + Ước tính MD

> Nội bộ Sotatek · 2026-07-08 · trả lời 6 chỉ đạo của user (payroll model, payslip, MVP-dependency, system-design, app-server, MD estimate). Baseline = code khách đã làm; gap = Sotatek build. **MD only — £ defer (chờ rate card).**

---

## #1 + #2 — Payroll & Payslip: tư vấn khách (research UK, có nguồn)

### Thực tế pháp lý (không phải lựa chọn tùy ý)
- **Yedi (education supply):** **self-employed BẤT HỢP PHÁP/không bảo vệ được.** Supply teacher làm dưới direction/control của trường → HMRC coi là disguised employment (s44 ITEPA 2003 + IR35). **Bắt buộc agency PAYE hoặc umbrella.** Kèm **AWR 2010**: sau 12 tuần cùng vai trò → equal treatment (platform phải track thời lượng assignment).
- **Tidal (beauty/retail/event):** **mixed.** Self-employed **chỉ bảo vệ được** nếu worker có business đăng ký thật (VAT, nhiều client, tự chủ phương pháp) — điển hình MUA freelance. Retail/event/brand-ambassador (zero-hours, client set lịch/quy tắc) → **phải umbrella/PAYE.**
- **Gross-only hiện tại (code) = rủi ro CRITICAL:** back-tax lookback tới 20 năm, phạt 5%+ PAYE/NI chưa nộp, director personal liability, mất hợp đồng trường (education compliance-sensitive). *(Payslip lại đang là stub rỗng → càng phơi bày.)*

### Khuyến nghị tư vấn (assumption để consult khách)
**MVP: tích hợp UMBRELLA COMPANY payroll partner** (Parasol / Umbrella.co.uk / Staffology) cho toàn bộ worker.
- Vì: outsource ~95% gánh compliance (PAYE/NI/holiday/pension/payslip do umbrella lo), scale ngay, giảm liability xuống umbrella, phí ~£30–50/worker/tháng.
- Platform chỉ feed assignment data (worker, giờ, rate, ngày) → umbrella API → nhận confirmation net pay/payslip, hiển thị lại cho worker.
- **Self-employed** giữ như **opt-in cho Tidal** (worker chứng minh business thật) — không mặc định.
- **In-house PAYE** (tự tính thuế/NI/RTI/pension/holiday) → **Phase 2** nếu volume lớn (>200–300 worker).

### Hệ quả payslip (#2)
Payslip hiện là **stub bỏ dở** (`pdfs/payslip.blade.php` chỉ in số). 2 kịch bản:
- **Umbrella/PAYE:** payslip do umbrella sinh → platform hiển thị proxy (không tự tính) → build = integration + hiển thị.
- **Self-employed (Tidal opt-in):** platform tự sinh remittance gross → chỉ cần **fill stub** (thêm cột gross/hours/rate + dựng lại blade), đọc **giờ từ approved timesheet**.

> **Cần khách xác nhận:** đồng ý hướng umbrella cho MVP? (ảnh hưởng lớn effort — xem WS-C).

---

## #5 — "Số app-server prod?" giải thích để bạn quyết
Command sinh invoice/payslip chạy **mỗi phút**. Rủi ro **trùng chứng từ tài chính** phụ thuộc kiến trúc deploy:
- **1 app-server (single-instance):** 1 cron `schedule:run` → chỉ rủi ro retry/overlap trong máy → **Medium**. `withoutOverlapping()` đủ.
- **Nhiều app-server (scale ngang):** nếu mỗi máy tự chạy cron (không leader-election) → cùng advert bị nhiều máy xử lý cùng lúc → **trùng CHẮC CHẮN → High/Critical**. Cần `onOneServer()` (khóa qua cache chung).
- Code hiện **không dùng** cả hai + **không unique index** ở DB.
**Điểm quyết:** fix (unique index + `onOneServer`) đúng cho **cả 2**, rẻ → **làm bất kể**. Câu trả lời của bạn chỉ đổi severity/ưu tiên. *(deployment-guide nhắc scale ngang + `HORIZON_PROCESSES` → khả năng multi-instance là thật → nghiêng "coi như multi → Critical".)*

---

## #4 — Review system design + phương án nên làm

### 2 insight nền tảng (chi phối effort)
1. **Billing theo giờ KẾ HOẠCH, không phải giờ thực:** `Advert->totalAdvertiserPay` (`app/Models/Advert.php:135-147`) cộng `shift->hours` = (ends−starts)/60 thuần lịch (`Shift.php:37-45`); billing auto khi `ends_at<now` (`MarkAdvertsAsCompleteCommand.php:33-46`). → **Thêm timesheet = ĐẢO nguồn dữ liệu billing** (refactor trigger + công thức), không phải feature độc lập.
2. **1 accepted application / advert** (`Advert.php:98-101`, `AcceptApplicationHandler.php:42` auto-decline sibling) → 1 người làm mọi shift; **không mô hình được multi-headcount** ("cần 3 người/tuần").

### Phương án khuyến nghị theo từng gap
| Gap | Phương án nên làm | Loại |
|---|---|---|
| **Booking** | Thêm entity `Booking` mỏng 1:1 accepted-application (anchor cho timesheet/attendance/payslip). KHÔNG rip-out Advert+Application+Shift. *(multi-headcount = lớn, cần khách chốt có cần không.)* | Additive, chạm nhiều điểm |
| **Timesheet** | `timesheets(booking_id, shift_id, actual_start/end, break, worked_hours, status)` + enum `TimesheetStatus` + handlers Submit/Approve/Dispute. **Rewire billing đọc approved hours + đổi trigger** (gate "tất cả timesheet Approved"). | Schema additive + **billing refactor** |
| **Availability** | `availabilities(applicant_id, date/day, start/end, type)` + **double-booking guard** trong AcceptApplication. | Additive thuần |
| **Matching** | **KHÔNG build engine.** Ranked "suggested candidates" (compliant + availability + proximity sẵn có + job_role) cho admin/advertiser override. Con người vẫn accept. | Additive nhỏ |
| **DBS/safeguarding** | `compliance_credentials(applicant_id, type, reference_number, issued_at, expires_at, verified_at, status)` + enum type (DBS_Enhanced/Safeguarding/QTS/RTW) + `ComputeComplianceStatusHandler` auto-derive + `ExpireCredentialsCommand` (mirror ClearExpiredUploads) + mở rộng `AdvertPolicy::apply` gate theo hạn. | Additive + refactor nhỏ; **blocker Yedi** |
| **Payroll** | Fix payslip stub trước; seam `PayrollProvider` Saloon connector (mirror `DocGenConnector`) cho umbrella/PAYE. | Nhỏ (self-emp) → Lớn (PAYE/umbrella) |

### Critique kiến trúc
- **Foundation Controller→Handler→Model + DTO + enum = ĐÚNG, extend as-is** (không thay).
- **Smells cần xử khi build MVP:** Advert conflate posting+booking+billing (→ tách Booking); **money-as-JSON** (→ refactor 2 cột `amount_minor`+`currency`, nếu không thì reporting/dashboard bế tắc + `MoneyCast::get()` crash null); billing planned-hours (→ rewire cùng timesheet); no-idempotency (→ fix ngay); polymorphic userable no-FK (→ defer).
- **Multi-tenant shared = ĐÚNG**, nhưng **thêm lớp "brand policy" DB-backed** (mở rộng `Settings`) chứa required-credential-set / gate-rules / payroll-model / matching-weights **NGAY** — trước khi divergence Yedi/Tidal (compliance, payroll, matching) lan thành `if(config==yedi)` rải rác. Quyết định này ảnh hưởng maintainability dài hạn.

---

## #3 — Đồ thị phụ thuộc build MVP (Phase 1)

**Spine nối tiếp (critical path — KHÔNG parallelize được):**
```
[idempotency fix + Money 2-cột]  →  Booking entity  →  Timesheet (submit/approve)  →  Billing rewire (invoice/payslip theo giờ thực)  →  Payslip real
```
**Hard blockers / thứ tự bắt buộc:**
1. **Booking trước Timesheet** (timesheet cần anchor per-shift-per-person).
2. **Timesheet trước Billing-rewire** — KHÔNG ship timesheet + auto-billing cũ song song (sai giờ/double-charge).
3. **Idempotency fix trước Billing-rewire** (và làm ngay bất kể).
4. **DBS structured trước DBS-enforcement gate.**
5. **Money 2-cột trước Reporting/dashboard.**

**Nhánh song song (independent — chạy ngay, không đợi spine):**
Availability → Matching ranked-list · DBS structured → enforcement gate · App FCM handler · Money refactor · idempotency fix · security hardening · test/CI.

→ Nếu đưa **tất cả** vào MVP: critical path = Booking→Timesheet→Billing-rewire (dài nhất); mọi thứ khác nhét song song. Timesheet+billing-rewire là **rủi ro lịch chính**.

---

## #6 — Ước tính MD (baseline = code khách; MD only, £ defer)

> **Giả định gói này (đánh dấu để khách chốt):** payroll = **umbrella integration**; DBS = **minimal typed+expiry+gate** (blocker Yedi); Booking = **thin 1:1** (không multi-headcount); Matching = **ranked-list** (không engine); Timesheet + Reporting-basic = **trong MVP**; full DBS-Update-Service/barred-list + in-house PAYE = **Phase 2**.

### WS-A — Hardening / Productionize (BẮT BUỘC trước go-live; không optional)
| # | Hạng mục | MD |
|---|---|---:|
| A1 | Security: rate-limit, token revoke/rotate, secure storage (Flutter), gỡ+rotate secrets committed, GDPR retention/erasure minimal | 15–20 |
| A2 | Payments integrity: fix payslip stub, idempotency (unique index + `onOneServer`), job retry/failed, charge% bounds, tách `invoiced_at` | 10–14 |
| A3 | Reliability: Horizon retry/backoff, crash reporting (app Sentry/Crashlytics), backup/monitoring, CORS | 8–11 |
| A4 | DB integrity: unique constraints, **money→2-cột**, index/FK | 6–9 |
| A5 | Mobile fixes: FCM handler + notif center, 401/token-refresh, Dio timeout, deep-link autoVerify, portable build (`.env.example`, `bootstrap/cache`, pre-script) | 9–13 |
| A6 | Test baseline + CI (2 repo): Feature test critical-path (charge math, compliance gate, lifecycle, signed reference) + app bloc/widget smoke + pipelines | 17–22 |
| | **WS-A subtotal** | **65–89** |

### WS-B — Gap features hoàn thiện MVP (build-new)
| # | Hạng mục | MD |
|---|---|---:|
| B1 | Booking entity **multi-headcount** (N người/advert, partial-fill, per-person Booking) + refactor AdvertStatus (bỏ Filled nhị phân) + rewire accept/billing/Filament | 20–34 |
| B2 | Timesheet (submit/approve per-shift) **+ billing rewire** (trigger + công thức theo approved hours) | 18–26 |
| B3 | Availability + double-booking guard | 8–12 |
| B4 | Matching ranked-suggestion + override UI (KHÔNG engine) | 8–13 |
| B5 | Reporting/export + client-visibility dashboard basic (phụ thuộc money 2-cột) | 12–18 |
| B6 | Notifications completion (server/admin triggers; app handler đã ở A5) | 5–8 |
| B7 | **DBS/safeguarding — human-review + expiry-flag-gate** (GIỮ admin verify/approve sẵn có trong Filament; build chỉ 3 việc máy client yêu cầu: cột **expiry** trên credential + **auto-flip** NonCompliant khi hết hạn/thiếu + **gate chặn book** theo hạn). *Theo đúng Tidal.docx dòng 56/86 ("system stores expiry… flags… cannot be booked"); MVP = "basic compliance status" (dòng 93); auto-reminder/DBS-Update-Service API = Future (dòng 97).* Blocker Yedi | 12–18 |
| | **WS-B subtotal** | **83–129** |

> *(Split API/App đầy đủ cho toàn bộ WS ở mục "**Estimate 2 cột**" bên dưới — App ≈ 55–82 md ~30% dev.)*

### WS-C — Payroll (business-gated)
| # | Hạng mục | MD |
|---|---|---:|
| C1 | **Umbrella integration** (PayrollProvider Saloon connector, worker onboarding handoff, feed assignment data, payslip proxy, AWR 12-tuần tracking) | 25–40 |
| | *Thay thế: self-employed only → chỉ fill payslip stub (đã ở A2), +0. In-house PAYE (RTI/NI/pension/holiday) = Phase 2, ~40–70 (ngoài MVP).* | |

### WS-D — Kiến trúc: brand-policy DB layer (khuyến nghị làm sớm)
| # | Hạng mục | MD |
|---|---|---:|
| D1 | Mở rộng Settings → brand-policy (credential-set/gate-rules/payroll-model/matching-weights) | 8–12 |

### Tổng hợp
| Khối | MD (dev) |
|---|---:|
| WS-A Hardening | 65–89 |
| WS-B Gap features (multi-headcount in) | 83–129 |
| WS-C Umbrella payroll | 25–40 |
| WS-D Brand-policy | 8–12 |
| **Dev subtotal** | **181–270** |
| + UI/UX (~15–20) + PM ~12% + Contingency ~12% *(giảm từ 15% cũ vì đã có source → dải hẹp hơn)* | ~ +58–85 |
| **TỔNG MVP (source-grounded)** | **≈ 240–355 md** (planning point ~295) |

**Timeline (team ~5–6, ~5 md/ngày throughput):** **≈ 3–4.5 tháng** MVP.

### Estimate 2 cột — API/Backend(+Admin) vs App (Flutter)
> Phân rã full-stack toàn bộ workstream. Tổng vẫn = dev subtotal 181–270. (— = không có phần đó.)

| Workstream / item | API+DB+Admin | **App (Flutter)** | Tổng |
|---|---:|---:|---:|
| A1 Security (rate-limit/token/GDPR ↔ secure-storage/cert-pin/gỡ key) | 10–13 | **5–7** | 15–20 |
| A2 Payments integrity (payslip/idempotency/retry) | 10–14 | **—** | 10–14 |
| A3 Reliability (Horizon/backup/CORS ↔ crash-reporting app) | 6–8 | **2–3** | 8–11 |
| A4 DB integrity (unique/money-2-cột/index) | 6–9 | **—** | 6–9 |
| A5 Mobile fixes (token-refresh endpoint ↔ FCM/401/timeout/deeplink/build) | 1 | **8–12** | 9–13 |
| A6 Test + CI (Feature test API ↔ bloc/widget app) | 11–14 | **6–8** | 17–22 |
| B1 Booking multi-headcount | 14–24 | **6–10** | 20–34 |
| B2 Timesheet + billing-rewire | 12–17 | **6–9** | 18–26 |
| B3 Availability | 4–6 | **4–6** | 8–12 |
| B4 Matching ranked-list | 5–8 | **3–5** | 8–13 |
| B5 Reporting + dashboard | 8–12 | **4–6** | 12–18 |
| B6 Notifications | 2–3 | **3–5** | 5–8 |
| B7 DBS expiry-gate | 9–14 | **3–4** | 12–18 |
| C1 Umbrella payroll (connector/AWR ↔ onboarding handoff) | 20–33 | **5–7** | 25–40 |
| D1 Brand-policy layer | 8–12 | **—** | 8–12 |
| **DEV SUBTOTAL** | **126–188** | **55–82** | **181–270** |

**App (Flutter) ≈ 55–82 md ≈ ~30% dev subtotal.** Ghi chú:
- UI/UX design (15–20 md, BA&Designer) chủ yếu phục vụ **app + admin screens** — chưa split ở bảng này.
- Cùng rate **Developer $150/md** cho cả API-dev lẫn app-dev → **split API/App ảnh hưởng STAFFING/lịch, KHÔNG đổi tổng chi phí**.
- **Team gợi ý:** ~2 BE (Laravel/Filament) · **~1–2 Flutter dev** · 1 QC · PM + BA/Designer + DevOps part-time.

### So với black-box cũ
| | Black-box (03/07) | Source-grounded (08/07) |
|---|---|---|
| MVP | ~660 md · £125–156k · 6.5–7.5 tháng | **≈ 240–355 md · ~3–4.5 tháng** |
| Lý do | giả định portal greenfield ~126 md + core-loop/billing greenfield | portal/app + lifecycle + compliance-framework + billing-engine **ĐÃ CÓ** → chỉ harden + fill gap |

→ **MVP giảm ~46–64%** so black-box, nhờ tái dùng phần khách đã build.

---

## GÓI MVP CHỐT + CHI PHÍ (confirmed 2026-07-08)

### Quyết định đã chốt (user)
1. **Payroll = umbrella integration** (WS-C in). 2. **Yedi + Tidal CÙNG launch** → DBS/compliance Yedi in MVP (B7 in). 3. **Multi-headcount booking = CÓ** (B1 20–34, refactor AdvertStatus). 4. **Timesheet = CÓ** (B2 + billing-rewire in). 5. **Reporting/client-dashboard = CÓ** (B5 + money-2-cột in). 6. **App-server: single-instance cho MVP (Phase 1), scale multi ở Phase 2** → idempotency MVP dùng `unique index + withoutOverlapping()` (rẻ, trong A2); `onOneServer()` để Phase 2.

→ Tất cả workstream **đều IN**. **Tổng MVP = ≈ 240–355 md, planning point ~295 md.**

### Rate card (user cung cấp, USD/man-month · 1 man-month = **20 md**)
| Vai trò | USD/tháng | USD/md |
|---|---:|---:|
| PM | 3,600 | 180.0 |
| Developer | 3,000 | 150.0 |
| DevOps | 3,400 | 170.0 |
| QC | 2,800 | 140.0 |
| BA & Designer | 3,000 | 150.0 |

### Phân bổ theo vai trò + chi phí (tại planning point ~295 md)
| Vai trò | % effort | MD | USD/md | Chi phí |
|---|---:|---:|---:|---:|
| Development (BE+FE+Tech Lead) | 68% | 201 | 150.0 | $30,150 |
| QC | 13% | 38 | 140.0 | $5,320 |
| BA & Designer | 9% | 27 | 150.0 | $4,050 |
| PM | 7% | 21 | 180.0 | $3,780 |
| DevOps | 3% | 9 | 170.0 | $1,530 |
| **TỔNG (planning)** | 100% | **~296** | | **≈ $44,800** |

**Blended ≈ $152/md.** Áp cho dải md:
| Kịch bản | MD | Chi phí USD |
|---|---:|---:|
| Optimistic (low) | 240 | **~$36,500** |
| **Planning (khuyến nghị báo)** | **295** | **~$44,800** |
| Conservative (high) | 355 | **~$54,000** |

→ **MVP ≈ $36k–54k, đề xuất chốt ~$45k · ~3–4.5 tháng · team ~5–6.**

### KHÔNG bao gồm (client opex / ngoài build)
- Phí umbrella provider (~£30–50/worker/tháng — client trả, không phải chi phí build).
- Hosting/infra, license 3rd-party (Google Maps, DocGen, Firebase, Sentry, phí tích hợp umbrella).
- Support/maintenance sau launch.
- *(Man-month = 20 md — user xác nhận.)*

### Phase 2 (extend — client tự xếp Future/Advanced)
Multi-server scaling + `onOneServer` · in-house PAYE (RTI/NI/pension/holiday) · full DBS engine (DBS Update Service API + barred-list + auto-reminder) · automated matching engine · advanced reporting/regional dashboards/talent pools · ratings depth · referral · in-app training · worker rewards · calendar integration.

---

## Trạng thái quyết định (đã chốt 2026-07-08)
| # | Quyết định | Chốt | Tác động |
|---|---|---|---|
| 1 | Payroll | ✅ **Umbrella** | WS-C 25–40 in |
| 2 | Yedi/Tidal launch | ✅ **Cùng launch** | B7 DBS in (blocker Yedi) |
| 3 | Multi-headcount booking | ✅ **Có** | B1 20–34 (refactor AdvertStatus) |
| 4 | Timesheet | ✅ **Có (MVP)** | B2 + billing-rewire in |
| 5 | Reporting/dashboard | ✅ **Có (MVP)** | B5 + money-2-cột in |
| 6 | App-server | ✅ **Single MVP, multi Phase-2** | idempotency MVP = unique index + withoutOverlapping; onOneServer Phase-2 |
| 7 | Rate card | ✅ **Đã có** (PM 3600 / Dev 3000 / DevOps 3400 / QC 2800 / BA&Design 3000 USD/tháng · 20 md/tháng) | → chi phí ~$45k (mục "GÓI MVP CHỐT") |
| Matching | ✅ ranked-list (engine = Phase-2) | B4 8–13 | |
| Vẫn defer | regenerate proposal client-facing (docx) | — | làm khi khách yêu cầu |

**Còn để verify khi có access (không block):** read-only prod DB (data volume + engine mysql/s3) + DocGen/Firebase creds (dynamic test billing/push).
