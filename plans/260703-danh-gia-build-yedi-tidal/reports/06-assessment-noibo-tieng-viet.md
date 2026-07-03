# Đánh giá Yedi + Tidal — Bản nội bộ Sotatek (tiếng Việt)

> **Phục vụ nội bộ team presale Sotatek** (không phải bản gửi thẳng client). Bản EN client-facing là việc tách riêng.
> Ngày: 2026-07-03 · Nguồn: audit live 2 platform + đối chiếu `client/Tidal.docx` §8 + tái dùng finding Tidal 29/06.
> Chi tiết: xem `02`–`05` + `06-*` cùng thư mục; finding gốc `prior-tidal/`.

---

## 0. Executive summary (đọc cái này trước)

1. **Yedi và Tidal là CÙNG 1 codebase** (Laravel+Filament), deploy tách rời + đổi nhãn (School/Teacher/Job vs Brand/Candidate/Advert) + config per-tenant. Bằng chứng cứng: route slug generic trùng khít, field label base lộ ở System, model/enum/schema/widget trùng, cùng dev agency (ne6.studio) + cùng seed date.
2. **Cả 2 mới là "admin panel", chưa phải sản phẩm.** Data model lõi + admin CRUD **thật, tái dùng tốt** (~1/4 platform). Nhưng **portal candidate/client, booking entity, billing engine, timesheet, matching, compliance enforcement, RBAC, notification — đều greenfield**. MVP mới ~8% hoàn thiện.
3. **Yedi KHÔNG đi trước Tidal về giáo dục.** Compliance giáo dục (DBS/safeguarding) mà client cần **không có engine thực** — chỉ 1 catalog "DBS Evidence" + role QTS (nhãn) + self-declaration boolean. Đây là **gap critical riêng Yedi** (safeguarding trẻ em).
4. **Khuyến nghị kiến trúc: shared multi-tenant, FE/branding/compliance riêng ngành** — đúng bản năng client, rẻ hơn ~40–45% so với tách rời.
5. **Ước tính:** MVP shared (Tidal launch) **~660 md (~£125k–156k, ~6.5–7.5 tháng)**; + Yedi education delta ~40–70 md; full production cả 2 **~870 md (~£165k–206k)**. Số dựa black-box → cần **source audit** (Phase 0, ~2 tuần) để chốt fixed-price.
6. **Bug production cần báo client:** Declarations create vỡ (Livewire upload) — trên cả 2 (cùng code).

---

## 1. Hiện trạng (§8.1) — tóm tắt
| Nhóm | Trạng thái |
|---|---|
| ✅ Dùng được | Data model (Candidate/Advert/Brand), admin CRUD, dashboard shell, System settings, evidence storage, config per-tenant, Application+aggregation |
| 🟡 Cần fix/hoàn thiện | Application lifecycle, compliance status (thủ công), Required Evidence rules, references automation, reporting wire, contract generation, **bug Declarations** |
| 🔴 Build mới | Portal ×2, Booking entity, Billing engine, Timesheet, Matching, Notification, RBAC+auth portal, Availability, Compliance enforcement, Multi-tenancy chính thức, Yedi DBS/safeguarding engine, Tidal talent-pool+client-visibility |

Chi tiết: `06-danh-gia-hien-trang-va-rui-ro.md`.

## 2. Rủi ro kỹ thuật (§8.2) — top
- 🔴 **R1 Safeguarding Yedi** (không DBS engine + không enforcement → book giáo viên non-compliant vào trường) — **gate go-live**.
- 🔴 R2 không test/CI-CD · R3 không RBAC/policies · R4 PII/GDPR (dữ liệu trẻ em/giáo viên).
- 🟡 R5 bug Declarations · R6 billing chưa engine (thuế/charge) · R7 chưa có source (±15–20%) · R8 2 fork trôi dạt · R9 upload không AV · R10 không backup/monitor.

Chi tiết + cách gỡ: `06-danh-gia-hien-trang-va-rui-ro.md`.

