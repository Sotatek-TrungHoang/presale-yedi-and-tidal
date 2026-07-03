# Phase 4 — So sánh chéo Yedi ↔ Tidal → Shared vs Tách rời

> Dựa bằng chứng live Phase 2 (Tidal) + Phase 3 (Yedi), ngày 2026-07-03.
> Trả lời câu hỏi chiến lược client (docx §8): 2 sản phẩm tách rời hay chung backend?

## Kết luận 1 dòng (khuyến nghị)
**Hiện trạng: 2 platform ĐANG là cùng 1 codebase, deploy tách rời + relabel/config per-tenant.** Tương lai nên **hợp nhất thành 1 codebase multi-tenant, front-end/branding/compliance riêng theo ngành** — đúng bản năng client, và rẻ hơn nhiều so với nuôi 2 fork song song. Confidence **cao** (black-box + fingerprint); chốt tuyệt đối cần source (two-step).

---

## 1. Bảng so sánh chéo

| Trục | Yedi | Tidal | Giống/Khác |
|---|---|---|:---:|
| Stack | Laravel + Filament + Livewire | Laravel + Filament + Livewire | **Giống** |
| Server | nginx | nginx | Giống |
| Session cookie | `yedi_education_session` | `tidal_agency_session` | Khác (deploy riêng, DB riêng) |
| Resource slug | `/advertisers /adverts /applicants /applications /invoices /payslips /declarations /job-roles /required-evidences /type-of-works /system /users` | **y hệt** | **Giống 100%** |
| Nhãn hiển thị | School / Job / Teacher | Brand / Advert / Candidate | Khác (override label) |
| Field label ẩn (System) | "Default applicant charge %", "Default advertiser charge %" | y hệt | **Giống** (base code chung lộ ra) |
| Candidate/Teacher model | 4 tab Personal/Identification/Work/Contracts + Update status/references | y hệt | **Giống** |
| Advert/Job model | Title/Client/Type/Status/Address/Date/Shift/Desc/Docs/Payment&Charges | y hệt | **Giống** |
| Status enum advert | 6 (Approved/Filled/Not filled/Pending allocation/Pending approval/Rejected) | y hệt | **Giống** |
| Application status enum | Pending/Accepted/Declined/Cancelled | y hệt | **Giống** |
| System settings schema | charge %, references required, invoice bank/terms, 2 contract template | y hệt | **Giống** |
| Dashboard widgets | count + Income/Expenditure/Charges/Profit + Non-compliant | y hệt | **Giống** |
| Seed data | `matthew.woodley+*@ne6.studio` | `*@ne6.studio` | **Giống** (cùng dev agency ne6.studio) |
| Job Roles seed date | Mar 7 2025 | Mar 7 2025 | **Giống** (cùng setup process) |
| — Config khác — | | | |
| Job Roles data | 5 (giáo dục, QTS) | 1 ("Any Role") | Khác (config per-tenant) |
| Required Evidence | 1 ("DBS Evidence") | 0 | Khác |
| Contract title | "Yedi Employment Contract" | "Tidal Employment Contract" | Khác |
| Data volume | 2 school / 19 teacher / 0 job / 0 app | 2 brand / 9 cand / 1 advert / 0 app | Khác (đều rất ít, đều seed) |
| Compliance ngành | 1 catalog DBS + role QTS (nhãn) | none | Khác (nhẹ) |

---

## 2. Phân loại quan hệ codebase

3 khả năng: (a) 1 codebase multi-deploy · (b) fork từ 1 base rồi tách · (c) 2 build độc lập.

**Kết luận: (a)/(b) — cùng 1 codebase gốc, 2 deployment độc lập, khác nhau chỉ ở config + display label.**

