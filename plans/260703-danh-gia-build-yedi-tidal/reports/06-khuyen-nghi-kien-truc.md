> ## ⚠️ CẬP NHẬT SAU SOURCE AUDIT (2026-07-08)
> Khuyến nghị **shared multi-tenant (hướng A)** dưới đây trước dựa **fingerprint black-box**. Source thật **XÁC NHẬN + nâng confidence**: đúng **1 codebase mono-repo** (`APP_CONFIGURATION=yedi|tidal` cho API, `--flavor` cho app) — white-label switch tại runtime/build, KHÔNG fork per-brand. → **R8 "two forks drifting" phần lớn OVERTURN**; hướng A vững hơn (không chỉ tối ưu chi phí mà là hiện trạng kỹ thuật xác thực). *(Còn lại: xác nhận git remote để chắc không có fork drift lịch sử.)* Chi tiết: **[`../../260708-source-audit-yedi-tidal/reports/08-consolidated-audit-summary.md`]**.

# §8.6 Khuyến nghị kiến trúc — Shared backend vs Tách rời

> Nội bộ Sotatek · 2026-07-03 · tóm từ Phase 4 (`04-cross-platform-comparison.md`).

## Khuyến nghị (1 dòng)
**Hợp nhất thành 1 codebase multi-tenant — backend chung, front-end + branding + compliance riêng theo ngành.** Đúng bản năng client; rẻ hơn ~40–45% so với nuôi 2 fork.

## Bằng chứng nền
Hiện trạng: Yedi và Tidal **đang là cùng 1 codebase** (Phase 4), deploy tách rời + relabel/config:
- Route slug trùng khít (`/advertisers /applicants`…), field label base lộ ở System ("applicant/advertiser charge"), model/enum/schema/widget trùng, cùng seed agency (ne6.studio) + cùng seed date (Mar 7 2025).
- Khác biệt chỉ: nhãn hiển thị, job-roles config, 1 DBS catalog, contract title, DB/cookie riêng.

→ 2 platform **không phải 2 hệ khác nhau** mà là 1 nền + lớp cấu hình ngành mỏng.

## Trade-off 3 kịch bản
| | A. Shared multi-tenant (khuyến nghị) | B. Shared core lib + 2 deploy | C. Tách rời hoàn toàn |
|---|---|---|---|
| Chi phí/giá trị | **Thấp nhất** (engine build 1 lần) | Trung bình | **Cao nhất** (~+70–90% effort) |
| Tốc độ dài hạn | Nhanh nhất | Trung bình | Chậm nhất |
| Compliance tách biệt | Đạt qua per-tenant rules (DBS/safeguarding chỉ bật Yedi) | Dễ (2 app riêng) | Tối đa nhưng thừa |
| Bảo trì | 1 nơi | package + 2 app | 2 nơi (drift, bug fix ×2) |
| Rủi ro | Cần data-isolation chặt (1 lần đầu tư P12) | Versioning overhead | Yedi tụt lại (đã thấy hiện trạng) |

## Vì sao A thắng
Tất cả engine còn thiếu — **booking, billing, timesheet, matching, portal, RBAC, notification, compliance** — **giống hệt nhau cho cả 2**. Build 1 lần (multi-tenant) rồi bật/tắt lớp ngành qua config:
- **Yedi bật:** DBS/safeguarding/expiry gate, education matching, job-roles QTS.
- **Tidal bật:** brand/retail experience, talent pool by city/brand, client-visibility "Tidal OS".

Compliance ngành **tách biệt bằng rule per-tenant**, không cần tách codebase — safeguarding Yedi không lẫn beauty Tidal vì tenant isolation + config rule riêng.

## Tác động chi phí
- **A (shared):** MVP ~660 md + Yedi delta ~40–70 md. Estimate hiện tại **đã theo mô hình này**.
- **C (tách):** engine build 2 lần → MVP phình ~1,100–1,200 md (~+70–90%). **Không khuyến nghị.**
- Client "bản năng shared infrastructure, branding/workflow/compliance riêng ngành" = **chính xác kịch bản A**.

## Điều kiện chốt (two-step — cần source)
- Xác định hiện là (a) mono-repo ENV-config hay (b) 2 branch fork đã drift → quyết công sức hợp nhất (nếu đã drift nhiều, cần refactor gộp; nếu ENV-config, gần như đã sẵn).
- Kiểm tra đã có package tenancy chưa hay phải thêm mới (P12).

**Kết luận dứt khoát:** đi hướng **A — shared multi-tenant, FE/branding/compliance riêng ngành**. Đây vừa là hiện trạng kỹ thuật (đã chung code), vừa là tối ưu chi phí, vừa khớp mong đợi client.
</content>
