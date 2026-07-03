# §8.5 Ước tính thời gian & chi phí

> Nội bộ Sotatek · 2026-07-03 · baseline = WBS per-feature 2026-06-29 (`prior-tidal/tidal-yedi-effort-breakdown-by-feature.md`), cộng Yedi delta.
> **Số dựa black-box (không source) → dải + confidence + điều kiện "cần source để chốt" (two-step).**
> Đơn giá **placeholder $240–300/md** — CHỜ rate card Sotatek trước khi báo client.

## TL;DR
| Scope | Effort | Timeline (team ~6) | Chi phí ($240–300/md) | GBP (~0.79) |
|---|---:|---|---|---|
| **MVP launch (Tidal, shared)** | ~660 md | ~6.5–7.5 tháng | ~$158k–198k | ~£125k–156k |
| **+ Yedi education delta** | +40–70 md | +~0.5–1 tháng | ~$10k–21k | ~£8k–17k |
| **Full production-grade (cả 2)** | ~870 md | ~8.5–10 tháng | ~$209k–261k | ~£165k–206k |
| Enhancement tranche (Full − MVP) | ~210 md | ~+3 tháng | ~$50k–63k | ~£40k–50k |

> **Quan trọng:** baseline ~660/~870 **đã là mô hình shared** (multi-tenant foundation P12 tính 1 lần; Yedi enablement ở Tranche 2). **KHÔNG nhân đôi cho Yedi.** Yedi delta dưới đây là phần compliance giáo dục **chưa** cost đầy đủ trong baseline Tidal-centric.

---

## Baseline roll-up (14 domain, per-feature — 2026-06-29, re-verify 03/07 xác nhận không đổi)

| Domain | Full md | MVP md |
|---|---:|---:|
| P1 Auth | 36 | 27 |
| P2 Brand/School portal | 56 | 48 |
| P3 Candidate/Teacher portal | 67 | 59 |
| P4 Adverts/Job lifecycle | 41 | 26 |
| P5 Core loop (Application/Matching/Booking) | 59 | 52 |
| P6 Compliance & RTW | 48 | 41 |
| P7 Timesheets | 35 | 27 |
| P8 Billing (invoice/payslip) | 55 | 46 |
| P9 Payments | 32 | 8 |
| P10 Notifications | 27 | 14 |
| P11 Docs/contracts/e-sign | 30 | 19 |
| P12 Multi-tenancy/white-label | 39 | 29 |
| P13 Reporting | 25 | 7 |
| P14 Non-functional (security/GDPR/QA/CI-CD) | 68 | 59 |
| **Dev subtotal** | **618** | **462** |
| + Overlay (discovery+audit 10, UI/UX 25, foundation 15) | +50 | +50 |
| + PM ~12% + Contingency ~15% | | |
| **TOTAL** | **~870** | **~660** |

> Contingency 15% (cao hơn 12% thường) vì **chưa xem source**. Audit thu hẹp dải.

> **T2 net-new (client Phase 2, chưa tách dòng trong 14 domain):** Ratings/Feedback 2 chiều ~8 md · Referral ~4 md · Training records ~5 md → **~17 md**. Nằm gọn trong dải Tranche 2 (~210 md) + contingency; **giữ nguyên headline**, chỉ đánh dấu để chốt khi rate card/source về. Availability đã cost trong P5 (model, MVP) + P3 — không phát sinh thêm.

---

## Yedi education-compliance delta (mới, ngoài baseline Tidal)

| Feature Yedi-specific | md | Ghi chú (overlap với baseline) |
|---|---:|---|
| DBS structured (number/status/expiry + renewal reminder) | 8 | Mở rộng P6 compliance |
| Safeguarding training records + expiry | 5 | Mới |
| Document-expiry flag + enforcement gate giáo dục | 5 | Tăng cường P6.9 eligibility gate |
| QTS/qualifications structured | 4 | Mở rộng model |
| Education matching criteria (DBS/age group/school type/reliability) | 6 | Tăng cường P5 matching |
| Yedi branding/tenant provisioning | 3 | Phần lớn đã ở P12 |
| Contingency Yedi delta | ~9–29 | Dải rộng vì compliance giáo dục nhạy cảm + chưa source |
| **Yedi delta total** | **~40–70** | |

---

## Timeline & team
- **Team ~6:** 1 Tech Lead/BE · 2 Laravel/Filament BE · 2 FE · 1 QA + PM & UI/UX part-time. ~5 productive md/ngày.
- **MVP Tidal:** ~660 md → **~6.5–7.5 tháng**. Yedi go-live +~0.5–1 tháng sau (config + delta).
- **Full:** ~870 md → **~8.5–10 tháng**.

## Giả định & điều kiện chốt số (two-step — cần source)
1. **Rate card Sotatek** thay placeholder $240–300 (ảnh hưởng trực tiếp mọi con số).
2. **Source + Git** để: (a) chốt module rỗng có backend ẩn không (co P5/P8) hay greenfield hoàn toàn; (b) chốt (a) mono-repo ENV-config vs (b) 2 fork drift → ảnh hưởng effort multi-tenancy P12 & Yedi delta.
3. **Employment model** candidate (PAYE/umbrella/self-employed) → chi phối logic P8/P9 (thuế/payslip).
4. **Single-hire vs multi-slot** advert → schema P4/P5.
5. **Có mobile app chưa release?** (marketing nhắc "OnDemand App") → ảnh hưởng scope FE.
6. Chưa gồm: hosting, license 3rd-party (Twilio/GoCardless/DocuSign/Yoti), support sau launch.

## Đề xuất commercial (de-risk 2 phía)
- **Phase 0 — Discovery + code audit (~2 tuần, fixed price)** → chốt reusability + validate estimate → ra **fixed price** cho MVP nằm trong (hoặc dưới) dải trên. Tránh vừa báo giá "phòng thủ" quá cao vừa surprise giữa dự án.
</content>