## 3. Route tới MVP (§8.3)
Dependency-order: Foundation(multi-tenant+auth+RBAC+CI) → Auth portal → Adverts lifecycle → **Core loop+Booking** → Timesheet → Billing → Compliance+enforcement (Yedi: +DBS/safeguarding) → Notification+dashboard → Security/GDPR/tests → **Tidal go-live**, Yedi bật ngay sau bằng config+delta.
Chi tiết: `06-route-mvp-va-roadmap.md`.

## 4. Roadmap (§8.4)
- **MVP (~660md):** auth+RBAC, 2 portal, core loop, compliance+enforcement, timesheet, billing gen, notification, security baseline, multi-tenant foundation. **[C]** chung chiếm đa số.
- **Tranche 2 (~+210md):** payment automation, e-sign, in-app noti, accounting export, geo/multi-slot, reporting depth, **Yedi full + education matching**, **Tidal "OS" client visibility**.
- **Future:** AI matching, forecasting, auto-payroll, mobile app.
Chi tiết + đánh dấu [C]/[Y]/[T]: `06-route-mvp-va-roadmap.md`.

## 5. Ước tính (§8.5)
| Scope | Effort | Timeline | GBP |
|---|---:|---|---|
| MVP launch (Tidal, shared) | ~660 md | ~6.5–7.5 th | ~£125k–156k |
| + Yedi education delta | +40–70 md | +0.5–1 th | ~£8k–17k |
| Full production (cả 2) | ~870 md | ~8.5–10 th | ~£165k–206k |

Đơn giá **placeholder $240–300/md — chờ rate card Sotatek**. Số black-box → **Phase 0 audit (~2 tuần, fixed)** để chốt.
Chi tiết + breakdown 14 domain + Yedi delta: `06-uoc-tinh-thoi-gian-chi-phi.md`.

## 6. Khuyến nghị kiến trúc (§8.6)
**Shared multi-tenant, FE/branding/compliance riêng ngành (kịch bản A).** Vì mọi engine thiếu là giống hệt 2 platform → build 1 lần; compliance ngành tách bằng rule per-tenant. Tách rời (C) tốn +70–90%. Khớp bản năng client.
Chi tiết + trade-off: `06-khuyen-nghi-kien-truc.md`.

---

## 7. Giả định & phụ thuộc cần xác nhận (two-step nguồn dữ liệu)
Kết luận hiện dựa **black-box + fingerprint** (confidence cao). Cần **source/DB read-only** để chốt tuyệt đối:
1. **Rate card Sotatek** (thay $240–300 placeholder) — ảnh hưởng mọi con số cost.
2. **Source + Git**: (a) module rỗng (Invoice/Payslip/Booking) có backend service ẩn chưa wire UI hay greenfield? (b) hiện là mono-repo ENV-config hay 2 fork drift? → quyết effort P12 + Yedi delta.
3. **Employment model** (PAYE/umbrella/self-employed) → logic payslip/thuế P8/P9.
4. **Single-hire vs multi-slot** advert → schema P4/P5.
5. **Có mobile app chưa release?** (marketing nhắc "OnDemand App") → scope FE.
6. **Declarations upload bug**: cần dummy-file repro / source để xác nhận còn vỡ (cao khả năng còn — cùng code).

## 8. Việc nên làm tiếp
- Báo client bug Declarations (miễn phí, thiện chí).
- Đề xuất **Phase 0 audit-first** để de-risk 2 phía → ra fixed-price.
- Xin source + Yedi/Tidal Git + trả lời §7.
- Nếu client cần: dựng bản **EN client-facing** (ngoài scope plan này).

---

## Phụ lục (trong thư mục reports/)
- `00-methodology-and-requirements-checklist.md` — phương pháp + khung requirement.
- `02-tidal-reverify-delta.md` — re-verify Tidal (no change vs 29/06).
- `03-yedi-teardown-live-findings.md` — bóc tách Yedi (mới).
- `04-cross-platform-comparison.md` — so sánh chéo + shared vs tách.
- `05-requirements-traceability-matrix.md` — ma trận docx §2–§6 ↔ hiện trạng.
- `06-*` — 4 deliverable §8 chi tiết.
- `prior-tidal/` — finding Tidal gốc 29/06 + gap analysis 14 domain (EN+VI) + WBS + proposal.
</content>
