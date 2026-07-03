---
phase: 3
title: "Candidate-Portal"
status: pending
priority: P1
effort: "70d (MVP 54d)"
dependencies: [1]
---

# Phase 3: Portal cho candidate (web responsive)

## Tổng quan
Toàn bộ bề mặt web phía candidate. **Chưa tồn tại** — candidate đang được admin quản lý thủ công.
Đây là nơi candidate dành phần lớn thời gian (tìm shift, chứng minh right-to-work, nhận lương),
nên là bề mặt có lưu lượng cao nhất và bắt buộc phải mobile-responsive.

## Hiện trạng (đã verify)
- 🟡 Entity candidate là model giàu dữ liệu nhất: 4 tab (Personal / Identification / Work / Contracts),
  status + compliance, action references, tài khoản đăng nhập. (evidence: `03-candidate-detail.png`, `applicants/create`)
- 🟡 Các status candidate đã có (Incomplete / Pending Approval / Active) — ngụ ý một onboarding funnel
  hiện đang được hoàn tất *bởi admin*, không phải bởi candidate.
- 🔴 Chưa có app phía candidate: không tự sửa profile, không upload tài liệu, không tìm việc, không apply,
  không accept booking, không timesheet, không xem payslip.
- 🔴 **Không tồn tại front-end candidate live nào** *(domain recon đã verify 2026-06-29)*: `tidalagency.co.uk` =
  chỉ là marketing site (không có login/register); `app.tidalagency.co.uk` = placeholder nginx 403 rỗng, chưa
  deploy gì (`/login`, `/api`, `/register` đều 404); Filament admin là app đang chạy duy nhất.
  (evidence: `evidences/blackbox/t5-marketing-site-home.png`)
- Record candidate CÓ chứa dữ liệu video-verification + ID + signed-contract thật
  (`evidences/blackbox/t2-candidate-identification-tab.png`, `t2-candidate-contracts-tab.png`), nhưng không có
  bề mặt capture live nào và toàn bộ candidate/login đều `@ne6.studio` (build agency), nên đây **rất có khả năng
  là dev/test seed data** — KHÔNG phải bằng chứng về một candidate pipeline đang hoạt động. Coi phase này là **greenfield**.
  (Open: xác nhận liệu có **mobile app** chưa release hay không — marketing tuyên bố có "OnDemand App" nhưng không tìm thấy bản live nào.)

## Mục tiêu mức Production
- **Onboarding wizard**: thông tin cá nhân, địa chỉ, upload evidence right-to-work, qualifications,
  declarations, references → chuyển Incomplete → Pending → Compliant/Active.
- **Upload tài liệu** cho từng mục Required Evidence (passport, visa, DBS, v.v.) kèm phản hồi status.
- **Browse/search advert**: lọc theo role, type, location, date; xem pay rate (đã trừ candidate charge).
- **Apply** vào advert; theo dõi trạng thái application.
- **Accept/decline booking**; thiết lập availability/calendar.
- **Quản lý shift**: xem các shift sắp tới, **clock-in/out hoặc submit timesheet** (P7).
- **Payslip**: liệt kê + tải PDF (P8).
- Notification (offer, nhắc compliance, nhắc shift) (P10).
- Thanh đo độ hoàn thiện profile + status compliance.

## Ma trận Feature Gap
| # | Feature | Hiện tại | Mục tiêu | Gap |
|---|---------|---------|--------|-----|
| 3.1 | Dashboard candidate | 🔴 | Status, shift kế tiếp, action items | Bề mặt responsive mới |
| 3.2 | Onboarding wizard | 🟡 admin điều khiển | Candidate tự phục vụ funnel | UI nhiều bước + state machine |
| 3.3 | Tự sửa profile (4 mục) | 🟡 chỉ admin | Candidate sửa Personal/Work | Form theo phạm vi |
| 3.4 | Upload tài liệu right-to-work | 🔴 (config rỗng) | Upload theo từng Required Evidence | Phụ thuộc P6 |
| 3.5 | Declarations | 🔴 (config rỗng) | Ký các declaration bắt buộc | Phụ thuộc P6 |
| 3.6 | References | 🟡 admin action | Candidate gửi referee, hệ thống thu thập | Workflow reference + email |
| 3.7 | Tìm/duyệt việc | 🔴 | Danh sách advert có thể lọc | Search + view advert public |
| 3.8 | Apply vào advert | 🔴 | Apply một chạm + theo dõi | Phụ thuộc P5 |
| 3.9 | Accept/decline booking | 🔴 | Phản hồi offer | Phụ thuộc P5 |
| 3.10 | Lịch availability | 🔴 | Thiết lập ngày rảnh | Model availability |
| 3.11 | Timesheet / clock | 🔴 | Submit giờ theo từng shift | Phụ thuộc P7 |
| 3.12 | Payslip | 🔴 | Liệt kê + PDF | Phụ thuộc P8 |
| 3.13 | Notification | 🔴 | Offer/nhắc nhở | Phụ thuộc P10 |

## Phạm vi Build (phần gap)
- Web app candidate responsive mới (mobile-first).
- Onboarding state machine điều khiển các status Incomplete→Pending→Active sẵn có theo cơ chế tự phục vụ.
- Upload tài liệu an toàn gắn với các rule compliance (P6).
- Tìm việc + apply + phản hồi offer gắn với P5.
- Model availability (mới).

## Đánh giá Rủi ro
- Chất lượng mobile-responsive quan trọng nhất ở đây (candidate dùng điện thoại) — tập trung effort thiết kế.
- UX right-to-work nhạy cảm về mặt pháp lý; phải khớp với các rule compliance P6 trước khi ship.