Bằng chứng quyết định:
1. **Slug generic trùng khít** (`advertisers`/`applicants` cho School/Teacher) → code viết cho Tidal, Yedi override nhãn, không viết lại.
2. **Field label base lộ ở System** ("applicant/advertiser charge") → form config dùng nguyên base code.
3. **Toàn bộ model/enum/schema/widget trùng**.
4. **Cùng seed agency + cùng seed date (Mar 7 2025)** → cùng nguồn build & quy trình.
5. **Cookie + DB riêng** → 2 deployment tách biệt (chưa multi-tenant chung instance).

Chưa phân biệt được (a) vs (b) tuyệt đối (mono-repo cấu hình theo ENV, hay 2 branch fork) — **cần source để chốt**. Nhưng với mục tiêu chiến lược, khác biệt này **không đổi khuyến nghị**: dù đang là ENV-config hay 2 fork, cả hai đều hội tụ về "gần như cùng code".

---

## 3. Ba kịch bản kiến trúc tương lai + trade-off

| Kịch bản | Mô tả | Chi phí | Tốc độ | Compliance tách biệt | Rủi ro |
|---|---|---|---|---|---|
| **A. Shared backend multi-tenant, FE riêng ngành** (khuyến nghị) | 1 codebase, tenant Tidal/Yedi qua config; branding + workflow + compliance riêng theo tenant; 2 portal FE riêng | **Thấp nhất/đơn vị giá trị** — build engine 1 lần dùng cho 2 | Nhanh nhất về dài hạn | Đạt được qua per-tenant compliance rules (DBS/safeguarding chỉ bật cho Yedi) | Cần data isolation chặt; 1 lần đầu tư multi-tenancy (P12 ~25-39md) |
| **B. Shared core library + 2 deploy riêng** | Tách phần chung thành package, 2 app riêng import | Trung bình (duy trì package + 2 app) | Trung bình | Dễ (2 app vật lý riêng) | Drift giữa 2 app; overhead versioning package |
| **C. 2 sản phẩm hoàn toàn tách rời** | Nuôi 2 codebase độc lập (gần hiện trạng) | **Cao nhất** — mọi engine build/maintain 2 lần | Chậm nhất | Tối đa (nhưng thừa) | ~2× effort & cost; bug fix 2 nơi; hiện trạng đã cho thấy Yedi tụt lại |

**Vì sao A thắng:** engine thiếu (booking, billing, compliance, portal, RBAC, timesheet) là **giống hệt nhau cho cả 2** — build 1 lần (multi-tenant) tiết kiệm ~40-45% so với build 2 lần. Khác biệt ngành (Yedi: DBS/safeguarding; Tidal: brand/retail experience, client visibility) là **lớp mỏng cấu hình/rule/field trên nền chung**, không phải 2 hệ khác nhau. Hiện trạng "2 deploy" đã chứng minh mô hình chung khả thi — chỉ cần chính thức hoá thành multi-tenant thay vì 2 fork trôi dạt.

---

## 4. Tác động chi phí (feed Phase 6)
- **Estimate cũ (~660 MVP / ~870 full md) đã là mô hình shared** (P12 multi-tenancy foundation tính 1 lần; "Yedi enablement" ở Tranche 2). → **Không cần nhân đôi cho Yedi.**
- Nếu chọn **C (tách rời)**: effort tăng ~+70-90% (engine build 2 lần) → MVP có thể phình lên ~1,100-1,200 md. **Không khuyến nghị.**
- Chọn **A**: delta Yedi so với baseline Tidal chỉ là: per-tenant config compliance giáo dục (DBS engine/safeguarding rules/expiry) + branding + tenant provisioning → ước ~+40-70 md trên nền MVP shared (chi tiết Phase 6).

## 5. Điểm cần source để chốt chắc (two-step)
- (a) vs (b): mono-repo ENV-config hay 2 branch fork thực sự → xem git remote(s).
- Mức độ divergence code giữa 2 deploy (nếu là 2 fork, đã drift bao nhiêu).
- Có sẵn hạ tầng multi-tenant (package tenancy) hay phải thêm mới.
</content>
